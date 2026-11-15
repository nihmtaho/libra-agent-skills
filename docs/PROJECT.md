---
title: libra-agent-skills
updated: 2026-11-15
---
# Bộ 14 skill cho agent lập trình, dựng quanh một file trạng thái để mở lại project sau sáu tháng

## Chạy & kiểm chứng
- `bash scripts/test.sh` — kiểm hợp đồng của mọi skill rồi chạy ba phép thử cài đặt.
- `./install.sh --to agents,claude --dest <thư mục>` — cài thử vào một thư mục tạm.
- Dấu hiệu đúng: `all checks passed` rồi `install tests passed`.

## Bản đồ module
- `skills/<tên>/SKILL.md` — nguồn duy nhất của bộ skill; mỗi file tối đa 80 dòng, năm mục cố định.
- `scripts/check.sh` — hợp đồng của skill (frontmatter, độ dài, heading, token cấm, mục rỗng).
- `scripts/test-install.sh` — symlink, chạy hai lần, từ chối ghi đè.
- `docs/` — xương sống của chính repo này; repo này là nơi dogfood đầu tiên.

## Tính năng
| Tính năng | Trạng thái | Dừng ở | Tài liệu |
| bộ 14 skill | in progress | T3 xong, T4 đang làm | [plan](plans/2026-11-15-libra-agent-skills-plan.md) |
| đọc tài liệu Office | in progress | T1 chưa bắt đầu | [task](tasks/office-docs.md) |

## Quyết định
- [ADR-0001](adr/0001-markdown-is-the-only-source.md) — markdown là nguồn duy nhất; Word/Excel chỉ là cửa vào và cửa ra.

## Tiếp theo
1. Viết xong `bootstrap-project` và template của nó.
2. `resume` đọc bốn dòng trạng thái.
3. `write-spec` hỏi năm câu.
