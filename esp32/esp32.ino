#include "WiFi.h"
#include "DHT.h"
#include "ArduinoWebsockets.h"
#include "ArduinoJson.h"

// ==================== Pin Assignment ==================== //
#define DHT_PIN 4
#define SOIL_MOISTURE_PIN 5
#define LED_PIN 6
#define SERVO_PIN 7
#define WATER_PUMP_PIN 8

// ==================== WiFi Credentials ==================== //
#define WIFI_NAME ""
#define WIFI_PASS ""

#define WS_CONNECTION_STR "ws://192.168.0.21:3000"

// ==================== Initialization ==================== //
#define DHT_TYPE DHT11

DHT dht(DHT_PIN, DHT_TYPE);

using namespace websockets;
WebsocketsClient ws;

void onEventsCallback(WebsocketsEvent event, String data)
{
  if (event == WebsocketsEvent::ConnectionOpened)
  {
    Serial.println("WS connection opened");
  }
  else if (event == WebsocketsEvent::ConnectionClosed)
  {
    Serial.println("WS connnection closed");
  }
}

void onMessageCallback(WebsocketsMessage message)
{
  Serial.print("WS Message: ");
  Serial.println(message.data());
}

void connect_wifi()
{
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_NAME, WIFI_PASS);
  Serial.printf("Connecting to WiFi %s..", WIFI_NAME);
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print('.');
    delay(1000);
  }
  Serial.println("\nConnected to Wifi!");
  Serial.print("Local IP Address: ");
  Serial.println(WiFi.localIP());
}

void setup()
{
  Serial.begin(115200);
  Serial.print("\n======================\n\n");

  connect_wifi();

  // Register Websocket callback functions
  ws.onMessage(onMessageCallback);
  ws.onEvent(onEventsCallback);
  ws.connect(WS_CONNECTION_STR);
  // ws.send("ESP32 Connected!");

  dht.begin();
}

void loop()
{
  ws.poll();

  float temp = get_temp();
  float humidity = get_humidity();

  DynamicJsonDocument env_conditions(1024);

  env_conditions["action"] = "env_conditions";
  env_conditions["humidity"] = humidity;
  env_conditions["temp"] = temp;
  env_conditions["soil_moisture"] = 70.0;
  env_conditions["light_intensity"] = 16.0;

  // char data[200];
  // size_t len = serializeJson(env_conditions, data);

  String output;
  serializeJson(env_conditions, output);
  ws.send(output);
  // serializeJson(env_conditions, client.send);

  delay(2000);
}

float get_temp()
{
  // Reading temperature or humidity takes about 250 milliseconds!
  float t = dht.readTemperature(); // C

  if (isnan(t))
  {
    Serial.println(F("ERROR: Failed to read temperature from DHT sensor"));
    return -273.0;
  }

  Serial.printf("Temperature: %.1f°C \n", t);

  return t;
}

float get_humidity()
{
  float h = dht.readHumidity(); // RH%

  if (isnan(h))
  {
    Serial.println(F("ERROR: Failed to read humidity from DHT sensor"));
    return -1.0;
  }

  Serial.printf("Humidity:    %.1f%% \n", h);
  return h;

  // Compute heat index in Celsius
  // float hic = dht.computeHeatIndex(t, h, false);
  // Serial.printf("Heat index:  %.1f°C \n", hic);
}