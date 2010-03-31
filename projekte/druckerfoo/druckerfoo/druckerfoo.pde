#include <avr/pgmspace.h>

/* 
Arduino Desc     DB-25 Pin
======= ====     =========
GND     GND      18-25    
13      BUSY     11
12      nACK     10
11      D7        9
10      D6        8
 9      D5        7
 8      D4        6
 7      D3        5
 6      D2        4
 5      D1        3
 4      D0        2
 3      nSTROBE   1
*/

int PIN_nSTROBE = 3;
int PIN_nACK = 12;
int PIN_BUSY = 13;

PROGMEM char porn[] = 
"\r\n"
"\r\n"
"                                     sexsexsexsexsexse\r\n"
"                                   sexsesexsexsexsexsexs\r\n"
"                                  sexsexsexsexsexsexsexse\r\n"
"                                sexsexsexsexsexsexsexsexsex\r\n"
"                              sexsexsexsexsexsexsexsexsexsex\r\n"
"                             sexsexsexsexsexsexsexsexsexsexs\r\n"
"                            sexsexsexsexsexsexsexsexsexsexsex\r\n"
"                           sexsexsexsexsexsexsexsexsexsexsexse\r\n"
"                          sexsexsexsexsexsexsexsexsexsexsexsex\r\n"
"                          exsexsexsexsexsexsexsex  sexsexsexsex\r\n"
"                         sexsexsexsexsexsexsexs     sexsexsexse\r\n"
"                         sexsexsexsexsexsexsex        sexsexsex\r\n"
"                         sexsexsexsexsexsex            sexsexsx\r\n"
"                         sexsexsexsexsexx              sexsexs x\r\n"
"                         sexsexsexsexsex-****.    .***-sexsexs sexs\r\n"
"                         sexsexsexsexsex               sexsex sexsexs\r\n"
"                         sexsexsexsexsex              sexsex sexsexsexs\r\n"
"                         sexsexsexsexsex              sexse sexsexsexse\r\n"
"                         sesexsexsexsexs   --sexsex- sexse sexsexsexse\r\n"
"                         xsexsexsexsexse      sexs  sexse sexsexsexs\r\n"
"                        sexsexsexsexsexse         sexse sexsexsexse\r\n"
"                      sexsexsexsexsexsexs       sexse    sexsexse\r\n"
"                     sexsexse      sexsexs      ixx       sexse\r\n"
"                     sexsex         sexsexs     i         sex\r\n"
"                     sexs            sexsexs    i         x\r\n"
"                     sex              sexsex        x   x\r\n"
"                      x               sexsex        x  x\r\n"
"                     x                sexse          xx\r\n"
"                   sex                sex                x\r\n"
"                 sexsexs             xx                     x\r\n"
"                sexsexsex    x x                  x           x\r\n"
"              sexsexsexsexse                       x          (o\r\n"
"            sexsexsexsexse       x                            x\r\n"
"          sexsexsexsexse   x     x         (o)      x        x\r\n"
"        sexsexsexsexse     x      x                 x       x\r\n"
"       sexsexsexsex        x       x               x      x\r\n"
"     sexsexsexsex          x        x             x    xx\r\n"
"     sexsexsexse           x         x          x      x\r\n"
"      sexsexsexse           x           x x  x         x\r\n"
"        sexsexsexs          x                          x\r\n"
"         sexsexsexs          x                        x\r\n"
"          sexsexsex           x                       x\r\n"
"           sexsexsex           x                     x\r\n"
"            sexsexsex           x                    x\r\n"
"              sexsexse            x                 x\r\n"
"               sexsexse            x                x\r\n"
"                 sexsexs           x                 x\r\n"
"                   sexsex sexsexse x                  x\r\n"
"                    sexsexsexsexsexs                   x\r\n"
"                      sexsexsexsexse                     x\r\n"
"                       sexsexsexsex               o       x\r\n"
"                            sexsex                        x\r\n"
"                             x                             x\r\n"
"                            x                              x\r\n"
"                           x                               x\r\n"
"                           x                      Y        x\r\n"
"                           x                      x        x\r\n"
"                           x                       x       x\r\n"
"                           x                        x      x\r\n"
"                           x                 sexsexsex     x\r\n"
"                           x            sexsexsexsexsx exsex\r\n"
"                           x          sexsexsexsexsexs sexx\r\n"
"                            x       sexsexsexsexsexsexs xx\r\n"
"                             x     sexsexsexsexsexsexse x\r\n"
"                              x   sexsexsexsexsexsexsexs\r\n"
"                               x sexsexsexsexsexsexsexse\r\n"
"                                 sexsexsexsexsexsexsexsex\r\n"
"                                  sexsexsexsexsexsexsexse\r\n"
"                                 x sexsexsexsexsexsexsexs\r\n"
"                                 xx sexsexsexsexsexsexsexs\r\n"
"                                 sex sexsexsexsexsexsexsex\r\n"
"                                  sex sexsexsexsexsexsexse\r\n"
"                                  sexs sexsexsexsexsexsexs\r\n"
"                                   sexse sexsexsexsexsexse\r\n"
"                                   sexsex sexsexsexsexsexse\r\n"
"                                    sexsex sexsexsexsexsexs\r\n"
"                                    sexsexs sexsexsexsexsex\r\n"
"                                     sexsexs sexsexsexsexse\r\n"
"                                     sexsexse sexsexsexsexs\r\n"
"                                     sexsexsex sexsexsexsex\r\n"
"                                     sexsexsexs  sexsexsexse\r\n"
"                                     sexsexsexs  sexsexsexse\r\n"
"                                    sexsexsexse   sexsexsexs\r\n"
"                                    sexsexsexs    sexsexsexse\r\n"
"                                   sexsexsexse    sexsexsexse\r\n"
"                                  sexsexsexse     sexsexsexse\r\n"
"                                 sexsexsexse      sexsexsexs\r\n"
"                                 sexsexsexse     sexsexsexse\r\n"
"                                sexsexsexsex     sexsexsexse\r\n"
"                                sexsexsexsex     sexsexsexse\r\n"
"                                sexsexsexsex     sexsexsexsex\r\n"
"                                sexsexsexse      sexsexsexsex\r\n"
"                                sexsexsexse      sexsexsexsex\r\n"
"                                 sexsexsexs      sexsexsexsex\r\n"
"                                 sexsexsexs       sexsexsexse\r\n"
"                                 sexsexsex        sexsexsexse\r\n"
"                                  sexsexse         sexsexsexs\r\n"
"                                  sexsexse          sexsexsex\r\n"
"                                   sexsexs           sexsexse\r\n"
"                                   sexsex             sexsexs\r\n"
"                                   sexsex              sexsexs\r\n"
"                                   sexsex               sexsex\r\n"
"                                    exsex                sexse\r\n"
"                                   sexsex                sexsex\r\n"
"                                   sexsex                sexsex\r\n"
"                                   sexsexs               sexsexx\r\n"
"                                  sexsexsex             sexsexse\r\n"
"                                 sexsexsexse          sexsexsexse\r\n"
"                                 sexsexsexsexs        sexsexsexsex\r\n"
"                                 sexsexsexsexse       sexsexsexsex\r\n"
"                                   sex    sexsexsex    sexsexsexsex\r\n"
"                                    x        sexsexse   xx sexsexse\r\n"
"                                                        x    sexsex\r\n"
"                                                              sexse\r\n"
"                                                              sexse\r\n"
"                                                              sexse\r\n"
"                                                                sex\r\n"
"                                                                 xx\r\n"
"                                                                 xx\r\n"
"\r\n"
;

void setup() {
  int i;
  
  for( i = 3; i <= 11; i++ ) {
    pinMode (i, OUTPUT);
    digitalWrite(i, LOW);
  }
  
  digitalWrite(PIN_nSTROBE, HIGH);
  pinMode (PIN_nACK, INPUT);
  pinMode (PIN_BUSY, INPUT);
  
  // DEBUG
  Serial.begin(9600);
}

void lpString(char* string) {
  /****************************
  http://www.beyondlogic.org/spp/parallel.htm
  
  Data is first applied on the Parallel Port pins 2 to 7.
  The host then checks to see if the printer is busy.
  i.e. the busy line should be low. The program then
  asserts the strobe, waits a minimum of 1uS, and then
  de-asserts the strobe. Data is normally read by the
  printer/peripheral on the rising edge of the strobe.
  he printer will indicate that it is busy processing data
  via the Busy line. Once the printer has accepted data,
  t will acknowledge the byte by a negative pulse about
  uS on the nAck line. 
  ****************************/
  
  int i = 0;
  while(char c = string[i++]) {
    // Spin on busy printer
    while (digitalRead(PIN_BUSY) == HIGH){;}

    // assert character to data lines
    for (uint8_t b=0; b<8; b++) {
      digitalWrite(4+b, c & 1);
      c = c >> 1;
    }
    
    delayMicroseconds(50); // settle
    
    // assert strobe,
    // then deassert strobe (commit data)
    digitalWrite(PIN_nSTROBE, LOW);
    delayMicroseconds(50); // settle
    digitalWrite(PIN_nSTROBE, HIGH);
    
    // ignore BUSY, wait for falling nACK
    while (digitalRead(PIN_nACK) == HIGH){;}
    
    // now wait for rising nACK 
    while (digitalRead(PIN_nACK) == LOW){;}
  }
}

void lpPorn(PGM_P string) {
  int i = 0, j = 0;
  char buf[80];
  
  while (buf[j++] = pgm_read_byte(&string[i++])) {
    
    // print a line a few times
    if (buf[j-1] == '\n') {
      buf[j-1] = 0; // terminate string
      for (int k=1; k<=5; k++) {
        lpString(buf);
        Serial.println(buf);
      }
      //
      lpString("\n");

      j = 0; // reset
    }
  }
}

void loop() {
  lpPorn(porn);
}
