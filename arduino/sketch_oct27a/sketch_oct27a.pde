#include <LCD4Bit.h>
LCD4Bit lcd = LCD4Bit(2);

void setup() {
  lcd.init();
  lcd.clear();

  // create char
  lcd.commandWrite(0x40);
  lcd.print(0b10001);
  lcd.print(0b01010);
  lcd.print(0b10101);
  lcd.print(0b11111);
  lcd.print(0b01110);
  lcd.print(0b10001);
  lcd.print(0b10001);
  lcd.print(0b01010);

  // back to normal
  lcd.cursorTo(1,0);
  for(uint8_t i = 0; i < 80; i++) {
    lcd.print(0x00+(i&0x7));
  }
 
}

void loop() {
  digitalWrite(13, HIGH);

  lcd.commandWrite(0x40+8*random(8));
  uint8_t fnord = random(8);
  for (uint8_t i = 0; i<8; i++) {
    if(i == fnord) {
      lcd.print(0b11111);
    } else {
      lcd.print(0b00000);
    }
  }
  
  digitalWrite(13,LOW);
  delay(10);
}

