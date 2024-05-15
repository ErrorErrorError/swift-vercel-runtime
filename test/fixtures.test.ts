import path from 'path';
import ms from 'ms';
import fetch from 'node-fetch';
import execa from 'execa';

const readyRegex = /Ready!\s+Available at (?<url>https?:\/\/\w+:\d+)/;

jest.setTimeout(ms('50m'));

type ProbesConf = {
  probes: Probe[];
};

type Probe = {
  path: string;
  status?: number;
  mustContain?: string;
};

function getVercelProcess(dir: string): execa.ExecaChildProcess {
  const defaultArgs = ['dev', '--yes', '-d'];

  if (process.env.VERCEL_TOKEN) {
    defaultArgs.push('--token', process.env.VERCEL_TOKEN);
  }

  return execa('vercel', [...defaultArgs, dir]);
}

function isReady(vercelServ: execa.ExecaChildProcess): Promise<string> {
  return new Promise((resolve) => {
    vercelServ.stderr?.on('data', (d: Buffer) => {
      const res = readyRegex.exec(d.toString());
      if (res?.groups?.url) {
        resolve(res.groups.url);
      }
    });
    vercelServ.stderr?.pipe(process.stderr);
  });
}

async function testFixture(fixture: string): Promise<'ok'> {
  const { probes } = (await import(
    path.join(__dirname, 'fixtures', fixture, 'probes.json')
  )) as unknown as ProbesConf;

  const vercelProcess = getVercelProcess(
    path.join(__dirname, 'fixtures', fixture),
  );
  const baseUrl = await isReady(vercelProcess);

  try {
    await new Promise((r) => setTimeout(r, 3000));
    for (const probe of probes) {
      const res = (await fetch(`${baseUrl}${probe.path}`)) as unknown as {
        status: number;
        text: () => Promise<string>;
      };

      const status = res.status;
      const text = await res.text();

      if (probe.status) {
        expect(status).toBe(probe.status);
      }

      if (probe.mustContain) {
        expect(text).toContain(probe.mustContain);
      }
    }
  } finally {
    vercelProcess.cancel();
    vercelProcess.stdout?.destroy();
    vercelProcess.stderr?.destroy();
  }

  return Promise.resolve('ok');
}

describe('vercel-swift', () => {
  it('deploy 01-spm-routes', async () => {
    await expect(testFixture('01-spm-routes')).resolves.toBe('ok');
  });
});
