---
title: Markdown là nguồn sự thật duy nhất
updated: 2026-11-15
---
# ADR-0001: Markdown là nguồn sự thật duy nhất, Word và Excel chỉ là cửa vào và cửa ra

## Bối cảnh
Tài liệu của project có thể nằm ở Word, Excel, hoặc markdown. Nếu hai định dạng
cùng tồn tại, chúng sẽ lệch nhau: Word không diff được, không merge được, và mỗi
lần agent đọc phải parse lại từ đầu. Người đọc lại sau sáu tháng cần một bản duy
nhất đáng tin, mở được bằng Obsidian.

## Quyết định
Mọi tài liệu sống ở dạng markdown trong `docs/`. Word và Excel chỉ dùng để nhận
vào (trích thành `docs/imports/*.md`) hoặc gửi đi (sinh một chiều từ markdown).
Sửa nội dung thì sửa markdown rồi xuất lại.

## Phương án đã loại
- `.docx` là nguồn, markdown là bản trích — loại vì phải đồng bộ hai chiều bằng
  tay, và bản trích sẽ lệch trong vòng một tuần.
- Chỉ dùng Word, không markdown — loại vì agent không diff được, Obsidian không
  dựng graph được, và lịch sử thay đổi mất.
- Markdown cho mọi thứ kể cả bảng tính có công thức — loại vì `.xlsx` chứa công
  thức là sản phẩm thật; với trường hợp đó, chính file `.xlsx` là nguồn và
  markdown chỉ ghi chú.

## Hệ quả
- Gửi cho người khác phải xuất file, và bản xuất không sửa tay được.
- Bảng tính có công thức là ngoại lệ: một file `.xlsx` là nguồn, markdown chỉ trỏ
  tới nó, và phải ghi rõ "nguồn:".
- Ảnh và sơ đồ nằm ở `docs/assets/` để graph không bị rác.
