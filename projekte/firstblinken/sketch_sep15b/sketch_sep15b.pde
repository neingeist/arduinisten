int ledPin = 11;
int foo = 0;
int dir = 1;

int loga[32] = {0, 1, 2, 2, 2, 3, 3, 4, 5, 6, 7, 8, 10, 11,
                13, 16, 19, 23, 27, 32, 38, 45, 54, 64, 76,
                91, 108, 128, 152, 181, 215, 255};


void setup() {
  pinMode(ledPin, OUTPUT);
}

void loop() {
  analogWrite(ledPin, loga[foo]);
  delay(100);

  foo += dir;
  if (foo >= 31) {
    dir = -1;
  }
  
  if (foo <= 0) {
    dir = +1;
  }
}
