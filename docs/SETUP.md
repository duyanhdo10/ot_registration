# Setup môi trường trên một máy mới

Dự án được dùng trên nhiều máy. File này để dựng lại toàn bộ môi trường từ đầu.

Nguyên tắc: **đường dẫn khác nhau giữa các máy**, nên mọi lệnh dùng biến `$ODOO`.
Không hard-code đường dẫn vào tài liệu hay config.

---

## 0. Kết quả cần đạt

```text
$ODOO/                              # thư mục môi trường, KHÔNG phải repo
├── compose.yml
├── compose.debug.yml
├── config/
│   └── odoo.conf
├── docker/
│   └── odoo-debug.Dockerfile
└── custom_addons/                  # mount vào /mnt/extra-addons
    └── vti-japan/                  # ← repo này
        ├── env/                    # bản gốc của 4 file môi trường ở trên
        ├── docs/
        └── ...
```

Bốn file môi trường được version trong repo tại [`env/`](../env/). Đó là **bản
gốc**; các file ở `$ODOO/` là bản sao. Khi sửa môi trường, sửa trong `env/` rồi
copy ra, để máy khác nhận được thay đổi.

---

## 1. Cài Docker (nếu máy chưa có)

### Linux — bước chung cho Ubuntu và Debian

Gỡ các bản cũ do distro đóng gói, chúng thường thiếu `docker compose` v2:

```bash
for p in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    sudo apt-get remove -y $p
done

sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
```

Ubuntu và Debian dùng **hai repo khác nhau**. Chọn đúng một trong hai mục dưới;
dùng nhầm URL sẽ cài phải gói không khớp release.

#### Ubuntu

```bash
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

> Trên Linux Mint hoặc distro phái sinh Ubuntu, `$VERSION_CODENAME` là codename
> của distro đó, không phải của Ubuntu. Dùng `$UBUNTU_CODENAME` thay thế.

#### Debian

```bash
sudo curl -fsSL https://download.docker.com/linux/debian/gpg \
    -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Tài liệu: [Ubuntu](https://docs.docker.com/engine/install/ubuntu/) ·
[Debian](https://docs.docker.com/engine/install/debian/)

#### Cài engine + compose plugin (cả hai distro)

```bash
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin
```

Chạy docker không cần `sudo`:

```bash
sudo usermod -aG docker $USER
newgrp docker        # hoặc đăng xuất/đăng nhập lại
```

### macOS / Windows

Cài Docker Desktop từ https://www.docker.com/products/docker-desktop/.
Trên Windows nên dùng WSL2 backend và **đặt repo trong filesystem của WSL**
(`~/projects/...`), không đặt ở `/mnt/c/...` — I/O qua ranh giới Windows rất
chậm và Odoo đọc rất nhiều file nhỏ.

### Kiểm chứng

```bash
docker --version
docker compose version      # phải là v2.x, KHÔNG phải docker-compose 1.x
docker run --rm hello-world
```

---

## 2. Lấy repo và dựng thư mục môi trường

```bash
export ODOO=~/projects/odoo17          # đổi theo máy
mkdir -p "$ODOO/custom_addons"

git clone <repo-url> "$ODOO/custom_addons/vti-japan"

"$ODOO/custom_addons/vti-japan/env/bootstrap.sh" "$ODOO"
```

`bootstrap.sh` copy 4 file môi trường vào đúng chỗ. Script **không ghi đè** file
đã tồn tại, nên chạy lại nhiều lần là an toàn.

Đặt biến cho các phiên sau — cú pháp khác nhau theo shell:

```bash
# bash / zsh — thêm vào ~/.bashrc hoặc ~/.zshrc
export ODOO=~/projects/odoo17
```

```fish
# fish — thêm vào ~/.config/fish/config.fish
set -gx ODOO ~/projects/odoo17
```

**Nếu shell mặc định của bạn là fish:**

- Các block ```` ```bash ```` trong tài liệu này là cú pháp POSIX — có `for ...;
  do ...; done`, `export`, `$(...)` lồng nhau. Fish **không** chạy trực tiếp
  được. Chạy chúng bằng Bash: mở `bash` rồi dán, hoặc `bash -c '<lệnh>'`.
- Riêng các lệnh `docker compose ...` là lệnh đơn, gõ giống hệt nhau trong fish.
- Biến `$ODOO` đặt bằng `set -gx` như trên thì fish và các tiến trình con đều
  thấy, kể cả khi bạn mở `bash` từ fish.

---

## 3. Chạy Odoo

```bash
docker compose -f "$ODOO/compose.yml" up -d
docker compose -f "$ODOO/compose.yml" logs -f odoo
```

Lần đầu sẽ pull `odoo:17.0` (~2.7 GB) và `postgres:15-alpine`.

Kiểm chứng:

```bash
docker compose -f "$ODOO/compose.yml" ps        # cả hai service Up, db healthy
curl -sI http://localhost:8069/web/login | head -1   # HTTP/1.1 200 OK
```

Mở http://localhost:8069. Master password để tạo database là `admin`
(`admin_passwd` trong `config/odoo.conf`).

> **Cổng chỉ mở trên loopback.** `compose.yml` bind `127.0.0.1:8069`, không phải
> `0.0.0.0`. Lý do: `admin_passwd = admin` và `list_db = True`, nên bind ra mọi
> interface đồng nghĩa mở trang quản trị database cho toàn bộ mạng LAN — ai vào
> được cũng tạo/xóa/backup được database.
>
> Cần truy cập từ máy khác (test trên điện thoại, demo cho đồng nghiệp) thì
> **đổi `admin_passwd` trước**, rồi mới sửa bind trong `env/compose.yml`.

### Tạo database và cài module

```bash
docker compose -f "$ODOO/compose.yml" run --rm odoo \
  odoo --config=/etc/odoo/odoo.conf -d ot_registration \
  -i ot_registration --stop-after-init
```

> Lệnh này **chưa chạy được** cho tới khi bài tập `addons_path` ở Chặng 0 được
> hoàn thành — xem mục 6.

---

## 4. Chế độ debug

`compose.yml` mặc định dùng `odoo:17.0`, **không có debugpy**. Muốn đặt
breakpoint phải thêm override:

```bash
docker compose -f "$ODOO/compose.yml" -f "$ODOO/compose.debug.yml" up -d --build odoo
```

Lần đầu sẽ build image `odoo17-debug:local`.

Kiểm chứng — cả ba đều phải đúng:

```bash
docker compose -f "$ODOO/compose.yml" -f "$ODOO/compose.debug.yml" ps
#   IMAGE phải là odoo17-debug:local, PORTS có 127.0.0.1:5678->5678/tcp

ss -ltn | grep 5678
#   LISTEN 127.0.0.1:5678

docker compose -f "$ODOO/compose.yml" -f "$ODOO/compose.debug.yml" logs odoo | grep "database:"
#   odoo: database: odoo@db:5432
```

Nếu log báo không nối được database: xem lại `--db_*` trong `compose.debug.yml`.
Lý do kỹ thuật ở `ROADMAP.md` §3.4.

Quay lại chế độ thường:

```bash
docker compose -f "$ODOO/compose.yml" up -d --force-recreate odoo
```

### Attach IDE

Path mapping bắt buộc, vì code ở host nhưng chạy trong container:

| | |
| --- | --- |
| Host | thư mục repo — trong IDE hãy **chọn bằng Browse**, đừng gõ literal `$ODOO/...` (IDE không expand biến shell) |
| Container | `/mnt/extra-addons/vti-japan` |

PyCharm: dùng run configuration **Attach to DAP** (không phải `Python Debug
Server`) và bật **Store as project file** để config được lưu vào
`.idea/runConfigurations/` — thư mục duy nhất trong `.idea/` được version, nhờ đó
cấu hình debug đi theo repo sang máy khác.

Cấu hình chi tiết cho PyCharm và VS Code: `ROADMAP.md` §3.4.

---

## 5. Lệnh hằng ngày

> Mục này là **nguồn lệnh chuẩn** của dự án: bộ lệnh hằng ngày
> install/upgrade/test/shell/psql/down chỉ được duy trì tại đây.
> `AGENTS.md` giữ ba lệnh mở đầu buổi và trỏ về đây. `ROADMAP.md` chỉ lặp các
> lệnh cần cho bài debug (§3.4), vì ở đó lệnh là một phần của bài học.
> Sửa lệnh hằng ngày thì sửa ở đây trước.

```bash
# cài mới module vào một database
docker compose -f "$ODOO/compose.yml" run --rm odoo \
  odoo --config=/etc/odoo/odoo.conf -d <db> -i ot_registration --stop-after-init

# upgrade module sau khi sửa code Python
docker compose -f "$ODOO/compose.yml" run --rm odoo \
  odoo --config=/etc/odoo/odoo.conf -d <db> -u ot_registration --stop-after-init

# chạy test
docker compose -f "$ODOO/compose.yml" run --rm odoo \
  odoo --config=/etc/odoo/odoo.conf -d <db> -u ot_registration \
  --test-enable --test-tags=/ot_registration --stop-after-init

# odoo shell
docker compose -f "$ODOO/compose.yml" run --rm odoo \
  odoo shell --config=/etc/odoo/odoo.conf -d <db>

# psql
docker compose -f "$ODOO/compose.yml" exec db psql -U odoo -d <db>

# dừng / xóa sạch (mất cả database)
docker compose -f "$ODOO/compose.yml" down
docker compose -f "$ODOO/compose.yml" down -v
```

Dùng `docker compose exec db` thay vì `docker exec odoo17-db-1`: tên container
phụ thuộc `COMPOSE_PROJECT_NAME`, đổi tên project là lệnh hard-code sẽ hỏng.

Sửa code Python cần `-u` hoặc restart. Sửa XML view cần `-u`. Sửa asset JS thì
mở `?debug=assets`.

---

## 6. Vấn đề đã biết, chưa đóng

**`addons_path` chưa thấy module.** `config/odoo.conf` chỉ có
`/mnt/extra-addons`, mà Odoo quét *con trực tiếp* của thư mục đó. Module đích dự
kiến nằm ở `/mnt/extra-addons/vti-japan/ot_registration/`, sâu hơn một tầng.

Ngoài ra hiện đã có `__manifest__.py` ở **root repo**, nên Odoo sẽ coi chính repo
là addon tên `vti-japan` — tên có dấu gạch ngang, không hợp lệ làm Python package.

Đây là **bài tập Chặng 0**, user tự quyết cách xử lý (sửa `addons_path`, chuyển
manifest xuống thư mục con, hoặc bố trí lại). Xem `ROADMAP.md` §4.

---

## 7. Đồng bộ giữa các máy

Chỉ những gì nằm trong repo mới đi theo bạn:

| Đi theo repo | Không đi theo repo |
| --- | --- |
| `env/` (4 file môi trường) | Docker volumes: `postgres-data`, `odoo-data` |
| `docs/`, `ROADMAP.md`, `AGENTS.md`, `CLAUDE.md` | Database và dữ liệu test |
| Code module | Image đã build |

Database **không** được đồng bộ. Trên máy mới phải tạo lại database và cài module
từ đầu. Đó là chủ ý: dữ liệu test phải dựng lại được từ code, không phải tài sản
cần mang theo.

Khi sửa file môi trường: sửa trong `env/`, commit, rồi copy ra `$ODOO/`. Kiểm tra
xem có lệch không:

```bash
for f in compose.yml compose.debug.yml config/odoo.conf docker/odoo-debug.Dockerfile; do
    diff -q "$ODOO/custom_addons/vti-japan/env/$f" "$ODOO/$f" || echo "LỆCH: $f"
done
```
