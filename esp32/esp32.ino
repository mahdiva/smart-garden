#include "WiFi.h"
#include "DHT.h"
#include "ArduinoWebsockets.h"
#include "ArduinoJson.h"

#define DHTPIN 4       // Digital pin connected to the DHT sensor
#define DHTTYPE DHT11  // DHT 11

#define WIFI_NAME "NAME"
#define WIFI_PASS "PASS"

using namespace websockets;
const char* websockets_connection_string = "ws://192.168.0.21:3000";
WebsocketsClient client;

void onEventsCallback(WebsocketsEvent event, String data) {
    if(event == WebsocketsEvent::ConnectionOpened) {
        Serial.println("WS connection opened");
    } else if(event == WebsocketsEvent::ConnectionClosed) {
        Serial.println("WS connnection closed");
    }
}

void onMessageCallback(WebsocketsMessage message) {
    Serial.print("WS Message: ");
    Serial.println(message.data());
}

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(115200);
  Serial.print("\n===================================================\n\n");

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_NAME, WIFI_PASS);
  Serial.printf("Connecting to WiFi %s..", WIFI_NAME);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print('.');
    delay(1000);
  }
  Serial.println("\nConnected to Wifi!");
  Serial.print("Local IP Address: ");
  Serial.println(WiFi.localIP());

  client.onMessage(onMessageCallback);
  client.onEvent(onEventsCallback);
  client.connect(websockets_connection_string);
  client.send("ESP32 Connected!");

  dht.begin();
}

void loop() {
  delay(2000);
  client.poll();

  float temp = get_temp();
  float humidity = get_humidity();
  client.send("Tempearture: " + String(temp, 1) + "°C");
  client.send("Humidity: " + String(humidity, 1) + "%");
}

float get_temp() {
  // Reading temperature or humidity takes about 250 milliseconds!
  float t = dht.readTemperature();  // C

  if (isnan(t)) {
    Serial.println(F("ERROR: Failed to read temperature from DHT sensor"));
    return -273.0;
  }

  Serial.printf("Temperature: %.1f°C \n", t);

  return t;
}

float get_humidity() {
  float h = dht.readHumidity();  // RH%

  if (isnan(h)) {
    Serial.println(F("ERROR: Failed to read humidity from DHT sensor"));
    return -1.0;
  }

  Serial.printf("Humidity:    %.1f%% \n", h);
  return h;

  // Compute heat index in Celsius
  // float hic = dht.computeHeatIndex(t, h, false);
  // Serial.printf("Heat index:  %.1f°C \n", hic);
}