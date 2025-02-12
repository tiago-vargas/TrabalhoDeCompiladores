#include <Arduino.h>

// Variáveis globais
int temperatura;
String mensagem;

void setup() {
    Serial.begin(115200);
    ledcSetup(2, 5000, 8);
    temperatura = 0;
}

void loop() {
    if (temperatura > 30) {
        ledcWrite(2, 255);
        Serial.println("LED no máximo - Temperatura alta!");
        delay(1000);
    }
}
