import { debug } from "@vercel/build-utils/dist";
import { execa } from "execa"

export async function downloadSwiftToolchain(): Promise<void> {
  try {
    await execa(
      "curl -L https://swift-server.github.io/swiftly/swiftly-install.sh | sh -s -- -y", 
      [], 
      { shell: true, stdio: 'inherit' }
    )
  } catch (err) {
    let message = 'Unknown Error';
    if (err instanceof Error) {
      message = err.message;
    }
    throw new Error(`Installing Swift via swiftly failed: ${message}`);
  }
}

export async function installSwiftToolchain(): Promise<void> {
  try {
    await execa("swift --version", [], { shell: true, stdio: 'ignore' });
    // TODO: Check swift installed version is at least 5.9
    debug("Swift is already installed, skipping download");
  } catch (err) {
    await downloadSwiftToolchain();
  }
}