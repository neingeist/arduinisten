#include "avr/delay.h"

void setup() {
  pinMode(11, OUTPUT);
 
  // Set up Timer 2 to do pulse width modulation on the speaker
  // pin.

  // Use internal clock (datasheet p.160)
  ASSR &= ~(_BV(EXCLK) | _BV(AS2));

  // Set fast PWM mode  (p.157)
  TCCR2A |= _BV(WGM21) | _BV(WGM20);
  TCCR2B &= ~_BV(WGM22);

  // Do non-inverting PWM on pin OC2A (p.155)
  // On the Arduino this is pin 11.
  TCCR2A = (TCCR2A | _BV(COM2A1)) & ~_BV(COM2A0);
  TCCR2A &= ~(_BV(COM2B1) | _BV(COM2B0));

  // No prescaler (p.158)
  TCCR2B = (TCCR2B & ~(_BV(CS12) | _BV(CS11))) | _BV(CS10);

  // Set initial pulse width to the first sample.
  OCR2A = 0;
}


int play (uint16_t f, uint8_t T) {
  sendKarplusStrongSound(f, T);
}
  
  
// http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1249193795
int sendKarplusStrongSound(const uint16_t f /*Hz*/, const uint8_t T /*sec*/) {
   const uint8_t N = 32;
   const uint32_t sr = f * N; // sample rate: 800(25Hz)..47619(1488Hz)

   int16_t buf[N];
   for (uint8_t i=0; i<N; i++)
     buf[i] = (int16_t) random(-32768,32767);
   uint8_t bh = 0;

   const int Tloop = 60; // or is it more?
   const int dt = 16000000/sr - Tloop;
   
   for (uint32_t i=sr*T/2; i>0; i--) {
	const int8_t v = (int8_t) (buf[bh] >> 8);

	OCR2A = v;
        _delay_us(dt); // or do something else for <dt> usecs
        
	uint8_t nbh = bh!=N-1 ? bh+1 : 0;
	int32_t avg = buf[bh] + (int32_t)buf[nbh];
	//avg = (avg << 10) - avg; // subtract avg more than once to get faster volume decrease
        avg = (avg << 10) - avg -avg;
	buf[bh] = avg >> 11; // no division, just shift
	bh = nbh;
   }
} 

// Frequencies (in Hz) of notes
#define FSH_4 370
#define A_4 440
#define B_4 494
#define E_4 330
#define CSH_5 554
#define D_5 587
#define FSH_5 740
#define CSH_4 277
#define GSH_4 415

#define REST 0

void loop() {
    // Axel F
    play(FSH_4, 2);
    play(REST, 2);
    play(A_4, 3);
    play(FSH_4, 2);
    play(FSH_4, 1);
    play(B_4, 2);
    play(FSH_4, 2);
    play(E_4, 2);
    play(FSH_4, 2);
    play(REST, 2);
    play(CSH_5, 3);
    play(FSH_4, 2);
    play(FSH_4, 1);
    play(D_5, 2);
    play(CSH_5, 2);
    play(A_4, 2);
    play(FSH_4, 2);
    play(CSH_5, 2);
    play(FSH_5, 2);
    play(FSH_4, 1);
    play(E_4, 2);
    play(E_4, 1);
    play(CSH_4, 2);
    play(GSH_4, 2);
    play(FSH_4, 6);
    play(REST, 12);
    delay(100);
}
