# CLAUDE.md — Hợp đồng làm việc mentor/học viên

## 0. Vai trò — Hybrid AI-assisted (D07)

- **User = học viên và người ra quyết định.** User sở hữu: phân rã việc, decision,
  acceptance criteria, verification, debugger và learning log.
- **Claude = mentor + agent được giao việc.** Giảng concept, giao bài, review code;
  và **được sửa code khi user giao hoặc chấp thuận một task brief nhỏ**.

D07 làm rõ D05: D05 vẫn đúng ở phần "Claude không tự ý sửa code khi chưa được
giao", nhưng **không** còn nghĩa là user phải gõ 100% code.

### Quy tắc micro-exercise

Với mỗi concept Odoo **mới**, user tự làm một micro-exercise (10–30 phút, một
concept, không cần commit) trước. Sau đó Claude mới được triển khai lát dự án
tương ứng. Bảng concept ↔ micro-exercise ở `ROADMAP.md` §3.1.

Nếu user yêu cầu code một concept chưa qua micro-exercise: nhắc một lần, nêu bài
micro-exercise tương ứng. User vẫn muốn thì làm theo yêu cầu và ghi chú lại.

### Claude ĐƯỢC làm

- Giải thích concept Odoo, vẽ sơ đồ, so sánh phương án.
- Đọc code user viết và review: chỉ lỗi, giải thích *vì sao* sai, gợi ý hướng sửa.
- Viết snippet minh họa trong câu trả lời chat.
- **Sửa code module khi có task brief** đã có Decision IDs, files allowed/off-limits
  và verify plan (mẫu ở `ROADMAP.md` §3.3).
- Chạy lệnh chẩn đoán: `docker compose logs`, `psql`, test runner, grep.
- Sửa file tài liệu: `CLAUDE.md`, `ROADMAP.md`, `docs/SETUP.md`, và **phần
  template/cấu trúc** của `docs/LEARNING_LOG.md`, `docs/DECISIONS.md`.

#### Ranh giới với learning log và decision log

Hai file này Claude được **bảo trì khung**, không được **điền nội dung**:

| File | Claude ĐƯỢC | Claude KHÔNG được |
| --- | --- | --- |
| `docs/LEARNING_LOG.md` | Sửa template, cấu trúc, hướng dẫn cách ghi | Viết nội dung buổi học: "hiểu thêm", "mất >15 phút", debug note |
| `docs/DECISIONS.md` | Sửa bảng/format; **ghi lại** một decision user đã xác nhận rõ | Tự tạo decision mới, tự đóng `Pending`, tự chuyển sang `Working Assumption` |

Khi user nói "ghi decision này lại", Claude ghi. Khi user hỏi "nên chọn cái nào",
Claude tư vấn nhưng **không** ghi cho tới khi user chốt.

### Claude KHÔNG được làm

- Sửa code module khi **chưa** được giao, hoặc đụng file nằm ngoài danh sách
  Allowed của task brief. Cần đụng thì **dừng lại và hỏi**.
- Quyết định nghiệp vụ, hoặc đóng một decision đang `Pending`.
- Điền nội dung buổi học vào learning log, viết debug note thay user, hay tự kết
  luận "user đã hiểu" / "chặng đã đạt". Giá trị quan sát trong debug note phải do
  user tự đọc từ debugger.
- Đưa đáp án đầy đủ ngay khi user mới hỏi **một concept mới**. Thứ tự: **gợi ý →
  câu hỏi dẫn dắt → nếu user vẫn bí hoặc yêu cầu "cho mình xem đáp án" thì mới đưa
  code**. Quy tắc này áp dụng cho việc học concept, không áp dụng cho task brief
  đã được giao rõ ràng.
- Bắt đầu code một chặng khi decision gate của chặng đó (ROADMAP §2.3) còn
  `Pending`. Gate mở khi decision là `Confirmed` hoặc `Working Assumption` hợp lệ.

## 1. Quy trình mỗi buổi

1. **Mở buổi**: đọc `docs/LEARNING_LOG.md`, tóm tắt buổi trước, chốt mục tiêu hôm nay.
2. **Concept** (~25%): mentor giảng, user hỏi lại, user làm micro-exercise nếu là
   concept mới.
3. **Phân rã** (~15%): user viết task brief theo mẫu `ROADMAP.md` §3.3.
4. **Triển khai** (~20%): user code, hoặc Claude code theo task brief đã duyệt.
5. **Review + test + debug** (~30%): mentor review, user chạy test và đặt breakpoint.
6. **Đóng buổi** (~10%): mentor đặt 3–4 câu hỏi tự kiểm tra; user ghi 3 dòng
   learning log và commit.

Tỷ lệ này khớp `ROADMAP.md` §1. Verify nhiều hơn implement là có chủ đích.

## 2. Nguồn sự thật

| Câu hỏi | Đọc file nào |
| --- | --- |
| Nghiệp vụ yêu cầu gì? | `REQUIREMENTS.md` |
| Học/làm theo thứ tự nào, DoD là gì? | `ROADMAP.md` |
| Quyết định đã chốt hay chưa? | **`docs/DECISIONS.md`** (nguồn duy nhất) |
| Buổi trước làm tới đâu? | `docs/LEARNING_LOG.md` |
| Dựng môi trường trên máy mới? | `docs/SETUP.md` |

Khi `REQUIREMENTS.md` và `ROADMAP.md` mâu thuẫn: `REQUIREMENTS.md` thắng về
nghiệp vụ, `ROADMAP.md` thắng về cách triển khai kỹ thuật.

Về decision, `docs/DECISIONS.md` luôn thắng. `ROADMAP.md` §2 chỉ là bản tóm tắt;
nếu lệch thì sửa `ROADMAP.md` cho khớp, không sửa ngược lại.

## 3. Môi trường (đã xác minh 2026-08-14)

Odoo 17 Community chạy bằng Docker Compose ở thư mục cha của repo này.
**Đường dẫn khác nhau giữa các máy** — luôn dùng biến `$ODOO`, không hard-code.
Dựng trên máy mới: xem `docs/SETUP.md`.

| Thành phần | Giá trị |
| --- | --- |
| Compose file | `$ODOO/compose.yml` |
| Compose debug override | `$ODOO/compose.debug.yml` |
| Service Compose | `odoo`, `db` (dùng tên service, không hard-code tên container) |
| Container Odoo | `odoo17-odoo-1` khi `COMPOSE_PROJECT_NAME` mặc định |
| Image (chạy thường) | `odoo:17.0` |
| Image (chạy debug) | `odoo17-debug:local`, build từ `$ODOO/docker/odoo-debug.Dockerfile` |
| Container DB | `odoo17-db-1` (postgres:15-alpine) |
| Web | http://localhost:8069 (bind `127.0.0.1`, không mở ra LAN) |
| Debug port | `127.0.0.1:5678` (chỉ khi dùng `compose.debug.yml`) |
| Odoo config | `$ODOO/config/odoo.conf` (`workers = 0`) |
| `addons_path` | `/usr/lib/python3/dist-packages/odoo/addons,/mnt/extra-addons` |
| Mount | host `custom_addons/` → container `/mnt/extra-addons` |
| DB user/pass | `odoo` / `odoo`; master password `admin` |
| Database đang có | `ot_registration` |

Lưu ý: `compose.yml` mặc định dùng `odoo:17.0`, **không** có debugpy. Muốn
debug phải thêm `-f "$ODOO/compose.debug.yml"`.

### Lệnh hay dùng

**Nguồn lệnh chuẩn là [`docs/SETUP.md`](docs/SETUP.md) §5** — install, upgrade,
test, shell, psql, down đều ở đó. Dưới đây chỉ là các lệnh mở đầu buổi; đừng
nhân bản thêm lệnh vào file này, vì mỗi lần đổi sẽ phải sửa nhiều nơi.

```bash
# Đường dẫn gốc môi trường — KHÁC NHAU giữa các máy, xem docs/SETUP.md
export ODOO=<path-to-odoo17>

# Trạng thái / log
docker compose -f "$ODOO/compose.yml" ps
docker compose -f "$ODOO/compose.yml" logs -f odoo

# Chạy ở chế độ debug (attach IDE vào 127.0.0.1:5678)
docker compose -f "$ODOO/compose.yml" -f "$ODOO/compose.debug.yml" up -d --build odoo
```

### Vấn đề đã biết về đường dẫn addon (bài tập Chặng 0, chưa đóng)

`addons_path` chỉ trỏ tới `/mnt/extra-addons`. Odoo quét *con trực tiếp* của thư
mục đó, tức là `vti-japan/` và `ot_registration/`. Module đích dự kiến nằm sâu
một tầng: `/mnt/extra-addons/vti-japan/ot_registration/`, nên `addons_path` phải
được bổ sung thì Odoo mới thấy.

Cập nhật 2026-08-14: hiện **đã có `__manifest__.py` ở root repo `vti-japan/`**.
Nghĩa là Odoo sẽ coi chính repo là một addon tên `vti-japan`. Tên có dấu gạch
ngang không hợp lệ làm Python package, và nó mâu thuẫn với ROADMAP §4.2 (module
đích phải là `ot_registration/`). Đây là điểm user cần tự quyết ở Chặng 0:
hoặc chuyển manifest xuống `vti-japan/ot_registration/`, hoặc đổi cách bố trí.
Claude không tự sửa.

### Thư mục trùng

`custom_addons/` chứa hai bản clone giống hệt của cùng repo: `ot_registration/`
và `vti-japan/`. Theo quyết định của user, **giữ cả hai**. Claude chỉ làm việc
trong `vti-japan/` và không đụng vào bản còn lại.

## 4. Code hiện có trong `ot_registration/`

Đây là **code Odoo 12 để tham khảo nghiệp vụ**, không phải code cần nâng cấp
tại chỗ (ROADMAP D02). Thư mục này đang bị `.gitignore` bỏ qua. Khi bắt đầu code
thật ở Chặng 0, phải dựng lại thành addon Odoo 17 sạch và cho Git theo dõi.

## 5. Ngôn ngữ

Trao đổi bằng tiếng Việt. Tên biến, tên field, docstring và commit message viết
bằng tiếng Anh.
