/* Disney Sound Source

From: http://www.awe.com/mark/dev/disney.html
--------------------------------------------------------------
Turning it on

   1. Send the value 0x04 to BASE_PORT+2 

Turning it off

   1. Send the value 0x0C to BASE_PORT+2 

Sending a value to the DAC

   1. Send the unsigned DAC value to the BASE_PORT as normal.
   2. Send the value 0x0C to BASE_PORT+2
   3. Send the value 0x04 to BASE_PORT+2 
--------------------------------------------------------------

BASE_PORT + 2 = control port
  0x04 (bit 2) is INIT
  0x0c (bits 2+3) are INIT + nSELECTIN

--------------------------------------------------------------
Arduino Desc     DB-25 Pin
======= ====     =========
GND     GND      18-25
13      BUSY     11
12      nACK     10
11      D7        9
10      D6        8
 9      D5        7
 8      D4        6
 7      D3        5
 6      D2        4
 5      D1        3
 4      D0        2
 3      nSTROBE   1
 2      SELECT    17
--------------------------------------------------------------

*/

int pin_SELECT = 2;

void setup() {
  digitalWrite(pin_SELECT, HIGH);
}

 
void loop() {
  boolean val = 1;
  
  for (uint8_t i=0; i<8; i++) {
    digitalWrite(4+i, val);
  }
  digitalWrite(pin_SELECT, LOW); 
  delayMicroseconds(5); 
  digitalWrite(pin_SELECT, HIGH);
  delay(2);

  val = 0;

  for (uint8_t i=0; i<8; i++) {
    digitalWrite(4+i, val);
  }
  digitalWrite(pin_SELECT, LOW); 
  delayMicroseconds(5); 
  digitalWrite(pin_SELECT, HIGH);
  delay(2);
  

}
