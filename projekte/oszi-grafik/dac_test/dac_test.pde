void setup()   {                
  pinMode(7, OUTPUT);     
  pinMode(6, OUTPUT);     
  pinMode(5, OUTPUT);     
  pinMode(4, OUTPUT);     
  pinMode(3, OUTPUT);     
  pinMode(2, OUTPUT);     
}

int count = 0;

void loop()                     
{
  digitalWrite(7, (count & 0b100000) >> 5);
  digitalWrite(6, (count & 0b010000) >> 4);
  digitalWrite(5, (count & 0b001000) >> 3);
  digitalWrite(4, (count & 0b000100) >> 2);
  digitalWrite(3, (count & 0b000010) >> 1);
  digitalWrite(2, (count & 0b000001) >> 0);
 
  delay(1000);        
  count++;
}
