void setup() {
  for(int p=8; p<=11; p++) {
    pinMode(p, OUTPUT);
  } 
}

void loop() {
  for (int c=0; c<16; c++) {
    for (int b=0; b<4; b++) {
      digitalWrite(8+b, c & _BV(b));
    }
    delay(100);
  }
}
