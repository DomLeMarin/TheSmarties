#include <Bridge.h>
#include <YunServer.h>
#include <YunClient.h>

// Listen on default port 5555, the webserver on the Yun
// will forward there all the HTTP requests for us.
YunServer server;
String readString; 
const int ledPin = 13; // the pin that the LED is attached to
const int sensorPin1 = 0;
const int sensorPin2 = 1;
const int sensorPin3 = 2;
int val = 0;

void setup() {
  
  // Bridge startup
  Bridge.begin();
  
  // Listen for incoming connection only from localhost
  // (no one from the external network could connect)
  server.listenOnLocalhost();
  server.begin();

  // initialize the LED pin as an output:
  pinMode(ledPin, OUTPUT);
  pinMode(sensorPin1, INPUT);
  pinMode(sensorPin2, INPUT);
  pinMode(sensorPin3, INPUT);
  
}


void loop() {

  // Get clients coming from server
  YunClient client = server.accept();

  if (client) {
    //Read temperature
    float celsius = process(client);
    server.print("{\"sensor\":");
    server.print(celsius);
    server.print("}");
    // Close connection and free resources.
    client.stop();
  }
  delay(150);
}


float process(YunClient client) {
  
  String command = client.readStringUntil('/');
  // Check if the url contains the word "on"
  int value = client.parseInt();
  
  if (command == "sensor") {
    //Read temperature
    switch(value) {
      case 0:
        digitalWrite(ledPin, LOW);
      case 1:
        val = analogRead(sensorPin1);
        digitalWrite(ledPin, HIGH);
        break;
      case 2:
        val = analogRead(sensorPin2);
        digitalWrite(ledPin, LOW);
        break;
      case 3:
        val = analogRead(sensorPin3);
        digitalWrite(ledPin, HIGH);
        break;
      default:
        digitalWrite(ledPin, LOW);
        break;
    }
    float mv = ( val/1024.0)*5000; 
    float celsius = (mv-550)/10;
    return celsius;
  } 
  
}

