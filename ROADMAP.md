# Roadmap học và xây dựng module OT Registration trên Odoo 17

## 1. Mục tiêu

Roadmap này dùng module `ot_registration` hiện tại làm tài liệu tham khảo nghiệp vụ,
không coi đây là code cần nâng cấp trực tiếp từ Odoo 12.

Kết quả cuối cùng cần đạt được:

- Xây dựng một module chạy sạch trên Odoo 17 Community.
- Hiểu các concept Odoo được dùng trong từng phần, không chỉ sao chép code.
- Hoàn thành luồng đăng ký và phê duyệt OT theo `REQUIREMENTS.md`.
- Có test tự động cho nghiệp vụ, phân quyền và migration.
- Có thể cài mới, cập nhật module và kiểm thử trên môi trường local.

Thời lượng dự kiến:

- 6–7 tuần nếu học và làm khoảng 8–10 giờ mỗi tuần.
- 3–4 tuần nếu có thể dành khoảng 15–20 giờ mỗi tuần.

Tỷ lệ thời gian khuyến nghị cho mỗi buổi:

- 20% đọc concept và tài liệu.
- 60% triển khai một phần nhỏ có thể chạy được.
- 20% viết test, ghi chú và commit.

## 2. Các giả định đã thống nhất

### 2.1. Môi trường

- Odoo 17 Community.
- Chạy trên máy local.
- Sử dụng database test riêng.
- Không nâng cấp database thật từ Odoo 12.
- Code cũ chỉ dùng để tham khảo nghiệp vụ và cách tổ chức.

### 2.2. PM và DL

- PM được xác định từ `project.project.user_id`.
- Từ user của project tìm `hr.employee` có `user_id` tương ứng.
- DL được xác định từ `employee.parent_id`.
- Khi thiếu PM, DL, tài khoản đăng nhập hoặc email cần thiết, hệ thống chặn
  Submit và hiển thị lỗi rõ ràng.

### 2.3. Nút tạo OT trên danh sách

Tham khảo hành vi của project cũ:

- Mỗi lần nhấn tạo một `ot.request`.
- Request được tạo ở trạng thái Draft.
- Tạo kèm một `ot.request.line`.
- Dữ liệu sinh ra phải luôn thỏa mãn constraint.
- Không tự chọn một project bất kỳ nếu người dùng có nhiều project; nên dùng
  wizard để người dùng chọn project trước khi tạo.
- Nếu vẫn cần dữ liệu random phục vụ bài tập, chỉ random trong tập giá trị hợp lệ.

### 2.4. Hạn đăng ký

“Trong vòng 2 ngày” được hiểu là hai ngày lịch:

- OT ngày 28/07 có thể gửi đến hết ngày 30/07.
- Từ ngày 31/07 bị xem là quá hạn.
- Không cho gửi đăng ký cho ngày OT trong tương lai.
- Việc lấy ngày phải theo timezone của user, không lấy `.date()` trực tiếp từ
  một giá trị UTC.

### 2.5. Email phê duyệt

- Không thay đổi trạng thái trực tiếp bằng HTTP GET từ email.
- Nút trong email yêu cầu người dùng đăng nhập.
- Nút mở đúng bản ghi OT trong Odoo.
- Người dùng xác nhận bằng button nghiệp vụ trên form.
- Reject luôn đi qua wizard nhập lý do.

### 2.6. Các giả định an toàn khác

- Không hỗ trợ OT ngày thường 06:00–09:00 vì khoảng này không có trong
  `REQUIREMENTS.md`.
- Một line chỉ thuộc một danh mục OT. Nếu khoảng thời gian đi qua ranh giới danh
  mục, người dùng phải tách thành nhiều line.
- Không tự động duyệt hoàn tất khi employee, PM và DL là cùng một người. Trường
  hợp không có người duyệt độc lập cần báo lỗi cấu hình.
- Không cho PM hoặc DL chỉnh sửa trực tiếp thông tin đăng ký sau khi Submit;
  họ chỉ thực hiện hành động duyệt hoặc từ chối.

## 3. Bản đồ kiến thức

| Chặng | Concept chính | Sản phẩm đầu ra |
| --- | --- | --- |
| 0 | Kiến trúc Odoo, module lifecycle, XML ID | Module tối thiểu cài được |
| 1 | ORM, model, fields, recordset, relations | Data model hoàn chỉnh |
| 2 | Compute, onchange, constraints, timezone | Logic tính OT đúng và có test |
| 3 | State machine, business action, wizard | Luồng duyệt hoàn chỉnh |
| 4 | ACL, record rules, method security | Không rò rỉ dữ liệu |
| 5 | View XML, domain, search, OWL | UI và nút tạo nhanh |
| 6 | `mail.thread`, template, tracking | Email và lịch sử thay đổi |
| 7 | Test framework, migration, release | Module sẵn sàng UAT |

---

## 4. Chặng 0 — Kiến trúc Odoo và baseline Odoo 17

Thời lượng: 1–2 buổi.

### 4.1. Concept cần học

#### Addon và module

Một addon Odoo là một Python package có manifest. Các thành phần thường gặp:

- `__manifest__.py`: metadata, dependencies, data files và assets.
- `models/`: khai báo model và nghiệp vụ.
- `views/`: form, list, search, action và menu.
- `security/`: groups, ACL và record rules.
- `data/`: sequence, category, mail template.
- `wizard/`: model tạm dùng cho popup.
- `static/`: JavaScript, XML template, SCSS và hình ảnh.
- `tests/`: test tự động.

#### Registry

Khi Odoo khởi động database, các model được import và đăng ký vào registry.
Nếu một file Python không được import từ `__init__.py`, model trong file đó
không tồn tại đối với Odoo.

#### Environment

`self.env` chứa ngữ cảnh làm việc hiện tại:

- `self.env.user`: user đang thực hiện thao tác.
- `self.env.company`: công ty hiện tại.
- `self.env.context`: context từ action, view hoặc lời gọi ORM.
- `self.env['model.name']`: truy cập một model.
- `self.env.ref('module.xml_id')`: lấy record bằng external ID.

#### External ID

External ID có dạng `module.record_id`, ví dụ:

```python
self.env.ref("ot_registration.ot_cat_normal_day")
```

External ID giúp code tham chiếu dữ liệu ổn định thay vì hard-code database ID.

#### Vòng đời module

- Install: tạo model/table, nạp security và data.
- Upgrade: cập nhật schema và nạp lại data được khai báo.
- Uninstall: gỡ dữ liệu thuộc module theo cơ chế của Odoo.

### 4.2. Phần cần làm

- Tạo nhánh hoặc snapshot code trước khi bắt đầu.
- Xác định lệnh khởi động Odoo local.
- Tạo database dành riêng cho module.
- Chuẩn hóa manifest về Odoo 17.
- Bỏ các khai báo Odoo 12 không còn dùng:
  - `@api.multi`;
  - `track_visibility`;
  - `attrs`;
  - `states`;
  - asset XML kiểu cũ;
  - JavaScript `ListController.include`;
  - mail placeholder `${...}`.
- Đảm bảo tất cả model và wizard được import đúng.
- Tạm thời chưa làm custom JavaScript; ưu tiên module cài được trước.

Lệnh tham khảo:

```bash
./odoo-bin -c <odoo.conf> -d <database> \
  -i ot_registration --stop-after-init

./odoo-bin -c <odoo.conf> -d <database> \
  -u ot_registration --stop-after-init
```

### 4.3. Bài thực hành

1. Thêm một field Char tạm vào `ot.request`.
2. Upgrade module.
3. Kiểm tra field xuất hiện trong database và form.
4. Xóa field tạm, upgrade lại và ghi nhận cách Odoo xử lý column cũ.
5. Tra cứu một category bằng `env.ref`.

### 4.4. Câu hỏi tự kiểm tra

- Vì sao model có trong file Python nhưng Odoo báo không tồn tại?
- Khác nhau giữa database ID và external ID là gì?
- Vì sao thứ tự các file trong manifest có thể làm module cài đặt thất bại?
- Install và upgrade khác nhau thế nào?

### 4.5. Definition of Done

- Cài mới module trên database rỗng thành công.
- Upgrade module lần thứ hai thành công.
- Mở menu, list view và form view không lỗi.
- Không còn lỗi Python hoặc JavaScript trong log/console.

Tài liệu:

- [Odoo 17 Developer Tutorials](https://www.odoo.com/documentation/17.0/developer/tutorials.html)
- [Module Manifests](https://www.odoo.com/documentation/17.0/developer/reference/backend/module.html)

---

## 5. Chặng 1 — ORM và thiết kế data model

Thời lượng: tuần 1.

### 5.1. Concept cần học

#### Model

`models.Model` đại diện cho dữ liệu được lưu trong database.

```python
class OTRequest(models.Model):
    _name = "ot.request"
    _description = "OT Request"
```

`models.TransientModel` dùng cho dữ liệu tạm như wizard. Odoo tự dọn các record
transient sau một khoảng thời gian.

#### Recordset

`self` không phải luôn là một record. Nó là một recordset có thể chứa:

- Không record nào.
- Một record.
- Nhiều record.

Các pattern quan trọng:

```python
self.ensure_one()

for request in self:
    request.state = "draft"

employees = requests.mapped("employee_id")
```

#### Field và relation

- `Char`, `Text`, `Boolean`, `Float`.
- `Date`, `Datetime`.
- `Selection`.
- `Many2one`: nhiều record trỏ đến một record.
- `One2many`: quan hệ ngược của `Many2one`.

Trong module:

```text
ot.request 1 ─────── n ot.request.line
    │
    ├── employee_id ─── hr.employee
    ├── project_id  ─── project.project
    ├── pm_id       ─── hr.employee
    └── dl_id       ─── hr.employee
```

#### `ondelete`

- `cascade`: xóa request thì xóa line.
- `restrict`: không cho xóa record đang được tham chiếu.
- `set null`: xóa relation và giữ record hiện tại.

#### `store=True`

Computed field mặc định không được lưu trong database. `store=True` cho phép:

- Search.
- Group by.
- Sắp xếp.
- Tránh tính lại mỗi lần đọc.

Đổi lại, cần khai báo dependency chính xác và cân nhắc chi phí recompute.

### 5.2. Data model mục tiêu

#### `ot.category`

- `name`
- `code`
- Có thể bổ sung `sequence` để sắp xếp.

Danh mục tối thiểu:

- Normal Day.
- Normal Day – Night.
- Saturday.
- Sunday.
- Weekend – Night.
- Unknown chỉ dùng để cảnh báo khi nhập form, không được phép Submit.

#### `ot.request`

- `name`: sequence, readonly, copy=False.
- `state`.
- `project_id`.
- `employee_id`.
- `pm_id`: computed và stored.
- `dl_id`: computed và stored.
- `ot_month`.
- `request_date`.
- `employee_custom_name`.
- `total_registration_hours`.
- `total_actual_hours`.
- `line_ids`.
- Các field audit từ chối sẽ bổ sung ở chặng workflow.

#### `ot.request.line`

- `request_id`.
- `from_date`.
- `to_date`.
- `category_id`.
- `ot_registration_hours`.
- `actual_ot_hours`.
- `wfh_bz`.
- `reason`.
- `evidences`.

### 5.3. Phần cần làm

- Thiết kế lại model theo chuẩn Odoo 17.
- Dùng `@api.model_create_multi` cho `create` nếu cần override sinh sequence.
- Compute PM từ `project_id.user_id`.
- Compute DL từ `employee_id.parent_id`.
- Compute `employee_custom_name` theo:

```text
Tên nhân viên - Phòng ban
```

- Compute tổng giờ từ các line.
- Xác định field nào do người dùng nhập, field nào do hệ thống tính.
- Không dùng `force_save` để bù cho một thiết kế field không rõ ràng.

### 5.4. Bài thực hành

1. Tạo request bằng form.
2. Tạo request bằng Odoo shell.
3. Tạo hai line bằng `Command.create`.
4. Thay đổi project và quan sát PM recompute.
5. Thay đổi manager của employee và quan sát DL recompute.
6. Thay đổi department và kiểm tra `employee_custom_name`.

### 5.5. Test cần viết

- Sequence được sinh cho từng request.
- Copy request không dùng lại sequence.
- PM đúng với project manager.
- DL đúng với manager của employee.
- Tổng giờ bằng tổng các line.
- Tên hiển thị đúng khi có và không có phòng ban.

### 5.6. Câu hỏi tự kiểm tra

- Khi nào dùng related field, khi nào dùng computed field?
- Vì sao `@api.depends("employee_id")` có thể chưa đủ khi manager của employee đổi?
- `store=True` ảnh hưởng search và performance như thế nào?
- Vì sao `self.ensure_one()` không nên dùng trong mọi method?

### 5.7. Definition of Done

- Data model cài mới được.
- Quan hệ request/line hoạt động đúng.
- Không có field computed bị stale sau khi dependency thay đổi.
- Test model cơ bản chạy xanh.

Tài liệu:

- [Server Framework 101](https://www.odoo.com/documentation/17.0/developer/tutorials/server_framework_101.html)
- [ORM API](https://www.odoo.com/documentation/17.0/developer/reference/backend/orm.html)

---

## 6. Chặng 2 — Compute, onchange, constraints và logic thời gian OT

Thời lượng: tuần 2.

### 6.1. Concept cần học

#### Computed field

Dùng khi giá trị được suy ra từ dữ liệu khác và phải đúng ở mọi nguồn nhập:

- Form.
- Import.
- RPC.
- Cron.
- Code Python.

Ví dụ: số giờ đăng ký và tổng giờ.

#### Onchange

Chỉ hỗ trợ trải nghiệm nhập liệu trên form. Onchange không tự chạy khi tạo record
bằng import hoặc ORM.

Nên dùng onchange để:

- Làm tròn giây/phút trên form.
- Hiển thị category dự kiến.
- Hiển thị warning không chặn.

Không dùng onchange làm lớp bảo vệ nghiệp vụ duy nhất.

#### Constraint

Constraint bảo vệ tính đúng của dữ liệu khi create/write:

```python
@api.constrains("from_date", "to_date")
def _check_period(self):
    ...
```

Constraint phải:

- Hoạt động với nhiều record.
- Raise `ValidationError` có thông báo dễ hiểu.
- Không dựa vào giá trị chỉ có trên UI.

#### Timezone

Odoo lưu `Datetime` theo UTC nhưng hiển thị theo timezone người dùng.

Do đó:

- So sánh timestamp bằng UTC.
- Phân loại thứ/ngày/giờ bằng thời gian local.
- Hạn hai ngày lịch phải dùng ngày local.

#### Khoảng nửa mở

Nên xem khoảng OT là `[from_date, to_date)`:

- Bao gồm thời điểm bắt đầu.
- Không bao gồm thời điểm kết thúc.
- Hai line `18:30–20:00` và `20:00–22:00` không bị xem là trùng.

### 6.2. Bảng phân loại phải triển khai

| Ngày local | Khoảng giờ local | Category |
| --- | --- | --- |
| Thứ Hai–Thứ Sáu | 18:30–22:00 | Normal Day |
| Thứ Hai–Thứ Sáu | 22:00–06:00 hôm sau | Normal Day – Night |
| Thứ Bảy | 06:00–22:00 | Saturday |
| Chủ Nhật | 06:00–22:00 | Sunday |
| Thứ Bảy/Chủ Nhật | 22:00–06:00 hôm sau | Weekend – Night |

Quy ước:

- Khoảng `21:00–23:00` đi qua hai category và phải tách thành hai line.
- Khoảng `18:00–20:00` không hợp lệ vì bắt đầu trước 18:30.
- Khoảng `22:00–02:00` hợp lệ nếu kết thúc vào ngày hôm sau.
- Không hỗ trợ ngày lễ riêng trong phạm vi hiện tại.

### 6.3. Phần cần làm

- Tách logic tính duration khỏi onchange để có thể tái sử dụng và test.
- Tách logic xác định category thành helper method.
- Làm tròn giờ theo quy ước thống nhất.
- Constraint `to_date > from_date`.
- Constraint line phải nằm trong một category hợp lệ.
- Constraint không trùng line trong cùng request.
- Constraint không trùng với request khác của cùng employee, trừ request Rejected.
- Kiểm tra hạn hai ngày lịch khi Submit.
- Chặn OT tương lai khi Submit.
- Sửa typo external ID `cacot_cat_unknown` trong code tham khảo.

### 6.4. Test biên bắt buộc

#### Ngày thường

- `18:29–20:00`: invalid.
- `18:30–20:00`: Normal Day.
- `21:00–22:00`: Normal Day.
- `21:00–22:01`: invalid vì đi qua category.
- `22:00–23:00`: Normal Day – Night.
- `22:00–06:00`: Normal Day – Night.
- `22:00–06:01`: invalid.

#### Cuối tuần

- Thứ Bảy `06:00–22:00`: Saturday.
- Chủ Nhật `06:00–22:00`: Sunday.
- Thứ Bảy `22:00–06:00`: Weekend – Night.
- Chủ Nhật `22:00–06:00`: Weekend – Night.

#### Trùng thời gian

- Hai line chạm biên nhưng không giao nhau: valid.
- Hai line giao nhau một phút: invalid.
- Trùng với request Draft khác: invalid khi Submit.
- Trùng với request Rejected: valid.

#### Hạn đăng ký

Với ngày hiện tại 30/07:

- OT ngày 30/07: valid.
- OT ngày 29/07: valid.
- OT ngày 28/07: valid.
- OT ngày 27/07: quá hạn.
- OT ngày 31/07: tương lai.

### 6.5. Bài thực hành

1. Viết helper nhận một khoảng UTC và trả về khoảng local.
2. Viết test cùng timestamp dưới hai timezone khác nhau.
3. Tạo line bằng form và bằng ORM, so sánh kết quả.
4. Cố tình bỏ onchange khi gọi ORM và chứng minh constraint vẫn bảo vệ dữ liệu.

### 6.6. Câu hỏi tự kiểm tra

- Vì sao `.date()` trực tiếp trên `fields.Datetime` có thể cho sai ngày?
- Vì sao business rule không được đặt chỉ trong onchange?
- Điều kiện kiểm tra overlap của hai khoảng là gì?
- Tại sao một line đi qua ranh giới category nên được tách?

### 6.7. Definition of Done

- Tất cả test biên giờ và timezone chạy xanh.
- Import/RPC không thể tạo line sai.
- Không còn category “Unknown” sau khi Submit.
- Hạn hai ngày lịch hoạt động theo timezone người dùng.

Tài liệu:

- [Computed Fields and Onchanges](https://www.odoo.com/documentation/17.0/developer/tutorials/server_framework_101/08_compute_onchange.html)
- [ORM constraints](https://www.odoo.com/documentation/17.0/developer/reference/backend/orm.html)

---

## 7. Chặng 3 — State machine và workflow phê duyệt

Thời lượng: tuần 3.

### 7.1. Concept cần học

#### State machine

State machine mô tả:

- Các trạng thái có thể tồn tại.
- Transition hợp lệ.
- Người có quyền thực hiện transition.
- Điều kiện trước khi transition.
- Side effect sau transition.

Luồng mục tiêu:

```text
draft ──submit──> to_approve_pm ──PM approve──> to_approve_dl
                        │                              │
                     reject                         reject
                        │                              │
                        └──────────> rejected <────────┘
                                         │
                                     reset draft
                                         │
                                         └──> draft

to_approve_dl ──DL approve──> approved
```

#### Guard

Guard là điều kiện phải đúng trước một transition:

- Request đang đúng state.
- Có ít nhất một line.
- Dữ liệu OT hợp lệ.
- Người gọi đúng PM hoặc DL.
- PM/DL có user và email.
- Request chưa bị quá hạn đăng ký.

#### Business method và UI

Button trên view chỉ là cách gọi method. Việc ẩn button không phải bảo mật.
Method phải tự kiểm tra quyền và state.

#### Idempotency

Một action không được tạo side effect lặp lại ngoài ý muốn:

- Không gửi hai email vì double click.
- Không approve lại request đã approved.
- Không reject request đã rejected.

#### Wizard

Reject cần `TransientModel` vì:

- Thu thập lý do trước khi thay đổi state.
- Có nút Confirm và Cancel.
- Dữ liệu tạm không cần lưu lâu dài.

### 7.2. Phần cần làm

- Viết action Submit.
- Viết action PM Approve.
- Viết action DL Approve.
- Viết action mở Reject wizard.
- Viết action Confirm Reject.
- Viết action Reset to Draft.
- Lưu:
  - `rejection_reason`;
  - `rejected_by`;
  - `rejected_at`.
- Khi Reset to Draft:
  - giữ lịch sử từ chối;
  - cho phép sửa request/line;
  - xóa các cờ deadline tạm nếu có.
- Chỉ gửi email sau khi state transition thành công.
- Không dùng auto-approve nếu employee, PM và DL cùng một người.

### 7.3. Thứ tự side effect đề xuất

```text
1. Kiểm tra quyền.
2. Kiểm tra state.
3. Kiểm tra dữ liệu.
4. Ghi state và audit fields.
5. Gửi email.
6. Trả về action hoặc notification.
```

Email thất bại cần được log rõ. Cần quyết định email fail có rollback transition hay
đưa email vào queue để gửi lại. Với Odoo local và bài học này, ưu tiên mail queue
và không rollback nghiệp vụ chỉ vì SMTP tạm thời lỗi.

### 7.4. Test cần viết

- Draft hợp lệ Submit thành công.
- Draft không có line không Submit được.
- Submitted không Submit lần hai.
- Sai PM không approve được.
- PM đúng approve sang bước DL.
- PM reject bắt buộc có lý do.
- Sai DL không approve/reject được.
- DL approve chuyển Approved.
- Employee không approve request của mình.
- Rejected có thể Reset to Draft bởi đúng employee.
- Approved không thể quay Draft.
- Double call không tạo hai transition.

### 7.5. Bài thực hành

1. Vẽ transition table gồm state nguồn, action, actor và state đích.
2. Viết một helper kiểm tra actor.
3. Gọi action bằng Odoo shell dưới user không có quyền.
4. Thử gọi action trực tiếp dù button bị ẩn.
5. Quan sát transaction rollback khi raise `ValidationError`.

### 7.6. Câu hỏi tự kiểm tra

- Vì sao kiểm tra `groups` trong view là chưa đủ?
- Khác nhau giữa `UserError` và `ValidationError` trong trường hợp này?
- Side effect nào nên thực hiện trước, ghi state hay gửi email?
- Làm sao tránh double click gửi hai email?

### 7.7. Definition of Done

- Tất cả transition hợp lệ hoạt động.
- Transition trái phép bị chặn từ backend.
- Reject luôn có lý do.
- Resubmit sau Reject hoạt động.
- Không có action nào chỉ được bảo vệ bằng UI.

---

## 8. Chặng 4 — ACL, record rules và bảo mật method

Thời lượng: tuần 4.

### 8.1. Concept cần học

#### ACL

ACL trả lời câu hỏi:

> User thuộc group này có quyền create/read/write/unlink trên model không?

ACL có tính cộng dồn. Nếu một ACL bất kỳ cấp quyền, user có quyền đó ở cấp model.

#### Record rule

Record rule trả lời câu hỏi:

> Trong các record của model, user được thao tác record nào?

ACL không thay thế record rule và record rule không thay thế ACL.

#### Visibility và security

- `groups` trên button/menu chủ yếu điều khiển khả năng nhìn thấy.
- `readonly` trên view điều khiển UI.
- Cả hai không đủ để bảo vệ RPC.
- Public model method phải tự kiểm tra actor hoặc access.

#### `sudo()`

`sudo()` bỏ qua ACL và record rules. Chỉ dùng cho thao tác hẹp sau khi:

- Đã xác thực actor.
- Đã xác thực state.
- Chỉ ghi đúng field cần thiết.
- Không truyền thẳng dữ liệu tùy ý từ client vào `sudo().write(vals)`.

### 8.2. Groups mục tiêu

- OT Employee.
- OT Project Manager.
- OT Department Lead.
- Có thể bổ sung OT Administrator nếu cần cấu hình category.

Không nên gán menu OT cho toàn bộ `base.group_user` nếu mọi internal user không
được phép dùng module.

### 8.3. Ma trận quyền mục tiêu

| Actor | Read | Create | Write | Unlink | Action |
| --- | --- | --- | --- | --- | --- |
| Employee | Request của mình | Có | Draft/Rejected của mình | Draft của mình | Submit, Reset Draft |
| PM | Non-draft thuộc project quản lý | Không | Không sửa trực tiếp | Không | PM Approve/Reject |
| DL | Non-draft thuộc đơn vị quản lý | Không | Không sửa trực tiếp | Không | DL Approve/Reject |
| OT Admin | Theo phạm vi quản trị | Theo cấu hình | Theo cấu hình | Hạn chế | Cấu hình |

DL được xem cả request đang chờ PM vì `REQUIREMENTS.md` yêu cầu DL xem các bản
ghi đang chờ duyệt thuộc đơn vị mình quản lý.

### 8.4. Thiết kế bảo mật đề xuất

- Employee có write ACL và record rule cho request Draft/Rejected của chính họ.
- Employee có rule tương ứng cho line.
- PM và DL chủ yếu có read access theo phạm vi.
- Action approve/reject:
  - kiểm tra actor bằng user hiện tại;
  - kiểm tra record thuộc phạm vi;
  - sau đó dùng thao tác ghi hẹp để đổi state/audit fields.
- Không cấp write rộng cho PM/DL rồi chỉ dựa vào readonly trên form.
- Hạn chế dùng `sudo()` trong compute; nếu bắt buộc, không để nó mở rộng dữ liệu
  user nhìn thấy.

### 8.5. Bộ dữ liệu test

Tạo:

- Employee A thuộc Department A.
- Employee B thuộc Department B.
- PM A quản lý Project A.
- PM B quản lý Project B.
- DL A quản lý Employee A.
- DL B quản lý Employee B.
- Một user có đồng thời vai trò Employee và PM.

### 8.6. Test bảo mật bắt buộc

- Employee A không đọc được request Employee B bằng ID.
- Employee A không sửa request đã Submit.
- Employee A không tạo line cho request Employee B.
- PM A không đọc request Project B.
- PM A không sửa giờ/project/employee sau Submit.
- PM A chỉ approve/reject bước PM của Project A.
- DL A không đọc Department B.
- DL A xem được request Department A đang chờ PM.
- DL A chỉ approve/reject bước DL.
- Internal user không có group OT không thấy menu và không truy cập model.

### 8.7. Bài thực hành

1. Tạo user test và dùng `with_user(user)` trong test.
2. Chứng minh button invisible không chặn lời gọi ORM.
3. Tạm cấp ACL write cho PM và quan sát rủi ro.
4. Kiểm tra record rules của request và line cùng lúc.
5. Gọi method với một recordset gồm record được phép và không được phép.

### 8.8. Câu hỏi tự kiểm tra

- ACL và record rule khác nhau ở đâu?
- Vì sao ACL có tính cộng dồn có thể tạo lỗ hổng?
- Vì sao PM có quyền gọi approve không đồng nghĩa PM cần write toàn bộ request?
- Khi nào `sudo()` là hợp lý?

### 8.9. Definition of Done

- Toàn bộ test positive và negative chạy xanh.
- Không đọc được dữ liệu ngoài phạm vi bằng RPC.
- PM/DL không sửa trực tiếp nội dung request.
- Mọi action đều có kiểm tra backend.

Tài liệu:

- [Restrict Access to Data](https://www.odoo.com/documentation/17.0/developer/tutorials/restrict_data_access.html)
- [Security in Odoo](https://www.odoo.com/documentation/17.0/developer/reference/backend/security.html)

---

## 9. Chặng 5 — View, search và frontend Odoo 17

Thời lượng: tuần 5.

### 9.1. Concept cần học

#### View record và architecture

Một view gồm:

- Record `ir.ui.view`.
- `model`.
- XML architecture.

Các view cần dùng:

- List view.
- Form view.
- Search view.

#### Modifier Odoo 17

Odoo 17 dùng biểu thức trực tiếp:

```xml
<field name="project_id"
       readonly="state not in ['draft', 'rejected']"/>

<button name="action_submit"
        type="object"
        invisible="state != 'draft'"/>
```

Không dùng `attrs` và `states` kiểu cũ.

#### Domain

Domain là biểu thức lọc:

```python
[("employee_id.user_id", "=", user.id)]
```

Domain xuất hiện ở:

- Search/filter.
- Record rule.
- Field relation.
- Python `search`.

Cùng cú pháp cơ bản nhưng mục đích bảo mật chỉ thuộc record rule/backend, không
thuộc search filter trên UI.

#### Action và menu

`ir.actions.act_window` xác định:

- Model cần mở.
- Các view mode.
- Domain/context ban đầu.

Menu chỉ là điểm điều hướng đến action.

#### OWL và frontend extension

Frontend Odoo 17 dùng:

- ES module với `/** @odoo-module **/`.
- OWL components.
- Services như `orm`, `action`, `notification`.
- Registry để đăng ký view/component.
- Asset bundle trong manifest.

Không dùng `ListController.include` kiểu project cũ.

### 9.2. Form view mục tiêu

- Header:
  - Submit.
  - PM Approve.
  - DL Approve.
  - Reject.
  - Reset to Draft.
  - Statusbar.
- Sheet:
  - Request metadata.
  - Employee, project, PM, DL.
  - Tổng giờ.
  - One2many line editable khi Draft/Rejected.
- Chatter:
  - Followers nếu cần.
  - Lịch sử tracked fields.

### 9.3. List và search mục tiêu

List:

- Request code.
- Employee.
- Project.
- PM.
- DL.
- Request date.
- Total hours.
- State.
- Tô màu đỏ khi tổng giờ lớn hơn 8.

Search:

- Search theo code, employee và project.
- Filter “Đơn của tôi”.
- Pending PM.
- Pending DL.
- Approved.
- Rejected.
- Group by project, employee, PM, DL, state và tháng OT.

### 9.4. Nút tạo OT nhanh

Triển khai sau khi form/list chuẩn đã chạy.

Luồng đề xuất:

1. User nhấn “Tạo OT nhanh”.
2. Mở wizard chọn project nếu cần.
3. Backend xác định employee hiện tại.
4. Tạo một request Draft.
5. Tạo một line hợp lệ.
6. Mở form của request vừa tạo.

Không dùng:

- Project đầu tiên trong toàn database.
- Employee đầu tiên nếu current user không có employee.
- `wfh_bz=False` khi field required.
- Giờ random có thể rơi ngoài category.

Nếu mục tiêu bài tập bắt buộc random:

- Chọn một ngày trong ba ngày lịch hợp lệ.
- Chọn một khoảng từ danh sách preset hợp lệ.
- Chọn `wfh` hoặc `bz`.
- Vẫn chạy toàn bộ constraint sau khi tạo.

### 9.5. Test cần viết

- XML view load được khi install/upgrade.
- Decoration dùng đúng field.
- Button chỉ xuất hiện cho đúng model/group.
- Wizard không cho tạo nếu user không có employee.
- Request và line được tạo theo quan hệ 1–n.
- Action trả về form của request mới.
- Có thể dùng `HttpCase` cho luồng JavaScript quan trọng.

### 9.6. Bài thực hành

1. Tạo filter “Đơn của tôi”.
2. Tạo group by trạng thái.
3. Chuyển một modifier từ cú pháp cũ sang Odoo 17.
4. Dùng service `orm` để gọi backend.
5. Dùng service `action` để mở form request vừa tạo.

### 9.7. Câu hỏi tự kiểm tra

- Search domain và record rule khác nhau thế nào?
- Vì sao readonly trên form không phải bảo mật?
- Asset JS/XML được Odoo 17 nạp từ đâu?
- Vì sao patch toàn bộ `ListController` có thể ảnh hưởng model khác?

### 9.8. Definition of Done

- Form/list/search hoạt động không lỗi console.
- Button đúng state và đúng group.
- Tổng giờ lớn hơn 8 được decoration.
- Nút tạo nhanh luôn tạo dữ liệu hợp lệ.
- Không patch frontend toàn cục ngoài phạm vi cần thiết.

Tài liệu:

- [View Architectures](https://www.odoo.com/documentation/17.0/developer/reference/user_interface/view_architectures.html)
- [Assets](https://www.odoo.com/documentation/17.0/developer/reference/frontend/assets.html)
- [JavaScript Reference](https://www.odoo.com/documentation/17.0/developer/reference/frontend/javascript_reference.html)

---

## 10. Chặng 6 — Email, chatter và lịch sử thay đổi

Thời lượng: tuần 6.

### 10.1. Concept cần học

#### `mail.thread`

Khi model inherit `mail.thread`, model có thể:

- Có chatter.
- Theo dõi thay đổi field.
- Quản lý followers.
- Post message.

Field muốn theo dõi dùng:

```python
state = fields.Selection(..., tracking=True)
```

#### Mail template

Mail template tách nội dung email khỏi Python:

- Subject.
- To.
- CC.
- Body HTML.
- Dynamic placeholders.

Odoo 17 dùng dynamic placeholder/QWeb, không dùng `${...}` như code mẫu cũ.

#### Mail queue

Gửi email qua queue giúp:

- Không giữ request HTTP chờ SMTP quá lâu.
- Có thể retry.
- Nghiệp vụ không nhất thiết rollback khi SMTP tạm lỗi.

#### Chatter và email log

Yêu cầu nói không ghi body email vào chatter. Cần phân biệt:

- Lịch sử thay đổi nghiệp vụ cần nằm trong chatter.
- Nội dung đầy đủ của email không được hiển thị như comment.
- Không nên mở rộng `mail.message` toàn hệ thống nếu chỉ module này cần hành vi
  riêng.

### 10.2. Ma trận email

| Sự kiện | To | CC | Nội dung chính |
| --- | --- | --- | --- |
| Submit | PM | Employee | Request mới cần PM xử lý |
| PM Approve | DL | Employee | Request cần DL xử lý |
| PM Reject | Người xử lý phù hợp | Employee | Lý do từ chối và link |
| DL Approve | Employee | Theo chính sách | Kết quả Approved |
| DL Reject | Người xử lý phù hợp | Employee | Lý do từ chối và link |

Trong giai đoạn triển khai cần preview từng template để bảo đảm To/CC không bị
trùng hoặc rỗng.

### 10.3. Hành động trong email

Email PM/DL có thể hiển thị:

- “Review / Approve”.
- “Review / Reject”.

Hai nút:

- Mở request sau khi đăng nhập.
- Không gọi trực tiếp method thay đổi state bằng GET.
- Người dùng bấm Approve hoặc Reject trên form.
- Reject mở wizard nhập lý do.

### 10.4. Lịch sử phải lưu

Theo requirements:

- State.
- Thời gian OT.
- PM.
- DL.

Cách triển khai:

- `tracking=True` cho state, PM và DL trên request.
- Line không nhất thiết inherit `mail.thread`.
- Khi `from_date` hoặc `to_date` của line thay đổi, post một message ngắn lên
  request:

```text
OT time changed: 18:30–20:30 → 18:30–21:00
```

- Không post toàn bộ body email.

### 10.5. Phần cần làm

- Viết lại template submit/approve/reject theo Odoo 17.
- Tạo helper tạo deep link đến request.
- Kiểm tra email thiếu người nhận trước Submit/Approve.
- Lưu rejection reason vào record để email render ổn định.
- Kiểm tra mail queue.
- Kiểm tra `mail.message` sinh ra sau gửi mail.
- Chọn giải pháp không hiển thị body email trong chatter mà không ảnh hưởng
  model khác.

### 10.6. Test cần viết

- Template render không còn placeholder thô.
- Submit gửi đúng PM và CC employee.
- PM Approve gửi đúng DL và CC employee.
- Reject chứa đúng rejection reason.
- Link chứa đúng model và record.
- User ngoài phạm vi không mở được record dù có URL.
- Body email không xuất hiện trong chatter.
- State/time/PM/DL có lịch sử.

### 10.7. Bài thực hành

1. Preview template từ giao diện Technical.
2. Render cùng template với hai request khác nhau.
3. Tạm cấu hình SMTP sai và quan sát mail queue.
4. Kiểm tra record `mail.mail` và `mail.message`.
5. Thay đổi thời gian một line và kiểm tra log trên request.

### 10.8. Câu hỏi tự kiểm tra

- `mail.thread` cung cấp những gì?
- Vì sao không nên đổi state trực tiếp bằng link GET?
- Mail queue giúp gì cho transaction nghiệp vụ?
- Vì sao mở rộng `mail.message` toàn cục có rủi ro?

### 10.9. Definition of Done

- Tất cả template render đúng.
- To/CC đúng từng bước.
- Link bắt buộc đăng nhập và tôn trọng record rules.
- Reject email có lý do.
- Chatter có lịch sử nghiệp vụ nhưng không có body email.

Tài liệu:

- [Email Templates](https://www.odoo.com/documentation/17.0/applications/general/companies/email_template.html)
- [Mixins and mail.thread](https://www.odoo.com/documentation/17.0/developer/reference/backend/mixins.html)

---

## 11. Chặng 7 — Test, migration và release

Thời lượng: tuần 7.

### 11.1. Concept cần học

#### Test pyramid

Ưu tiên:

1. Unit/model tests: logic nhỏ, chạy nhanh.
2. Integration tests: workflow, security, email.
3. UI tests: chỉ cho luồng frontend quan trọng.

#### `TransactionCase`

Phù hợp với:

- Model create/write.
- Compute/constraint.
- Workflow.
- Record rules với `with_user`.

#### `HttpCase`

Phù hợp với:

- JavaScript.
- Browser flow.
- Custom list controller/button.

#### Migration

Migration là thay đổi có kiểm soát khi version module tăng:

- Thêm/đổi field.
- Backfill dữ liệu.
- Chuyển format.
- Đảm bảo chạy lại không làm hỏng dữ liệu.

Migration trong project này là migration giữa các version Odoo 17 của module,
không phải migration database từ Odoo 12.

#### Idempotency

Migration idempotent có thể chạy lại mà không:

- Nhân đôi dữ liệu.
- Ghi đè dữ liệu đã đúng.
- Làm format bị lặp.

### 11.2. Kế hoạch version

Ví dụ:

```text
17.0.1.0.0  Module nghiệp vụ cơ bản
17.0.1.1.0  Thêm employee_custom_name và migration backfill
17.0.1.2.0  Hoàn thiện email/audit nếu cần
```

Khi thêm `employee_custom_name`, migration cần đồng bộ:

```text
Tên nhân viên - Phòng ban
```

Yêu cầu migration:

- Chỉ cập nhật record cần thiết.
- Xử lý employee không có department.
- Có log số record đã cập nhật.
- Chạy được trên bản sao database test.
- Dùng đúng convention migration của dự án/Odoo đang chạy.

### 11.3. Cấu trúc test đề xuất

```text
ot_registration/
└── tests/
    ├── __init__.py
    ├── common.py
    ├── test_ot_category.py
    ├── test_ot_request.py
    ├── test_ot_workflow.py
    ├── test_ot_security.py
    ├── test_ot_mail.py
    └── test_ot_migration.py
```

### 11.4. Bộ test tối thiểu trước UAT

- Module install test.
- Model relation test.
- Category boundary test.
- Timezone test.
- Two-calendar-day test.
- Overlap test.
- Total hours test.
- Workflow transition test.
- Reject/resubmit test.
- Employee/PM/DL security test.
- Mail recipient/render test.
- Chatter history test.
- Migration test.
- Custom list button test nếu có JavaScript.

### 11.5. UAT scenarios

#### Scenario 1 — Approve thành công

1. Employee tạo request.
2. Thêm các line hợp lệ.
3. Submit.
4. PM nhận email và approve.
5. DL nhận email và approve.
6. Employee thấy Approved và lịch sử đầy đủ.

#### Scenario 2 — PM Reject

1. Employee Submit.
2. PM mở Reject wizard.
3. Nhập lý do.
4. Employee nhận email.
5. Employee Reset to Draft, sửa và Submit lại.

#### Scenario 3 — DL Reject

1. PM Approve.
2. DL Reject với lý do.
3. Employee nhận đúng email.
4. Request không bị PM/DL chỉnh sửa nội dung ngoài workflow.

#### Scenario 4 — Security

1. Employee A thử mở URL request Employee B.
2. PM A thử mở request Project B.
3. DL A thử mở request Department B.
4. Tất cả đều nhận Access Error hoặc không tìm thấy record.

### 11.6. Release checklist

- [ ] Cài mới trên database rỗng thành công.
- [ ] Upgrade trên database có dữ liệu thành công.
- [ ] Không còn `@api.multi`.
- [ ] Không còn `track_visibility`.
- [ ] Không còn `attrs`/`states` kiểu cũ.
- [ ] Assets khai báo trong manifest.
- [ ] Không còn mail placeholder `${...}`.
- [ ] Không có `__pycache__` trong source control.
- [ ] Test tự động chạy xanh.
- [ ] Không có lỗi browser console.
- [ ] Security negative tests chạy xanh.
- [ ] Email preview đúng To/CC/link.
- [ ] Migration chạy trên bản sao database.
- [ ] README có hướng dẫn install, update và test.
- [ ] UAT được xác nhận.

### 11.7. Câu hỏi tự kiểm tra

- Vì sao test security phải có cả trường hợp được phép và không được phép?
- `TransactionCase` và `HttpCase` khác nhau thế nào?
- Migration idempotent nghĩa là gì?
- Vì sao phải test cả install mới và upgrade?

### 11.8. Definition of Done

- Test tự động chạy xanh.
- Cài mới và upgrade đều thành công.
- UAT hoàn tất với ba vai trò.
- README đủ để một developer khác chạy module.

Tài liệu:

- [Testing Odoo](https://www.odoo.com/documentation/17.0/developer/reference/backend/testing.html)
- [Odoo CLI and test tags](https://www.odoo.com/documentation/17.0/developer/reference/cli.html)

---

## 12. Thứ tự commit đề xuất

Mỗi commit chỉ nên giải quyết một chủ đề:

```text
[PORT] ot_registration: initialize Odoo 17 module
[MODEL] ot_registration: define request and line models
[COMPUTE] ot_registration: compute approvers and total hours
[VALIDATION] ot_registration: validate OT periods and categories
[WORKFLOW] ot_registration: implement approval transitions
[WIZARD] ot_registration: add rejection reason flow
[SEC] ot_registration: add role based access rules
[VIEW] ot_registration: add Odoo 17 form and search views
[WEB] ot_registration: add quick-create list action
[MAIL] ot_registration: add approval email templates
[TRACK] ot_registration: track approval and time changes
[MIG] ot_registration: backfill employee display name
[TEST] ot_registration: cover workflow and security
[DOC] ot_registration: document setup and UAT
```

## 13. Mẫu learning log

Sau mỗi buổi, ghi lại:

```markdown
## Ngày YYYY-MM-DD

### Concept đã học

- ...

### Phần đã triển khai

- ...

### Test đã chạy

- ...

### Điều chưa hiểu

- ...

### Lỗi gặp phải và nguyên nhân

- ...

### Việc tiếp theo

- ...
```

Không chỉ ghi “đã sửa được”; cần ghi nguyên nhân lỗi và vì sao cách sửa phù hợp
với Odoo.

## 14. Mốc đánh giá năng lực

### Sau chặng 2

Có thể:

- Tự tạo model và relations.
- Phân biệt compute/onchange/constraint.
- Xử lý timezone và validation cơ bản.
- Viết model test.

### Sau chặng 4

Có thể:

- Thiết kế workflow.
- Viết wizard.
- Thiết kế ACL/record rule.
- Bảo vệ public method khỏi lời gọi trái phép.

### Sau chặng 6

Có thể:

- Xây form/list/search view Odoo 17.
- Mở rộng frontend bằng OWL ở mức cơ bản.
- Dùng mail template và chatter đúng mục đích.

### Sau chặng 7

Có thể:

- Hoàn thiện một module business từ đặc tả.
- Viết test nghiệp vụ và security.
- Viết migration.
- Chuẩn bị module cho UAT và bàn giao.

## 15. Điểm bắt đầu đề xuất

Buổi đầu tiên nên hoàn thành đúng ba việc:

1. Chạy Odoo 17 Community với một database test mới.
2. Ghi lại kết quả cài module mẫu hiện tại.
3. Chuẩn hóa skeleton để module Odoo 17 cài và upgrade thành công.

Chưa triển khai email, JavaScript hoặc workflow phức tạp trước khi đạt được
baseline này.
