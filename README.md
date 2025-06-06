##  Luồng dữ liệu hệ thống

```text
[ IoT Devices ]
    └── Gửi dữ liệu (MQTT / HTTP / CoAP)
 |         ↓
 |   [ ThingsBoard Edge ]
 |   ├── Thu thập dữ liệu tại site cục bộ
 |   ├── Xử lý sơ bộ / phân loại / AI tại Edge (optional)
 |   └── Gửi dữ liệu lên Integration Layer
 ↓         ↓
[ Integration Layer (Gateway → Cloud) ]
    └── Đẩy dữ liệu vào ThingsBoard Core
 |                 ↓
 |        [ ThingsBoard Core ]  ---------------------------------------------------------------
 |           ├── Quản lý thiết bị                                                  |                          
 |           ├── Quản lý người dùng                                                |                         
 |           ├── OTA Updates, Scheduling                                           |                         
 |           ├── Truyền dữ liệu xuống Rule Engine                                  |                         
 |           ├── Cung cấp dữ liệu cho Real-time Dashboards                         |                                |                         
 |           └── Cung cấp dữ liệu và điều khiển thiết bị cho End Users             |                         
 ↓                                                                                 ↓                         
[ Rule Engine ]                                                        [ Real-time Dashboards ]       
    ├── Xử lý dữ liệu thời gian thực                                   ├── Hiển thị dữ liệu từ ThingsBoard Core → cho người dùng
    ├── Tạo cảnh báo (Alerting)                                    
    ├── Kích hoạt hành động (gửi command)                              ├── Điều khiển thiết bị
    └── Gửi dữ liệu đến hệ thống phân tích                             └── Theo dõi trạng thái thiết bị, nhận cảnh báo
          ↓                                                                                     ↓        
[ Trendz Analytics ]                                                                    [ End Users ]
    └── Phân tích nâng cao, biểu đồ xu hướng, dự đoán                                     ├── Tương tác qua Dashboard hoặc App
                                                                                           └── Nhận dữ liệu theo thời gian thực

[ SQL/NoSQL Database ] (Future Plan)
    └── Lưu trữ telemetry, thông tin thiết bị và người dùng

