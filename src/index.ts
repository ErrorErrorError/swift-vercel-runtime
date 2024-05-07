import {
  BuildOptions,
  BuildResultV3,
  debug,
  download,
  EdgeFunction,
  Lambda,
} from "@vercel/build-utils";
import { installSwiftToolchain } from "./lib/swift-toolchain";
import { findSPMWorkspace } from "./lib/utils";

async function buildOptions(options: BuildOptions): Promise<BuildResultV3> {
  const BUILDER_DEBUG = Boolean(process.env.VERCEL_BUILDER_DEBUG ?? false);
  const { files, entrypoint, workPath, config, meta } = options;

  await installSwiftToolchain();

  debug("Creating file system");
  const downloadedFiles = await download(files, workPath, meta);
  const entryPath = downloadedFiles[entrypoint].fsPath;

  const spmWorkspace = await findSPMWorkspace();

  const isLambda = false;
  let output: Lambda | EdgeFunction;

  if (isLambda) {
    output = new Lambda({
      files: {},
      handler: "index.swift",
      runtime: "swift",
    });
  } else {
    output = new EdgeFunction({
      files: {},
      deploymentTarget: "v8-worker",
      entrypoint: "",
    });
  }

  return {
    routes: [],
    output: output,
  };
}

const runtime = {
  version: 3,
  build: buildOptions,
};

export const { version, build } = runtime;
