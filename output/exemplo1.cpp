#include <Arduino.h>
#include <WiFi.h>


void setup() {
    Serial.begin(115200);
    ledcSetup(0, 5000, 8);
    ledcAttachPin(2, 0);
    temperatura = 0;
}

void loop() {
    if (temperatura > 30) {
        ledcWrite(0, 255);
        Serial.println("LED no maximo - Temperatura alta!");
        delay(1000);
    }
}
