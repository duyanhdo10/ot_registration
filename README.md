# OT Registration

Tài liệu đặc tả và lộ trình học–làm module quản lý đăng ký làm thêm giờ (OT)
trên Odoo 17 Community.

## Tài liệu

- [REQUIREMENTS.md](REQUIREMENTS.md): yêu cầu nghiệp vụ, luồng phê duyệt,
  phân quyền, email và giao diện.
- [ROADMAP.md](ROADMAP.md): roadmap theo từng chặng, gồm concept cần học,
  bài thực hành, test và tiêu chí hoàn thành.
- [docs/SETUP.md](docs/SETUP.md): dựng môi trường Docker trên một máy mới.
- [docs/DECISIONS.md](docs/DECISIONS.md): **nguồn sự thật duy nhất** cho mọi
  quyết định nghiệp vụ và kỹ thuật.
- [docs/LEARNING_LOG.md](docs/LEARNING_LOG.md): nhật ký học theo buổi.
- [AGENTS.md](AGENTS.md): hợp đồng làm việc giữa học viên và AI agent
  (hybrid AI-assisted) — **áp dụng cho mọi công cụ**.
- [CLAUDE.md](CLAUDE.md): con trỏ về `AGENTS.md` + ghi chú riêng Claude Code.
- [env/](env/): bản gốc của các file môi trường Docker.

## Định hướng triển khai

- Chạy trên Odoo 17 Community ở môi trường local.
- Xây module Odoo 17 sạch; code Odoo cũ chỉ được dùng làm tài liệu tham khảo.
- Thực hiện tuần tự từ data model, validation và workflow đến security,
  frontend, email, migration và kiểm thử.
- Mỗi chặng chỉ hoàn thành khi đạt Definition of Done trong roadmap.
