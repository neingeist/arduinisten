#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/delay.h>

#define REST -1

// number of timer0 overflows/sec
#define INT_PER_SEC F_CPU/1/256

volatile uint32_t intrs = 0;
volatile int32_t curNote = REST;

// TIMER0 overflow
ISR(TIMER0_OVF_vect) {
  if (curNote == REST) {
    intrs = 0;
  } else {
    intrs++;
    if (intrs >= curNote) {
      PORTD ^= _BV(PD4);
      intrs = 0;
    }
  }
}

void arpeggio_play(int32_t note, uint32_t len) {  
  // FIXME: curNote is in interrupts, note is in hertz...
  curNote = INT_PER_SEC/note/2; 
    
  // len is in PC clock ticks * 10
  // clock tick is 1s/18.2 == 54ms
  #define MAGIC_CLOCK_TICK 54
  #define MAGIC_DELAY_FACTOR 400 // well, should be 1000 us?!
  #define MAGIC_BREATH 50
  _delay_us(MAGIC_DELAY_FACTOR*(len*MAGIC_CLOCK_TICK/10));
    
  // breath
  curNote=REST;
  _delay_us(50);
}
  

void arpeggio(int32_t n1, int32_t n2, int32_t n3, int32_t len) { 
  for (int32_t i = 0; i < len; i++) {
    arpeggio_play(n1, len);
    arpeggio_play(n2, len);
    arpeggio_play(n3, len);
  }
}


int main(void) {
    /* setup clock divider. Timer0 overflows on counting to 256.
     * 16Mhz / 1 (CS0=1) = 16000000 increments/sec. Overflows every 256.
     */
    TCCR0B |= _BV(CS00);

    // enable overflow interrupts
    TIMSK0 |= _BV(TOIE0);

    // PD4 as output
    DDRD = _BV(PD4);

    TCNT0 = 0;
    intrs = 0;

    curNote = REST;

    // enable interrupts
    sei();
    
    
    for(;;) {
    arpeggio(261,329,130,7);
    arpeggio(329,392,130,4);
    arpeggio(329,392,130,6);
    arpeggio(329,392,123,6);
    arpeggio(261,329,110,7);
    arpeggio(329,392,110,4);
    arpeggio(493,392,110,4);
    arpeggio(523,440,110,4);
    arpeggio(440,349,110,6);
    arpeggio(293,246,146,7);
    arpeggio(329,261,146,4);
    arpeggio(349,293,146,6);
    arpeggio(293,246,146,6);
    arpeggio(246,196,99,7);
    arpeggio(261,220,99,4);
    arpeggio(293,246,99,6);
    arpeggio(246,196,99,6);
    arpeggio(261,329,130,7);
    arpeggio(329,392,130,4);
    arpeggio(329,392,130,6);
    arpeggio(329,392,123,6);
    arpeggio(262,329,110,7);
    arpeggio(329,392,110,4);
    arpeggio(493,392,110,4);
    arpeggio(523,440,110,4);
    arpeggio(440,349,110,6);
    arpeggio(293,246,146,7);
    arpeggio(329,261,146,4);
    arpeggio(349,293,146,6);
    arpeggio(246,196,99,6);
    arpeggio(261,329,110,6);
    arpeggio(261,329,110,6);
    arpeggio(261,329,110,6);
    arpeggio(246,196,99,6);
    arpeggio(174,220,82,6);
    arpeggio(174,220,82,6);
    arpeggio(174,220,82,6);
    arpeggio(246,196,99,6);
    arpeggio(261,329,110,6);
    arpeggio(261,329,110,6);
    arpeggio(261,329,110,6);
    arpeggio(261,329,110,6);
    arpeggio(261,329,110,6);
    arpeggio(261,329,110,6);
    arpeggio(261,329,110,6);

      
    }
}
  

/*
    10 REM ARPEGGIO BY JIM LEONARD 5/8/1984
    15 WIDTH 80:SCREEN 0,0,0:KEY OFF
    20 READ N1,N2,N3,D:ON ERROR GOTO 10000
    30 FOR I = 1 TO D
    40 SOUND N1,D*.1
    50 SOUND N2,D*.1
    60 SOUND N3,D*.1
    70 NEXT
    80 GOTO 20
    300 DATA 261,329,130,7
    310 DATA 329,392,130,4
    320 DATA 329,392,130,6
    330 DATA 329,392,123,6
    340 DATA 261,329,110,7
    350 DATA 329,392,110,4
    360 DATA 493,392,110,4
    370 DATA 523,440,110,4
    375 DATA 440,349,110,6
    380 DATA 293,246,146,7
    390 DATA 329,261,146,4
    400 DATA 349,293,146,6
    410 DATA 293,246,146,6
    420 DATA 246,196,99,7
    430 DATA 261,220,99,4
    440 DATA 293,246,99,6
    450 DATA 246,196,99,6
    500 DATA 261,329,130,7:REM REPEAT (ALMOST)
    510 DATA 329,392,130,4
    520 DATA 329,392,130,6
    530 DATA 329,392,123,6
    540 DATA 261,329,110,7
    550 DATA 329,392,110,4
    560 DATA 493,392,110,4
    570 DATA 523,440,110,4
    575 DATA 440,349,110,6
    580 DATA 293,246,146,7
    590 DATA 329,261,146,4
    600 DATA 349,293,146,6
    620 DATA 246,196,99,6
    630 DATA 261,329,110,6
    640 DATA 261,329,110,6
    645 DATA 261,329,110,6
    650 DATA 246,196,99,6
    660 DATA 174,220,82,6
    670 DATA 174,220,82,6
    680 DATA 174,220,82,6
    690 DATA 246,196,99,6
    700 DATA 261,329,110,6
    710 DATA 261,329,110,6
    720 DATA 261,329,110,6
    730 DATA 261,329,110,6
    740 DATA 261,329,110,6
    750 DATA 261,329,110,6
    760 DATA 261,329,110,6
    10000 LOCATE 24,1:END
*/



