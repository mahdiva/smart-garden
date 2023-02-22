#include <Servo.h>

Servo myservo;
int pos = 0;

void setup() {
  myservo.attach(4);
}

void loop() {
  for (pos = 0; pos <= 120; pos += 1) {
    myservo.write(pos);
    delay(30);
  }
  for (pos = 120; pos >= 0; pos -= 1) {
    myservo.write(pos);
    delay(30);
  }

  delay(2000);
}

