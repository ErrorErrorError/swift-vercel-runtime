import {
  BuildResultV3,
  BuildV3,
  debug,
  download,
  FileFsRef,
  getLambdaOptionsFromFunction,
  getProvidedRuntime,
  glob,
  Lambda,
  ShouldServe,
  // shouldServe,
} from '@vercel/build-utils';
import { installSwiftToolchain } from './lib/swift-toolchain';
import path from 'node:path';
import { hasSwiftPM } from './lib/utils';
import execa from 'execa';
import { existsSync } from 'node:fs';
import { generateRoutes } from './lib/routes';

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

  debug('Creating file system');
  const downloadedFiles = await download(originalFiles, workPath, meta);
  const entryPath = downloadedFiles[entrypoint].fsPath;

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

  const appExecutablePath = path.join(
    workPath,
    '.build',
    BUILDER_DEBUG ? 'debug' : 'release',
    'App',
  );

  if (!existsSync(appExecutablePath)) {
    throw new Error(
      'Failed to build `App` executable. Make sure `Package.swift` has `.executableTarget` and the target name is set to `App`.',
    );
  }

  debug(`Building \`App\` for \`${process.platform}\` completed`);

  const lambdaOptions = getLambdaOptionsFromFunction({
    sourceFile: entrypoint,
    config,
  });

  const runtime = meta?.isDev ? 'provided' : await getProvidedRuntime();
  const handlerFiles = await glob('api/**/[!(mM)ain][!(aA)pp]*.swift', workPath);
  const routes = generateRoutes(Object.keys(handlerFiles));

  let output: Lambda = new Lambda({
    files: {
      [HANDLER_FILENAME]: new FileFsRef({
        mode: 0o755,
        fsPath: appExecutablePath,
      }),
    },
    handler: HANDLER_FILENAME,
    // supportsWrapper: true,
    runtime,
    ...lambdaOptions,
    // experimentalAllowBundling: true
  });

  return { 
    output: output,
    routes: routes.map((src, dest) => ({ src, dest }))
  };
};

export const shouldServe: ShouldServe = async ({
  requestPath,
  entrypoint,
}): Promise<boolean> => {
  debug(`Requested ${requestPath} for ${entrypoint}`);
  return Promise.resolve(entrypoint === 'api/main');
};

// export { shouldServe };
