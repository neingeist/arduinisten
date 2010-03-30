/*
 * speaker_pcm
 *
 * Plays 8-bit PCM audio on pin 11 using pulse-width modulation (PWM).
 * For Arduino with Atmega168 at 16 MHz.
 *
 * Uses two timers. The first changes the sample value 8000 times a second.
 * The second holds pin 11 high for 0-255 ticks out of a 256-tick cycle,
 * depending on sample value. The second timer repeats 62500 times per second
 * (16000000 / 256), much faster than the playback rate (8000 Hz), so
 * it almost sounds halfway decent, just really quiet on a PC speaker.
 *
 * Takes over Timer 1 (16-bit) for the 8000 Hz timer. This breaks PWM
 * (analogWrite()) for Arduino pins 9 and 10. Takes Timer 2 (8-bit)
 * for the pulse width modulation, breaking PWM for pins 11 & 3.
 *
 * References:
 *     http://www.uchobby.com/index.php/2007/11/11/arduino-sound-part-1/
 *     http://www.atmel.com/dyn/resources/prod_documents/doc2542.pdf
 *     http://www.evilmadscientist.com/article.php/avrdac
 *     http://gonium.net/md/2006/12/27/i-will-think-before-i-code/
 *     http://fly.cc.fer.hr/GDM/articles/sndmus/speaker2.html
 *     http://www.gamedev.net/reference/articles/article442.asp
 *
 * Michael Smith <michael@hurts.ca>
 */
 
#include <stdint.h>
#include <avr/interrupt.h>
#include <avr/io.h>
#include <avr/pgmspace.h>
#include <avr/delay.h>

#define SAMPLE_RATE 8000




/*
 * The audio data needs to be unsigned, 8-bit, 8000 Hz, and small enough
 * to fit in flash. 10000-13000 samples is about the limit.
 *
 * sounddata.h should look like this:
 *     const int sounddata_length=10000;
 *     const unsigned char sounddata_data[] PROGMEM = { ..... };
 *
 * You can use wav2c from GBA CSS:
 *     http://thieumsweb.free.fr/english/gbacss.html
 * Then add "PROGMEM" in the right place. I hacked it up to dump the samples
 * as unsigned rather than signed, but it shouldn't matter.
 *
 * http://musicthing.blogspot.com/2005/05/tiny-music-makers-pt-4-mac-startup.html
 * mplayer -ao pcm macstartup.mp3
 * sox audiodump.wav -v 1.32 -c 1 -r 8000 -u -1 macstartup-8000.wav
 * sox macstartup-8000.wav macstartup-cut.wav trim 0 10000s
 * wav2c macstartup-cut.wav sounddata.h sounddata
 *
 * (starfox) nb. under sox 12.18 (distributed in CentOS 5), i needed to run
 * the following command to convert my wav file to the appropriate format:
 * sox audiodump.wav -c 1 -r 8000 -u -b macstartup-8000.wav
 */

int ledPin = 13;
int speakerPin = 11;
volatile uint16_t sample1;
volatile uint16_t sample2;
byte lastSample;

prog_uint8_t sintab[] = {
        0x01,0x01,0x01,0x01,0x02,0x03,0x05,0x07,
        0x09,0x0c,0x0f,0x12,0x15,0x19,0x1c,0x21,
        0x25,0x29,0x2e,0x33,0x38,0x3d,0x43,0x48,
        0x4e,0x54,0x5a,0x60,0x66,0x6c,0x73,0x79,
        0x7f,0x85,0x8b,0x92,0x98,0x9e,0xa4,0xaa,
        0xb0,0xb6,0xbb,0xc1,0xc6,0xcb,0xd0,0xd5,
        0xd9,0xdd,0xe2,0xe5,0xe9,0xec,0xef,0xf2,
        0xf5,0xf7,0xf9,0xfb,0xfc,0xfd,0xfe,0xfe,
        0xfe,0xfe,0xfe,0xfd,0xfc,0xfb,0xf9,0xf7,
        0xf5,0xf2,0xef,0xec,0xe9,0xe5,0xe2,0xdd,
        0xd9,0xd5,0xd0,0xcb,0xc6,0xc1,0xbb,0xb6,
        0xb0,0xaa,0xa4,0x9e,0x98,0x92,0x8b,0x85,
        0x7f,0x79,0x73,0x6c,0x66,0x60,0x5a,0x54,
        0x4e,0x48,0x43,0x3d,0x38,0x33,0x2e,0x29,
        0x25,0x21,0x1c,0x19,0x15,0x12,0x0f,0x0c,
        0x09,0x07,0x05,0x03,0x02,0x01,0x01,0x01
};

volatile uint16_t tone1_h;
volatile uint16_t tone2_h;

// This is called at 8000 Hz to load the next sample.
ISR(TIMER1_COMPA_vect) {
    OCR2A = (pgm_read_byte(&sintab[sample1 / 512]) +
             pgm_read_byte(&sintab[sample2 / 512])) / 2; 

//    OCR2A = pgm_read_byte(&sintab[sample1 / 512]);
    sample1 = (sample1 +  tone1_h);
    sample2 = (sample2 +  tone2_h);
}

void startPlayback()
{
    pinMode(speakerPin, OUTPUT);

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


    // Set up Timer 1 to send a sample every interrupt.

    cli();

    // Set CTC mode (Clear Timer on Compare Match) (p.133)
    // Have to set OCR1A *after*, otherwise it gets reset to 0!
    TCCR1B = (TCCR1B & ~_BV(WGM13)) | _BV(WGM12);
    TCCR1A = TCCR1A & ~(_BV(WGM11) | _BV(WGM10));

    // No prescaler (p.134)
    TCCR1B = (TCCR1B & ~(_BV(CS12) | _BV(CS11))) | _BV(CS10);

    // Set the compare register (OCR1A).
    // OCR1A is a 16-bit register, so we have to do this with
    // interrupts disabled to be safe.
    OCR1A = F_CPU / SAMPLE_RATE;    // 16e6 / 8000 = 2000

    // Enable interrupt when TCNT1 == OCR1A (p.136)
    TIMSK1 |= _BV(OCIE1A);


    sei();
}

void stopPlayback()
{
    // Disable playback per-sample interrupt.
    TIMSK1 &= ~_BV(OCIE1A);

    // Disable the per-sample timer completely.
    TCCR1B &= ~_BV(CS10);

    // Disable the PWM timer.
    TCCR2B &= ~_BV(CS10);

    digitalWrite(speakerPin, LOW);
}

void setup()
{
    pinMode(ledPin, OUTPUT);
    tone1_h = 10;
    tone2_h = 10;
    startPlayback();
}

void arpeggio(int32_t n1, int32_t n2, int32_t n3, int32_t len) { 
  tone1_h = 16000/n1;
  tone2_h = 16000/n2;
  _delay_ms(50*len);
}

void loop()
{
  
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
    _delay_ms(3000); 
  }
  
}


