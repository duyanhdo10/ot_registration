# Decision log

**File này là nguồn sự thật duy nhất cho mọi decision.** `ROADMAP.md` §2 chỉ tóm
tắt và tham chiếu ID; khi hai file lệch nhau, file này thắng.

## Trạng thái decision

| Trạng thái | Ý nghĩa | Được code không? |
| --- | --- | --- |
| `Confirmed` | Chủ dự án đã xác nhận | Có |
| `Working Assumption` | Chủ dự án xác nhận **cho phép tạm giả định**, có owner và hạn | Có, kèm điều kiện ở §3 |
| `Pending` | Chưa có xác nhận nghiệp vụ | Không. Chỉ spike/đọc tài liệu |
| `Deferred` | Ngoài phạm vi MVP | Không |

Thời gian trôi qua **không** tự chuyển `Pending` thành `Working Assumption`.
Chỉ chủ dự án mới chuyển được trạng thái.

## 1. Đã xác nhận

| ID | Quyết định | Người xác nhận | Ngày |
| --- | --- | --- | --- |
| D01 | Odoo 17 Community, chạy local với database test riêng | Chủ dự án | 2026-07-30 |
| D02 | Code Odoo 12 chỉ để tham khảo; không nâng cấp database thật | Chủ dự án | 2026-07-30 |
| D03 | Hạn Submit là 2 ngày lịch, theo timezone của user Submit | Chủ dự án | 2026-07-30 |
| D04 | Email không đổi state bằng HTTP GET | Chủ dự án | 2026-07-30 |
| D05 | Mentor mode: Claude giảng + review, không tự ý sửa code module | Chủ dự án | 2026-07-31 |
| D06 | Giữ cả `custom_addons/ot_registration/` và `custom_addons/vti-japan/`; chỉ làm việc trong `vti-japan/` | Chủ dự án | 2026-07-31 |
| D07 | Hybrid AI-assisted learning (chi tiết bên dưới) | Chủ dự án | 2026-08-14 |
| D08 | Repo đích hiện tại là `custom_addons/ot_registration/`; quyết định này thay thế ràng buộc đường dẫn và clone đích trong D06 | Chủ dự án | 2026-08-17 |

### D07 — Hybrid AI-assisted learning

D07 **làm rõ và thay thế phần "user viết toàn bộ code" của D05**. D05 vẫn giữ
nguyên ở phần: agent không tự ý sửa code khi chưa được giao.

D05 viết ra khi mới chỉ dùng Claude. D07 áp dụng cho **mọi AI agent** — Claude
Code, Codex, Cursor, Gemini CLI hay công cụ khác. Hợp đồng chuẩn nằm ở
[`AGENTS.md`](../AGENTS.md); các file như `CLAUDE.md` chỉ trỏ về đó.

> User sở hữu: phân rã việc, decision, acceptance criteria, verification,
> debugger và learning log.
> AI được sửa code khi user giao hoặc chấp thuận một task brief nhỏ.
> Với mỗi concept Odoo mới, user tự làm một **micro-exercise** trước; sau đó AI
> mới được triển khai lát dự án tương ứng.

Hệ quả vận hành:

- Không có chặng nào bắt buộc code tay 100%, cũng không có chặng nào được giao
  trắng cho AI.
- Micro-exercise là điều kiện mở khóa: chưa tự tay làm qua concept thì chưa được
  giao lát dự án dùng concept đó cho AI.
- Điều AI **không bao giờ** làm thay: quyết định nghiệp vụ, đóng decision,
  learning log, debug note, kết luận "đã hiểu".

## 2. Còn Pending — chặn chặng nào

| ID | Nội dung tóm tắt | Chặn chặng | Trạng thái |
| --- | --- | --- | --- |
| P01 | PM từ `project.project.user_id`; DL từ `employee.parent_id` | 1 | Pending |
| P02 | Snapshot PM/DL khi Submit | 1 | Pending |
| P08 | `total_hours` = tổng giờ đăng ký | 1 | Pending |
| P09 | `category_timezone` snapshot từ cấu hình công ty | 1, 2 | Pending |
| P05 | Không hỗ trợ 06:00–09:00 ngày thường; 1 line = 1 category | 2 | Pending |
| P11 | Cắt giây/microsecond, không làm tròn phút | 2 | Pending |
| P12 | Overlap: chặn trong request khi lưu, giữa request khi Submit | 2 | Pending |
| P04 | Không auto-approve khi employee = PM = DL | 3 | Pending |
| P06 | DL chỉ thấy từ `to_approve_dl` | 4 | Pending |
| P03 | Nút tạo nhanh tạo 1 request + 1 line qua wizard | 5 | Pending |
| P07 | Employee ở To thì không lặp lại ở CC | 6 | Pending |
| P10 | Reassign + custom OT Admin group | — | Deferred, ngoài MVP |

**Chặng 0 không có decision gate** → được code ngay.
**Trước khi vào Chặng 1** phải đóng: P01, P02, P08, P09.

## 3. Working Assumption

Khi nghiệp vụ chưa trả lời được nhưng cần đi tiếp, chủ dự án có thể chuyển một
mục `Pending` sang `Working Assumption`. Điều kiện bắt buộc, thiếu một mục là
không hợp lệ:

1. Chủ dự án xác nhận rõ ràng bằng văn bản trong file này.
2. Có **owner** chịu trách nhiệm theo đuổi câu trả lời thật.
3. Có **ngày tạo** và **ngày hết hạn**. Quá hạn mà chưa Confirmed thì dừng code
   phần liên quan, không tự động gia hạn.
4. Ghi **impact**: nếu giả định sai thì phải sửa những gì.
5. Logic bị ảnh hưởng **cô lập trong một helper hoặc config** để đổi rẻ.
6. Test liên quan phải mang decision ID trong tên, ví dụ
   `test_p09_category_uses_snapshot_timezone`.
7. **Không release, không UAT** một Working Assumption như thể nó đã Confirmed.

### Bảng theo dõi

| ID | Giả định | Owner | Ngày tạo | Hết hạn | Impact nếu sai | Nơi cô lập |
| --- | --- | --- | --- | --- | --- | --- |
| _(chưa có)_ | | | | | | |

## 4. Quy trình đóng decision

1. Cập nhật trạng thái trong file này trước.
2. Ghi người xác nhận và ngày.
3. Cập nhật test/acceptance criteria bị ảnh hưởng.
4. Nếu quyết định cũ bị thay đổi, **thêm dòng mới**, không xóa lịch sử.
5. Đồng bộ ngược lại bảng tóm tắt ở `ROADMAP.md` §2.
