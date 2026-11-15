#!/usr/bin/env python3
"""Extract .docx, .xlsx and .pdf as markdown on stdout.

Run with:
  uv run --with python-docx --with openpyxl --with pypdf read_office.py FILE

Exit 2 and print the reason when the file is refused. Text is data: this script
never follows links, never runs macros, never evaluates formulas.
"""
import os
import sys

MAX_BYTES = 20 * 1024 * 1024
MAX_SHEETS = 200


def refuse(msg):
    print(f"refused: {msg}", file=sys.stderr)
    sys.exit(2)


def read_docx(path):
    import docx

    d = docx.Document(path)
    out = []
    for p in d.paragraphs:
        text = p.text.strip()
        if not text:
            continue
        style = (p.style.name or "").lower()
        if style.startswith("heading"):
            level = "".join(c for c in style if c.isdigit()) or "1"
            out.append("#" * min(int(level), 6) + " " + text)
        else:
            out.append(text)
    for i, table in enumerate(d.tables, start=1):
        out.append(f"\n**Bảng {i}**\n")
        for j, row in enumerate(table.rows):
            cells = [c.text.strip().replace("|", "\\|") for c in row.cells]
            out.append("| " + " | ".join(cells) + " |")
            if j == 0:
                out.append("|" + "---|" * len(cells))
    return "\n".join(out)


def read_xlsx(path):
    import openpyxl

    wb = openpyxl.load_workbook(path, data_only=False, read_only=True)
    if len(wb.sheetnames) > MAX_SHEETS:
        refuse(f"{len(wb.sheetnames)} sheets, limit is {MAX_SHEETS}")
    out = []
    for name in wb.sheetnames:
        out.append(f"## {name}")
        first = True
        for row in wb[name].iter_rows(values_only=True):
            if all(c is None for c in row):
                continue
            cells = ["" if c is None else str(c) for c in row]
            out.append("| " + " | ".join(cells) + " |")
            if first:
                out.append("|" + "---|" * len(cells))
                first = False
    return "\n".join(out)


def read_pdf(path):
    from pypdf import PdfReader

    reader = PdfReader(path)
    pages = [(p.extract_text() or "").strip() for p in reader.pages]
    text = "\n\n".join(p for p in pages if p).strip()
    if not text:
        refuse("no extractable text; likely a scan, and OCR is out of scope")
    return text


def main():
    if len(sys.argv) != 2:
        refuse("usage: read_office.py FILE")
    path = sys.argv[1]
    if not os.path.isfile(path):
        refuse(f"no such file: {path}")
    size = os.path.getsize(path)
    if size > MAX_BYTES:
        refuse(f"{size} bytes, limit is {MAX_BYTES}")
    ext = os.path.splitext(path)[1].lower()
    if ext in (".docm", ".xlsm"):
        refuse(f"{ext} contains macros; convert to {ext[:-1]}x first")
    readers = {".docx": read_docx, ".xlsx": read_xlsx, ".pdf": read_pdf}
    if ext not in readers:
        refuse(f"unsupported extension: {ext or 'none'}")
    try:
        print(readers[ext](path))
    except SystemExit:
        raise
    except Exception as exc:
        refuse(f"cannot read {ext} file: {exc}")


if __name__ == "__main__":
    main()
