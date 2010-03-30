#include <LCD4Bit.h>
#include "WProgram.h"
void setup();
void loop();
LCD4Bit lcd = LCD4Bit(2);

void setup() {
  lcd.init();
  lcd.clear();
  lcd.printIn("World Arduinination in progress...");
}

int i = 0,j = 0, dir = 1;
char bfr[4];

void loop() {
  digitalWrite(13, HIGH);

  lcd.cursorTo(2, 0);
  itoa(i, bfr, 10);
  lcd.printIn(bfr);
  lcd.printIn("%");
  
  lcd.cursorTo(2, 4);
  
  for(j=0; j < (i / 3); j++)
      lcd.print(255);
  for(j=i/3; j < 100/3; j++)
      lcd.printIn(" ");

 
  if(i >= 98)
    dir = -1;
  if(dir == -1 && i <= 80)
    dir = 1;
    
  i += dir;
  
  digitalWrite(13,LOW);
  delay(100);
}

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

