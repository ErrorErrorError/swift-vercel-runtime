import {
  BuildResultV3,
  BuildV3,
  debug,
  FileFsRef,
  getLambdaOptionsFromFunction,
  getProvidedRuntime,
  Lambda,
  ShouldServe,
} from '@vercel/build-utils';
import { installSwiftToolchain } from './lib/swift-toolchain';
import path from 'node:path';
import { hasSwiftPM } from './lib/utils';
import execa from 'execa';
import { existsSync } from 'node:fs';
import { readFile } from 'node:fs/promises';
import { parseRoutes, RouteOutput } from './lib/routes';

// In order to allow the user to have `main.swift`, we need our
// `main.swift` to be called something else
// const MAIN_SWIFT_FILENAME = '__vc_main_swift.swift';
const HANDLER_FILENAME = 'bootstrap';

export const version = 3;

export const build: BuildV3 = async ({
  workPath,
  files: originalFiles,
  entrypoint,
  meta = {},
  config,
}): Promise<BuildResultV3> => {
  const BUILDER_DEBUG = Boolean(process.env.VERCEL_BUILDER_DEBUG ?? false);
  await installSwiftToolchain();

  debug('Entrypoint is', entrypoint);

  if (!(await hasSwiftPM(workPath))) {
    throw new Error(
      `This directory does not have Swift Package Manager's \`Package.swift\` file.`,
    );
  }

  try {
    await execa(
      'swift',
      ['build'].concat(!BUILDER_DEBUG ? ['-c', 'release'] : ['--verbose']),
      {
        cwd: workPath,
        stdin: 'inherit',
      },
    );
  } catch (err) {
    debug(
      `Running \`swift build ${!BUILDER_DEBUG ? '-c release' : '--verbose'} \` failed`,
    );
    throw err;
  }
  
  try {
    await execa(
      'swift',
      ['package', 'vercel-router-tool'],
      {
        cwd: workPath,
        stdin: 'inherit',
      },
    );
  } catch (err) {
    debug(
      `Running \`swift package vercel-router-tool\` failed.`,
    );
    throw err;
  }
  
  const routesOutputPath = path.join(
    workPath,
    '.build',
    'plugins',
    'VercelRouterTool',
    'outputs',
    'routes.json'
  )
  
  const routesOutputString = await readFile(routesOutputPath, { encoding: 'utf8' });
  const routesOutput = JSON.parse(routesOutputString) as unknown as RouteOutput;

  const binPath = path.join(
    workPath,
    '.build',
    BUILDER_DEBUG ? 'debug' : 'release',
    routesOutput.executableName,
  );

  if (!existsSync(binPath)) {
    throw new Error(
      `Failed to build \`${routesOutput.executableName}\` executable. Make sure \`Package.swift\` has \`.executableTarget()\``
    );
  }

  debug(`Building \`${routesOutput.executableName}\` for \`${process.platform}\` completed`);

  const lambdaOptions = getLambdaOptionsFromFunction({
    sourceFile: entrypoint,
    config,
  });

  const runtime = meta?.isDev ? 'provided' : await getProvidedRuntime();

  let output: Lambda = new Lambda({
    files: {
      [HANDLER_FILENAME]: new FileFsRef({
        mode: 0o755,
        fsPath: binPath,
      }),
    },
    handler: HANDLER_FILENAME,
    // supportsWrapper: true,
    runtime,
    ...lambdaOptions,
    // experimentalAllowBundling: true
  });

  const routes = parseRoutes(routesOutput.routes);

  return { output, routes };
};

export const shouldServe: ShouldServe = async ({
  requestPath,
  entrypoint,
}): Promise<boolean> => {
  debug(`Requested ${requestPath} for ${entrypoint}`);
  return Promise.resolve(entrypoint === 'api/main');
};