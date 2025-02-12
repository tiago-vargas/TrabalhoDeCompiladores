#include <Arduino.h>
#include <WiFi.h>


void setup() {
    ledPin = 2;
    ssid = "MinhaRedeWiFi";
    senha = "MinhaSenhaWiFi";
    pinMode(ledPin, OUTPUT);
    ledcSetup(0, 5000, 8);
    ledcAttachPin(2, 0);
    WiFi.begin(ssid.c_str(), senha.c_str());
}

void loop() {
    if (status > 0) {
        brilho = 128;
        ledcWrite(0, brilho);
        Serial.println("Conectado - LED 50%");
        delay(1000);
        brilho = 0;
        ledcWrite(0, brilho);
        Serial.println("Conectado - LED 0%");
        delay(1000);
    }
}
