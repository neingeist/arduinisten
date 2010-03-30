/*
 * Theremin - Arduino Physical Computing für Bastler, Designer & Geeks
 *
 * Soundcode von: Michael Smith <michael@hurts.ca> - http://www.arduino.cc/playground/Code/PCMAudio
 * CapSense: http://www.arduino.cc/playground/Main/CapSense
 *
 * Alex Wenger 2009
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


volatile uint16_t sample1;   // welches ist das nächste Sample aus der Sinustabelle
// die oberen 7 bit zeigen in die Tabelle, die restlichen 
// bits sind kommastellen
volatile uint16_t sample2;
volatile uint16_t sample3;

uint16_t vol;               // aktuelle Lautstärke
volatile uint16_t set_vol;  // gewuenschte Lautstärke
volatile uint16_t tone1;     // Tonhöhe in "Inkrementiereinheiten"
volatile uint16_t tone2;     // Tonhöhe in "Inkrementiereinheiten"
volatile uint16_t tone3;     // Tonhöhe in "Inkrementiereinheiten"


// Interruptroutine, diese wird 8000 mal pro Sekunde aufgerufen und berechnet den nächsten
// Wert für die Tonausgabe
ISR(TIMER1_COMPA_vect) {
  static int timer1counter;      // Zähler um Lautstärkeänderung langsamer zu machen
  int wert;

  // Wert an der Stelle sample1/512 aus der sinus-Tabelle lesen
/*  wert = pgm_read_byte(&sintab[(sample1 >> 9)])+
         pgm_read_byte(&sintab[(sample2 >> 9)])+
         pgm_read_byte(&sintab[(sample3 >> 9)]); */
         
         wert = pgm_read_byte(&sintab[(sample1 >> 9)])+
         pgm_read_byte(&sintab[(sample2 >> 9)])+
         (sample3 >> 8); 
  // Wert mit der aktuellen Lautstärke multiplizieren
  wert = (wert * vol) / 256; 
  // PWM Hardware anweisen ab jetzt diesen Wert auszugeben
  OCR2A = wert;

  // nächstes Sample in der Sinustabelle abhängig vom gewünschten
  // Ton auswählen.
  sample1 += tone1;                
  sample2 += tone2;                
  sample3 += tone3;                

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
  sample1 = 0;                
  sample2 = 0;                
  sample3 = 0;                

  // Global Interrupts wieder einschalten.
  sei();
}

// Aendert Ton und Lautstärke
// ton (50-4000Hz)
// volume (0-256);
void SetFreq(int ton1,int ton2, int ton3, int volume)
{
  tone1 = (128ul*512ul*ton1)/8000;
  tone2 = (128ul*512ul*ton2)/8000;
  tone3 = (128ul*512ul*ton3)/8000;
  set_vol  = volume;
}

void setup()                    
{
  startPlayback();
}

uint8_t st1_mod = 1;
uint8_t st2_mod = 1;
uint8_t st3_mod = 1;
uint8_t st3b_mod = 1;

void arpeggio(int32_t n1, int32_t n2, int32_t n3, int32_t len) { 
  #define MAGIC_FAC 2
  for (uint16_t i = 0; i < 5*len*len; i++)
  {
    SetFreq(MAGIC_FAC*n1, // Stimme 1
            MAGIC_FAC*n2,// Stimme 2
            n3,               // Basline
            80);              // Lautstärke
    _delay_us(600*st3_mod);
  }
}



void loop()                    
{
    st1_mod = random(1,3);
    st2_mod = random(1,3);
    //st3_mod = random(1,4);
    st3_mod = 2;
    st3b_mod = random(1,4);
    
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
