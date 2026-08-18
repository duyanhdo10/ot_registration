# Learning log

## Cách ghi

**Mỗi buổi: bắt buộc 3 dòng.** Mục tiêu là ghi được ngay trong 3–5 phút cuối
buổi, không phải viết báo cáo.

```markdown
## YYYY-MM-DD — Chặng N

- **Hiểu thêm:** ...
- **Mất >15 phút / còn mờ:** ...
- **Tiếp theo:** ...
```

**Chỉ bắt buộc thêm khi có:**

| Có việc gì | Ghi thêm mục nào |
| --- | --- |
| Giao task cho AI | Task brief đã dùng + điểm đã yêu cầu AI sửa lại và lý do |
| Debug một bug thật | Debug note: expected/actual → giả thuyết → breakpoint + giá trị quan sát → root cause → test chống tái phát |
| Kết chặng | Cả hai mục trên + kết quả bài gate khách quan (ROADMAP §3.7) |

Không ghi "đã sửa được". Ghi **nguyên nhân** và **vì sao cách sửa đó đúng với
Odoo**.

---

## 2026-08-18 — Chặng 0

- **Hiểu thêm:**
  - Registry: model chỉ tồn tại với Odoo nếu được import qua `__init__.py`
    (root → `models/__init__.py` → từng file model). Thiếu một bước import thì
    model "biến mất" dù bảng/cột đã có sẵn trong database.
  - `addons_path` chỉ quét **con trực tiếp** của mỗi đường dẫn khai báo. Layout
    theo D08 (repo root chính là addon root, nằm ngay dưới `custom_addons/`)
    khớp đúng yêu cầu này — không cần sửa `odoo.conf`/`compose.yml`.
  - "Container start không lỗi" không phải bằng chứng module được nhận diện —
    phải có hành động chủ động (Update Apps List, hoặc `-i`/`-u`) mới kiểm
    chứng được, vì không ai yêu cầu Odoo đi tìm module thì nó không có gì để
    báo lỗi.
  - Server chạy `workers = 0` là một process Python sống dài hạn; `import`
    chỉ đọc file `.py` từ đĩa **một lần** trong vòng đời process đó
    (`sys.modules` cache). Sửa `.py` rồi bấm Upgrade trên UI của server đang
    chạy sẵn **không** đọc lại file — phải restart process (hoặc dùng
    `docker compose run --rm`, luôn là process mới).
  - Cơ chế `ir.model.data`: mỗi module "sở hữu" record nó khai báo qua
    external ID. Lúc load/upgrade, record nào thuộc module mà không còn được
    "chạm" (không còn khai báo trong code/data hiện tại) bị coi là mồ côi và
    bị xóa.
  - Trong Odoo 17, xóa `ir.model.fields` của một field kéo theo
    `_drop_column()` — **DROP COLUMN thật** trong Postgres, áp dụng cho cả
    field khai báo bằng Python (`state='base'`), không chỉ field tạo qua UI
    (`state='manual'`). Verify trực tiếp bằng cách đọc source
    `odoo/addons/base/models/ir_model.py` trong container, không suy từ trí
    nhớ về bản Odoo cũ.

- **Mất >15 phút / còn mờ:**
    chua restart lai docker nen thong tin file .py chua duoc update

- **Tiếp theo:**
  - Task 3: action/menu/view tối thiểu cho `ot.request` để mở được trên UI.
  - Setup và verify debugger thật (2 mức: attach, breakpoint dừng được) — mục
    còn thiếu duy nhất của DoD Chặng 0, chưa động tới trong buổi này.

- **Task brief đã dùng:** Task 2 (Chặng 0) — model tối thiểu `ot.request` +
  import đúng thứ tự. Scope: `models/__init__.py`, `models/ot_request.py`,
  `__init__.py` root. Điểm đã yêu cầu AI sửa lại: indentation 3→4 space trong
  `ot_request.py` (style, không phải lỗi logic).

- **Debug note:**
  - Expected: sau khi thêm/xóa field trong code và Upgrade, cột trong database
    phải khớp đúng field hiện có.
  - Actual: thêm `temp_note`, Upgrade xong, cột không xuất hiện — không có
    lỗi nào hiện ra.
  - Giả thuyết đã loại: DataGrip cache schema (sai — `psql` trực tiếp cũng
    không thấy cột); bind mount không sync (sai — file trong container khớp
    host); `__pycache__` cũ (sai — không có pycache cho module thật, chỉ có ở
    thư mục legacy lồng bên trong, không liên quan).
  - Root cause thật, hai phần riêng biệt cộng lại:
    1. Database `ot_registration` cũ còn `ir.model`/`ir.model.data` từ một
       lần cài module đầy đủ hơn trước đây. Khi model rút gọn về skeleton,
       cleanup của Odoo xóa `ir.model`/`ir.model.fields` của `ot.request`,
       nhưng đúng lúc đó model **chưa kịp đăng ký vào registry**
       (`is_model=False` trong `_drop_column()`), nên không drop được cột —
       để lại trạng thái "cột tồn tại nhưng ORM không biết field tồn tại".
    2. Sau đó, ngay cả khi đổi sang database sạch (`ot_registration_test`),
       sửa `.py` xong bấm Upgrade trên UI vẫn không thấy đổi — vì server đang
       chạy là process cũ, chưa từng đọc lại file (theo cơ chế `sys.modules`
       ở mục Hiểu thêm).
  - Breakpoint + giá trị quan sát: **chưa dùng debugger thật** ở buổi này —
    chẩn đoán bằng `docker compose logs`, query trực tiếp
    `ir_model`/`ir_model_fields`/`information_schema` qua `psql`, và đọc
    source `ir_model.py` trong container. Đây cũng là lý do debugger vẫn còn
    nằm ở mục Tiếp theo.
  - Test chống tái phát: chưa có — Chặng 0 chưa tới phần viết test tự động.

### Draft đóng buổi — chưa được user xác nhận (D09)

- **Hiểu thêm (draft, user cần tự đọc/sửa/xác nhận):**
  - File XML chỉ được Odoo nạp khi nằm trong danh sách data của
    __manifest__.py. Loader tạo/cập nhật view, action và menu trong database
    qua external ID.
  - ir.ui.view lưu kiến trúc giao diện; ir.actions.act_window mở res_model;
    menu chỉ là điểm điều hướng gọi action.
  - Odoo có thể ẩn menu action ngay từ đầu nếu user không có quyền read trên
    model đích; XML load thành công không đồng nghĩa menu sẽ visible.
  - docker compose down không xóa named volume khi không có -v. Tuy nhiên,
    Compose chọn compose.yml trước docker-compose.yml; hai file khai báo
    volume khác nhau nên up đã tạo một bộ volume rỗng mới.

- **Mất >15 phút / còn mờ (draft):**
  - Cần tự diễn đạt lại ba lớp riêng: XML được load vào database, ACL cho phép
    truy cập model, và logic menu visibility dùng quyền read.
  - Cần nhớ dùng file Compose chuẩn theo docs/SETUP.md, không dựa vào cơ chế
    tự tìm file khi thư mục có cả compose.yml và docker-compose.yml.

- **Tiếp theo (draft):**
  - Duyệt và triển khai Task 3b: ACL tối thiểu cho base.group_system, rồi
    Upgrade trên UI và chạy lại probe visibility.
  - Sau khi menu mở được, setup và verify debugger thật để hoàn tất phần còn
    thiếu của DoD Chặng 0.

- **Task brief đã dùng (draft):** Task 3 (Chặng 0), Decision IDs D01/D07/D08.
  Scope: __manifest__.py, views/ot_request_views.xml; off-limits: model,
  security và workflow. Agent đã thêm list/form view, window action và menu.
  User đã yêu cầu bỏ qua micro-exercise action/menu/view. Không có điểm sửa lại
  code sau review trong task này. Task 3b về ACL mới chỉ là đề xuất, chưa được
  duyệt và chưa triển khai.

- **Debug note — Compose dùng nhầm bộ volume (draft):**
  - Expected: docker compose down && docker compose up -d giữ database cũ.
  - Actual: Postgres của compose.yml chỉ có database postgres; database ứng
    dụng không xuất hiện trên UI.
  - Evidence: thư mục có cả hai Compose file; bộ volume của compose.yml được
    tạo lúc 23:07, còn volume cũ được tạo ngày 01/08. Probe read-only trên bản
    copy volume cũ tìm thấy database odoo17, module ot_registration ở trạng
    thái installed và bảng ot_request.
  - Root cause: trước đây Compose dùng docker-compose.yml; khi compose.yml
    xuất hiện/được ưu tiên, tên và mount target volume đổi nên stack nối vào
    cluster PostgreSQL mới, không phải dữ liệu bị xóa bởi down.
  - Verification sau recovery: DB và Odoo container đều healthy; database
    odoo17 tồn tại; module ot_registration là installed; HTTP login trả 200.
    Hai volume nguồn cũ và hai backup volume vẫn được giữ.
  - Breakpoint: chưa dùng debugger; dữ kiện đến từ Docker metadata, psql và
    probe container trên bản copy read-only.

- **Debug note — menu không visible (draft):**
  - Expected: sau Upgrade, menu OT Registration → OT Requests xuất hiện.
  - Actual: user không thấy menu.
  - Feedback loop bằng Odoo shell với base.user_admin:
    root_loaded=True, child_loaded=True, can_read=False,
    root_visible=False, child_visible=False.
  - Root cause: module chưa có ACL cho ot.request; Odoo lọc menu có action
    trỏ tới model mà user không có quyền read.
  - Test chống tái phát hiện đang đỏ: Odoo-shell assertion yêu cầu cả root và
    child menu visible. Chạy lại sau Task 3b; chưa có fix hay kết quả xanh.
  - Breakpoint: chưa dùng debugger thật trong bug này.
