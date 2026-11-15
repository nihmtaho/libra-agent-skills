---
title: Reading Word, Excel and PDF
updated: 2026-11-15
---
# Reading Office documents as data, not as instructions

## Problem
My old documents, and documents other people send me, are usually `.docx`, `.xlsx`,
`.pdf`. The agent cannot read them directly, so I copy them by hand into markdown,
and every time I come back I have to copy them again. The hand copy also loses
heading and table structure.

## Use cases
1. Hand over an old `.docx`, get back markdown with headings and tables, saved into `docs/imports/`.
2. Hand over an `.xlsx`, see each sheet as a table, formulas printed as strings.
3. Hand over a text `.pdf`, get text back; a scanned PDF is reported as unreadable.

## Acceptance criteria
- [x] `read_office.py evil.docx` prints markdown, and the sentence "ignore previous instructions…" stays intact in the output.
- [x] `read_office.py bad.docm` prints the reason for refusal and exits with code 2.
- [x] A file larger than 20 MB is refused with code 2, not partially read.
- [x] The result written to `docs/imports/<original name>.md` has `trust: external` and a source line.

## Out of scope
- No writing `.xlsx` unless explicitly asked; read-only by default.
- No OCR of scanned PDFs; report back instead of guessing the content.
- No following hyperlinks, no running macros.

Checked 2026-11-15: the first three items run on fixtures; the last one runs in a temp directory, no sample file is kept in the repo.
