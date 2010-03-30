int pinA = 7;
int pinB = 8;
int pinLED = 13;
int pinLEDstate = LOW;
long prevMillis = 0;

void setup() {
  Serial.begin(9600);
  pinMode(pinA, INPUT);
  digitalWrite(pinA, HIGH); 
  pinMode(pinB, INPUT);
  digitalWrite(pinB, HIGH); 
  pinMode(pinLED, OUTPUT);
}

int a_old, b_old, dreh;



void loop() {
  // shall we blink
//  if (millis() - prevMillis > 100) {
//    prevMillis = millis();
//    
//    if (pinLEDstate == LOW) 
//      pinLEDstate = HIGH;
//    else 
//      pinLEDstate = LOW;
//    digitalWrite(pinLED, pinLEDstate);
//    
  int a = digitalRead(pinA);
  int b = digitalRead(pinB);

  if (a != a_old || b != b_old) {
    Serial.print(digitalRead(pinA));
    Serial.print(" ");
    Serial.print(digitalRead(pinB));
    Serial.println();
    dreh++;
    // Serial.println("C:> _");
  } else {
    if (dreh%2 == 0) {
      Serial.println();
    }
  }

  digitalWrite(pinLED, a);
  a_old = a; b_old = b;
}
