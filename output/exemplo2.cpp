#include <Arduino.h>
#include <WiFi.h>


void setup() {
    Serial.begin(115200);
    ledcSetup(0, 5000, 8);
    ledcAttachPin(2, 0);
}

void loop() {
    if (estadoBotao > 0) {
        ledcWrite(0, 255);
        Serial.println("LED ligado!");
        delay(500);
    }
}
