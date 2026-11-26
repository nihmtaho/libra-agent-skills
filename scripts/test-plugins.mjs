import assert from "node:assert/strict"
import { execFileSync } from "node:child_process"
import { mkdtempSync, rmSync } from "node:fs"
import { tmpdir } from "node:os"
import { dirname, join } from "node:path"
import { fileURLToPath } from "node:url"
import { GROUP_OF } from "../lib/groups.mjs"
import { defaultBranch, isDirectCommit, isMarkdownPath, MARKER } from "../lib/guardrails.mjs"
import { loadSkills } from "../lib/skills.mjs"

const root = dirname(dirname(fileURLToPath(import.meta.url)))
let failed = 0

function check(name, condition, detail = "") {
  if (condition) return
  failed += 1
  console.error(`FAIL plugin: ${name}${detail ? ` — ${detail}` : ""}`)
}

const skills = loadSkills(root)
check("27 skills", skills.length === 27, String(skills.length))
check("unique ids", new Set(skills.map((s) => s.id)).size === skills.length)

for (const skill of skills) {
  check(`${skill.id}: prefixed`, skill.id.startsWith("libra-"))
  check(`${skill.id}: name matches directory`, skill.name === skill.id, skill.name)
  check(`${skill.id}: description`, skill.description.length > 10)
  check(`${skill.id}: group`, typeof GROUP_OF[skill.id] === "string", GROUP_OF[skill.id])
  check(`${skill.id}: frontmatter stripped`, !skill.body.startsWith("---"))
  check(`${skill.id}: body starts with H1`, skill.body.startsWith("# "), skill.body.slice(0, 20))
}

check("markdown path", isMarkdownPath("/tmp/x.md") && isMarkdownPath("A.MD") && !isMarkdownPath("/tmp/x.mjs"))
check("marker", MARKER === "<!-- libra:allow-direct-commit -->")

const main = { branch: "main", defaultBranch: "main", gitDoc: "" }
const commit = (command, overrides = {}) => isDirectCommit({ ...main, command, ...overrides })

check("commit on main blocks", commit("git commit -m x"))
check("commit on master blocks", isDirectCommit({ branch: "master", defaultBranch: "master", gitDoc: "", command: "git commit -m x" }))
check("commit on a feature branch passes", !commit("git commit -m x", { branch: "feat/x" }))
check("marker allows the commit", !commit("git commit -m x", { gitDoc: `${MARKER}\n` }))
check("git status passes", !commit("git status"))
check("git log --grep commit passes", !commit("git log --grep commit"))
check("git -C path commit blocks", commit("git -C /repo commit -m x"))
check("chained commit blocks", commit("cd /repo && git commit -m x"))
check("force push blocks", commit("git push --force origin main"))
check("short force push blocks", commit("git push -f origin main"))
check("force-with-lease blocks", commit("git push --force-with-lease origin main"))
check("plain push passes", !commit("git push origin main"))
check("force push to another branch passes", !commit("git push --force origin feature"))

const temp = mkdtempSync(join(tmpdir(), "libra-plugins-"))
try {
  execFileSync("git", ["init", "-q", "-b", "trunk"], { cwd: temp, stdio: "ignore" })
  check("default branch falls back to current", defaultBranch(temp) === "trunk", defaultBranch(temp))
} finally {
  rmSync(temp, { recursive: true, force: true })
}

const packed = JSON.parse(
  execFileSync("npm", ["pack", "--dry-run", "--json"], { cwd: root, encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] }),
)
const files = new Set(Object.values(packed)[0].files.map((entry) => entry.path))
for (const skill of skills) check(`${skill.id}: packed`, files.has(`skills/${skill.id}/SKILL.md`))
for (const file of [
  "package.json",
  ".claude-plugin/plugin.json",
  ".claude-plugin/marketplace.json",
  "hooks/hooks.json",
  "hooks/guardrails/md-check.mjs",
  "hooks/guardrails/git-guard.mjs",
  "lib/skills.mjs",
  "lib/guardrails.mjs",
  "lib/groups.mjs",
  "adapters/opencode/index.ts",
  "adapters/pi/index.ts",
  "scripts/check-docs.sh",
]) {
  check(`packed ${file}`, files.has(file))
}

assert.equal(failed, 0, `${failed} plugin checks failed`)
console.log("plugin tests passed")
