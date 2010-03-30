// digital pins 2-7 => kathoden 1-6
// analog pins  3-5 => kathoden 7-9
// analog pins  0-2 => anoden A, B, C

#include "WProgram.h"
void setup();
void loop();
void setup() {
  // digital pins 2-7
  DDRD |= 0b11111100;
  // analog pins 0-2 + 3-5
  DDRC |= 0b00111111;
  
  // anoden an
  PORTC |= 0b00000111;
}

void loop() {
  // kathoden auf 1 (leuchtet nicht)
  PORTD |= 0b11111100;
  PORTC |= 0b00111000;
  delay(1000);
  
  // kathoden auf 0 (leuchtet)
  PORTD &= 0b00000011;
  PORTC &= 0b11000111;
  delay(1000); 
}
  

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

