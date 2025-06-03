
#include <WiFi.h>
#include <Arduino_MQTT_Client.h>
#include <esp_log.h>
#include <OTA_Firmware_Update.h>
#include <ThingsBoard.h>
#include "PubSubClient.h"
#include <Espressif_Updater.h>
#include <Server_Side_RPC.h>

#define FAN_PIN 33 // Replace 0 with the actual pin number for D3


constexpr char CURRENT_FIRMWARE_TITLE[] = "HVAC";
constexpr char CURRENT_FIRMWARE_VERSION[] = "v2";

// Maximum amount of retries we attempt to download each firmware chunck over MQTT
constexpr uint8_t FIRMWARE_FAILURE_RETRIES = 12U;

// Size of each firmware chunck downloaded over MQTT,
// increased packet size, might increase download speed
constexpr uint16_t FIRMWARE_PACKET_SIZE = 4096U;

constexpr char WIFI_SSID[] = "Your_SSID"; // Replace with your WiFi SSID
constexpr char WIFI_PASSWORD[] = "Your_PASSWORD"; // Replace with your WiFi password

// See https://thingsboard.io/docs/getting-started-guides/helloworld/
// to understand how to obtain an access token
constexpr char TOKEN[] = "Your_Device_Token"; // Replace with your ThingsBoard token
// Thingsboard we want to establish a connection too
constexpr char THINGSBOARD_SERVER[] = "app.coreiot.io";

constexpr char ENABLED_KEY[] = "enabled";
constexpr char TARGET_TEMPERATURE_KEY[] = "targetTemperature";
constexpr char AIR_FLOW_KEY[] = "airFlow";

constexpr const char FW_TAG_KEY[] = "fw_tag";

constexpr uint16_t THINGSBOARD_PORT = 1883U;

constexpr uint16_t MAX_MESSAGE_SEND_SIZE = 512U;
constexpr uint16_t MAX_MESSAGE_RECEIVE_SIZE = 512U;

constexpr uint32_t SERIAL_DEBUG_BAUD = 115200U;
constexpr int16_t TELEMETRY_SEND_INTERVAL = 5000U;

constexpr size_t MAX_ATTRIBUTES = 6U;

uint32_t previousTelemetrySend;

WiFiClient espClient;
Arduino_MQTT_Client mqttClient(espClient);

OTA_Firmware_Update<> ota;
Server_Side_RPC<3U, 5U> rpc;
Shared_Attribute_Update<1U, MAX_ATTRIBUTES> shared;
const std::array<IAPI_Implementation *, 3U> apis = {&ota, &rpc, &shared};

Shared_Attribute_Update<1U, MAX_ATTRIBUTES> shared_update;

ThingsBoard tb(mqttClient, MAX_MESSAGE_RECEIVE_SIZE, MAX_MESSAGE_SEND_SIZE, Default_Max_Stack_Size, apis);

Espressif_Updater<> updater;

// Current led state, on or off
volatile bool enabled = false;
volatile float targetTemperature = 33;
// Handle led state changes
volatile bool ledStateChanged = false;
volatile bool pumpStateChanged = false;
constexpr const char ENABLED_ATTR[] = "enabled";
constexpr const char TARGET_TEMPERATURE_ATTR[] = "targetTemperature";

// Statuses for updating
bool currentFWSent = false;
bool updateRequestSent = false;

bool subscribed = false;

void InitWiFi()
{
  Serial.println("Connecting to AP ...");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }
  Serial.println("Connected to AP");
}

bool reconnect()
{
  // Check to ensure we aren't connected yet
  const wl_status_t status = WiFi.status();
  if (status == WL_CONNECTED)
  {
    return true;
  }

  // If we aren't establish a new connection to the given WiFi network
  InitWiFi();
  return true;
}

void processSharedAttributeUpdate(const JsonObjectConst &data)
{
  Serial.print("Received data from shared attributes: ");
  Serial.print(data);
  for (auto it = data.begin(); it != data.end(); ++it)
  {
    ESP_LOGI("MAIN", "Key: %s, Value: %s", it->key().c_str(), it->value().as<const char *>());
  }

  const size_t jsonSize = Helper::Measure_Json(data);
  char buffer[jsonSize];
  serializeJson(data, buffer, jsonSize);
  ESP_LOGI("MAIN", "%s", buffer);

  // Kiểm tra nếu có key "fw_version" trong dữ liệu shared attributes
  if (data.containsKey("fw_version"))
  {
    ESP_LOGI("MAIN", "Firmware version changed, updating currentFWSent to true");
    currentFWSent = true;
  }
}

void HVACControl(float targetTemp) {
  // Giới hạn nhiệt độ trong khoảng từ 10 đến 40
  //targetTemp = constrain(targetTemp, 10.0, 40.0);
    float airFlow ;
    if (!enabled){
      tb.sendTelemetryData(AIR_FLOW_KEY, 0.0);
      analogWrite(FAN_PIN, 0); // Tắt quạt
      return; // Nếu HVAC không được bật, không thực hiện điều khiển
    }
    else{
    // Tính toán giá trị airflow dựa trên targetTemp
    // Nếu targetTemp = 40, airflow = 0
    // Nếu targetTemp = 10, airflow = 400
    airFlow = map(targetTemp, 40.0, 10.0, 0.0, 400.0);
    // Gửi giá trị airflow đến quạt (giả sử quạt được điều khiển qua PWM)
    analogWrite(FAN_PIN, (airFlow* 255) / 400); // Chuyển đổi giá trị airflow sang giá trị PWM (0-255)
    tb.sendTelemetryData(AIR_FLOW_KEY, airFlow);
    }
    // In thông tin ra Serial để debug
    Serial.print("Target Temperature: ");
    Serial.print(targetTemp);
    Serial.print(" °C, Airflow: ");
    Serial.print(airFlow);
    Serial.println(" (cfm)");
}

void setTemperatureProcess(const JsonVariantConst &data, JsonDocument &response)
{
  // Process data
  targetTemperature = data;
  HVACControl(targetTemperature); 
  tb.sendTelemetryData(TARGET_TEMPERATURE_KEY, targetTemperature);
  Serial.print("Received set targetTemperature RPC. New state: ");
  Serial.println(targetTemperature);

  StaticJsonDocument<1> response_doc;
  // Returning current state as response
  response_doc["newState"] = (float)targetTemperature;
  response.set(response_doc);
}

void setEnabledProcess(const JsonVariantConst &data, JsonDocument &response)
{
  // Process data
  enabled = data;
  HVACControl(targetTemperature);
  tb.sendTelemetryData(ENABLED_KEY, enabled); 
  Serial.print("Received set Enabled RPC. New state: "); 
  Serial.println(enabled);

  StaticJsonDocument<1> response_doc;
  // Returning current state as response
  response_doc["newState"] = (bool)enabled;
  response.set(response_doc);
}

// Server-side RPC callback
const std::array<RPC_Callback, 2U> rpcCallbacks = {
  RPC_Callback{ "setEnabled", setEnabledProcess },
  RPC_Callback{ "setTemperature", setTemperatureProcess }
};

void update_starting_callback()
{
  // Nothing to do
}

void finished_callback(const bool &success)
{
  if (success)
  {
    Serial.println("Done, Reboot now");
    esp_restart();
    return;
  }
  Serial.println("Downloading firmware failed");
}

void progress_callback(const size_t &current, const size_t &total)
{
  Serial.printf("Progress %.2f%%\n", static_cast<float>(current * 100U) / total);
}


void TEST(void *pvParameters)
{
  Serial.println("TEST V1 started");
  while (true)
  {
    // Do something
    Serial.println("TEST V1 is running");
    vTaskDelay(5000 / portTICK_PERIOD_MS);
  }
}

void setup()
{
  // Initalize serial connection for debugging
  Serial.begin(SERIAL_DEBUG_BAUD);
  pinMode(FAN_PIN, OUTPUT);
  analogWrite(FAN_PIN, 0); // Đặt quạt ban đầu tắt
  delay(1000);
  InitWiFi();
  //xTaskCreate(TEST, "TEST", 2048, nullptr, 1, nullptr); // Tạo task TEST
}

void loop()
{
  delay(100);
  if (!reconnect())
  {
    return;
  }

  if (!tb.connected())
  {
    Serial.printf("Connecting to: (%s) with token (%s)\n", THINGSBOARD_SERVER, TOKEN);
    if (!tb.connect(THINGSBOARD_SERVER, TOKEN, THINGSBOARD_PORT, "DEVICEUPDATE", nullptr))
    {
      Serial.println("Failed to connect");
      return;
    }

    if (!subscribed)
    {
      // Shared attributes we want to request from the server
      constexpr std::array<const char *, MAX_ATTRIBUTES> SUBSCRIBED_SHARED_ATTRIBUTES = {FW_CHKS_KEY, FW_CHKS_ALGO_KEY, FW_SIZE_KEY, FW_TAG_KEY, FW_TITLE_KEY, FW_VER_KEY};
      const Shared_Attribute_Callback<MAX_ATTRIBUTES> callback(&processSharedAttributeUpdate, SUBSCRIBED_SHARED_ATTRIBUTES);
      subscribed = shared_update.Shared_Attributes_Subscribe(callback);
      Serial.print("Subscribed for shared attributes: ");
      Serial.println(subscribed);
    }

    Serial.println("Subscribing for RPC...");

    if (!rpc.RPC_Subscribe(rpcCallbacks.cbegin(), rpcCallbacks.cend()))
    {
      Serial.println("Failed to subscribe for RPC");
      return;
    }
  }

  if (!currentFWSent)
  {
    currentFWSent = ota.Firmware_Send_Info(CURRENT_FIRMWARE_TITLE, CURRENT_FIRMWARE_VERSION);
  }

  if (!updateRequestSent)
  {
    Serial.println("Firwmare Update...");
    const OTA_Update_Callback callback(CURRENT_FIRMWARE_TITLE, CURRENT_FIRMWARE_VERSION, &updater, &finished_callback, &progress_callback, &update_starting_callback, FIRMWARE_FAILURE_RETRIES, FIRMWARE_PACKET_SIZE);
    updateRequestSent = ota.Start_Firmware_Update(callback);
  }
  tb.loop();
  
}