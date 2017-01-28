#include <Bridge.h>
#include <YunServer.h>
#include <YunClient.h>

// Listen on default port 5555, the webserver on the Yun
// will forward there all the HTTP requests for us.
YunServer server;
String readString; 
const int ledPin = 13; // the pin that the LED is attached to
const int sensorPin = 0;

void setup() {
  
  // Bridge startup
  Bridge.begin();
  
  // Listen for incoming connection only from localhost
  // (no one from the external network could connect)
  server.listenOnLocalhost();
  server.begin();

  // initialize the LED pin as an output:
  pinMode(ledPin, OUTPUT);
  pinMode(sensorPin, INPUT);
  
}


void loop() {

  // Get clients coming from server
  YunClient client = server.accept();

  if (client) {
    //Read temperature
    int val = analogRead(sensorPin);
    float mv = ( val/1024.0)*5000; 
    float celsius = (mv-600)/10;
    
    server.print("{\"sensor\":");
    server.print(celsius);
    server.print("}");
    process(client);
    // Close connection and free resources.
    client.stop();
  }
  delay(150);
}


void process(YunClient client) {
  
  String command = client.readStringUntil('/');
  // Check if the url contains the word "on"
  int value = client.parseInt();
  if (command == "switchOn") {
    digitalWrite(ledPin, value); // Change the intensity
  } 
  // Check if the url contains the word "off"
  if (command == "switchOff") {
    digitalWrite(ledPin, LOW); // Change the intensity
  }
  
}

