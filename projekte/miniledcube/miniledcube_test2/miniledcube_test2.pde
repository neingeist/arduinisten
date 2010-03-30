// digital pins 2-7 => kathoden 0-5
// analog pins  3-5 => kathoden 6-8
// analog pins  0-2 => anoden A0, B1, C2

void setup() {
  // digital pins 2-7
  DDRD |= 0b11111100;
  // analog pins 0-2 + 3-5
  DDRC |= 0b00111111;
}


void loop() {
  for(int ebene=0; ebene<=2; ebene++) {
    // anoden auf 0
    PORTC &= 0b11111000;
    // unsere anode auf 1
    PORTC |= _BV(ebene+0);
   
    for (int kathode=0; kathode<=8; kathode++) {
      // kathoden auf 1 (leuchtet nicht)
      PORTD |= 0b11111100;
      PORTC |= 0b00111000;
      
      // unsere kathode auf 0 (leuchtet)
      if (kathode <= 5) {
        PORTD &= ~_BV(kathode+2);
      }
      if (kathode >= 6 && kathode <= 8) {
        PORTC &= ~_BV(kathode-6+3);
      }
      delay(400); 
    }
  }
}
  
