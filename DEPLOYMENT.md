# Thông Tin Deploy — Checkpoint 5

> Điền file này sau khi deploy xong. `pytest tests/test_cp5.py` đọc file này
> để tìm địa chỉ service của bạn và gọi thử.
>
> **Chỉ ghi TÊN biến môi trường, tuyệt đối không dán giá trị API key vào đây.**
> Repo này công khai — dán khóa vào là mất khóa.

## Thông Tin Học Viên

| Mục | Nội dung |
|-----|----------|
| Họ và tên | Cao Văn Cường |
| Mã học viên | 2A202602493 |
| Repo | https://github.com/caovancuong611/K4-L3A-DAY12-CaoVanCuong-2A202602493-CloudServicesAndDeployment |

## Service

| Mục | Nội dung |
|-----|----------|
| Public URL | https://day12-agent-production-27aa.up.railway.app |
| Platform | Railway |
| Ngày deploy | 2026-09-28 |

## Biến Môi Trường Đã Set Trên Cloud

Ghi tên biến và **nguồn giá trị**, không ghi giá trị:

| Biến | Đã set | Ghi chú |
|------|--------|---------|
| `PORT` | ✅ | Railway tự gán |
| `AGENT_API_KEY` | ✅ | đặt trong dashboard Railway, không nằm trong repo |
| `REDIS_URL` | ✅ | tham chiếu tới service Redis add-on của Railway (`${{day12-redis.REDIS_URL}}`) |
| `RATE_LIMIT_PER_MINUTE` | ✅ | 10 |
| `MONTHLY_BUDGET_USD` | ✅ | 10.0 |
| `LOG_LEVEL` | ✅ | INFO |

## Lệnh Kiểm Tra

```powershell
$URL = "https://day12-agent-production-27aa.up.railway.app"

# 1. Liveness
curl.exe -i "$URL/health"

# 2. Readiness
curl.exe -i "$URL/ready"

# 3. Không có API key — mong đợi 401
curl.exe -i -X POST "$URL/ask" -H "Content-Type: application/json" --data "@ask.json"

# 4. Có API key — mong đợi 200 kèm câu trả lời
curl.exe -i -X POST "$URL/ask" -H "Content-Type: application/json" -H "X-API-Key: $apiKey" -H "X-User-Id: sv-test" --data "@ask.json"

# 5. Rate limit — gọi 15 lần, những lần cuối phải trả 429
for ($i=1; $i -le 15; $i++) {
  $code = curl.exe -s -o NUL -w "%{http_code}" -X POST "$URL/ask" -H "Content-Type: application/json" -H "X-API-Key: $apiKey" -H "X-User-Id: sv-test" --data "@ask.json"
  Write-Host "$code " -NoNewline
}
```

## Kết Quả Chạy Thật

```
1. GET /health
HTTP/1.1 200 OK
{"status":"ok","service":"day12-agent","version":"1.0.0"}

2. GET /ready
HTTP/1.1 200 OK
{"status":"ready","redis":true}

3. POST /ask (không có API key)
HTTP/1.1 401 Unauthorized
{"detail":"invalid or missing API key"}

4. POST /ask (có API key hợp lệ)
HTTP/1.1 200 OK
{"answer":"Theo mình hiểu, Docker la gi liên quan tới cách hệ thống được đóng
gói và vận hành. Điểm mấu chốt là tách cấu hình ra khỏi code và giữ service ở
trạng thái stateless.","user_id":"sv01","history_length":0,
"cost_usd":2.505e-05,"tokens":{"in":3,"out":41}}

5. Rate limit test (15 request liên tiếp, giới hạn 10/phút)
200 200 200 200 200 200 200 200 200 200 429 429 429 429 429
→ đúng như kỳ vọng: 10 request đầu qua, 5 request sau bị chặn 429.
```

## Ảnh Chụp Màn Hình

Đặt ảnh trong thư mục `screenshots/`:

- `screenshots/dashboard.png` — trang quản lý service trên Railway (2 service day12-agent + day12-redis, trạng thái Online)
- `screenshots/health.png` — kết quả gọi `/health` từ trình duyệt hoặc curl
- `screenshots/ready.png` — kết quả gọi `/ready`
- `screenshots/ask-401.png` — kết quả `/ask` không có API key
- `screenshots/ask-200.png` — kết quả `/ask` có API key hợp lệ

---

## Nếu Dùng Phương Án Dự Phòng

(Không áp dụng — đã deploy thành công lên Railway với public URL ở trên.)
