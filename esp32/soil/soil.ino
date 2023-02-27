#define AOUT_PIN 4
#define THRESHOLD 1000

void setup() {
  Serial.begin(115200);
}

void loop() {
  int value = analogRead(AOUT_PIN);

  // Max value (water): 2800
  // Min value (air): 1170
  float rh = 1.00 - ((value - 1170.0) / (2800.0 - 1170.0));

  Serial.print(rh);
  Serial.println("");

  delay(500);
}