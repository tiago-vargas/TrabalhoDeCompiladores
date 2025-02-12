#include <Arduino.h>

// Variáveis globais
int botao;
int led;
int estadoBotao;

void setup() {
    Serial.begin(115200);
    ledcSetup(2, 5000, 8);
}

void loop() {
    if (estadoBotao > 0) {
        ledcWrite(2, 255);
        Serial.println("LED ligado!");
        delay(500);
    }
}
