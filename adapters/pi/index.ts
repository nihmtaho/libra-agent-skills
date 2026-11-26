import type { ExtensionAPI } from "@earendil-works/pi-coding-agent"
import { isToolCallEventType } from "@earendil-works/pi-coding-agent"
import { execFile, execFileSync } from "node:child_process"
import { existsSync, readFileSync } from "node:fs"
import { isAbsolute, join, resolve } from "node:path"
import { fileURLToPath } from "node:url"
import { promisify } from "node:util"
import { MARKER, defaultBranch, isDirectCommit, isMarkdownPath } from "../../lib/guardrails.mjs"

const run = promisify(execFile)
const root = fileURLToPath(new URL("../..", import.meta.url))

function repoRoot(cwd: string): string | null {
  try {
    return execFileSync("git", ["rev-parse", "--show-toplevel"], {
      cwd,
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    }).trim()
  } catch {
    return null
  }
}

function currentBranch(cwd: string): string {
  try {
    return execFileSync("git", ["branch", "--show-current"], {
      cwd,
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    }).trim()
  } catch {
    return ""
  }
}

async function markdownFailure(file: string): Promise<string> {
  try {
    await run("bash", [join(root, "scripts/check-docs.sh"), file], { cwd: root })
    return ""
  } catch (error) {
    return `libra markdown check failed:\n${(error as { stdout?: string }).stdout ?? String(error)}`
  }
}

export default function libra(pi: ExtensionAPI) {
  pi.on("tool_call", (event) => {
    if (!isToolCallEventType("bash", event)) return
    if (!/\bgit\b/.test(event.input.command)) return
    const repo = repoRoot(process.cwd())
    if (!repo) return
    const branch = currentBranch(repo)
    const gitDoc = existsSync(join(repo, "docs/GIT.md")) ? readFileSync(join(repo, "docs/GIT.md"), "utf8") : ""
    const main = defaultBranch(repo)
    if (!isDirectCommit({ command: event.input.command, branch, defaultBranch: main, gitDoc })) return
    return { block: true, reason: `libra: direct commit on ${main} needs ${MARKER} in docs/GIT.md` }
  })

  pi.on("tool_result", async (event) => {
    if (event.toolName !== "write" && event.toolName !== "edit") return
    const input = event.input as { path?: string; file_path?: string } | undefined
    const file = input?.path ?? input?.file_path
    if (!isMarkdownPath(file)) return
    const full = isAbsolute(file as string) ? (file as string) : resolve(process.cwd(), file as string)
    const failure = await markdownFailure(full)
    if (!failure) return
    return {
      content: [...event.content, { type: "text" as const, text: failure }],
      isError: true,
    }
  })
}
