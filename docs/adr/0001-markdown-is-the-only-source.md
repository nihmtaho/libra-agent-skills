---
title: Markdown is the only source of truth
updated: 2026-11-15
---
# ADR-0001: Markdown is the only source of truth, Word and Excel are only the way in and the way out

## Context
A project's docs can live in Word, Excel, or markdown. If two formats coexist they
drift: Word cannot be diffed, cannot be merged, and the agent has to parse it again
from scratch every time it reads it. Someone reading again six months later needs
one trustworthy copy that opens in Obsidian.

## Decision
Every document lives as markdown in `docs/`. Word and Excel are only used to bring
content in (extracted into `docs/imports/*.md`) or to send it out (generated one
way from markdown). To change content, change the markdown and export again.

## Rejected options
- `.docx` as the source, markdown as the extract — rejected because the two have to
  be synced by hand in both directions, and the extract drifts within a week.
- Word only, no markdown — rejected because the agent cannot diff it, Obsidian
  cannot build the graph, and the change history is lost.
- Markdown for everything, including spreadsheets with formulas — rejected because
  an `.xlsx` with formulas is a real product; in that case the `.xlsx` file itself
  is the source and markdown is only a note.

## Consequences
- Sending to someone else means exporting a file, and the export cannot be edited by
  hand.
- Spreadsheets with formulas are the exception: one `.xlsx` file is the source,
  markdown only points to it, and must state "source:".
- Images and diagrams live in `docs/assets/` so the graph stays clean.
