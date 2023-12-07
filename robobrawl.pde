import controlP5.*; 
import processing.serial.*;
import java.awt.*;
import java.awt.event.*;

Serial bluePort;
Serial orangePort;

static int MATCH_TIME = 180200; //3 MINUTES + 3 SECOND COUNTDOWN

ControlP5 cp5; 
ControlP5 cp5session1;
ControlP5 cp5session2;
ControlP5 cp5session3;
ControlP5 cp5session4;
ControlP5 cp5session5;
boolean blueReady = false;
boolean orangeReady = false;
boolean matchStarted = false;
PFont font;
boolean firstContact = false;
String val = "-1 -1 -1 -1"; //4 nulls for all 4 buttons
String orangeval = "-1 -1 -1 -1";
int savedTime;
int totalTime = MATCH_TIME;
int currSession = 1;
boolean tapout = false;

String prevVal0 = "";
String prevVal1 = "";
String prevVal2 = "";
String prevVal3 = "";
color prevVal4 = color(0, 0, 0);
color prevVal5 = color(0, 0, 0);

color initial = color(254, 255, 219);
color standardBlue = color(0, 0, 255);
color standardOrange = color(207, 106, 0);
color win = color(0, 255, 0);
color lose = color(255, 0, 0);
color pause = color(100, 100, 100);
color judges = color(100, 100, 100);

Robot robot;
/*
sessions
1 - power
2 - match is ready
3 - match is live
4 - match is paused
5 - judges decision
6 - blue ko
7 - blue tap out
8 - orange ko
9 - orange tap out

colors 
0 - initial (beige)
1 - standard (blue or orange)
2 - win (green)
3 - lose (red)
4 - countdown (pulse)
5 - pause (grey)
6 - judges decision (yellow)
*/

void setup(){
  fullScreen();
  surface.setSize(250, 130);
  surface.setLocation(1670, 0);
  surface.setAlwaysOnTop(true);
  //bluePort = new Serial(this, "COM5", 9600);
  //bluePort.bufferUntil('\n');
  orangePort = new Serial(this, "COM4", 9600);
  orangePort.bufferUntil('\n');
  //serialEvent(bluePort);
  serialEvent(orangePort);
  cp5 = new ControlP5(this);
  cp5session1 = new ControlP5(this);
  cp5session2 = new ControlP5(this);
  cp5session3 = new ControlP5(this);
  cp5session4 = new ControlP5(this);
  cp5session5 = new ControlP5(this);
  font = createFont("Arial", 20); 
  try { 
    robot = new Robot();
    robot.setAutoDelay(0);
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
  frameRate(20);
  cp5session1.addButton("power")
    .setColorForeground(color(170, 0, 0))
    .setColorBackground(color(120, 0, 0))
    .setPosition(0,0)
    .setSize(100, 50)      
    .setFont(font)
  ;
  cp5session2.addButton("ready")
    .setColorForeground(color(0, 170, 0))
    .setColorBackground(color(0, 120, 0))
    .setPosition(0,0)
    .setSize(100, 50)      
    .setFont(font)
  ;
  cp5session3.addButton("pause")
    .setColorForeground(color(120, 120, 0))
    .setColorBackground(color(80, 80, 0))
    .setPosition(0,0)
    .setSize(100, 50)      
    .setFont(font)
  ;
  cp5session4.addButton("unpause")
    .setColorForeground(color(120, 120, 0))
    .setColorBackground(color(80, 80, 0))
    .setPosition(0,0)
    .setSize(100, 50)      
    .setFont(font)
  ;
  cp5session5.addButton("judges")
    .setColorForeground(color(100, 100, 0))
    .setColorBackground(color(60, 60, 0))
    .setPosition(0,0)
    .setSize(100, 50)      
    .setFont(font)
  ;
  cp5.addButton("bwin") 
    .setColorForeground(color(90, 147, 255))
    .setColorBackground(color(48, 109, 212)) //blue
    .setPosition(0, 50) 
    .setSize(100, 40)
    .setLabel("b ko")
    .setFont(font)
  ;
  cp5.addButton("owin")
    .setColorForeground(color(255, 160, 80))
    .setColorBackground(color(255, 119, 31)) //blue
    .setPosition(0, 90) 
    .setSize(100, 40)
    .setLabel("o ko")
    .setFont(font)
  ;
  cp5session2.setVisible(false);
  cp5session3.setVisible(false);
  cp5session4.setVisible(false);
  cp5session5.setVisible(false);
  surface.setResizable(false);
}

void draw(){ 
  //if (bluePort.available() > 0) {
  //  val = bluePort.readStringUntil('\n'); //read arduino serial
  //} else {
  //  println("no red");
  //}
  //if (orangePort.available() > 0) {
  //  orangeval = bluePort.readStringUntil('\n');
  //} else {
  //  println("no read");
  //}
  font = createFont("Arial Bold", 20);
  textAlign(CENTER, TOP);
  fill(0, 0, 0);  
  textFont(font);
  textSize(15);
  rect(0, 0, 250, 130);
  fill(244,243,244);
  rect(102, 2, 146, 22);
  fill(48, 109, 212); //blue
  rect(102, 26, 72, 101);
  fill(255, 119, 31);
  rect(176, 26, 72, 101);
  fill(255, 255, 255); 
  text("READY", 138, 27);
  text("READY", 212, 27);
  text("TRIGGER", 138, 77);
  text("TRIGGER", 212, 77);
  textSize(18);
  try {
    String[] values = val.split(" "); //split all 4 values under each space
    String[] orangeValues = orangeval.split(" ");
    //switch (Integer.valueOf(values[4])) {
    //  case 0:
    //    fill(initial);
    //    prevVal4 = initial;
    //    break;
    //  case 1:
    //    fill(standardBlue);
    //    prevVal4 = standardBlue;
    //    break;
    //  case 2:
    //    fill(win);
    //    prevVal4 = win;
    //    break;
    //  case 3:
    //    fill(lose);
    //    prevVal4 = lose;
    //    break;
    //  case 4: 
    //    fill(standardBlue);
    //    prevVal4 = standardBlue;
    //    break;
    //  case 5:
    //    fill(pause);
    //    prevVal4 = pause;
    //    break;
    //  case 6:
    //    fill(judges);
    //    prevVal4 = judges;
    //    break;
    //}
    text(values[0], 138, 47);
    text(orangeValues[0], 212, 47);
    text(values[3], 138, 98);
    text(orangeValues[3], 212, 98);
    prevVal0 = values[0];
    prevVal1 = orangeValues[0];
    prevVal2 = values[3];
    prevVal3 = orangeValues[3];
    if(Integer.valueOf(values[1]) == 1 && blueReady != true) {
      blueReady = true;
      try {
        robot.keyPress(java.awt.event.KeyEvent.VK_PAGE_UP);
        delay(100);
        robot.keyRelease(java.awt.event.KeyEvent.VK_PAGE_UP);
      } catch (Exception e) {}  
    }
    if(Integer.valueOf(values[1]) == 2) {
      tapout = true;
      owin();
    }
    if(Integer.valueOf(orangeValues[1]) == 1 && orangeReady != true) {
      orangeReady = true;
      try {
        robot.keyPress(java.awt.event.KeyEvent.VK_PAGE_DOWN);
        delay(100);
        robot.keyRelease(java.awt.event.KeyEvent.VK_PAGE_DOWN);
      } catch (Exception e) {}  
    }
    if(Integer.valueOf(orangeValues[1]) == 2) bwin(); 
    //println(orangeValues[3]);
  }
  catch (Exception e) {
    text(prevVal0, 138, 47);
    text(prevVal1, 212, 47);
    text(prevVal2, 138, 98);
    text(prevVal3, 212, 98);
  }
  String headerText = "";
  switch (currSession) {
    case 1:
      headerText = "CONNECTIONS";
      break;
    case 2:
      headerText = "MATCH READY";
      break;
    case 3:
      headerText = "LIVE: " + totalTime / 60000 + ":";
      if ((totalTime % 60000) / 1000 < 10) headerText += ("0" + (totalTime % 60000) / 1000);
      else headerText += ("" + (totalTime % 60000) / 1000);
      break;
    case 4:
      headerText = "PAUSED: " + totalTime / 60000 + ":";
      if ((totalTime % 60000) / 1000 < 10) headerText += ("0" + (totalTime % 60000) / 1000);
      else headerText += ("" + (totalTime % 60000) / 1000);
      break;
    case 5:
      headerText = "TIMER EXPIRED";
      break;
    case 6:
      headerText = "BLUE TEAM KO";
      break;
    case 8:
      headerText = "ORANGE TEAM KO";
      break;
  }
  fill(0, 0, 0); 
  textSize(15);
  text(headerText, 175, 5); 
  
  
  delay(195); //set to adjust for lag
  if (matchStarted) {
    totalTime -= 200;
    countdown();
  }
}

void power(){
  cp5session1.setVisible(false);
  cp5session2.setVisible(true);
  //bluePort.write('p');
  orangePort.write('p');
  println("power");
  currSession = 2;
  blueReady = false;
  orangeReady = false;
}

void ready(){
  if (blueReady && orangeReady){
    cp5session2.setVisible(false);
    cp5session3.setVisible(true);
    //bluePort.write('r');
    orangePort.write('r');
    println("ready");
    totalTime = MATCH_TIME + 3000;
    matchStarted = true;
    currSession = 3;
    tapout = false;
    try {
      robot.keyPress(java.awt.event.KeyEvent.VK_HOME);
      delay(100);
      robot.keyRelease(java.awt.event.KeyEvent.VK_HOME);
    } catch (Exception e) {
    }  
  }
}

void countdown(){
  if(totalTime < 0){
    cp5session3.setVisible(false);
    cp5session5.setVisible(true);
    currSession = 5;
  }
  else if(totalTime == 180000) {
    //bluePort.write('l');
    orangePort.write('l');
    println("match live");
    try {
      robot.keyPress(java.awt.event.KeyEvent.VK_F12);
      delay(100);
      robot.keyRelease(java.awt.event.KeyEvent.VK_F12);
    } catch (Exception e) {
    }  
  }
}

void pause(){
  cp5session3.setVisible(false);
  cp5session4.setVisible(true);
  //bluePort.write('e');
  orangePort.write('e');
  println("pause");
  matchStarted = false;
  currSession = 4;
  try {
    robot.keyPress(java.awt.event.KeyEvent.VK_F12);
    delay(100);
    robot.keyRelease(java.awt.event.KeyEvent.VK_F12);
  } catch (Exception e) {
  }  
}

void unpause(){
  cp5session4.setVisible(false);
  cp5session3.setVisible(true);
  //bluePort.write('u');
  orangePort.write('u');
  println("unpause");
  matchStarted = true;
  currSession = 3;
  try {
    robot.keyPress(java.awt.event.KeyEvent.VK_F12);
    delay(100);
    robot.keyRelease(java.awt.event.KeyEvent.VK_F12);
  } catch (Exception e) {
  }  
}

void judges(){
  cp5session5.setVisible(false);
  cp5session1.setVisible(true);
  //bluePort.write('j');
  orangePort.write('j');
  println("judges");
  matchStarted = false;
  currSession = 1;
}

void bwin(){
  //bluePort.write('b');
  orangePort.write('o');
  println("blue team wins");
  cp5session3.setVisible(false);
  cp5session4.setVisible(false);
  cp5session5.setVisible(false);
  cp5session1.setVisible(true);
  currSession = 6;
  matchStarted = false;
}

void owin(){
  //bluePort.write('o');
  orangePort.write('b');
  println("orange team wins")  ;
  cp5session3.setVisible(false);
  cp5session4.setVisible(false);
  cp5session5.setVisible(false);
  cp5session1.setVisible(true);
  currSession = 8;
  matchStarted = false;
  try {
    if (tapout) {
      robot.keyPress(java.awt.event.KeyEvent.VK_F9);
      delay(100);
      robot.keyRelease(java.awt.event.KeyEvent.VK_F9); 
    } else {
      robot.keyPress(java.awt.event.KeyEvent.VK_F10);
      delay(100);
      robot.keyRelease(java.awt.event.KeyEvent.VK_F10); 
    }
    robot.keyPress(java.awt.event.KeyEvent.VK_F12);
    delay(100);
    robot.keyRelease(java.awt.event.KeyEvent.VK_F12);
  } catch (Exception e) {}  
}

void serialEvent(Serial myPort) {
  val = myPort.readStringUntil('\n');
  if (val != null) {
    val = trim(val);
    println(val);
    if (val.contains("O")){
      orangeval = val;
    }
    if (firstContact == false) {
      if (val.equals("A")) {
        myPort.clear();
        firstContact = true;
        myPort.write("A");
        println("contact");
      }
    }
    else {
      myPort.write("A");
    }
  }
}
