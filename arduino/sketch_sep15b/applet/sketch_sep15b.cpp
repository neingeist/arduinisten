#include "WProgram.h"
void setup();
void loop();
int ledPin = 11;
int foo = 0;
int dir = 1;
int fnord = 0;

int loga[32] = {0, 1, 2, 2, 2, 3, 3, 4, 5, 6, 7, 8, 10, 11,
                13, 16, 19, 23, 27, 32, 38, 45, 54, 64, 76,
                91, 108, 128, 152, 181, 215, 255};


void setup() {
  pinMode(ledPin, OUTPUT);
  pinMode(7, INPUT);
}

void loop() {
  analogWrite(ledPin, loga[foo]);
  fnord = digitalRead(7);
  delay(100);

  if (fnord) {
    foo += dir;
  }
  if (foo >= 31) {
    dir = -1;
  }
  
  if (foo <= 0) {
    dir = +1;
  }
}

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

