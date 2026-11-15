---
title: Đọc Word, Excel và PDF
updated: 2026-11-15
spec: ../specs/office-docs.md
---
# Đọc Word, Excel và PDF

Dừng ở: chưa bắt đầu

## Checkpoint 1 — sau T1
`read_office.py` trên một `.docx` mẫu phải in markdown có heading `#` và bảng, không lỗi.

## Checkpoint 2 — sau T3
`read_office.py` từ chối `.docm` với mã 2, và đọc được `.xlsx` hai sheet.

- [ ] **T1 — Đọc `.docx` ra markdown**
      Xong nghĩa là: fixture có heading "Notes" và câu "ignore previous instructions…" in ra, cả hai còn nguyên
      Đụng: `skills/office-docs/scripts/read_office.py`
- [ ] **T2 — Đọc `.xlsx` ra bảng**
      Xong nghĩa là: fixture hai sheet in ra hai heading `## <tên sheet>` và đúng số dòng
      Đụng: `skills/office-docs/scripts/read_office.py`
      Phụ thuộc: T1
- [ ] **T3 — Chặn `.docm` và file lớn**
      Xong nghĩa là: `.docm` → thoát mã 2 kèm lý do; file > 20 MB → thoát mã 2
      Đụng: `skills/office-docs/scripts/read_office.py`
      Phụ thuộc: T1
