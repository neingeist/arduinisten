const int pins[] = {2, 3, 4};

void setup() {
  for(int p=0; p<=2; p++) {
    pinMode(pins[p], INPUT); 
  }
}

const int charlieplexed[6][3] =
{
  { 1,0,-1},
  { 0,1,-1},
  {-1,1, 0},
  {-1,0, 1},
  {1,-1, 0},
  {0,-1, 1},
};

void loop() {
  for(int i=0; i<=5; i++) {
    // set pin tristate
    for(int p=0; p<=2; p++) {
      if (charlieplexed[i][p] == -1) {
        pinMode(pins[p], INPUT);
      } else {
        pinMode(pins[p], OUTPUT);
        digitalWrite(pins[p], charlieplexed[i][p]);
      }
    }
  delay(200);
  }
}
