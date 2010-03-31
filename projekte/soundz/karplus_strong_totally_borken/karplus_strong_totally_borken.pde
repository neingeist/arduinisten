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

  // DEBUG
  Serial.begin(9600);
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


int play (uint16_t f, uint8_t T) {
  #define MAGIC_TUNE_FAC 3
  if (f == REST) {
    _delay_ms(T*1000/16*MAGIC_TUNE_FAC);
  } else {
    sendKarplusStrongSound(f, T*MAGIC_TUNE_FAC);
  }
}
  
  
// http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1249193795
int sendKarplusStrongSound(uint16_t f /*Hz*/, uint8_t T /* 1/16 sec*/) {
   uint32_t sr = 11025;
   uint8_t N = sr/f;
   //uint8_t N=32;
   //uint32_t sr = (uint32_t) N*f;

   Serial.print("N = ");
   Serial.print(N, DEC);
   Serial.println();

   unsigned long millis_alt = millis();

   int buf[N];
   for (uint8_t i=0; i<N; i++)
     buf[i] = random(65536);
   uint8_t bh = 0;

   int Tloop = 18
   ; // FIXME: tune
   int dt = (1000000ul)/sr - Tloop;
   Serial.print("dt = ");
   Serial.print(dt, DEC);
   Serial.println();
   
   for (uint32_t i=sr*T/16; i>0; i--) {
        // current amplitude to play is the highest byte of buf[bh]	
        #if 1
	OCR2A = buf[bh] >> 8;
        #else
        OCR2A = buf[bh];
        #endif

        // delay or do something else for <dt> usecs
        _delay_us(dt); 
        
        // calculate avg between current buf[bh] and next sample buf[nbh]
        uint8_t nbh;
        if (bh < N-1) {
          nbh = bh + 1;
        } else {
          nbh = 0;
        }
        
        // calculate avg 
	unsigned long avg = ((unsigned long) buf[bh] + (unsigned long) buf[nbh])/2;
        // with gain<1 (1020/1024 ~ 0.996)
        avg *= 1020;
        avg /= 1024;

        // put back in buffer
	buf[bh] = (int) avg;        
	bh = nbh;
   }
   
   Serial.print("T_real = ");
   Serial.print(millis() - millis_alt, DEC);
   Serial.print(", T/16 = ");
   Serial.print(T*1000/16, DEC);
   Serial.println();
} 



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
}
