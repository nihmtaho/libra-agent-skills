---
title: libra-agent-skills
updated: 2026-11-15
---
# Bộ 14 skill cho agent lập trình, dựng quanh một file trạng thái để mở lại project sau sáu tháng

## Chạy & kiểm chứng
- `bash scripts/test.sh` — kiểm hợp đồng của mọi skill rồi chạy bốn phép thử cài đặt.
- `bash scripts/check.sh` — chỉ phần hợp đồng skill và mục rỗng của `PROJECT.md`.
- Dấu hiệu đúng: exit 0, và hai dòng `all checks passed` rồi `install tests passed`.

## Bản đồ module
- `skills/<tên>/SKILL.md` — nguồn duy nhất của bộ skill; ≤80 dòng, năm mục cố định; đổi tên file là phải đổi `name`.
- `install.sh` — symlink vào đích; dễ vỡ nhất ở chỗ ghi đè và ở đường dẫn có dấu cách.
- `scripts/check.sh` — hợp đồng skill (frontmatter, độ dài, heading, token cấm, mục rỗng); sửa luật ở đây là sửa cho cả 14 skill.
- `scripts/test-install.sh` — symlink, chạy hai lần, từ chối ghi đè, script đọc Office phải chạy được từ đích đã cài.
- `docs/` — xương sống của chính repo này; repo này là nơi dogfood đầu tiên.

## Tính năng
| Tính năng | Trạng thái | Dừng ở | Tài liệu |
| bộ 14 skill | done | | [plan](plans/2026-11-15-libra-agent-skills-plan.md) |
| đọc tài liệu Office | done | | [spec](specs/office-docs.md) |

## Quyết định
- [ADR-0001](adr/0001-markdown-is-the-only-source.md) — markdown là nguồn duy nhất; Word/Excel chỉ là cửa vào và cửa ra.

## Tiếp theo
1. Chốt cách xử lý khi `docs/` bị gitignore — chạy thật trên `goxviet` cho thấy skill chỉ biết hỏi, chưa có đường đi.
2. Dùng bộ này một tuần trên công việc thật; ghi chỗ vướng vào đây.
3. Push lên GitHub rồi kiểm lại `npx skills add nihmtaho/libra-agent-skills`.
