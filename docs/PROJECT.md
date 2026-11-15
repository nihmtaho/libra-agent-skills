---
title: libra-agent-skills
updated: 2026-11-15
---
# Bộ 14 skill cho agent lập trình, dựng quanh một file trạng thái để mở lại project sau sáu tháng

## Chạy & kiểm chứng
- `bash scripts/test.sh` — kiểm hợp đồng của mọi skill rồi chạy bốn phép thử cài đặt.
- `bash scripts/check.sh` — chỉ phần hợp đồng skill và mục rỗng của `PROJECT.md`.
- Dấu hiệu đúng: `all checks passed`.

## Bản đồ module
- `skills/<tên>/SKILL.md` — nguồn duy nhất của bộ skill; mỗi file tối đa 80 dòng, năm mục cố định.
- `scripts/check.sh` — hợp đồng của skill (frontmatter, độ dài, heading, token cấm, mục rỗng).
- `scripts/test-install.sh` — symlink, chạy hai lần, từ chối ghi đè.
- `docs/` — xương sống của chính repo này; repo này là nơi dogfood đầu tiên.

## Tính năng
| Tính năng | Trạng thái | Dừng ở | Tài liệu |
| bộ 14 skill | done | | [plan](plans/2026-11-15-libra-agent-skills-plan.md) |
| đọc tài liệu Office | done | | [spec](specs/office-docs.md) |

## Quyết định
- [ADR-0001](adr/0001-markdown-is-the-only-source.md) — markdown là nguồn duy nhất; Word/Excel chỉ là cửa vào và cửa ra.

## Tiếp theo
1. Chạy `bootstrap-project` trên một repo cũ thật, rồi để một phiên mới chỉ đọc `PROJECT.md` trả lời bốn dòng của `resume`.
2. Dùng bộ này một tuần trên công việc thật; ghi chỗ vướng vào đây.
3. Push lên GitHub rồi kiểm lại `npx skills add nihmtaho/libra-agent-skills`.
