#include "avr/io.h"
#include "util/delay.h"

#include "pt.h"

/* Two flags that the two protothread functions use. */
static int protothread1_flag, protothread2_flag;

static int
protothread1(struct pt *pt)
{
  /* A protothread function must begin with PT_BEGIN() which takes a
 *      pointer to a struct pt. */
  PT_BEGIN(pt);

  /* We loop forever here. */
  while(1) {
    /* Wait until the other protothread has set its flag. */
    PT_WAIT_UNTIL(pt, protothread2_flag != 0);

    PORTB |= _BV(PB3);
    _delay_ms(200);
    PORTB &= ~_BV(PB3);
    _delay_ms(200);


    /* We then reset the other protothread's flag, and set our own
       flag so that the other protothread can run. */
    protothread2_flag = 0;
    protothread1_flag = 1;

    /* And we loop. */
  }

  /* All protothread functions must end with PT_END() which takes a
 *      pointer to a struct pt. */
  PT_END(pt);
}

static int
protothread2(struct pt *pt)
{
  /* A protothread function must begin with PT_BEGIN() which takes a
     pointer to a struct pt. */
  PT_BEGIN(pt);

  /* We loop forever here. */
  while(1) {
    /* Let the other protothread run. */
    protothread2_flag = 1;

    /* Wait until the other protothread has set its flag. */
    PT_WAIT_UNTIL(pt, protothread1_flag != 0);

    PORTB |= _BV(PB2);
    _delay_ms(100);
    PORTB &= ~_BV(PB2);
    _delay_ms(100);


    /* We then reset the other protothread's flag, and set our own
       flag so that the other protothread can run. */
    protothread1_flag = 0;
    protothread2_flag = 1;

    /* And we loop. */
  }

  /* All protothread functions must end with PT_END() which takes a
 *      pointer to a struct pt. */
  PT_END(pt);
}

static struct pt pt1, pt2;

int main() {
  // pin 11 = PB3
  DDRB |= _BV(PB3);
  // pin 10 = PB2
  DDRB |= _BV(PB2);

  /* Initialize the protothread state variables with PT_INIT(). */
  PT_INIT(&pt1);
  PT_INIT(&pt2);

  /*
   * Then we schedule the two protothreads by repeatedly calling their
   * protothread functions and passing a pointer to the protothread
   * state variables as arguments.
   */
  while(1) {
    protothread1(&pt1);
    protothread2(&pt2);
  }
}
