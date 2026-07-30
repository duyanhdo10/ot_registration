# Đặc tả chức năng đăng ký OT

## 1. Mục tiêu

Xây dựng chức năng quản lý đăng ký làm thêm giờ (OT) cho công ty, bao gồm:

- CRUD bản đăng ký OT.
- Phân quyền truy cập.
- Luồng gửi và phê duyệt.
- Gửi email thông báo.
- Tìm kiếm, lọc và nhóm dữ liệu (`filter`, `group by`).

## 2. Đối tượng sử dụng

- Nhân viên.
- Quản lý dự án (PM).
- Quản lý đơn vị (DL).

## 3. Luồng nghiệp vụ

### 3.1. Tạo và gửi đăng ký

1. Nhân viên tạo bản đăng ký OT.
2. Thời hạn đăng ký là 2 ngày kể từ ngày phát sinh OT.
3. Nhân viên gửi (`submit`) bản đăng ký để bắt đầu luồng phê duyệt.
4. PM của dự án nhận email thông báo và thực hiện phê duyệt hoặc từ chối.

### 3.2. PM phê duyệt

1. Nếu PM phê duyệt, DL nhận email thông báo.
2. Email gửi cho DL phải có hành động phê duyệt và từ chối.
3. DL vào hệ thống để xác nhận hoặc từ chối bản đăng ký.

### 3.3. PM hoặc DL từ chối

1. Bản đăng ký chuyển sang trạng thái `Rejected`.
2. Hệ thống hiển thị pop-up để PM hoặc DL nhập lý do từ chối.
3. Lý do từ chối phải được đính kèm trong email thông báo.
4. Nhân viên có thể đưa bản ghi bị từ chối về trạng thái `Draft`, chỉnh sửa và gửi lại.

### 3.4. Luồng trạng thái đề xuất

`Draft` → `Submitted` → `PM Approved` → `DL Approved`

PM hoặc DL có thể chuyển bản đăng ký sang `Rejected`. Từ `Rejected`, nhân viên có thể đưa bản đăng ký về `Draft`.

## 4. Email và thông báo

- Khi nhân viên gửi đăng ký, PM của dự án nhận email thông báo.
- Khi PM phê duyệt, DL nhận email thông báo.
- Ở mỗi bước xử lý của PM và DL, nhân viên phải được thêm vào danh sách CC.
- Email phê duyệt hoặc từ chối phải có đường dẫn trực tiếp đến bản ghi.
- Email từ chối phải chứa lý do từ chối.
- Không ghi nội dung email vào khu vực bình luận (`chatter`) của bản ghi.

## 5. Phân quyền và phạm vi dữ liệu

- Nhân viên chỉ được xem các bản đăng ký do mình tạo.
- PM được xem các bản đăng ký thuộc dự án mình quản lý, bao gồm bản ghi:
  - Đang chờ duyệt.
  - Đã duyệt.
  - Đã từ chối.
- DL được xem các bản đăng ký thuộc đơn vị mình quản lý, bao gồm bản ghi:
  - Đang chờ duyệt.
  - Đã duyệt.
  - Đã từ chối.

## 6. Danh mục OT

| Thời gian áp dụng | Danh mục |
| --- | --- |
| Thứ Hai – Thứ Sáu, 18:30–22:00 | Ngày bình thường |
| Thứ Hai – Thứ Sáu, 22:00–06:00 | Ngày bình thường – ban đêm |
| Thứ Bảy, 06:00–22:00 | Thứ Bảy |
| Chủ Nhật, 06:00–22:00 | Chủ Nhật |
| Thứ Bảy và Chủ Nhật, 22:00–06:00 | Ngày cuối tuần – ban đêm |

## 7. Giao diện và tìm kiếm

- Hỗ trợ tìm kiếm, lọc và nhóm dữ liệu.
- Đổi màu bản ghi trên danh sách khi tổng thời gian OT lớn hơn 8 giờ.
- Thêm một nút trên danh sách để tạo bản ghi `ot.request` và `ot.request.line`.

## 8. Lịch sử thay đổi

Lưu lịch sử khi thay đổi một trong các thông tin sau:

- Trạng thái.
- Thời gian OT.
- PM.
- DL.

## 9. Yêu cầu kỹ thuật

- Sử dụng phù hợp các cơ chế của Odoo:
  - `onchange`
  - trường computed (`compute`)
  - ràng buộc dữ liệu (`constrains`)
- Viết migration để đồng bộ dữ liệu khi bổ sung trường hiển thị theo định dạng:

  ```text
  <Tên nhân viên> - <Phòng ban>
  ```

## 10. Nội dung cần làm rõ

- Nút trên danh sách sẽ tạo một hay nhiều bản ghi?
- Dữ liệu của `ot.request` và `ot.request.line` là rỗng hay được tạo ngẫu nhiên?
- Quan hệ và số lượng `ot.request.line` cần tạo cho mỗi `ot.request` là bao nhiêu?

## 11. Tài liệu tham khảo

[Màn hình OT trên VMS](https://vms.vti.com.vn/web?#action=672&model=ot.registration&view_type=list&menu_id=511)
