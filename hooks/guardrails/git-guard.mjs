import { execFileSync } from "node:child_process"
import { existsSync, readFileSync } from "node:fs"
import { MARKER, defaultBranch, isDirectCommit } from "../../lib/guardrails.mjs"

const input = JSON.parse(readFileSync(0, "utf8"))
const command = input?.tool_input?.command ?? ""
if (!/\bgit\b/.test(command)) process.exit(0)

const cwd = input?.cwd ?? process.cwd()
let root
try {
  root = execFileSync("git", ["rev-parse", "--show-toplevel"], {
    cwd,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "ignore"],
  }).trim()
} catch {
  process.exit(0)
}

const branch = execFileSync("git", ["branch", "--show-current"], {
  cwd: root,
  encoding: "utf8",
  stdio: ["ignore", "pipe", "ignore"],
}).trim()
const doc = existsSync(`${root}/docs/GIT.md`) ? readFileSync(`${root}/docs/GIT.md`, "utf8") : ""
const main = defaultBranch(root)

if (!isDirectCommit({ command, branch, defaultBranch: main, gitDoc: doc })) process.exit(0)

process.stderr.write(`libra: direct commit on ${main} needs ${MARKER} in docs/GIT.md\n`)
process.exit(2)
