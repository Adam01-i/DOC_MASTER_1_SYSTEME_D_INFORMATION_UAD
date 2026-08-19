#include "DHT.h"

//======================================================
// DHT11
//======================================================

DHT dht;

#define DHTPIN 2

//======================================================
// HC-SR04
//======================================================

const int trigPin = 4;
const int echoPin = 6;

long duration;
int distance;

//======================================================
// Lampes
//======================================================

const int LAMPE1 = 12;
const int LAMPE2 = 10;
const int LAMPE3 = 8;

//======================================================
// Variables
//======================================================

String trame = "";

unsigned long dernierEnvoi = 0;
unsigned long dernierCapteur = 0;

//======================================================
// SETUP
//======================================================

void setup()
{
    pinMode(LAMPE1, OUTPUT);
    pinMode(LAMPE2, OUTPUT);
    pinMode(LAMPE3, OUTPUT);

    digitalWrite(LAMPE1, LOW);
    digitalWrite(LAMPE2, LOW);
    digitalWrite(LAMPE3, LOW);

    pinMode(trigPin, OUTPUT);
    pinMode(echoPin, INPUT);

    Serial.begin(9600);

    dht.setup(DHTPIN);

    delay(1000);
}

//======================================================
// LOOP
//======================================================

void loop()
{
    receptionSerie();

    // Température toutes les secondes
    if (millis() - dernierEnvoi >= dht.getMinimumSamplingPeriod())
    {
        dernierEnvoi = millis();
        envoyerTemperature();
    }

    // Distance toutes les 300 ms
    if (millis() - dernierCapteur >= 300)
    {
        dernierCapteur = millis();
        verifierDistance();
    }
}

//======================================================
// Réception des commandes Node-RED
//======================================================

void receptionSerie()
{
    while (Serial.available())
    {
        char c = Serial.read();

        if (c == '\n' || c == '\r')
        {
            if (trame.length() == 6)
            {
                decoderLampes(trame);
            }

            trame = "";
        }
        else
        {
            trame += c;

            if (trame.length() > 6)
            {
                trame = "";
            }
        }
    }
}

//======================================================
// Décodage lampes
//======================================================

void decoderLampes(String s)
{
    appliquerLampe(LAMPE1, s.substring(0,2));
    appliquerLampe(LAMPE2, s.substring(2,4));
    appliquerLampe(LAMPE3, s.substring(4,6));
}

//======================================================
// Allumer / Eteindre
//======================================================

void appliquerLampe(int pin, String code)
{
    if(code=="11")
        digitalWrite(pin,HIGH);

    else if(code=="10")
        digitalWrite(pin,LOW);
}

//======================================================
// Température DHT11
//======================================================

void envoyerTemperature()
{
    float temperature = dht.getTemperature();

    if(dht.getStatus() == DHT::ERROR_NONE)
    {
        Serial.print("TEMP:");
        Serial.println(temperature,1);
    }
}

//======================================================
// HC-SR04
//======================================================

void verifierDistance()
{
    digitalWrite(trigPin, LOW);
    delayMicroseconds(2);

    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);

    digitalWrite(trigPin, LOW);

    duration = pulseIn(echoPin, HIGH);

    distance = duration * 0.034 / 2;

    if(distance > 0 && distance < 10)
    {
        Serial.print("ALERTE:");
        Serial.println(distance);

        for(int i=0;i<3;i++)
        {
            digitalWrite(LAMPE1,HIGH);
            digitalWrite(LAMPE2,HIGH);
            digitalWrite(LAMPE3,HIGH);

            delay(150);

            digitalWrite(LAMPE1,LOW);
            digitalWrite(LAMPE2,LOW);
            digitalWrite(LAMPE3,LOW);

            delay(150);
        }
    }
}