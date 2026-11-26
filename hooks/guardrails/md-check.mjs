import { execFileSync } from "node:child_process"
import { readFileSync } from "node:fs"
import { fileURLToPath } from "node:url"
import { isMarkdownPath } from "../../lib/guardrails.mjs"

const root = fileURLToPath(new URL("../..", import.meta.url))
const input = JSON.parse(readFileSync(0, "utf8"))
const file = input?.tool_input?.file_path ?? input?.tool_input?.path

if (!isMarkdownPath(file)) process.exit(0)

try {
  execFileSync("bash", [`${root}/scripts/check-docs.sh`, file], { stdio: "pipe" })
} catch (error) {
  const message = error.stdout?.toString() || error.message
  process.stderr.write(`libra markdown check failed:\n${message}\n`)
  process.exit(2)
}
