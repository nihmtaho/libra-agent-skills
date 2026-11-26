import { readFileSync, readdirSync } from "node:fs"
import { join } from "node:path"

function unquote(value) {
  const trimmed = value.trim()
  if (trimmed.length >= 2 && trimmed.startsWith('"') && trimmed.endsWith('"')) return trimmed.slice(1, -1)
  if (trimmed.length >= 2 && trimmed.startsWith("'") && trimmed.endsWith("'")) return trimmed.slice(1, -1)
  return trimmed
}

export function parseSkill(raw) {
  const match = /^---\r?\n([\s\S]*?)\r?\n---\r?\n?/.exec(raw)
  if (!match) throw new Error("SKILL.md has no frontmatter")
  const meta = {}
  for (const line of match[1].split(/\r?\n/)) {
    const field = /^([a-z][a-z-]*):\s*(.*)$/.exec(line)
    if (field) meta[field[1]] = unquote(field[2])
  }
  return { meta, body: raw.slice(match[0].length).replace(/^\s*\n/, "").trimEnd() }
}

export function loadSkills(root) {
  const dir = join(root, "skills")
  return readdirSync(dir, { withFileTypes: true })
    .filter((entry) => entry.isDirectory())
    .map((entry) => entry.name)
    .sort()
    .map((id) => {
      const path = join(dir, id, "SKILL.md")
      const { meta, body } = parseSkill(readFileSync(path, "utf8"))
      return { id, name: meta.name ?? "", description: meta.description ?? "", body, path }
    })
}
