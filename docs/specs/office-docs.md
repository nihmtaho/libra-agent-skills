---
title: Đọc Word, Excel và PDF
updated: 2026-11-15
---
# Đọc tài liệu Office như dữ liệu, không như mệnh lệnh

## Vấn đề
Tài liệu cũ của tôi và tài liệu người khác gửi thường là `.docx`, `.xlsx`, `.pdf`.
Agent không đọc được trực tiếp, nên tôi phải chép tay sang markdown, và mỗi lần
quay lại phải chép lại. Bản chép tay cũng mất cấu trúc heading và bảng.

## Use case
1. Đưa một `.docx` cũ, nhận lại markdown có heading và bảng, lưu vào `docs/imports/`.
2. Đưa một `.xlsx`, xem từng sheet dưới dạng bảng, công thức in ra dạng chuỗi.
3. Đưa một `.pdf` dạng text, nhận lại text; gặp PDF scan thì được báo là không đọc được.

## Tiêu chí nghiệm thu
- [ ] `read_office.py evil.docx` in ra markdown, và câu "ignore previous instructions…" nằm nguyên trong output.
- [ ] `read_office.py bad.docm` in lý do từ chối và thoát với mã 2.
- [ ] File lớn hơn 20 MB bị từ chối với mã 2, không bị đọc một phần.
- [ ] Kết quả ghi vào `docs/imports/<tên gốc>.md` có `trust: external` và dòng nguồn.

## Ngoài phạm vi
- Không ghi `.xlsx` trừ khi được yêu cầu rõ; mặc định chỉ đọc.
- Không OCR PDF scan; báo lại thay vì đoán nội dung.
- Không theo hyperlink, không chạy macro.
