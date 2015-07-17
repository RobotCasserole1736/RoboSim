//Test sketch
//Turns arduino into serial loopback device.
//Anything rx'ed on the serial port will be tx'ed right back.
//It's like a parrot, but technology!

void setup() {
  Serial.begin(115200);

}

void loop() {

    while(Serial.available())
      Serial.write(Serial.read());

}
