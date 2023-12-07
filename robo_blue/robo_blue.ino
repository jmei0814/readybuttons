//LIBRARIES
#include <Adafruit_DotStar.h>
#include <SPI.h>
#include <ezButton.h>
#include <math.h>

//PIN DEFINITIONS
#define DATAPIN   4
#define CLOCKPIN  5
#define READYPIN  6
#define TAPOUTPIN 7

//CONNECTION INITS
Adafruit_DotStar strip(30, DATAPIN, CLOCKPIN, DOTSTAR_BRG);
ezButton readybutton(READYPIN);
ezButton tapoutbutton(TAPOUTPIN);

//VARIABLE DECLARATIONS
uint32_t initial = strip.Color(48, 109, 212);
uint32_t wingreen = strip.Color(0, 254, 0);
uint32_t losered = strip.Color(0, 0, 254);
uint32_t blue = strip.Color(254, 0, 0);
uint32_t pausegrey = strip.Color(100, 100, 100);
uint32_t judgeyellow = strip.Color(0, 254, 254);
uint32_t color = initial;
int brightness = 64; 
char receipt;
int trigger = 0;
int val0 = -1;
int val1 = 0;
int tap = 0;
int c1 = 0;
int pulse = 0;
bool newData = true;

void setup() {
  Serial.begin(9600);
  strip.begin();
  strip.show(); 
  establishContact();
}

/*
trigger cases

0 - intialization
1 - waiting for buttons to be ready
2 - button pressed
3 - button released
4 - match countdown
5 - match live
6 - blue team KO
7 - orange team KO
8 - pause
9 - judges decision

serial reads
p - power on from intiialization, waiting on buttons
r - match is ready, start countdown
l - match is live
e - pause match
u - unpause match
b - blue team wins (by tap out or knock out)
o - orange team wins (by tap out or knock out)
j - judges decision
*/

void loop() {
  readybutton.loop();
  tapoutbutton.loop();
  if (Serial.available() > 0) { // If data is available to read,
    receipt = Serial.read();
  } else {
    establishContact();
  }
  if(receipt == 'p') {
    trigger = 1;
    newData = true;
    val1 = 0;
  }
  else if(receipt == 'r') {
    trigger = 4;
    newData = true;
  }
  else if(receipt == 'l') {
    trigger = 5;
    newData = true;
  }
  else if(receipt == 'u') {
    trigger = 5;
    newData = true;
  }
  else if(receipt == 'b') {
    trigger = 6;
    newData = true;
    val1 = 0;
  }
  else if(receipt == 'o') {
    trigger = 7;
    newData = true;
    val1 = 0;
  }
  else if(receipt == 'e') {
    trigger = 8;
    newData = true;
  }
  else if(receipt == 'j') {
    trigger = 9;
    newData = true;
  }
  if(readybutton.isPressed() && trigger == 1) {
    trigger = 2;
    newData = true;
  }
  if(readybutton.isReleased() && trigger == 2) {
    trigger = 3;
    newData = true;
    val1 = 1;
  }
  if(tapoutbutton.isPressed() && trigger == 5) {
    trigger = 7;
    newData = true;
    val1 = 2;
  }
  if (newData) {
    setButtonColor();
  }
  sendData();
  delay(250);
}

void sendData(){
  Serial.println("" + String(val0) + " " + val1 + " " + c1 + " " + trigger + " B");
}
int head  = 0, tail = -10; 
void setButtonColor() {
  switch (trigger) {
    case(0):
      color = initial;
      brightness = 128;
      c1 = 0;
      break;
    case(1):
      color = blue;
      brightness = 100;
      c1 = 1;
      break;
    case(2):
      color = blue;
      brightness = 64;
      c1 = 1;
      break;
    case(3):
      color = blue;
      brightness = 254;
      c1 = 1;
      break;
    case(4):
      color = blue;
      brightness = 100;
      c1 = 4;
      break;
    case(5):
      color = wingreen;
      brightness = 100;
      c1 = 2;
      break;
    case(6):
      color = wingreen;
      brightness = 254;
      c1 = 3;
      break;
    case(7):
      color = losered;
      brightness = 128;
      c1 = 2;
      break;
    case(8):
      color = pausegrey;
      brightness = 30;
      c1 = 5;
      break;
    case(9):
      color = judgeyellow;
      brightness = 128;
      c1 = 6;
      break;
  }
  newData = false;
  val0 = brightness;
  strip.setBrightness(brightness);
  strip.fill(color, 0, 30);
  strip.show();
}

void establishContact() {
  while (Serial.available() <= 0) {
    Serial.println("A");   // send a capital A
    delay(300);
    color = losered;
    strip.setBrightness(10);
    strip.fill(color, 0, 30);
    strip.show();
  }
}