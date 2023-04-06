#include "WiFi.h"
#include "DHT.h"
#include <WebSocketsClient.h>
#include "ArduinoJson.h"
#include "FastLED.h"
#include <Servo.h>

// ==================== Pin Assignment ==================== //
#define DHT_PIN 13
#define SOIL_MOISTURE_PIN 36 // Analog
#define LED_PIN 22
#define SERVO_PIN 4
#define WATER_PUMP_PIN 26
#define LDR_PIN 32

// ==================== WiFi Credentials ==================== //
#define WIFI_NAME "Pixel_AP1"
#define WIFI_PASS "mien9950"

#define WS_SERVER_IP "18.118.210.197"
#define WS_SERVER_PORT 80

// ==================== Initialization ==================== //
#define DHT_TYPE DHT11
#define NUM_LEDS 24

DHT dht(DHT_PIN, DHT_TYPE);
CRGB leds[NUM_LEDS];
Servo servo;
WebSocketsClient webSocket;

double target_temp = 22.0;
double target_humidity = 30.0;
double target_soil_moisture = 40.0;
double target_light_intensity = 50.0;

int led_state = 0;
int window_state = 0;
unsigned long timer_start = 0;

void webSocketEvent(WStype_t type, uint8_t * payload, size_t length) {
  if (type == WStype_TEXT) {
    // Serial.print("WS Message: ");
    // Serial.println(payload);

    DynamicJsonDocument msg_json(1024);
    deserializeJson(msg_json, payload);
    String action = msg_json["action"];

    if (action.equals("led_toggle")) {
      toggle_leds(msg_json["state"]);
    } else if (action.equals("window_toggle")) {
      toggle_window(msg_json["state"]);
    } else if(action.equals("shower")) {
      digitalWrite(WATER_PUMP_PIN, HIGH);
      delay(3000);
      digitalWrite(WATER_PUMP_PIN, LOW);
    } else if(action.equals("update_target_conditions")) {
      target_temp = msg_json["target_temp"];
      target_humidity = msg_json["target_humidity"];
      target_soil_moisture = msg_json["target_soil_moisture"];
      target_light_intensity = msg_json["target_light_intensity"];
    }
  }
}

void connect_wifi() {
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
}

void toggle_leds(int state){
  if (state != led_state){
    if (state) {
      fill_solid(leds, NUM_LEDS, CRGB(190, 0, 190));
      FastLED.show();
    } else {
      FastLED.clear(); // Turn off all LEDs
      FastLED.show();
    }
    led_state = state;
  }
}

void toggle_window(int state){
  if (state != window_state){
    if (state) {
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
  
}

void setup() {
  Serial.begin(115200);
  Serial.print("\n==============================================\n\n");

  connect_wifi();

  dht.begin();
  FastLED.addLeds<WS2811, LED_PIN, GRB>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip);
  servo.attach(SERVO_PIN);
  pinMode(WATER_PUMP_PIN, OUTPUT);

  delay(2000);
  webSocket.begin(WS_SERVER_IP, WS_SERVER_PORT, "/"); 
  webSocket.onEvent(webSocketEvent);
  webSocket.setReconnectInterval(3000);
  //ws.send("ESP32 Connected!");  

  timer_start = millis();
}

void loop() {
  webSocket.loop();

  if ((millis() - timer_start) >= 1000) {
    float temp = get_temp();
    float humidity = get_humidity();
    float soil_moisture = get_soil_moisture();
    float light_intensity = get_light_intensity();

    Serial.printf("Temperature:      %.1f°C \n", temp);
    Serial.printf("Humidity:         %.1f%% \n", humidity);
    Serial.printf("Soil Moisture:    %.1f%% \n", soil_moisture);
    Serial.printf("Light Intensity:    %.1f%% \n", light_intensity);

    //================== Environment Conditions Controller:
    if (temp < target_temp - 0.5) {
      toggle_window(0);
    } else if (temp > target_temp + 0.5) {
      toggle_window(1);
    }

    if (humidity < target_humidity - 1.0) {
      toggle_window(0);
    } else if (humidity < target_humidity + 1.0) {
      toggle_window(1);
    }

    if (light_intensity < target_light_intensity - 5.0) {
      toggle_leds(1);
    } else if (light_intensity > target_light_intensity + 5.0) {
      toggle_leds(0);
    }

    if (soil_moisture < target_soil_moisture - 1.0) {
      digitalWrite(WATER_PUMP_PIN, HIGH);
      delay(3000);
      digitalWrite(WATER_PUMP_PIN, LOW);
    }
    //================== End Controller

    DynamicJsonDocument env_conditions(1024);

    env_conditions["action"] = "env_conditions";
    env_conditions["humidity"] = humidity;
    env_conditions["temp"] = temp;
    env_conditions["soil_moisture"] = soil_moisture;
    env_conditions["light_intensity"] = light_intensity;

    env_conditions["led_state"] = led_state;
    env_conditions["window_state"] = window_state;

    String output;
    serializeJson(env_conditions, output);
    //ws.send(output);
    webSocket.sendTXT(output);

    timer_start = millis();
  }
}

float get_light_intensity(){
  int value = analogRead(LDR_PIN);

  // Max value (light): 4500
  // Min value (dark): 0
  if (value > 4500) {
    value = 4500;
  } else if (value < 0) {
    value = 0;
  }
  float light_intensity_percentage = ((value - 0.0) / (4500.0 - 0.0)) * 100.0;

  Serial.print("Light intensity: ");
  Serial.println(value);

  return light_intensity_percentage;
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
