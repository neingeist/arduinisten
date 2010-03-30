#include <avr/interrupt.h>
#include <avr/io.h>
#include <LCD4Bit.h>
#include <assert.h>

#define DEBUG 0

LCD4Bit lcd = LCD4Bit(2);

int pinA = 11;
int pinB = 12;
int ledPin = 13;

volatile int8_t enc_value = 0;
volatile int8_t enc_value_old = 0;

void awesome_scroller() {
  // the logo
  lcd.cursorTo(1,13);
  lcd.printIn("ARDUINO POING");
  lcd.cursorTo(2,1);
  lcd.printIn("shall i prewarm sir's rotary encoder?");

  // awesum fx
  delay(500);
  lcd.cursorTo(2,39);
  for (int i=0; i<80; i++) {
    lcd.print(' ');
    delay(100);
  }
}

#define SCALE 64
#define COLS        20
#define PADDLE2_POS (COLS-1)

int ball_x, ball_y;
int ball_vel_x, ball_vel_y;
uint8_t level;

void setup_game() {
  lcd.clear();

  // reinit stuff
  ball_x = 2*SCALE;
  ball_y = random(0,16);
  ball_vel_x = 1.0 * SCALE;
  ball_vel_y = 1.0 * SCALE;

  //
  for (int i=PADDLE2_POS+2; i<=39; i++) {
    lcd.cursorTo(2, i);
    lcd.print(' ');
  }

  // level
  level = 1;
  display_level();

  // init paddles
  enc_value = 0; 
  display_paddle(0,2);
  display_paddle(1,2);
}

void setup() {
  //Timer2 Settings
  TCCR2A = 0;
  TCCR2B = 0<<CS22 | 1<<CS21 | 0<<CS20;

  //Timer2 Overflow Interrupt Enable
  TIMSK2 = 1<<TOIE2;

  // pullups  
  digitalWrite(pinA, HIGH); 
  digitalWrite(pinB, HIGH); 

  // init lcd
  lcd.init();
  lcd.clear();
  
  // init serial
  Serial.begin(9600);

  // intro
  // awesome_scroller();
 
  // 
  setup_game(); 
}

#define ENC_STEPS 2
static int last;
ISR(TIMER2_OVF_vect) {
  int neu, diff;

  // convert gray to binary 
  neu = 0;
  if(digitalRead(pinA))
    neu = 3;
  if(digitalRead(pinB))
    neu ^= 1;
    
  diff = last - neu;				// difference last - new
  if( diff & 1 ) {				// bit 0 = value (1)
    last = neu;					// store new as next last
    enc_value += (diff & 2) - 1;		// bit 1 = direction (+/-)
  }

  // begrenze enc_value
  if (enc_value < 1*ENC_STEPS)
    enc_value = 1*ENC_STEPS;
  if (enc_value > 14*ENC_STEPS)
    enc_value = 14*ENC_STEPS;
}



void display_paddle (int paddle, int pos) {
  #define CHAR_PADDLE paddle
  
  assert(paddle == 0 || paddle == 1);
  
  // blank first
  lcd.cursorTo(1,paddle*(COLS-1)); lcd.print(' ');
  lcd.cursorTo(2,paddle*(COLS-1)); lcd.print(' ');

  // gen char
  lcd.commandWrite(0x40+CHAR_PADDLE*8); // char 0b00
  for (uint8_t i = 0; i<8; i++) {
    if(i == (pos & 0x7) || i-1 == (pos & 0x7) || i+1 == (pos & 0x7) ) {
      if (paddle == 0) {
        lcd.print(0b00011);
      } else {
        lcd.print(0b11000);
      }
    } else {
      lcd.print(0b00000);
    }
  }

  // display shit
  if (pos < 8) {
    lcd.cursorTo(1,paddle*PADDLE2_POS); lcd.print(CHAR_PADDLE);
    lcd.cursorTo(2,paddle*PADDLE2_POS); lcd.print(' ');
  } else {  
    lcd.cursorTo(1,paddle*PADDLE2_POS); lcd.print(' ');
    lcd.cursorTo(2,paddle*PADDLE2_POS); lcd.print(CHAR_PADDLE);
  }
}

#define BALL_X_MAX (COLS-2)
#define res_x BALL_X_MAX*5*SCALE
#define res_y 16*SCALE

void move_ball () {
  ball_x += ball_vel_x;
  ball_y += ball_vel_y;
  
  if (ball_x >= res_x || ball_x < 0) {
    ball_vel_x *= -1;
    ball_x += ball_vel_x;
  }
  
  if (ball_y >= res_y || ball_y < 0) {
    ball_vel_y *= -1;
    ball_y += ball_vel_y;
  }
}

int cursor_x_alt = 1;
int cursor_y_alt = 1;

void display_ball () {
  #define CHAR_BALL 2

  int cursor_x = (ball_x/SCALE)/5+1;
  int cursor_y = (ball_y/SCALE)/8+1;
  
  // first, delete old ball
  if (cursor_x != cursor_x_alt || cursor_y != cursor_y_alt) {
    lcd.cursorTo(cursor_y_alt, cursor_x_alt);
    lcd.print(' ');
  }
  cursor_x_alt = cursor_x;
  cursor_y_alt = cursor_y;
 
  // second, generate character for new ball
  lcd.commandWrite(0x40+CHAR_BALL*8);
  for (int i = 0; i<8; i++) {
    if(i == ((ball_y/SCALE)&7)) {
      lcd.print(1 << 4-(ball_x/SCALE)%5);
    } else {
      lcd.print(0b00000);
    }
  }
  
  // third, write new ball
  lcd.cursorTo(cursor_y, cursor_x);
  lcd.print(CHAR_BALL);
}

void game_over() {
  for (int8_t i=0; i<7; i++) {
    lcd.cursorTo(2, PADDLE2_POS + 2);
    lcd.printIn("          ");
    delay(100);

    lcd.cursorTo(2, PADDLE2_POS + 2);
    lcd.printIn("GAME OVER.");
    delay(200);
  }
  delay(1000);
  
  while(enc_value == enc_value_old);
  setup_game();
}

void display_level() {
  lcd.cursorTo(1, PADDLE2_POS + 2);
  lcd.printIn("LEVEL ");
  
  char level_str[4];
  itoa(level, level_str, 10);
  lcd.printIn(level_str);
}

void level_up() {
  // pump it up
  level++;
  display_level();
 
  // make ball faster
  // 70 / 64 is about 1.1
  ball_vel_x = ball_vel_x * 70 / 64; 
}

int player2 = random(1,14);
void loop() {
  // move player1's paddle
  int val = enc_value;
  enc_value_old = val;
  display_paddle(0, val/ENC_STEPS);

  // teh ball!
  move_ball();
  display_ball();
  
  // incoming ball? WIN or FAIL.
  if (ball_x/SCALE < 1 && ball_vel_x < 0) {
    if (val/ENC_STEPS-1 != ball_y/SCALE
     && val/ENC_STEPS   != ball_y/SCALE
     && val/ENC_STEPS+1 != ball_y/SCALE) {
      game_over();
    } else {
      level_up();
    }
  }
  
  // fake computer player2 by moving its paddle in
  // direction of the ball's vertical position
  if (ball_vel_x > 0 && ball_x/SCALE > (BALL_X_MAX-4)*5) {
    if (player2 < ball_y/SCALE && player2 < 14)
      player2++;
    if (player2 > ball_y/SCALE && player2 > 1)
      player2--;
  }
  display_paddle(1, player2); 
}
