#include <Arduino.h>

// Variáveis globais
int sensor;
int led;
int valorSensor;
int brilhoLed;
String mensagem;

void setup() {
    Serial.begin(115200);
    ledcSetup(2, 5000, 8);
}

void loop() {
    if (valorSensor > 200) {
        ledcWrite(2, 255);
        Serial.println("Luminosidade alta!");
        delay(1000);
    }
}
