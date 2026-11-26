import { execFileSync } from "node:child_process"

export const MARKER = "<!-- libra:allow-direct-commit -->"

export function isMarkdownPath(file) {
  return typeof file === "string" && /\.md$/i.test(file)
}

function segments(command) {
  return String(command ?? "")
    .split(/&&|\|\||[;|]/)
    .map((part) => part.trim())
    .filter(Boolean)
}

function gitCall(segment) {
  const words = segment.split(/\s+/)
  const git = words.findIndex((word) => word === "git" || word.endsWith("/git"))
  if (git === -1) return null
  let index = git + 1
  while (index < words.length) {
    const word = words[index]
    if (word === "-C" || word === "-c" || word === "--git-dir" || word === "--work-tree") {
      index += 2
      continue
    }
    if (word.startsWith("-")) {
      index += 1
      continue
    }
    return { subcommand: word, args: words.slice(index + 1) }
  }
  return null
}

function isForcePushArg(arg) {
  return arg === "-f" || arg === "--force" || arg === "--force-with-lease" || arg.startsWith("--force-with-lease=")
}

function forcePushes(command, defaultBranch) {
  for (const segment of segments(command)) {
    const call = gitCall(segment)
    if (!call || call.subcommand !== "push") continue
    if (!call.args.some(isForcePushArg)) continue
    const refs = call.args.filter((arg) => !arg.startsWith("-"))
    const refspec = refs[1]
    if (!refspec) return true
    const target = refspec.split(":").pop().split("/").pop()
    if (target === defaultBranch) return true
  }
  return false
}

export function isDirectCommit({ command, branch, defaultBranch, gitDoc }) {
  if (typeof gitDoc === "string" && gitDoc.includes(MARKER)) return false
  if (forcePushes(command, defaultBranch)) return true
  if (branch !== defaultBranch) return false
  return segments(command).some((segment) => gitCall(segment)?.subcommand === "commit")
}

export function defaultBranch(cwd = process.cwd()) {
  const run = (args) =>
    execFileSync("git", args, { cwd, encoding: "utf8", stdio: ["ignore", "pipe", "ignore"] }).trim()
  try {
    return run(["symbolic-ref", "--short", "refs/remotes/origin/HEAD"]).replace(/^origin\//, "")
  } catch {}
  try {
    return run(["branch", "--show-current"])
  } catch {}
  try {
    return run(["rev-parse", "--abbrev-ref", "HEAD"])
  } catch {
    return "main"
  }
}
