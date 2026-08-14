# CLAUDE.md

**Đọc [`AGENTS.md`](AGENTS.md) trước.** Toàn bộ hợp đồng làm việc — vai trò,
quy trình buổi học, nguồn sự thật, môi trường Docker, cảnh báo Odoo 17 — nằm ở
đó và áp dụng cho mọi AI agent.

File này **cố ý ngắn**. Nó chỉ chứa phần riêng của Claude Code. Đừng chép nội
dung từ `AGENTS.md` sang đây: repo này đã từng mất một vòng review vì lệnh môi
trường bị lặp ở ba file.

## Riêng cho Claude Code

- Khi user gõ `/`-command hoặc nhắc tới skill, vẫn phải theo ranh giới ở
  `AGENTS.md` §0. Không có skill nào cho phép sửa code module khi chưa có task
  brief được duyệt.
- Trước khi sửa file, kiểm tra file đó có nằm trong danh sách Allowed của task
  brief không. Không có trong danh sách thì dừng lại và hỏi.
- Không tự commit. User commit ở bước đóng buổi.

## Nếu hết quota Claude

Chuyển sang agent khác (Codex CLI, Cursor, Gemini CLI…) — chúng đọc `AGENTS.md`
và nhận đúng hợp đồng này. Xem bảng công cụ ở đầu `AGENTS.md`.
