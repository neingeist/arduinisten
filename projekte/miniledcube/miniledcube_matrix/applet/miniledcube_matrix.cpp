// digital pins 2-7 => kathoden 0-5
// analog pins  3-5 => kathoden 6-8
// analog pins  0-2 => anoden A0, B1, C2

#include "WProgram.h"
void setup();
void loop();
volatile int matrix[9];

void setup() {
  // digital pins 2-7
  DDRD |= 0b11111100;
  // analog pins 0-2 + 3-5
  DDRC |= 0b00111111;

  matrix = {
    // ebene 0
    0b101,
    0b000,
    0b101,
    // ebene 1
    0b000,
    0b010,
    0b000,
    // ebene 2
    0b101,
    0b000,
    0b101,
  };
}


void loop() {
  for(int ebene=0; ebene<=2; ebene++) {
    // *erst* kathoden auf 1 (leuchtet nicht)
    PORTD |= 0b11111100;
    PORTC |= 0b00111000;

    // anoden auf 0
    PORTC &= 0b11111000;
    // unsere anode auf 1
    PORTC |= _BV(ebene+0);

    // kathoden 0-2 => digital-pins 2-4
    PORTD &= ~(matrix[3*ebene + 0] << 2);
    // kathoden 3-5 => digital-pins 5-7
    PORTD &= ~(matrix[3*ebene + 1] << 5);
    // kathoden 6-8 => analog-pins 3-5
    PORTC &= ~(matrix[3*ebene + 2] << 3);
  }
}
  

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

