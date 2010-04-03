#include "avr/io.h"
#include "util/delay.h"

#include "pt.h"
#include "timer/clock.h"
#include "timer/timer.h"

/* Two flags that the two protothread functions use. */
static int protothread1_flag, protothread2_flag;

/* Two timers for the two protothreads. */
static struct timer timer1, timer2;

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
    timer_set(&timer1, CLOCK_SECOND/2);
    PT_WAIT_UNTIL(pt, timer_expired(&timer1));
    PORTB &= ~_BV(PB3);
    timer_set(&timer1, CLOCK_SECOND/2);
    PT_WAIT_UNTIL(pt, timer_expired(&timer1));

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
    timer_set(&timer2, CLOCK_SECOND/2);
    PT_WAIT_UNTIL(pt, timer_expired(&timer2));
    PORTB &= ~_BV(PB2);
    timer_set(&timer2, CLOCK_SECOND/2);
    PT_WAIT_UNTIL(pt, timer_expired(&timer2));


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

int main(void) {
  // pin 11 = PB3
  DDRB |= _BV(PB3);
  // pin 10 = PB2
  DDRB |= _BV(PB2);

  /* Initialize clock */
  clock_init();

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
