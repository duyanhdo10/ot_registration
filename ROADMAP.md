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

## 2. Decision log

Roadmap phân biệt rõ quyết định đã được xác nhận và đề xuất kỹ thuật còn chờ
nghiệp vụ xác nhận. Không triển khai một mục `Pending` như thể đó là yêu cầu đã
được chốt.

### 2.1. Quyết định đã xác nhận

| ID | Quyết định | Người xác nhận | Ngày xác nhận |
| --- | --- | --- | --- |
| D01 | Dùng Odoo 17 Community, chạy local với database test riêng | Chủ dự án | 2026-07-30 |
| D02 | Code Odoo cũ chỉ để tham khảo; không nâng cấp database thật từ Odoo 12 | Chủ dự án | 2026-07-30 |
| D03 | Hạn Submit là hai ngày lịch, tính theo timezone của user thực hiện Submit | Chủ dự án | 2026-07-30 |
| D04 | Email không đổi state bằng HTTP GET; user phải đăng nhập và xác nhận trong Odoo | Chủ dự án | 2026-07-30 |

Chi tiết D03:

- OT ngày 28/07 có thể Submit đến hết ngày 30/07.
- Từ ngày 31/07 bị xem là quá hạn.
- Không cho Submit line có ngày OT trong tương lai.
- Kiểm tra từng line trong request, không dùng ngày gần nhất hoặc xa nhất đại
  diện cho toàn request.

### 2.2. Đề xuất cần xác nhận trước khi triển khai

| ID | Đề xuất hiện tại | Nguồn | Trạng thái |
| --- | --- | --- | --- |
| P01 | PM lấy từ `project.project.user_id`; DL lấy từ `employee.parent_id` | Legacy code | Pending |
| P02 | Snapshot PM/DL khi Submit; không recompute người duyệt sau Submit | Đề xuất kỹ thuật | Pending |
| P03 | Nút tạo nhanh tạo một request và một line; dùng wizard chọn project | Legacy code + đề xuất UX | Pending |
| P04 | Không auto-approve khi employee, PM và DL trùng nhau; thiếu người duyệt độc lập thì báo cấu hình | Đề xuất bảo mật | Pending |
| P05 | Không hỗ trợ ngày thường 06:00–09:00; một line chỉ thuộc một category | Suy ra từ requirements | Pending |
| P06 | DL mặc định chỉ thấy từ `to_approve_dl`; mở rộng để thấy `to_approve_pm` chỉ khi nghiệp vụ xác nhận | Nguyên tắc tối thiểu quyền | Pending |
| P07 | Khi employee là người nhận chính của email thì đặt ở To và không lặp lại trong CC | Đề xuất tránh gửi trùng | Pending |
| P08 | “Tổng OT lớn hơn 8 giờ” dùng tổng thời lượng đăng ký; actual hours là optional backlog | Suy ra từ chức năng đăng ký | Pending |
| P09 | Category dùng `category_timezone` snapshot trên request, lấy từ cấu hình công ty; không dùng timezone của actor hiện tại | Đề xuất tính quyết định | Pending |
| P10 | Reassign và custom OT Admin group | Không có trong requirements | Deferred, ngoài MVP |
| P11 | Cắt bỏ giây/microsecond trên mỗi timestamp; không làm tròn phút. Category, duration, overlap và decoration `> 8` giờ dùng giá trị đã chuẩn hóa | Đề xuất an toàn khi requirements chưa có quy tắc làm tròn | Pending |
| P12 | Trong cùng request chặn overlap khi lưu; giữa các request cho phép Draft trùng và kiểm tra khi Submit, bỏ qua Draft/Rejected | Đề xuất kỹ thuật; requirements chưa quy định overlap | Pending |

Khi một đề xuất được xác nhận:

1. Chuyển dòng tương ứng sang bảng “Quyết định đã xác nhận”.
2. Ghi người xác nhận và ngày xác nhận.
3. Cập nhật test/acceptance criteria bị ảnh hưởng.
4. Nếu quyết định thay đổi, ghi thêm dòng mới thay vì xóa lịch sử quyết định cũ.

### 2.3. Decision gate theo chặng

Không bắt đầu code một chặng nếu decision bắt buộc của chặng đó còn Pending:

| Trước khi bắt đầu | Decision phải đóng |
| --- | --- |
| Chặng 1 | P01, P02, P08, P09 |
| Chặng 2 | P05, P09, P11, P12 |
| Chặng 3 | P04; P10 chỉ cần mở lại nếu đưa Reassign vào scope |
| Chặng 4 | P06 |
| Chặng 5 | P03 |
| Chặng 6 | P07 |

Nếu decision chưa đóng, chỉ được làm spike/đọc tài liệu; không tính chặng đó đạt
Definition of Done.

### 2.4. Quy tắc kỹ thuật không phụ thuộc nghiệp vụ

- PM hoặc DL không được chỉnh trực tiếp nội dung đăng ký sau Submit; họ chỉ
  thực hiện action duyệt hoặc từ chối được kiểm soát.
- Reject luôn đi qua wizard nhập lý do.
- Dữ liệu do nút tạo nhanh sinh ra phải thỏa mãn toàn bộ constraint.
- Khi thiếu approver hoặc tài khoản đăng nhập, Submit phải dừng với thông báo
  cấu hình rõ ràng. Email chỉ được kiểm tra khi adapter mail ở chặng 6 được bật;
  thiếu email không làm rollback state đã ghi mà phải tạo lỗi cấu hình có thể xử lý.

## 3. Bản đồ kiến thức

| Chặng | Concept chính | Sản phẩm đầu ra |
| --- | --- | --- |
| 0 | Kiến trúc Odoo, module lifecycle, XML ID | Module tối thiểu cài được |
| 1 | ORM, model, fields, recordset, relations | Data model hoàn chỉnh |
| 2 | Compute, onchange, constraints, timezone | Logic tính OT đúng và có test |
| 3 | State machine, snapshot approver, notification port | Luồng duyệt độc lập với email |
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
- Lưu code tham khảo ở ngoài thư mục addon đích hoặc trong một bản archive local.
- Khi bắt đầu code thật, bỏ rule `/ot_registration/` khỏi `.gitignore` rồi tạo
  lại `ot_registration/` như một addon Odoo 17 sạch được Git theo dõi.
- Không sao chép manifest version `12.0.1.0.0` hoặc thư mục
  `migrations/12.0.1.0.0` vào addon mới; xóa/thay thế chúng nếu khởi tạo từ bản
  tham khảo.
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
- Addon đích được Git theo dõi và không còn manifest/migration mang version
  `12.0.1.0.0`.

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

### 5.2. Data model mục tiêu và nguồn yêu cầu

Chỉ các field MVP mới được triển khai ở `17.0.1.0.0`. Field lấy riêng từ legacy
code phải có use case được xác nhận trước khi đưa vào model chính.

#### `ot.category`

| Field | Nguồn | Phạm vi |
| --- | --- | --- |
| `name` | Requirements mục 6 | MVP |
| `code` | Nhu cầu kỹ thuật, tránh phụ thuộc label | MVP |
| `sequence` | UX sắp xếp | Optional |

Danh mục MVP:

- Normal Day.
- Normal Day – Night.
- Saturday.
- Sunday.
- Weekend – Night.

#### `ot.request` trong `17.0.1.0.0`

| Field | Nguồn | Quyết định |
| --- | --- | --- |
| `name` | Kỹ thuật CRUD/sequence | MVP |
| `state` | Requirements mục 3 | MVP |
| `project_id` | Requirements mục 2–5 | MVP |
| `employee_id` | Requirements mục 2–5 | MVP |
| `pm_id` | Vai trò PM + legacy mapping | Snapshot field; mapping P01 còn Pending |
| `dl_id` | Vai trò DL + legacy mapping | Snapshot field; mapping P01 còn Pending |
| `request_date` | Audit kỹ thuật | MVP |
| `category_timezone` | P09 | Readonly snapshot; nguồn cấu hình công ty còn Pending |
| `total_hours` | Requirements mục 7 | Tổng thời lượng đăng ký theo P08; Pending |
| `line_ids` | Requirements mục 6–7 | MVP |
| `rejection_reason`, `rejected_by_id`, `rejected_at` | Requirements mục 3 | Bổ sung ở chặng 3 |
| `pm_approved_by_id`, `pm_approved_at`, `dl_approved_by_id`, `dl_approved_at` | Audit người thực sự duyệt | Bổ sung ở chặng 3 |

`total_hours` tạm được hiểu là tổng `duration_hours` đã đăng ký. Không tạo cặp
registration/actual cho đến khi có use case xác nhận thời điểm và actor nhập giờ
thực tế.

#### Field chỉ được thêm ở `17.0.1.1.0`

| Field | Nguồn | Mục đích |
| --- | --- | --- |
| `employee_custom_name` | Requirements mục 9 | System-owned, readonly, computed stored; `<Tên nhân viên> - <Phòng ban>` |

#### `ot.request.line` trong MVP

| Field | Nguồn | Phạm vi |
| --- | --- | --- |
| `request_id` | Quan hệ request/line | MVP |
| `from_date` | Requirements mục 6, 8, 9 | MVP |
| `to_date` | Requirements mục 6, 8, 9 | MVP |
| `category_id` | Requirements mục 6 | System-owned, readonly, computed stored; `False` nếu khoảng không hợp lệ |
| `duration_hours` | Requirements mục 7 | Computed từ thời gian |

#### Field legacy để ở optional backlog

| Field | Nguồn hiện tại | Điều kiện đưa vào MVP |
| --- | --- | --- |
| `ot_month` | Legacy code | Chỉ thêm nếu không thể group theo ngày OT |
| `ot_registration_hours`, `actual_ot_hours` | Legacy code | Cần use case phân biệt đăng ký/thực tế |
| `wfh_bz` | Legacy code | Cần định nghĩa WFH/BZ và ảnh hưởng nghiệp vụ |
| `reason` | Legacy code | Cần xác nhận bắt buộc/optional và người dùng |
| `evidences` | Legacy code | Cần quy định loại file, dung lượng và quyền xem |
| `deadline_date`, `late_approved` | Legacy code | Không thuộc hạn Submit hai ngày trong requirements |

Không dùng field optional trong view, security, email hoặc test trước khi decision
log chuyển chúng sang trạng thái Confirmed.

### 5.3. Phần cần làm

Các bước liên quan approver chỉ được code sau khi P01 và P02 được xác nhận. Khi
còn Pending, chỉ thiết kế interface/helper và test fixture, không chốt record rule
hoặc behavior production.

- Thiết kế model MVP theo chuẩn Odoo 17.
- Dùng `@api.model_create_multi` cho `create` nếu cần override sinh sequence.
- Viết helper đề xuất PM/DL từ project/employee; không khai báo `pm_id`, `dl_id`
  là computed field tự động chạy mãi theo dữ liệu nguồn.
- Khi request còn Draft, làm mới PM/DL khi project hoặc employee thay đổi.
- Khi Submit, đọc lại nguồn một lần và ghi PM/DL thành snapshot.
- Sau Submit, không recompute PM/DL khi manager nguồn thay đổi.
- Khi tạo request, snapshot `category_timezone` từ cấu hình công ty đã xác nhận;
  không lấy timezone từ `env.user`, context import hoặc PM/DL đang mở record.
- Compute `total_hours` từ `line_ids.duration_hours`.
- Gắn mỗi field với nguồn requirement/decision log.
- Không dùng `force_save` để bù cho một thiết kế field không rõ ràng.

### 5.4. Bài thực hành

1. Tạo request bằng form.
2. Tạo request bằng Odoo shell.
3. Tạo hai line bằng `Command.create`.
4. Thay đổi project khi Draft và quan sát approver đề xuất thay đổi.
5. Submit để snapshot PM/DL.
6. Thay đổi manager nguồn sau Submit.
7. Kiểm tra PM/DL trên request không đổi sau bước 6.
8. Chưa thêm `employee_custom_name`; dành field này cho bài upgrade chặng 7.

### 5.5. Test cần viết

- Sequence được sinh cho từng request.
- Copy request không dùng lại sequence.
- Approver đề xuất đúng mapping đã được xác nhận.
- Approver cập nhật khi request còn Draft.
- Snapshot PM/DL không đổi sau Submit dù dữ liệu nguồn thay đổi.
- `category_timezone` không đổi khi actor/context timezone thay đổi.
- `total_hours` bằng tổng duration của các line.
- Schema `17.0.1.0.0` chưa có `employee_custom_name`.

### 5.6. Câu hỏi tự kiểm tra

- Khi nào dùng related field, computed field và snapshot field?
- Vì sao approver động làm record rule và lịch sử phê duyệt không ổn định?
- `store=True` ảnh hưởng search và performance như thế nào?
- Vì sao `self.ensure_one()` không nên dùng trong mọi method?
- Field nào thực sự đến từ requirements và field nào chỉ đến từ legacy code?

### 5.7. Definition of Done

- Data model MVP cài mới được ở version `17.0.1.0.0`.
- Quan hệ request/line hoạt động đúng.
- PM/DL trở thành snapshot ổn định sau Submit.
- Không có field optional chưa được xác nhận trong schema MVP.
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

- Preview timestamp đã được cắt giây/microsecond theo P11; backend vẫn là nguồn chuẩn.
- Gọi cùng helper backend để preview category system-owned.
- Đặt `category_id=False` và hiển thị warning khi khoảng không hợp lệ.

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

Odoo lưu `Datetime` theo UTC. `context_timestamp()` chuyển theo timezone trong
context/user nên không được dùng trực tiếp để quyết định category nghiệp vụ.

Roadmap tách hai khái niệm:

- Deadline D03: lấy ngày local theo timezone của user thực hiện action Submit và
  dùng cùng timezone đó cho tất cả line trong lần Submit.
- Category P09: chuyển UTC bằng `category_timezone` readonly đã snapshot trên
  request từ cấu hình công ty. Kết quả không phụ thuộc employee, admin/import,
  PM, DL hoặc context `tz` của actor hiện tại.
- So sánh overlap/timestamp tuyệt đối bằng UTC.
- Phân loại thứ/ngày/giờ bằng local time theo snapshot P09.

Nếu cấu hình timezone công ty thay đổi, request cũ giữ snapshot cũ; request mới
nhận giá trị mới. Không cho sửa timezone sau khi request có line hoặc đã Submit.

#### Độ chính xác thời gian và làm tròn (P11)

Nếu không có quy tắc nghiệp vụ khác, baseline an toàn là:

- Cắt mỗi `from_date` và `to_date` xuống đầu phút bằng cách đặt `second=0` và
  `microsecond=0`; không làm tròn lên hoặc về phút gần nhất.
- Chuẩn hóa timestamp ở backend trước khi lưu; onchange chỉ preview cùng kết quả.
- Category, duration, deadline và overlap đều dùng timestamp đã chuẩn hóa.
- `duration_hours` là hiệu hai timestamp đã chuẩn hóa; không làm tròn duration
  lần hai theo bước 15 hoặc 30 phút.
- `total_hours` cộng các duration đã chuẩn hóa. Decoration dùng điều kiện nghiêm
  ngặt `total_hours > 8.0`; đúng 8 giờ không đổi màu, 8 giờ 01 phút thì đổi màu.

Không triển khai baseline này trước khi P11 được xác nhận.

#### Khoảng nửa mở

Nên xem khoảng OT là `[from_date, to_date)`:

- Bao gồm thời điểm bắt đầu.
- Không bao gồm thời điểm kết thúc.
- Hai line `18:30–20:00` và `20:00–22:00` không bị xem là trùng.

### 6.2. Bảng phân loại đề xuất (chờ xác nhận P05)

Không code category ngoài bảng requirements hoặc quy tắc tách line cho đến khi P05
được xác nhận. Sau khi xác nhận, bảng dưới đây trở thành acceptance criteria.

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
- Tách logic xác định category thành một helper thuần nhận UTC interval và
  `category_timezone`; không đọc timezone từ current user/context.
- `category_id` do backend tính, readonly trên UI và không cho RPC/import gán tay.
- Không tạo category master tên Unknown; interval không hợp lệ trả về `False`.
- Onchange, compute, constraint và Submit gọi chung helper phân loại.
- Sau khi P11 được xác nhận, override create/write bằng helper backend chung để
  chuẩn hóa timestamp; không dựa vào onchange.
- Constraint `to_date > from_date`.
- Constraint line phải nằm trong một category hợp lệ.
- Theo P12, chặn overlap giữa các line trong cùng request ngay khi create/write.
- Không chặn create/write khi hai request Draft trùng nhau. Khi Submit, kiểm tra
  overlap với request cùng employee đã rời Draft và chưa Rejected, tức các state
  `to_approve_pm`, `to_approve_dl`, `approved`.
- Trước kiểm tra overlap khi Submit, khóa row `hr.employee` tương ứng bằng
  `SELECT ... FOR UPDATE`; sau khi lấy khóa phải chạy lại search/check. Cách này
  tuần tự hóa hai request cùng employee Submit gần như đồng thời.
- Kiểm tra hạn hai ngày lịch trên từng line khi Submit.
- Chặn Submit nếu bất kỳ line nào quá hạn hoặc có ngày OT trong tương lai.
- Deadline chỉ bảo vệ transition Draft → Submitted; PM/DL vẫn có thể duyệt hoặc
  từ chối sau thời hạn. `late_approved` không thuộc MVP.

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

#### Precision và ngưỡng tám giờ

- `18:30:59.999999–20:00:01` được lưu thành `18:30:00–20:00:00`.
- Không làm tròn `18:31` thành `18:30`, `18:45` hoặc `19:00`.
- Tổng đúng `8:00` giờ: không decoration; tổng `8:01` giờ: có decoration.
- Category, duration và overlap nhận cùng timestamp đã chuẩn hóa.

#### Trùng thời gian

- Hai line cùng request chạm biên nhưng không giao nhau: valid khi lưu.
- Hai line cùng request giao nhau một phút: create/write invalid.
- Hai request Draft cùng employee có thể lưu interval trùng nhau.
- Sau khi request thứ nhất Submit, request Draft còn lại không Submit được nếu
  vẫn trùng.
- Request Rejected không tham gia kiểm tra overlap.
- Hai cursor/transaction cùng Submit hai request trùng của một employee: đúng một
  request thành công; request còn lại kiểm tra lại sau khi lấy employee lock và bị chặn.

#### Hạn đăng ký

Với ngày hiện tại 30/07:

- OT ngày 30/07: valid.
- OT ngày 29/07: valid.
- OT ngày 28/07: valid.
- OT ngày 27/07: quá hạn.
- OT ngày 31/07: tương lai.

### 6.5. Bài thực hành

1. Viết helper nhận khoảng UTC và `category_timezone`, trả về local interval.
2. Chạy cùng request/timestamp dưới employee, admin và hai context `tz` khác nhau;
   category phải giống nhau.
3. Tạo hai request có snapshot timezone khác nhau để chứng minh category chỉ đổi
   khi snapshot khác, không phải khi actor khác.
4. Tạo line bằng form và bằng ORM, so sánh kết quả.
5. Cố tình gán `category_id` bằng RPC/import và chứng minh backend tự tính lại.
6. Cố tình bỏ onchange khi gọi ORM và chứng minh constraint vẫn bảo vệ dữ liệu.
7. Dùng hai cursor riêng Submit đồng thời hai request trùng và quan sát employee
   row lock chỉ cho một request đi tiếp.

### 6.6. Câu hỏi tự kiểm tra

- Vì sao `.date()` trực tiếp trên `fields.Datetime` có thể cho sai ngày?
- Vì sao business rule không được đặt chỉ trong onchange?
- Điều kiện kiểm tra overlap của hai khoảng là gì?
- Vì sao overlap trong request được chặn khi lưu nhưng overlap giữa request chỉ
  được chặn khi Submit?
- Vì sao khóa request chưa đủ để bảo vệ hai request khác nhau của cùng employee?
- Tại sao một line đi qua ranh giới category nên được tách?

### 6.7. Definition of Done

- Tất cả test biên giờ và timezone chạy xanh.
- Import/RPC không thể tạo line sai.
- Chỉ có đúng năm category từ requirements; không có record Unknown.
- Interval invalid có `category_id=False` trên form và không thể persist/Submit.
- Category không đổi theo current user/context timezone.
- Precision và decoration `> 8` giờ tuân theo P11 đã xác nhận.
- Cả overlap nội bộ và concurrent Submit liên request tuân theo P12 đã xác nhận.
- Hạn hai ngày lịch hoạt động theo timezone user thực hiện Submit.

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
- Người gọi đúng PM hoặc DL snapshot trên request.
- PM/DL có user đăng nhập; email chưa phải dependency của workflow core.
- Riêng Submit: mọi line phải nằm trong hạn hai ngày lịch và không ở tương lai.
- PM Approve, DL Approve và Reject không bị chặn bởi hạn Submit.

#### Business method và UI

Button trên view chỉ là cách gọi method. Việc ẩn button không phải bảo mật.
Method phải tự kiểm tra quyền và state.

#### Idempotency

Một action không được tạo side effect lặp lại ngoài ý muốn:

- Không phát hai notification event vì double click.
- Không approve lại request đã approved.
- Không reject request đã rejected.

Kiểm tra state bằng ORM thông thường chưa đủ khi hai transaction cùng đọc state
cũ. Chiến lược MVP:

- Mỗi transition khóa request bằng `SELECT ... FOR UPDATE` theo thứ tự ID ổn định
  trước khi kiểm tra state/guard.
- Sau khi lấy khóa, invalidate cache cần thiết và đọc lại state; chỉ transaction
  đầu tiên được ghi transition và phát notification event.
- State, audit fields và việc ghi nhận notification event nằm trong cùng transaction.
- Riêng Submit còn khóa row employee trước khi kiểm tra overlap P12. Request lock
  bảo vệ một request; employee lock bảo vệ invariant giữa nhiều request của cùng
  employee.

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
  - `rejected_by_id`;
  - `rejected_at`;
  - `pm_approved_by_id`, `pm_approved_at`;
  - `dl_approved_by_id`, `dl_approved_at`.
- Snapshot PM/DL trong transaction Submit và dùng snapshot cho toàn bộ workflow.
- Reassign không thuộc MVP theo P10. Nếu sau này mở scope, thiết kế thành action
  riêng có quyền, lý do, actor/time và tracking; không sửa trực tiếp approver.
- Khi Reset to Draft:
  - giữ lịch sử từ chối và phê duyệt cũ trong chatter/audit;
  - cho phép sửa request/line;
  - làm mới approver đề xuất trước lần Submit kế tiếp.
- Chặng 3 chỉ gọi `_notify_transition(event)` sau khi ghi state thành công. Helper
  này là notification port no-op hoặc được mock trong test, chưa phụ thuộc
  `mail.template`.
- Chặng 6 mới hiện thực `_notify_transition` bằng mail template và mail queue.
- Không dùng auto-approve nếu employee, PM và DL cùng một người.

### 7.3. Thứ tự side effect đề xuất

```text
1. Khóa request theo thứ tự ID; riêng Submit khóa thêm employee.
2. Invalidate cache cần thiết rồi đọc lại state.
3. Kiểm tra quyền, state và dữ liệu trên giá trị mới nhất.
4. Ghi state, snapshot và audit fields.
5. Gọi notification port đúng một lần.
6. Trả về action hoặc client notification.
```

Trong chặng 3, notification port được mock nên workflow test không cần template
email. Sang chặng 6, adapter email đưa mail vào queue qua error boundary riêng;
lỗi notification không được thoát ra làm rollback transition đã ghi, ngoại trừ
lỗi transaction/database mà hệ thống bắt buộc phải retry toàn transaction.

### 7.4. Test cần viết

- Draft hợp lệ Submit thành công.
- Draft không có line không Submit được.
- Submitted không Submit lần hai.
- Sai PM không approve được.
- PM đúng approve sang bước DL và lưu actor/time thực tế.
- PM reject bắt buộc có lý do.
- Sai DL không approve/reject được.
- DL approve chuyển Approved và lưu actor/time thực tế.
- Employee không approve request của mình.
- Thay đổi manager nguồn không đổi approver snapshot.
- Rejected có thể Reset to Draft bởi đúng employee.
- Approved không thể quay Draft.
- Hai lời gọi tuần tự không tạo hai transition hoặc hai notification event.
- Hai cursor/transaction được đồng bộ để cùng đọc state cũ rồi transition: đúng
  một transaction thành công và chỉ có một notification event.
- Hai request trùng của cùng employee Submit đồng thời: đúng một request đi tiếp.

### 7.5. Bài thực hành

1. Vẽ transition table gồm state nguồn, action, actor và state đích.
2. Viết một helper kiểm tra actor.
3. Gọi action bằng Odoo shell dưới user không có quyền.
4. Thử gọi action trực tiếp dù button bị ẩn.
5. Quan sát transaction rollback khi raise `ValidationError`.

### 7.6. Câu hỏi tự kiểm tra

- Vì sao kiểm tra `groups` trong view là chưa đủ?
- Khác nhau giữa `UserError` và `ValidationError` trong trường hợp này?
- Side effect nào nên thực hiện trước, ghi state hay gọi notification port?
- Vì sao kiểm tra state không đủ để chống hai transaction chạy đồng thời?
- Khi nào khóa request, khi nào cần khóa thêm employee?

### 7.7. Definition of Done

- Tất cả transition hợp lệ hoạt động.
- Transition trái phép bị chặn từ backend.
- Reject luôn có lý do.
- Resubmit sau Reject hoạt động.
- Không có action nào chỉ được bảo vệ bằng UI.
- Concurrency test bằng hai cursor chứng minh không có double transition/event.
- Workflow test chạy mà không cần nạp mail template Odoo 12 hoặc Odoo 17.

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

Custom OT Administrator không thuộc MVP theo P10. Category/config kỹ thuật dùng
`base.group_system` hiện có cho đến khi có yêu cầu group riêng.

Không nên gán menu OT cho toàn bộ `base.group_user` nếu mọi internal user không
được phép dùng module.

### 8.3. Ma trận quyền mục tiêu

| Actor | Read | Create | Write | Unlink | Action |
| --- | --- | --- | --- | --- | --- |
| Employee | Request của mình | Có | Draft/Rejected của mình | Draft của mình | Submit, Reset Draft |
| PM | Non-draft có `pm_id` snapshot là mình | Không | Không sửa trực tiếp | Không | PM Approve/Reject |
| DL | Từ `to_approve_dl` có `dl_id` snapshot là mình | Không | Không sửa trực tiếp | Không | DL Approve/Reject |

Phạm vi DL là quyết định P06 đang Pending. Không release record rule DL trước khi
P06 được xác nhận. Trong local spike, baseline tạm dùng tối thiểu quyền: DL không
thấy `to_approve_pm`. Nếu nghiệp vụ xác nhận DL cần theo dõi toàn bộ, mở rộng rule
và thêm test riêng; không suy diễn cụm “đang chờ duyệt” thành quyền rộng mặc định.

### 8.4. Thiết kế bảo mật đề xuất

- Employee có write ACL và record rule cho request Draft/Rejected của chính họ.
- Employee có rule tương ứng cho line.
- PM và DL chủ yếu có read access theo `pm_id`/`dl_id` snapshot, không theo
  manager động trên project/employee.
- Action approve/reject:
  - kiểm tra actor bằng user hiện tại;
  - kiểm tra record thuộc phạm vi snapshot;
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
- Theo baseline P06, DL A không đọc request Department A đang `to_approve_pm`.
- Nếu P06 được xác nhận theo hướng theo dõi toàn bộ, đảo expectation trên bằng
  một test có tên và decision ID rõ ràng.
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
- Group by project, employee, PM, DL và state.
- Bỏ group theo tháng khỏi MVP: request có thể chứa line ở nhiều tháng và
  `ot_month` vẫn là optional backlog. Chỉ thêm lại sau khi có rule một tháng/request
  hoặc định nghĩa aggregation rõ ràng.

### 9.4. Nút tạo OT nhanh

Chỉ triển khai behavior sau khi P03 được xác nhận. Trước đó có thể học OWL bằng
một action thử nghiệm không tạo dữ liệu production. Triển khai sau khi form/list
chuẩn đã chạy.

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
- Field optional từ legacy code chưa được xác nhận.
- Giờ random có thể rơi ngoài category.

Nếu mục tiêu bài tập bắt buộc random:

- Chọn một ngày trong ba ngày lịch hợp lệ.
- Chọn một khoảng từ danh sách preset hợp lệ.
- Chỉ tạo các field MVP; không tự sinh field legacy optional.
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

#### `mail.thread` và `mail.activity.mixin`

`mail.thread` cung cấp chatter, tracking, followers và `message_post()`. Activity
không tự đi kèm với `mail.thread`; request cần inherit cả hai mixin:

```python
_inherit = ["mail.thread", "mail.activity.mixin"]
state = fields.Selection(..., tracking=True)
```

Form request hiển thị `message_follower_ids`, `activity_ids` với widget
`mail_activity`, và `message_ids`. Nhờ đó fallback activity gắn trực tiếp vào
request và xuất hiện đúng trong chatter/activity view.

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
- Có thể retry lỗi SMTP sau khi transaction nghiệp vụ đã commit.

Queue không tự cách ly lỗi render template hoặc lỗi tạo `mail.mail` xảy ra ngay
trong transaction hiện tại; adapter vẫn cần error boundary riêng.

#### Error boundary cho notification

Sau khi workflow đã ghi state:

1. Render template và tạo queue record trong một savepoint riêng.
2. Nếu notification-layer exception xảy ra, rollback savepoint đó, log exception,
   rồi tạo fallback activity trong một savepoint thứ hai.
3. Nếu tạo activity cũng lỗi, rollback riêng activity, log lỗi và vẫn không ném
   lỗi notification ngược ra workflow.
4. Không nuốt lỗi concurrency/transaction-level như deadlock hoặc serialization;
   các lỗi đó phải để toàn transaction retry/rollback đúng cơ chế database.

Như vậy template hỏng hoặc recipient thiếu không để lại mail dở dang và không
rollback state. Lỗi database làm transaction không thể commit nằm ngoài cam kết này.

#### Chatter và email log

Yêu cầu nói không ghi body email vào chatter. Cần phân biệt:

- Lịch sử thay đổi nghiệp vụ cần nằm trong chatter.
- Nội dung đầy đủ của email không được hiển thị như comment.
- Không nên mở rộng `mail.message` toàn hệ thống nếu chỉ module này cần hành vi
  riêng.

### 10.2. Ma trận email có thể code/test

Baseline dưới đây là đề xuất P07, cần được xác nhận trước khi viết template:

| Sự kiện | To | CC | Nội dung chính |
| --- | --- | --- | --- |
| Submit | PM snapshot | Employee | Request mới cần PM xử lý |
| PM Approve | DL snapshot | Employee | Request cần DL xử lý |
| PM Reject | Employee | Trống | Lý do PM từ chối và link |
| DL Approve | Employee | Trống | Kết quả Approved và link |
| DL Reject | Employee | Trống | Lý do DL từ chối và link |

Quy tắc tránh gửi trùng: employee nằm trong CC khi người nhận chính là manager;
khi employee là người nhận chính thì dùng To và để CC trống. Fallback user được
cấu hình theo công ty bằng `res.company.ot_mail_fallback_user_id`; local mặc định
trỏ tới `base.user_admin`. Field chỉ cho chọn internal user đang active và thuộc
công ty phù hợp. Không tạo custom OT Admin group.

Nếu thiếu recipient, adapter không tạo mail rỗng: nó log lỗi và tạo activity trên
request cho fallback user. Toàn bộ render/queue/activity tuân theo error boundary
ở mục 10.1 nên lỗi notification không rollback transition nghiệp vụ.

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

- `ot.request` inherit `mail.thread` và `mail.activity.mixin`; form thêm
  `activity_ids` với widget `mail_activity`.
- `tracking=True` cho state, PM và DL trên request.
- Line không nhất thiết inherit `mail.thread`.
- Khi `from_date` hoặc `to_date` của line thay đổi, post một message ngắn lên
  request:

```text
OT time changed: 18:30–20:30 → 18:30–21:00
```

- Không post toàn bộ body email.

### 10.5. Phần cần làm

- Xác nhận P07 và đóng băng ma trận To/CC trước khi viết assertion/template.
- Viết lại template submit/approve/reject theo Odoo 17.
- Thêm `res.company.ot_mail_fallback_user_id`, default local và validation user.
- Thêm `mail.activity.mixin`, activity fields/widget trên request form.
- Tạo helper tạo deep link đến request.
- Bọc render/template và enqueue trong savepoint; bọc fallback activity bằng
  savepoint độc lập và chỉ bắt notification-layer exception.
- Kiểm tra behavior thiếu người nhận hoặc template lỗi: không có mail dở dang,
  activity gán fallback user khi có thể và state không rollback.
- Lưu rejection reason vào record để email render ổn định.
- Kiểm tra mail queue.
- Kiểm tra `mail.message` sinh ra sau gửi mail.
- Chọn giải pháp không hiển thị body email trong chatter mà không ảnh hưởng
  model khác.

### 10.6. Test cần viết

- Template render không còn placeholder thô.
- Submit gửi đúng PM snapshot và CC employee.
- PM Approve gửi đúng DL snapshot và CC employee.
- PM Reject gửi To employee, CC trống và chứa đúng rejection reason.
- DL Approve gửi To employee, CC trống.
- DL Reject gửi To employee, CC trống và chứa đúng rejection reason.
- Request có activity fields và form view load đúng widget `mail_activity`.
- Thiếu recipient không tạo mail rỗng, activity gán đúng fallback user và state không rollback.
- Template render exception rollback phần mail, tạo fallback activity và không rollback state.
- Giả lập lỗi tạo fallback activity: state vẫn giữ, lỗi được log và không có dữ liệu activity dở dang.
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
- Mail queue giúp gì cho transaction nghiệp vụ và không bảo vệ được lỗi nào?
- Vì sao mail và fallback activity cần hai savepoint độc lập?
- Vì sao không nên nuốt deadlock/serialization error trong adapter?
- Vì sao mở rộng `mail.message` toàn cục có rủi ro?

### 10.9. Definition of Done

- Tất cả template render đúng.
- To/CC đúng từng bước.
- Link bắt buộc đăng nhập và tôn trọng record rules.
- Reject email có lý do.
- Fallback activity hiển thị đúng trên request và theo cấu hình công ty.
- Template/queue notification error không rollback state hoặc để lại mail dở dang.
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

Migration trong project này là upgrade giữa các version Odoo 17 của module,
không phải migration database từ Odoo 12. Odoo chỉ chạy upgrade script khi gọi
update module. Thư mục script phải mang full target version cao hơn version đang
cài và không cao hơn version manifest mới.

Dùng cấu trúc ưu tiên:

```text
ot_registration/
└── upgrades/
    └── 17.0.1.1.0/
        └── post-10-backfill_employee_custom_name.py
```

`migrations/` vẫn hợp lệ trên Odoo 17, nhưng `upgrades/` diễn đạt đúng mục đích
hơn. Không giữ `migrations/12.0.1.0.0` trong addon mới.

#### Idempotency

Migration idempotent có thể chạy lại mà không:

- Nhân đôi dữ liệu.
- Ghi đè dữ liệu đã đúng.
- Làm format bị lặp.

### 11.2. Kịch bản upgrade thật `17.0.1.0.0 → 17.0.1.1.0`

#### Bước A — Cài source version `17.0.1.0.0`

- Manifest là `17.0.1.0.0`.
- Schema chưa có `employee_custom_name`.
- Cài module trên database test mới.
- Tạo nhiều request cũ: có/không có department, tên Unicode và nhiều employee.
- Chụp database hoặc giữ một bản sao để có thể chạy lại rehearsal.

#### Bước B — Chuẩn bị target version `17.0.1.1.0`

- Bump manifest thành `17.0.1.1.0`.
- Thêm `employee_custom_name` là system-owned `compute=...`, `store=True`,
  `readonly=True`, không có inverse; record mới hoặc employee/department thay đổi
  được recompute đúng và user/admin không sửa tay.
- Thêm script:

```text
ot_registration/upgrades/17.0.1.1.0/
└── post-10-backfill_employee_custom_name.py
```

- Script backfill đúng format:

```text
Tên nhân viên - Phòng ban
```

#### Bước C — Chạy và kiểm chứng

- Chạy `-u ot_registration` trên database đang cài `17.0.1.0.0`.
- Xác nhận script chạy đúng một lần trong upgrade path hợp lệ.
- Kiểm tra record cũ được backfill.
- Tạo record mới sau upgrade và kiểm tra giá trị được sinh đúng.
- Chạy update lần nữa và xác nhận dữ liệu không bị nối/lặp.
- Cài mới thẳng `17.0.1.1.0` trên database rỗng; fresh install không phụ thuộc
  upgrade script nhưng record mới vẫn có giá trị đúng.

Yêu cầu script:

- Chỉ cập nhật record cần thiết.
- Xử lý employee không có department.
- Có log số record đã cập nhật.
- Backfill/recompute mọi giá trị thiếu hoặc stale; không có giá trị sửa tay cần bảo toàn.
- Chạy trên bản sao database test và có kịch bản rollback/retry.

### 11.3. Cấu trúc test thường và upgrade test

`TransactionCase` trong `ot_registration/tests/` kiểm tra model ở version đã load;
không dùng nó để chứng minh upgrade path hai version.

```text
ot_registration/
├── tests/
│   ├── __init__.py
│   ├── common.py
│   ├── test_ot_category.py
│   ├── test_ot_request.py
│   ├── test_ot_workflow.py
│   ├── test_ot_security.py
│   └── test_ot_mail.py
└── upgrades/
    ├── 17.0.1.1.0/
    │   └── post-10-backfill_employee_custom_name.py
    └── tests/
        ├── __init__.py
        └── test_employee_custom_name.py
```

`test_employee_custom_name.py` kế thừa `odoo.upgrade.testing.UpgradeCase`:

- `prepare()`: chạy trên source schema, tạo request cũ và trả về ID JSON-serializable.
- Bước giữa: update module để Odoo chạy script `17.0.1.1.0`.
- `check(ids)`: chạy trên target schema, kiểm tra backfill và system-owned field.
- Không dùng `change_version` vì đây là upgrade trong cùng major version 17.

Chạy ba bước trên database rehearsal với `upgrade-util` trong `--upgrade-path`:

```text
1. --test-tags=upgrade.test_prepare
2. -u ot_registration
3. --test-tags=upgrade.test_check
```

Không chạy `UpgradeCase.prepare()` trên database production.

### 11.4. Bộ test tối thiểu trước UAT

- Module install test.
- Model relation test.
- Category boundary test.
- Timezone test.
- Two-calendar-day test.
- Overlap test, gồm hai request Submit đồng thời bằng hai cursor.
- Precision/rounding và ngưỡng decoration `> 8` test.
- Total hours test.
- Workflow transition và concurrent transition test.
- Reject/resubmit test.
- Employee/PM/DL security test.
- Mail recipient/render và notification error-boundary test.
- Activity fallback/configuration test.
- Chatter history test.
- `UpgradeCase` prepare → module update → check từ `17.0.1.0.0` sang `17.0.1.1.0`.
- Fresh install `17.0.1.1.0` và `TransactionCase` cho record mới/recompute.
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
- [Odoo 17 Upgrade Scripts](https://www.odoo.com/documentation/17.0/developer/reference/upgrades/upgrade_scripts.html)
- [Odoo 17 Upgrade Utils and UpgradeCase](https://www.odoo.com/documentation/17.0/developer/reference/upgrades/upgrade_utils.html)

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
