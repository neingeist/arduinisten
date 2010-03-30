// Wire Master Writer
// by Nicholas Zambetti <http://www.zambetti.com>

// Demonstrates use of the Wire library
// Writes data to an I2C/TWI slave device
// Refer to the "Wire Slave Receiver" example for use with this

// Created 29 March 2006

#include <Wire.h>

#include "WProgram.h"
void setup();
void loop();
void setup()
{
  Wire.begin(); // join i2c bus (address optional for master)
  Serial.begin(9600);
}

byte x = 0;

void loop()
{

  Wire.beginTransmission(4); // transmit to device #4
  Wire.send("x is ");        // sends five bytes
  Wire.send(x);              // sends one byte  
  Wire.endTransmission();    // stop transmitting

  //Wire.requestFrom(2,2);
  while(Wire.available()) // loop through all but the last
  {
    char c = Wire.receive(); // receive byte as a character
    Serial.print(c);         // print the character
  }

  x++;
  delay(500);
  Serial.print(".");
}

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

