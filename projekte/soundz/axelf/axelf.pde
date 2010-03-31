// originally by Joby Taffey
// http://chiphacker.com/questions/2057/polyphonic-sounds-from-a-microcontroller

#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/delay.h>

// number of timer0 overflows/sec
#define INT_PER_SEC F_CPU/1/256

// Frequencies (in Hz) of notes
#define F_FSH_4 370
#define F_A_4 440
#define F_B_4 494
#define F_E_4 330
#define F_CSH_5 554
#define F_D_5 587
#define F_FSH_5 740
#define F_CSH_4 277
#define F_GSH_4 415

// number of timer0 overflows for notes
#define REST -1 // special case
#define FSH_4 INT_PER_SEC/F_FSH_4
#define A_4 INT_PER_SEC/F_A_4
#define B_4 INT_PER_SEC/F_B_4
#define E_4 INT_PER_SEC/F_E_4
#define CSH_5 INT_PER_SEC/F_CSH_5
#define D_5 INT_PER_SEC/F_D_5
#define FSH_5 INT_PER_SEC/F_FSH_5
#define CSH_4 INT_PER_SEC/F_CSH_4
#define GSH_4 INT_PER_SEC/F_GSH_4

#define SEMIQUAVER_TIME 60  // ms
#define BREATH_TIME 20      // ms

volatile uint32_t intrs = 0;
volatile int32_t curNote = REST;

// TIMER0 overflow
ISR(TIMER0_OVF_vect)
{
  if (curNote == REST)
    intrs = 0;
  else
  {
    intrs++;
    if (intrs >= curNote)
    {
      PORTD ^= _BV(PD4);
      intrs = 0;
    }
  }
}


void play(int32_t note, uint32_t len)
{
  int i;
  curNote = note;
  for (i = 0; i< len; i++)
    _delay_ms(SEMIQUAVER_TIME);
  curNote = REST;
  _delay_ms(BREATH_TIME);
}

int main(void)
{
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

  while (1)
  {
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
  delay(3000);
}


