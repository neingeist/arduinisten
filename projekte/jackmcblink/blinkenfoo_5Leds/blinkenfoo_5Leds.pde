int i,foo;
boolean b;

void setup() {

  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(5, OUTPUT);
  pinMode(6, OUTPUT);
  pinMode(7, OUTPUT);
  pinMode(8, OUTPUT);
  pinMode(9, OUTPUT);

  b = false;
  foo = 0;
  
  
}

void loop() { 
  delay(random(25)*0+15);
  for (i = 0; i<=7; i++) {
   digitalWrite(i+2,random(2)); 
  }
//  b = !b;

  foo++;

}
