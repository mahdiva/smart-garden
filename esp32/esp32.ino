#include "WiFi.h"
#include "DHT.h"
#include "ArduinoWebsockets.h"
#include "ArduinoJson.h"
#include "FastLED.h"
#include <Servo.h>

// ==================== Pin Assignment ==================== //
#define DHT_PIN 13
#define SOIL_MOISTURE_PIN 36 // Analog
#define LED_PIN 26
#define SERVO_PIN 33
#define WATER_PUMP_PIN 4

// ==================== WiFi Credentials ==================== //
#define WIFI_NAME "Pixel_AP1"
#define WIFI_PASS "mien9950"

#define WS_CONNECTION_STR "ws://192.168.131.229:3000"

// ==================== Initialization ==================== //
#define DHT_TYPE DHT11
#define NUM_LEDS 24

DHT dht(DHT_PIN, DHT_TYPE);
CRGB leds[NUM_LEDS];
Servo servo;

int led_state = 0;
int window_state = 0;
unsigned long timer_start = 0;

using namespace websockets;
WebsocketsClient ws;

void onEventsCallback(WebsocketsEvent event, String data) {
  if (event == WebsocketsEvent::ConnectionOpened)
  {
    Serial.println("WS connection opened");
  }
  else if (event == WebsocketsEvent::ConnectionClosed)
  {
    Serial.println("WS connnection closed");
  }
}

void onMessageCallback(WebsocketsMessage message) {
  String msg_str = message.data();

  Serial.print("WS Message: ");
  Serial.println(msg_str);

  DynamicJsonDocument msg_json(1024);
  deserializeJson(msg_json, msg_str);
  String action = msg_json["action"];

  if (action.equals("led_toggle")){
    toggle_leds(msg_json["state"]);
  } else if (action.equals("window_toggle")){
    toggle_window(msg_json["state"]);
  } else if(action.equals("shower")){
    digitalWrite(WATER_PUMP_PIN, HIGH);
    delay(5000);
    digitalWrite(WATER_PUMP_PIN, LOW);
  }
}

void connect_wifi() {
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

void toggle_leds(int state){
  if (state){
    fill_solid(leds, NUM_LEDS, CRGB(190, 0, 190));
    FastLED.show();
  } else {
    FastLED.clear(); // Turn off all LEDs
    FastLED.show();
  }
  led_state = state;
}

void toggle_window(int state){
  if (state){
    for (int pos = 0; pos <= 90; pos += 1) {
      servo.write(pos);
      delay(40);
    }
  } else {
    for (int pos = 90; pos >= 0; pos -= 1) {
      servo.write(pos);
      delay(40);
    }
  }
  window_state = state;
}

void setup() {
  Serial.begin(115200);
  Serial.print("\n======================\n\n");

  pinMode(WATER_PUMP_PIN, OUTPUT);

  connect_wifi();

  FastLED.addLeds<WS2811, LED_PIN, GRB>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip);

  servo.attach(SERVO_PIN);

  // Register Websocket callback functions
  ws.onMessage(onMessageCallback);
  ws.onEvent(onEventsCallback);
  ws.connect(WS_CONNECTION_STR);
  // ws.send("ESP32 Connected!");

  dht.begin();

  

  timer_start = millis();
}

void loop() {
  ws.poll();

  if ((millis() - timer_start) >= 3000) {
    float temp = get_temp();
    float humidity = get_humidity();
    float soil_moisture = get_soil_moisture();

    Serial.printf("Temperature:      %.1f°C \n", temp);
    Serial.printf("Humidity:         %.1f%% \n", humidity);
    Serial.printf("Soil Moisture:    %.1f%% \n", soil_moisture);

    DynamicJsonDocument env_conditions(1024);

    env_conditions["action"] = "env_conditions";
    env_conditions["humidity"] = humidity;
    env_conditions["temp"] = temp;
    env_conditions["soil_moisture"] = soil_moisture;
    env_conditions["light_intensity"] = 15.0;

    String output;
    serializeJson(env_conditions, output);
    ws.send(output);

    timer_start = millis();
  }

  // delay(2000);
}

float get_soil_moisture(){
  int value = analogRead(SOIL_MOISTURE_PIN);

  // Max value (water): 2800
  // Min value (air): 1170
  if (value > 2800) {
    value = 2800;
  } else if (value < 1170) {
    value = 1170;
  }
  float rh = (1.00 - ((value - 1170.0) / (2800.0 - 1170.0))) * 100.0;

  // Serial.print("Soil Moisture Value: ");
  // Serial.println(value);

  return rh;
}

float get_temp() {
  // Reading temperature or humidity takes about 250 milliseconds
  float t = dht.readTemperature(); // C
  if (isnan(t)) {
    Serial.println(F("ERROR: Failed to read temperature from DHT sensor"));
    return -273.0;
  }
  
  return t;
}

float get_humidity() {
  float h = dht.readHumidity(); // RH%
  if (isnan(h)) {
    Serial.println(F("ERROR: Failed to read humidity from DHT sensor"));
    return -1.0;
  }
  
  return h;

  // Compute heat index in Celsius
  // float hic = dht.computeHeatIndex(t, h, false);
  // Serial.printf("Heat index:  %.1f°C \n", hic);
}