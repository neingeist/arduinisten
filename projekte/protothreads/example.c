/* based on example-small.c in the protothreads tarball */

#include "avr/io.h"
#include "util/delay.h"

#include "pt.h"
#include "timer/clock.h"
#include "timer/timer.h"

/* TIMER_DELAY macro for convenience, do { } while(0) is just a macro trick */
#define TIMER_DELAY(pt, timer, t) \
  do { \
  timer_set(&timer, t); \
  PT_WAIT_UNTIL(pt, timer_expired(&timer)); \
  } while(0)

/* Two timers for the two protothreads. */
static struct timer timer1, timer2;

static int
protothread1(struct pt *pt)
{
  /* A protothread function must begin with PT_BEGIN() which takes a
     pointer to a struct pt. */
  PT_BEGIN(pt);

  /* We loop forever here. */
  while(1) {
    PORTB |= _BV(PB3);
    TIMER_DELAY(pt, timer1, 20);
    PORTB &= ~_BV(PB3);
    TIMER_DELAY(pt, timer1, 20);

    /* And we loop. */
  }

  /* All protothread functions must end with PT_END() which takes a
     pointer to a struct pt. */
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
    PORTB |= _BV(PB2);
    TIMER_DELAY(pt, timer2, 60);
    PORTB &= ~_BV(PB2);
    TIMER_DELAY(pt, timer2, 60);

    /* And we loop. */
  }

  /* All protothread functions must end with PT_END() which takes a
     pointer to a struct pt. */
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
