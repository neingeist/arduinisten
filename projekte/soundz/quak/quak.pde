byte foo;
int bar;
byte mul;
byte cnt;
float wow;
boolean b;
int inv;

#define WOW_FACTOR 512
#define WOW_LIMIT 4

void setup() {
    pinMode(8, OUTPUT);
    cnt = 0;
    mul = 1;
    wow = WOW_FACTOR;
    inv = 1;
}



void loop() {
  
  if( cnt == 0 ) {
    mul = random(6)+1;
    cnt = 25;
  }
  
  cnt--;
  
  foo = random(5*mul)+2;
  
  for(bar = 0; bar < (255-(foo*20)); bar++) {
    
    
    if( inv == 1 )
      wow /= 2;
    else
      wow *= 2;
      
    if( wow < WOW_LIMIT || wow > WOW_FACTOR ) {
      inv = inv == 1 ? -1 : 1;
    }
    
    digitalWrite(8, b = !b);
    delayMicroseconds((WOW_FACTOR+(wow*inv))*foo+(bar*2*b));
    
    // NOISE
    if( random(10) == 0 ) {
      digitalWrite(8, b = !b); delayMicroseconds(4500); digitalWrite(8, b = !b);
    } 
  }
}
