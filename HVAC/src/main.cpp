#include <WiFi.h>
#include <Arduino_MQTT_Client.h>
#include <ThingsBoard.h>
#include "Wire.h"
#include <ArduinoOTA.h>

constexpr char WIFI_SSID[] = "YOUR_WIFI_SSID"; // Replace with your WiFi SSID
constexpr char WIFI_PASSWORD[] = "YOUR_WIFI_PASSWORD"; // Replace with your WiFi password
constexpr char TOKEN[] = "YOUR_DEVICE_TOKEN"; // Replace with your ThingsBoard device token

constexpr char THINGSBOARD_SERVER[] = "app.coreiot.io";
constexpr uint16_t THINGSBOARD_PORT = 1883U;

constexpr uint32_t MAX_MESSAGE_SIZE = 1024U;
constexpr uint32_t SERIAL_DEBUG_BAUD = 115200U;

constexpr uint8_t FAN_PIN = 25; // GPIO pin for fan control

WiFiClient wifiClient;
Arduino_MQTT_Client mqttClient(wifiClient);
ThingsBoard tb(mqttClient, MAX_MESSAGE_SIZE);


bool enabled = false; 
float airFlow = 0.0; // Giá trị airflow ban đầu
float currentTargetTemp = 25.0; 

void HVACControl(float targetTemp) {
    if (!enabled){
      airFlow = 0.0; // Nếu HVAC không được bật, airflow sẽ là 0
      tb.sendTelemetryData("airFlow", airFlow);
      analogWrite(FAN_PIN, 0); // Tắt quạt
      return; // Nếu HVAC không được bật, không thực hiện điều khiển
    }

    // Giới hạn nhiệt độ trong khoảng từ 10 đến 40
    targetTemp = constrain(targetTemp, 10.0, 40.0);

    // Tính toán giá trị airflow dựa trên targetTemp
    // Nếu targetTemp = 40, airflow = 0
    // Nếu targetTemp = 10, airflow = 400
    airFlow = map(targetTemp, 40.0, 10.0, 0.0, 400.0);

    // Gửi giá trị airflow đến quạt (giả sử quạt được điều khiển qua PWM)
    analogWrite(FAN_PIN, (airFlow* 255) / 400); // Chuyển đổi giá trị airflow sang giá trị PWM (0-255)
    tb.sendTelemetryData("airFlow", airFlow);
    // In thông tin ra Serial để debug
    Serial.print("Target Temperature: ");
    Serial.print(targetTemp);
    Serial.print(" °C, Airflow: ");
    Serial.print(airFlow);
    Serial.println(" (cfm)");
}

RPC_Response setEnabledProcess(const RPC_Data &data) {
    Serial.println("Received Switch state");
    bool newState = data;
    Serial.print("Switch state change: ");
    Serial.println(newState);
    enabled = newState;
    HVACControl(currentTargetTemp); 
    tb.sendTelemetryData("enabled", newState);
    return RPC_Response("setEnabled", newState);
}

RPC_Response setTemperatureProcess(const RPC_Data &data) {
    Serial.println("Received Switch state");
    float newTemperature = data;
    Serial.print("Switch state change: ");
    Serial.println(newTemperature);
    currentTargetTemp = newTemperature;
    HVACControl(newTemperature);
    tb.sendTelemetryData("targetTemperature", newTemperature);
    return RPC_Response("setTemperature", newTemperature);
}

const std::array<RPC_Callback, 2U> callbacks = {
  RPC_Callback{ "setEnabled", setEnabledProcess },
  RPC_Callback{ "setTemperature", setTemperatureProcess }
};

void InitWiFi() {
  Serial.println("Connecting to AP ...");
  // Attempting to establish a connection to the given WiFi network
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    // Delay 500ms until a connection has been successfully established
    delay(500);
    Serial.print(".");
  }
  Serial.println("Connected to AP");
}

const bool reconnect() {
  // Check to ensure we aren't connected yet
  const wl_status_t status = WiFi.status();
  if (status == WL_CONNECTED) {
    return true;
  }
  // If we aren't establish a new connection to the given WiFi network
  InitWiFi();
  return true;
}

void setup() {
  pinMode(FAN_PIN, OUTPUT);
  analogWrite(FAN_PIN, 0); // Đặt quạt ban đầu tắt
  Serial.begin(SERIAL_DEBUG_BAUD);
  delay(1000);
  InitWiFi();

}

void loop() {
  delay(10);
  if (!reconnect()) {
    return;
  }
  if (!tb.connected()) {
    Serial.print("Connecting to: ");
    Serial.print(THINGSBOARD_SERVER);
    Serial.print(" with token ");
    Serial.println(TOKEN);
    if (!tb.connect(THINGSBOARD_SERVER, TOKEN, THINGSBOARD_PORT)) {
      Serial.println("Failed to connect");
      return;
    }
    tb.sendAttributeData("macAddress", WiFi.macAddress().c_str());
    Serial.println("Subscribing for RPC...");
    if (!tb.RPC_Subscribe(callbacks.cbegin(), callbacks.cend())) {
      Serial.println("Failed to subscribe for RPC");
      return;
    }
    Serial.println("Subscribe done");
  }
  tb.loop();
}





