import { glob, GlobOptions } from '@vercel/build-utils';

export async function hasSwiftPM(workspace: string): Promise<boolean> {
  const options = {
    cwd: workspace,
    ignore: ['**/.build/**/*', '**/.swiftpm/**/*'],
  } as unknown as GlobOptions;
  const files = await glob('**/Package.swift', options);
  return Object.keys(files).length !== 0;  
}

export async function hasMainFile(workspace: string): Promise<boolean> {
  const options = {
    cwd: workspace,
    ignore: ['**/.build/**/*', '**/.swiftpm/**/*'],
  } as unknown as GlobOptions;
  const files = await glob('**/+([mM]ain|[aA]pp).swift', options);
  return Object.keys(files).length !== 0;
}