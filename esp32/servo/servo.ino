#include <Servo.h>
#define SERVO 17

Servo myservo;
int pos = 0;

void setup() {
  myservo.attach(SERVO);
}

void loop() {
  myservo.write(0);
  // for (pos = 0; pos <= 90; pos += 1) {
  //   myservo.write(pos);
  //   delay(30);
  // }
  // for (pos = 100; pos >= 0; pos -= 1) {
  //   myservo.write(pos);
  //   delay(30);
  // }

  delay(2000);
}

