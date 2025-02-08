#include <Arduino.h>
#include <WiFi.h>

// Declaração de variáveis
int ledPin;
// Pino GPIO onde o LED está conectado
int brilho;
// Valor do PWM (0-255)
String ssid;
// Nome da rede Wi-Fi
String senha;
// Senha da rede Wi-Fi

// Configuração do PWM
const int canalPWM = 0;
// Canal do PWM para o pino
const int frequencia = 5000; // Frequência do PWM em Hz const int resolucao = 8;
// Resolução do PWM em bits(0 - 255)

void setup()
{
	// Atribuição de valores às variáveis
	ledPin = 2;
	ssid = "MinhaRedeWiFi";
	senha = "MinhaSenhaWiFi";

	// Configuração do pino como saı́da
	pinMode(ledPin, OUTPUT);

	// Configuração do PWM
	ledcSetup(canalPWM, frequencia, resolucao);
	ledcAttachPin(ledPin, canalPWM);

	// Conexão ao Wi - Fi
	WiFi.begin(ssid.c_str(), senha.c_str());
	while (WiFi.status() != WL_CONNECTED)
	{
		delay(500);
		Serial.println("Conectando ao WiFi...");
	}
	Serial.println("Conectado ao WiFi!");
}

void loop()
{
	// Liga o LED com 50% de brilho (PWM = 128)
	brilho = 128;
	ledcWrite(canalPWM, brilho);
	delay(1000); // Aguarda 1 segundo

	// Desliga o LED (PWM = 0)
	brilho = 0;
	ledcWrite(canalPWM, brilho);
	delay(1000); // Aguarda 1 segundo
}
