# Phiếu Phản Ánh — K4 Level 3A, Ngày 12

> **Bài làm cá nhân.** Trả lời bằng lời của chính bạn, dựa trên những gì bạn
> quan sát được khi chạy code — không sao chép đáp án của người khác.
>
> Cách trả lời: thay dòng `> *Câu trả lời của bạn*` bằng câu trả lời.
> `grade.py` đếm số câu đã trả lời (15 điểm cho 10 câu).
>
> Họ và tên: .......................... Mã học viên: ..........................

---

### Câu 1 — Fail fast (CP1)

Trong `Settings`, `agent_api_key` không có giá trị mặc định nên app chết ngay
khi khởi động nếu thiếu biến môi trường. Hãy mô tả một tình huống cụ thể mà
việc "chết sớm" này cứu bạn, so với việc để mặc định `"changeme"`.

> _Câu trả lời của bạn_

## Nếu default là "changeme" và bạn quên set AGENT_API_KEY thật trên Railway → app vẫn chạy, ai cũng gọi /ask được bằng key mặc định đó → tốn tiền/tài nguyên mà không biết. Vì code bạn viết không có default nên nếu quên set biến, container sẽ crash ngay lúc khởi động (bạn thấy lỗi ngay trong Deploy Logs) thay vì âm thầm chạy sai.

### Câu 2 — Log cho máy đọc (CP1)

Chạy service và gọi `/ask` vài lần. Dán một dòng log JSON bạn thu được, rồi
nêu **hai** việc bạn làm được với dòng log đó mà `print("đã trả lời xong")`
không làm được.

> _Câu trả lời của bạn_

## Vào Railway → Deploy Logs → tìm dòng có "event": "ask_completed" — copy nguyên dòng đó (thật, không tự bịa). Hai việc log JSON làm được mà print thường không: (a) lọc theo field cụ thể như user_id hoặc cost_usd bằng công cụ log thay vì đọc mắt; (b) tính tổng/thống kê tự động (ví dụ tổng chi phí trong ngày) vì dữ liệu đã có cấu trúc.

### Câu 3 — Kích thước image (CP2)

Build cả hai phiên bản và ghi lại số đo thật:

```bash
docker build -f <Dockerfile-1-stage> -t agent:single .
docker build -t agent:multi .
docker images | grep agent
```

| Bản               | Dung lượng |
| ----------------- | ---------- |
| 1 stage (bản đầu) | ... MB     |
| Multi-stage       | ... MB     |

Giải thích: phần dung lượng chênh lệch đó là những gì?

> _Câu trả lời của bạn_

## Cần số đo thật từ máy bạn (docker images | Select-String day12-agent). Về mặt khái niệm: bản 1-stage giữ nguyên compiler, cache pip, source .git trong image cuối; bản multi-stage stage runtime chỉ copy /usr/local (thư viện đã cài) + code, bỏ hết phần build.

### Câu 4 — Thứ tự lệnh trong Dockerfile (CP2)

Sửa một ký tự trong `app/main.py` rồi build lại. Với Dockerfile của bạn, những
layer nào được dùng lại từ cache, layer nào phải chạy lại? Nếu bạn đặt
`COPY . .` lên trước `RUN pip install` thì kết quả khác thế nào?

> _Câu trả lời của bạn_

## Vì Dockerfile bạn viết theo thứ tự COPY requirements.txt → pip install → COPY . ., nên sửa 1 dòng trong main.py chỉ invalid hoá cache từ layer COPY . . trở đi (layer cài dependency phía trên vẫn dùng lại). Nếu đảo ngược (COPY . . trước), mọi lần sửa code dù nhỏ cũng làm mất cache của pip install, phải cài lại toàn bộ thư viện mỗi lần build.

### Câu 5 — Vì sao không chạy bằng root (CP2)

Container mặc định chạy bằng root. Mô tả chuỗi sự kiện dẫn từ "một lỗ hổng
trong code Python của bạn" tới "kẻ tấn công có quyền cao trên máy host", và
lệnh `USER` cắt đứt chuỗi đó ở chỗ nào.

> _Câu trả lời của bạn_

## Chuỗi sự kiện: lỗ hổng trong code (ví dụ RCE qua thư viện) → attacker chạy được lệnh trong container → nếu container chạy root, lệnh đó có full quyền trong container (đọc/ghi mọi file, cài phần mềm) → nếu có thêm lỗi Docker/kernel cho phép "container escape", root trong container = root trên host. Dòng USER appuser (UID 10001) trong Dockerfile của bạn chặn ngay ở bước 2 — dù attacker chạy được lệnh, lệnh đó cũng chỉ có quyền của user thường.

### Câu 6 — Cửa sổ trượt (CP3)

Rate limit của bạn dùng sliding window 60 giây. Nếu thay bằng cách đếm theo
phút đồng hồ (reset lúc giây 00), một người dùng có thể gửi tối đa bao nhiêu
request trong 2 giây liên tiếp khi hạn mức là 10/phút? Giải thích cách đạt được
con số đó.

> _Câu trả lời của bạn_

## Tính: nếu đếm theo phút đồng hồ reset ở giây 00, gửi 10 request lúc giây 59 (tính vào phút A) và 10 request lúc giây 01 (tính vào phút B) → 20 request lọt qua trong vòng 2 giây, dù giới hạn là 10/phút. Vì mỗi phút được tính riêng, request "né" đúng ranh giới reset.

### Câu 7 — Rate limit và cost guard (CP3)

Hai cơ chế này khác nhau ở điểm nào? Cho một tình huống mà rate limit cho qua
nhưng cost guard phải chặn, và một tình huống ngược lại.

> _Câu trả lời của bạn_

## Ví dụ rate limit cho qua nhưng cost guard chặn: user gửi đúng 3 request/phút (dưới hạn 10) nhưng câu hỏi rất dài/tốn nhiều token → hết ngân sách tháng. Ví dụ ngược lại: user gửi 11 request/phút với câu hỏi rất ngắn, rẻ tiền → rate limit chặn ở request thứ 11 dù tổng chi phí vẫn rất thấp so với ngân sách tháng.

### Câu 8 — /health khác /ready (CP4)

Nếu gộp hai endpoint làm một và cho nó kiểm tra Redis, chuyện gì xảy ra với cụm
3 container khi Redis mất kết nối 30 giây? Trả lời theo đúng thứ tự sự kiện.

> _Câu trả lời của bạn_

## Nếu gộp /health và /ready, khi Redis rớt 30 giây: cả 3 container đồng loạt fail health check (vì giờ cả liveness cũng phụ thuộc Redis) → orchestrator hiểu nhầm process chết → restart cả 3 container → mất traffic thật trong lúc lẽ ra chỉ cần gỡ khỏi load balancer tạm thời (/ready fail) mà không cần khởi động lại process.

### Câu 9 — Stateless (CP4)

Chạy `docker compose up --scale agent=3` rồi gọi `/ask` nhiều lần với cùng một
`X-User-Id`. Quan sát `history_length` trong response. Nếu lịch sử được lưu
trong một dict Python thay vì Redis, bạn sẽ thấy con số đó thay đổi thế nào?

> _Câu trả lời của bạn_

## Bạn đã test CP4 pass — dữ liệu history nằm trong Redis (dùng chung mọi instance) nên history_length tăng liên tục dù request rơi vào container nào. Nếu lưu trong dict Python (RAM riêng từng container), khi load balancer route sang container khác, dict đó rỗng → history_length có thể "nhảy về 0" hoặc không nhất quán giữa các lần gọi.

### Câu 10 — Deploy thật (CP5)

Ghi lại **một** lỗi bạn gặp khi deploy lên cloud (build fail, health check
timeout, sai REDIS_URL, app không đọc `$PORT`...): thông báo lỗi là gì, bạn
tìm ra nguyên nhân bằng cách nào, và sửa ra sao?

> _Câu trả lời của bạn_
> đặt REDIS_URL = ${{day12-redis.DATABASE_URL}} nhưng biến đó không tồn tại trên Redis add-on của Railway → /ready trả lỗi 500. Bạn phát hiện bằng cách vào Deploy Logs xem, rồi kiểm tra tab Variables của service day12-redis thấy tên biến thật là REDIS_URL chứ không phải DATABASE_URL. Sửa bằng cách đổi reference thành ${{day12-redis.REDIS_URL}} và deploy lại, sau đó /ready trả 200.
