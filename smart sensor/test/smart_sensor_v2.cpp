#define CONFIG_THINGSBOARD_ENABLE_DEBUG false
// #define THINGSBOARD_ENABLE_STL
#include <Arduino.h>
#include <ThingsBoard.h>
#include <WiFi.h>
#include <Arduino_MQTT_Client.h>
#include <OTA_Firmware_Update.h>
#include <Shared_Attribute_Update.h>
#include <Attribute_Request.h>
#include <Espressif_Updater.h>
#include <DHT.h>
#include <Wire.h>
#include <HCSR04.h>
#include <ESP32Servo.h>
#include "RPC_Callback.h"
#include "DHT.h"
#include <MQUnifiedsensor.h>
// #include <PubSubClient.h>

constexpr int16_t TELEMETRY_SEND_INTERVAL = 5000U;
constexpr char CURRENT_FIRMWARE_TITLE[] = "Smart Sensor";
constexpr char CURRENT_FIRMWARE_VERSION[] = "v2";
constexpr uint8_t FIRMWARE_FAILURE_RETRIES = 12U;
constexpr uint16_t FIRMWARE_PACKET_SIZE = 4096U;


constexpr char WIFI_SSID[] = "Your_SSID";
constexpr char WIFI_PASSWORD[] = "Your_Password";
constexpr char TOKEN[] = "2YQS8sZ9uLt9KmxFQbfF";
constexpr char THINGSBOARD_SERVER[] = "app.coreiot.io";

constexpr char TEMPERATURE_KEY[] = "temperature";
constexpr char HUMIDITY_KEY[] = "humidity";
constexpr char CO2_KEY[] = "co2";
constexpr char TVOC_KEY[] = "tvoc";

constexpr uint16_t THINGSBOARD_PORT = 1883U;
constexpr uint16_t MAX_MESSAGE_SEND_SIZE = 512U;
constexpr uint16_t MAX_MESSAGE_RECEIVE_SIZE = 512U;
constexpr uint32_t SERIAL_DEBUG_BAUD = 115200U;
constexpr uint64_t REQUEST_TIMEOUT_MICROSECONDS = 10000U * 1000U;
constexpr int16_t telemetrySendInterval = 3000U;
constexpr uint16_t BLINKING_INTERVAL_MS_MIN = 10U;
constexpr uint16_t BLINKING_INTERVAL_MS_MAX = 60000U;
volatile uint16_t blinkingInterval = 1000U;

constexpr char BLINKING_INTERVAL_ATTR[] = "blinkingInterval";
constexpr char LED_MODE_ATTR[] = "ledMode";
constexpr char LED_STATE_ATTR[] = "ledState";
constexpr uint8_t MAX_ATTRIBUTES = 2U;
constexpr std::array<const char *, 2U> SHARED_ATTRIBUTES_LIST = {
  LED_STATE_ATTR,
  BLINKING_INTERVAL_ATTR
};

#define DHT11_SIGNAL_PIN 15
#define MQ135_placa "Arduino UNO"
#define MQ135_Voltage_Resolution 3.3
#define MQ135_Pin 33 //Analog input 4 of your arduino
#define MQ135_type "MQ-135" //MQ4
#define MQ135_ADC_Bit_Resolution 10 // For arduino UNO/MEGA/NANO
#define RatioMQ135CleanAir 3.6//RS / R0 = 3.6 ppm 

WiFiClient espClient;
Arduino_MQTT_Client mqttClient(espClient);

OTA_Firmware_Update<> ota;
Shared_Attribute_Update<1U, MAX_ATTRIBUTES> shared_update;
Attribute_Request<2U, MAX_ATTRIBUTES> attr_request;
const std::array<IAPI_Implementation*, 3U> apis = { &shared_update, &attr_request, &ota };
ThingsBoard tb(mqttClient, MAX_MESSAGE_RECEIVE_SIZE, MAX_MESSAGE_SEND_SIZE, Default_Max_Stack_Size, apis);
Espressif_Updater<> updater;


volatile bool attributesChanged = false;
volatile bool ledState = false;
volatile bool fanState = false;
bool shared_update_subscribed = false;
bool currentFWSent = false;
bool updateRequestSent = false;
bool requestedShared = false;

void processSharedAttributes(const JsonObjectConst &data) {
  Serial.println("Process shared attributes");
  if (data.containsKey(BLINKING_INTERVAL_ATTR)) {
    const uint16_t new_interval = data[BLINKING_INTERVAL_ATTR].as<uint16_t>();
    if (new_interval >= BLINKING_INTERVAL_MS_MIN && new_interval <= BLINKING_INTERVAL_MS_MAX) {
      blinkingInterval = new_interval;
      Serial.print("Blinking interval is set to: ");
      Serial.println(new_interval);
    }
  }

  if (data.containsKey(LED_STATE_ATTR)) {
    ledState = data[LED_STATE_ATTR].as<bool>();
    //digitalWrite(LED_PIN, bool(ledState));
    Serial.print("LED state is set to: ");
    Serial.println(ledState);
  }

  attributesChanged = true;
}

void requestTimedOut() {
  Serial.printf("Attribute request timed out after %llu microseconds.\n", REQUEST_TIMEOUT_MICROSECONDS);
}

void InitWiFi() {
  Serial.println("Connecting to AP ...");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("Connected to AP");
}

void update_starting_callback() {}

void finished_callback(const bool & success) {
  if (success) {
    Serial.println("Done, Reboot now");
    esp_restart();
  } else {
    Serial.println("Downloading firmware failed");
  }
}

void progress_callback(const size_t & current, const size_t & total) {
  Serial.printf("Progress %.2f%%\n", static_cast<float>(current * 100U) / total);
}

void processSharedAttributeUpdate(const JsonObjectConst &data) {
  const size_t jsonSize = Helper::Measure_Json(data);
  char buffer[jsonSize];
  serializeJson(data, buffer, jsonSize);
  Serial.println(buffer);
}

void processSharedAttributeRequest(const JsonObjectConst &data) {
  const size_t jsonSize = Helper::Measure_Json(data);
  char buffer[jsonSize];
  serializeJson(data, buffer, jsonSize);
  Serial.println(buffer);
}

void WiFiTask(void *pvParameters) {
  InitWiFi();
  while (true) {
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println("WiFi disconnected, reconnecting...");
      WiFi.reconnect();
    }
    vTaskDelay(pdMS_TO_TICKS(5000));
  }
}

void ThingsBoardTask(void *pvParameters) {
  while (true) {
    if (!tb.connected()) {
      Serial.printf("Connecting to: (%s) with token (%s)\n", THINGSBOARD_SERVER, TOKEN);
      if (tb.connect(THINGSBOARD_SERVER, TOKEN, THINGSBOARD_PORT)) {
        Serial.println("Connected to ThingsBoard");

        if (!requestedShared) {
          const Attribute_Request_Callback<MAX_ATTRIBUTES> sharedCallback(&processSharedAttributeRequest, REQUEST_TIMEOUT_MICROSECONDS, &requestTimedOut, SHARED_ATTRIBUTES_LIST);
          requestedShared = attr_request.Shared_Attributes_Request(sharedCallback);
        }

        if (!shared_update_subscribed) {
          const Shared_Attribute_Callback<MAX_ATTRIBUTES> callback(&processSharedAttributeUpdate, SHARED_ATTRIBUTES_LIST);
          shared_update_subscribed = shared_update.Shared_Attributes_Subscribe(callback);
        }

        // tb.RPC_Subscribe(callbacks.data(), callbacks.size());


      } else {
        Serial.println("Failed to connect");
        vTaskDelay(pdMS_TO_TICKS(5000));
        continue;
      }
    }
    if (!currentFWSent) {
      currentFWSent = ota.Firmware_Send_Info(CURRENT_FIRMWARE_TITLE, CURRENT_FIRMWARE_VERSION);
    }

    if (!updateRequestSent) {
      const OTA_Update_Callback callback(
        CURRENT_FIRMWARE_TITLE, CURRENT_FIRMWARE_VERSION,
        &updater,
        &finished_callback,
        &progress_callback,
        &update_starting_callback,
        FIRMWARE_FAILURE_RETRIES,
        FIRMWARE_PACKET_SIZE
      );
    
      bool started = ota.Start_Firmware_Update(callback);
      bool subscribed = ota.Subscribe_Firmware_Update(callback);
    
      if (started && subscribed) {
        Serial.println("Firmware Update Started & Subscribed.");
        updateRequestSent = true;
      } else {
        Serial.println("Firmware Update FAILED to start or subscribe.");
      }
    }    
    tb.loop();
    vTaskDelay(pdMS_TO_TICKS(100));
  }
}

void READ_DHT_TASK(void *pvParameters) 
{
  float temperature = 0.0;
  float humidity = 0.0;
   //Wire.begin(SDA_PIN, SCL_PIN);
   //DHT20 dht20;
   //dht20.begin();


   DHT dht11(DHT11_SIGNAL_PIN, DHT11);
   dht11.begin();

   while (1) {
      temperature = dht11.readTemperature();
      humidity = dht11.readHumidity();

      if (isnan(temperature) || isnan(humidity)) {
         Serial.println("Failed to read from DHT20 sensor!");
      } 
      else 
      {
         Serial.print("Temperature: ");
         Serial.print(temperature);
         Serial.print(" °C, Humidity: ");
         Serial.print(humidity);
         Serial.println(" %");

         tb.sendTelemetryData(TEMPERATURE_KEY, temperature);
         tb.sendTelemetryData(HUMIDITY_KEY, humidity);
      }

      vTaskDelay(20000 / portTICK_PERIOD_MS);
   }
}

void READ_MQ135_TASK(void *pvParameter){
  float air_quality = 0.0; 
   //Init the serial port communication - to debug the library
  MQUnifiedsensor MQ135(MQ135_placa, MQ135_Voltage_Resolution, MQ135_ADC_Bit_Resolution, MQ135_Pin, MQ135_type);

  //Set math model to calculate the PPM concentration and the value of constants
  MQ135.setRegressionMethod(1); //_PPM =  a*ratio^b
  MQ135.setA(110.47); MQ135.setB(-2.862); // Configure the equation to to calculate NH4 concentration
  analogReadResolution(10);
  /*
    Exponential regression:
  GAS      | a      | b
  CO       | 605.18 | -3.937  
  Alcohol  | 77.255 | -3.18 
  CO2      | 110.47 | -2.862
  Toluen  | 44.947 | -3.445
  NH4      | 102.2  | -2.473
  Aceton  | 34.668 | -3.369
  */
  /*****************************  MQ Init ********************************************/ 
  //Remarks: Configure the pin of arduino as input.
  /************************************************************************************/ 
  //MQ135.init(); 
  /* 
    //If the RL value is different from 10K please assign your RL value with the following method:
    MQ135.setRL(10);
  */
  /*****************************  MQ CAlibration ********************************************/ 
  // Explanation: 
   // In this routine the sensor will measure the resistance of the sensor supposedly before being pre-heated
  // and on clean air (Calibration conditions), setting up R0 value.
  // We recomend executing this routine only on setup in laboratory conditions.
  // This routine does not need to be executed on each restart, you can load your R0 value from eeprom.
  // Acknowledgements: https://jayconsystems.com/blog/understanding-a-gas-sensor
  Serial.print("Calibrating please wait.");
  float calcR0 = 0;
  for(int i = 1; i<=10; i ++)
  {
    delay(100);
    MQ135.update(); // Update data, the arduino will read the voltage from the analog pin
    calcR0 += MQ135.calibrate(RatioMQ135CleanAir);
    
    Serial.print(".");
  }
  MQ135.setR0(calcR0/10);
  Serial.println("  done!.");
  
  if(isinf(calcR0)) {Serial.println("Warning: Conection issue, R0 is infinite (Open circuit detected) please check your wiring and supply"); while(1);}
  if(calcR0 == 0){Serial.println("Warning: Conection issue found, R0 is zero (Analog pin shorts to ground) please check your wiring and supply"); while(1);}
  /*****************************  MQ CAlibration ********************************************/ 
  MQ135.serialDebug(false);

  while(1){
  MQ135.update(); // Update data, the arduino will read the voltage from the analog pin
  air_quality =MQ135.readSensor(); // Sensor will read PPM concentration using the model, a and b values set previously or from the setup
  //MQ135.serialDebug(); // Will print the table on the serial port
  Serial.print("Air quality: ");Serial.println(air_quality);
  tb.sendTelemetryData(CO2_KEY, air_quality);
  tb.sendTelemetryData(TVOC_KEY, air_quality*0.05);
  vTaskDelay(20000 / portTICK_PERIOD_MS);
}
}

void setup() {
  //pinMode(LED_PIN,OUTPUT);
  Serial.begin(SERIAL_DEBUG_BAUD);
  delay(1000);
  xTaskCreatePinnedToCore(WiFiTask, "WiFiTask", 4096, NULL, 1, NULL, 0);
  xTaskCreatePinnedToCore(ThingsBoardTask, "TBTask", 8192, NULL, 1, NULL, 1);
  xTaskCreatePinnedToCore(READ_DHT_TASK, "TREAD_DHT_TASK", 8192, NULL, 1, NULL, 1);
  xTaskCreatePinnedToCore(READ_MQ135_TASK, "TREAD_DHT_TASK", 8192, NULL, 1, NULL, 1);
}

void loop() {
  // Empty - all logic runs in FreeRTOS tasks
  //Serial.println("Smart Sensor is running...");
  //delay(2000); // Delay to prevent flooding the serial output
}


