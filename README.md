##  Luồng dữ liệu hệ thống

```text
[ IoT Devices ]
    └── Gửi dữ liệu (MQTT / HTTP / CoAP)
          ↓
[ ThingsBoard Edge ]
    ├── Thu thập dữ liệu tại site cục bộ
    ├── Xử lý sơ bộ / phân loại / AI tại Edge (tùy chọn)
    └── Gửi dữ liệu lên Integration Layer
          ↓
[ Integration Layer (Gateway → Cloud) ]
    └── Đẩy dữ liệu vào ThingsBoard Core
          ↓
[ ThingsBoard Core ]
    ├── Quản lý thiết bị
    ├── Quản lý người dùng
    ├── OTA Updates, Scheduling
    └── Truyền dữ liệu xuống Rule Engine
          ↓
[ Rule Engine ]
    ├── Xử lý dữ liệu thời gian thực
    ├── Tạo cảnh báo (Alerting)
    ├── Kích hoạt hành động (gửi command lại IoT Devices qua Edge)
    └── Gửi dữ liệu đến hệ thống phân tích
          ↓
[ Trendz Analytics ]
    └── Phân tích nâng cao, biểu đồ xu hướng, dự đoán


[ SQL/NoSQL Database ] (song song)
    └── Lưu trữ telemetry, thông tin thiết bị và người dùng


[ Real-time Dashboards ]
    └── Hiển thị dữ liệu từ ThingsBoard Core → cho người dùng
          ↑
[ Mobile App / Web App ]
    ├── Kết nối qua REST API / WebSocket
    ├── Điều khiển thiết bị
    └── Theo dõi trạng thái thiết bị, nhận cảnh báo
          ↑
[ End Users ]
    ├── Tương tác qua Dashboard hoặc App
    └── Nhận dữ liệu theo thời gian thực
