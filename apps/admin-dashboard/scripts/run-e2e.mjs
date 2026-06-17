import { spawn } from "node:child_process";

const port = 3100;
const host = "127.0.0.1";
const baseUrl = `http://${host}:${port}/admin`;
const extraArgs = process.argv.slice(2);

function run(command, args, options = {}) {
  return spawn(command, args, {
    cwd: process.cwd(),
    env: process.env,
    windowsHide: true,
    ...options
  });
}

async function waitForServer(url, timeoutMs = 120_000) {
  const startedAt = Date.now();

  while (Date.now() - startedAt < timeoutMs) {
    try {
      const response = await fetch(url);
      if (response.ok) {
        return;
      }
    } catch {
      // Keep polling until Next is ready.
    }

    await new Promise((resolve) => setTimeout(resolve, 500));
  }

  throw new Error(`Timed out waiting for ${url}`);
}

function stopProcessTree(child) {
  if (!child.pid) {
    return Promise.resolve();
  }

  if (process.platform === "win32") {
    return new Promise((resolve) => {
      const killer = spawn("taskkill", ["/pid", String(child.pid), "/T", "/F"], {
        windowsHide: true,
        stdio: "ignore"
      });
      killer.on("exit", () => resolve());
      killer.on("error", () => resolve());
    });
  }

  child.kill("SIGTERM");
  return Promise.resolve();
}

const nextServer = run(
  process.execPath,
  ["node_modules/next/dist/bin/next", "dev", "--hostname", host, "--port", String(port)],
  {
    stdio: ["ignore", "pipe", "pipe"]
  }
);

nextServer.stdout?.on("data", (chunk) => process.stdout.write(chunk));
nextServer.stderr?.on("data", (chunk) => process.stderr.write(chunk));

try {
  await waitForServer(baseUrl);

  const testRun = run(process.execPath, ["node_modules/playwright/cli.js", "test", ...extraArgs], {
    env: {
      ...process.env,
      PLAYWRIGHT_SKIP_WEBSERVER: "1"
    },
    stdio: "inherit"
  });

  const exitCode = await new Promise((resolve) => {
    testRun.on("exit", (code) => resolve(code ?? 1));
    testRun.on("error", () => resolve(1));
  });

  await stopProcessTree(nextServer);
  process.exit(exitCode);
} catch (error) {
  console.error(error);
  await stopProcessTree(nextServer);
  process.exit(1);
}
