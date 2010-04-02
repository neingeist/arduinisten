/*
 * 8 bit counter melody
 *
 * idea from http://www.youtube.com/watch?v=hXgb8Y20aIk / http://eightbitsquare.ytmnd.com/
 *
 * Soundcode von: Michael Smith <michael@hurts.ca> - http://www.arduino.cc/playground/Code/PCMAudio
 * basierend auf code von Alex Wenger 2009 ("Arduino Physical Computing ...")
 *
 */
#include <stdint.h>
#include <avr/interrupt.h>
#include <avr/io.h>
#include <avr/pgmspace.h>
#include <avr/delay.h>

// Audioausgabe
#define SAMPLE_RATE 8000

// Auf welchem PIN soll Audio ausgegeben werden? (nicht Ändern!!!)
int speakerPin = 11;

const unsigned char sintab[] PROGMEM = {  
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

// welches ist das nächste Sample aus der Sinustabelle
// die oberen 7 bit zeigen in die Tabelle, die restlichen 
// bits sind kommastellen
volatile uint16_t sample[8];   

volatile uint8_t instrument[8]; 

uint16_t vol;               // aktuelle Lautstärke
volatile uint16_t set_vol;  // gewuenschte Lautstärke
volatile uint16_t tone_[8];     // Tonhöhe in "Inkrementiereinheiten"

// Interruptroutine, diese wird 8000 mal pro Sekunde aufgerufen und berechnet den nächsten
// Wert für die Tonausgabe
ISR(TIMER1_COMPA_vect) {
  static int timer1counter;      // Zähler um Lautstärkeänderung langsamer zu machen

  int wert = 0;
  uint8_t scale = 0;

  // Wert an der Stelle sample1/512 aus der sinus-Tabelle lesen
  for(uint8_t i=0; i<8; i++) {
    if (tone_[i] != 0) {
      
      uint8_t index = sample[i] >> 9; // 0-127
      if (instrument[i] == 0) {
        wert += pgm_read_byte(&sintab[index]);
      } else if (instrument[i] == 1) {
        wert += index*2;
      } else if (instrument[i] == 2) {
        if (index < 64) {
          wert += 0xff;
        }
      }      

      scale++;
    }
  };
  if (scale != 0) {
    // wert/=scale;
    wert/=4;
  }
  
  // Wert mit der aktuellen Lautstärke multiplizieren
  wert = (wert * vol) / 256; 
  // PWM Hardware anweisen ab jetzt diesen Wert auszugeben
  OCR2A = wert;

  // nächstes Sample in der Sinustabelle abhängig vom gewünschten
  // Ton auswählen.
  for(uint8_t i=0; i<8; i++) {
    sample[i] += tone_[i];
  };

  // Lautstärke anpassen wen gewünscht (nur alle 50 Interrupts, damit
  // es schön langsam passiert.
  timer1counter++;
  if (timer1counter > 50)
  {
    timer1counter = 0;  
    if (vol < set_vol) vol++;
    if (vol > set_vol) vol--;
  }

}

void startPlayback()
{
  pinMode(speakerPin, OUTPUT);

  // Initialisiere den Timer 2 für die schnelle PWM zur
  // Soundausgabe auf Pin 11

  // Verwende den internen Takt (Datenblatt Seite 160)
  ASSR &= ~(_BV(EXCLK) | _BV(AS2));

  // Fast PWM mode  (Seite 157)
  TCCR2A |= _BV(WGM21) | _BV(WGM20);
  TCCR2B &= ~_BV(WGM22);

  // Wähle die nicht invertierende PWM für pin OC2A und OC2B
  // Am Arduino ist das Pin 11 und 3
  TCCR2A = (TCCR2A | _BV(COM2A1) | _BV(COM2B1));

  // Keine Vorteiler / wir wollen es schnell! (Seite 158)
  TCCR2B = (TCCR2B & ~(_BV(CS12) | _BV(CS11))) | _BV(CS10);

  // Start Wert = 0, sonst gibt es ein hässliches Ploppgeräusch
  OCR2A = 0;
  OCR2B = 0;

  // Initialisiere Timer 1 für 8000 Interrupts/Sekunde
  cli();

  // Set CTC mode (Clear Timer on Compare Match) (Seite 133)
  TCCR1B = (TCCR1B & ~_BV(WGM13)) | _BV(WGM12);
  TCCR1A = TCCR1A & ~(_BV(WGM11) | _BV(WGM10));

  // Kein Vorteiler (Seite 134)
  TCCR1B = (TCCR1B & ~(_BV(CS12) | _BV(CS11))) | _BV(CS10);

  // Gewünschte Frequenz = 8000kHz
  OCR1A = F_CPU / SAMPLE_RATE;    // 16e6 / 8000 = 2000

  // Aktiviere den Interrupt für TCNT1 == OCR1A (Seite 136)
  TIMSK1 |= _BV(OCIE1A);

  // Startwerte
  for(uint8_t i=0; i<8; i++) {
    sample[i] = 0;
    tone_[i] = 0;
  }   

  // Global Interrupts wieder einschalten.
  sei();
}

void setup()                    
{
  Serial.begin(9600);
  startPlayback();
}

#include "pitches.h"
void loop()                    
{
   set_vol = 128;
   
   #define BLA(t) (2*(128ul*512ul*(t))/8000)

   instrument[0] = 2;
   instrument[1] = 2;
   instrument[2] = 0;
   instrument[3] = 0;
   instrument[4] = 0;
   instrument[5] = 1;
   instrument[6] = 1;
   instrument[7] = 1;

   
   for(int counter = 0; counter<256; counter++) {
     Serial.println(counter, BIN);
     
     tone_[0] = (counter & _BV(0))?BLA(NOTE_C4):0;  
     tone_[1] = (counter & _BV(1))?BLA(NOTE_A3):0;
     tone_[2] = (counter & _BV(2))?BLA(NOTE_F3):0;
     tone_[3] = (counter & _BV(3))?BLA(NOTE_D3):0; 
     tone_[4] = (counter & _BV(4))?BLA(NOTE_B2):0;
     tone_[5] = (counter & _BV(5))?BLA(NOTE_G2):0;
     tone_[6] = (counter & _BV(6))?BLA(NOTE_E2):0;
     tone_[7] = (counter & _BV(7))?BLA(NOTE_C2):0;
     
     _delay_ms(200);
   }     
   
   // fading away...
   if (set_vol>0) {
     set_vol--;
   }
   
   /* test code */
   /*
   tone_[0] = BLA(NOTE_C4);
   _delay_ms(500);
   tone_[0] = BLA(NOTE_C2);
   _delay_ms(500);
   */
}
