import { Plugin, Skill } from "@opencode/plugin"
import { execFile, execFileSync } from "node:child_process"
import { existsSync, readFileSync } from "node:fs"
import { isAbsolute, join, resolve } from "node:path"
import { fileURLToPath } from "node:url"
import { promisify } from "node:util"
import { GROUP_OF } from "../../lib/groups.mjs"
import { MARKER, defaultBranch, isDirectCommit, isMarkdownPath } from "../../lib/guardrails.mjs"
import { loadSkills } from "../../lib/skills.mjs"

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

function wantedGroups(options: Record<string, unknown>): string[] {
  const raw = options.groups
  if (Array.isArray(raw)) return raw.map(String)
  if (typeof raw === "string") return raw.split(",").map((group) => group.trim()).filter(Boolean)
  return []
}

export default Plugin.define({
  id: "libra",
  async setup(ctx) {
    const groups = wantedGroups(ctx.options)
    const skills = loadSkills(root).filter((skill) => groups.length === 0 || groups.includes(GROUP_OF[skill.id]))
    const project = ctx.location.directory

    await ctx.skill.transform((editor) => {
      for (const skill of skills) {
        editor.add({
          id: Skill.ID.make(skill.id),
          name: Skill.Name.make(skill.name),
          description: skill.description,
          path: skill.path as never,
          content: skill.body,
        })
      }
    })

    await ctx.tool.hook("execute.after", async (event) => {
      if (event.status !== "completed") return
      if (event.tool !== "write" && event.tool !== "edit") return
      const input = event.input as { path?: string; file_path?: string } | undefined
      const file = input?.path ?? input?.file_path
      if (!isMarkdownPath(file)) return
      const full = isAbsolute(file as string) ? (file as string) : resolve(project, file as string)
      const failure = await markdownFailure(full)
      if (!failure) return
      const result = event.result as { content?: Array<{ type: "text"; text: string } | { type: "file"; uri: string; mime: string; name?: string }> }
      event.result = {
        ...result,
        content: [...(Array.isArray(result.content) ? result.content : []), { type: "text" as const, text: failure }],
      } as typeof event.result
    })

    await ctx.shell.hook("create.before", (event) => {
      if (!/\bgit\b/.test(event.command)) return
      const repo = repoRoot(event.cwd)
      if (!repo) return
      const branch = currentBranch(repo)
      const gitDoc = existsSync(join(repo, "docs/GIT.md")) ? readFileSync(join(repo, "docs/GIT.md"), "utf8") : ""
      const main = defaultBranch(repo)
      if (!isDirectCommit({ command: event.command, branch, defaultBranch: main, gitDoc })) return
      event.command = `printf '%s\\n' 'libra: direct commit on ${main} needs ${MARKER} in docs/GIT.md' >&2; exit 1`
    })
  },
})
