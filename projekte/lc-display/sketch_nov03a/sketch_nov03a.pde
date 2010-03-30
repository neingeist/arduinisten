#include <avr/interrupt.h>
#include <avr/io.h>


int pinA = 11;
int pinB = 12;
int ledPin = 13;

void setup() {
  //Timer2 Settings
  TCCR2A = 0;
  TCCR2B = 0<<CS22 | 1<<CS21 | 0<<CS20;

  //Timer2 Overflow Interrupt Enable
  TIMSK2 = 1<<TOIE2;

  // pullups  
  digitalWrite(pinA, HIGH); 
  digitalWrite(pinB, HIGH); 
  
  Serial.begin(9600);
}

volatile int8_t enc_delta;			// -128 ... 127
static int8_t last;


ISR(TIMER2_OVF_vect) {
  int8_t neu, diff;

  // convert gray to binary 
  neu = 0;
  if(digitalRead(pinA))
    neu = 3;
  if(digitalRead(pinB))
    neu ^= 1;
    
  diff = last - neu;				// difference last - new
  if( diff & 1 ) {				// bit 0 = value (1)
    last = neu;					// store new as next last
    enc_delta += (diff & 2) - 1;		// bit 1 = direction (+/-)
  }
}

int8_t val_alt;
void loop() {
  int8_t val;

  digitalWrite(13,HIGH);

  cli();
  val = enc_delta;
  // enc_delta = val & 1;
  sei();
  
  if (val != val_alt) {
    Serial.println(val>>1);
  }
  
  val_alt = val;
  
  delay(100);
  digitalWrite(13,LOW);
  delay(100);
}
