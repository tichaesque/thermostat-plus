import processing.serial.*;

import cc.arduino.*;

Arduino arduino;

float rectwidth = 25;
float rectheight = 300;
float newheight = rectheight; 
float rate = 0f;
float targettemp = 0f;
float roomtemp = 0f; 

float temphigh = 86;
float templow = 50;

float remaining = 0;

float limittop = 170; 
float limitbottom = 150;
float timer = 2*PI;

float lastval = -1; 

int[] fanCol =  {0, #f2cd18, #a9f117}; 
String[] fanMode =  {"OFF", "AUTO", "ON"}; 
int mode = 1; 

float increment = 0; 
float sensorval;

void setup() {
  size(400, 750); 
  background(0);  
  pixelDensity(2); 
  rectMode(CENTER); 
  strokeWeight(4); 
  noStroke();

  textSize(20);
  textAlign(CENTER);
  
  arduino = new Arduino(this,Arduino.list()[3], 57600); 
  arduino.pinMode(3, Arduino.INPUT);
  arduino.pinMode(4, Arduino.INPUT);
  
  sensorval = arduino.analogRead(0);
  rectheight = (int) map(sensorval, 0, 1023, limitbottom, height*0.8-limittop);
  
  increment = (1024)/(temphigh-templow); 
}

void mouseDragged() { 
  float ypos = constrain(mouseY, limittop, height*0.8-limitbottom);
  newheight = height*0.8-ypos; 
}

void update() {
  sensorval = arduino.analogRead(0);
  
  if(abs(sensorval-lastval) >= increment) {
    newheight = (int) map(sensorval, 0, 1023, limitbottom, height*0.8-limittop);
    lastval = sensorval;
  }
  
  mode = 0; 
  //println(arduino.digitalRead(3), arduino.digitalRead(4)); 
  for(int i = 3; i <= 4; i++) {
    if(arduino.digitalRead(i) == Arduino.HIGH) {
      mode = i-2; 
      break;
    }
  }
}

void draw() {
  background(0);  
  
  update();  
  
  if(mode == 0) return;
  
  targettemp = map(newheight, limitbottom, height*0.8-limittop, templow, temphigh); 
  roomtemp = map(rectheight, limitbottom, height*0.8-limittop, templow, temphigh); 
  
  timer = map(abs(newheight-rectheight), height*0.8-limitbottom-limittop, 0, 1.5*PI, -PI/2);
  
  fill(#ff0000, 80); 
  quad(width/2-rectwidth, height*0.8, width/2+rectwidth, height*0.8, 
    width/2+rectwidth, limittop, width/2-rectwidth, limittop);


  color thermcol = #ff0000; 

  if (newheight > rectheight) {  
    color newcol = #ffc300;
    float amt = (0.4*sin(millis()/150f)+ 0.6); 
    thermcol = lerpColor(newcol, thermcol, amt);
  }
  if (newheight < rectheight) {
    color newcol = #a442f4;
    float amt = (0.4*sin(millis()/150f)+ 0.6); 
    thermcol = lerpColor(newcol, thermcol, amt);
  }
  
  noFill();
  strokeWeight(2); 
  stroke(255); 
  arc(width*0.5, height*0.8, 130, 130, PI,  TWO_PI-2.85*QUARTER_PI);
  arc(width*0.5, height*0.8, 130, 130, -HALF_PI+0.67,  0);
  
  // arrowhead
  pushMatrix();
  translate(width*0.5-130/2, height*0.8);
  rotate(radians(-20)); 
  line(0, 0, 0, -height*0.01);
  popMatrix(); 
  pushMatrix();
  translate(width*0.5-130/2, height*0.8);
  rotate(radians(40)); 
  line(0, 0, 0, -height*0.01);
  popMatrix(); 
  
  // arrowhead
  pushMatrix();
  translate(width*0.5+130/2, height*0.8);
  rotate(radians(20)); 
  line(0, 0, 0, -height*0.01);
  popMatrix(); 
  pushMatrix();
  translate(width*0.5+130/2, height*0.8);
  rotate(radians(-40)); 
  line(0, 0, 0, -height*0.01);
  popMatrix(); 
  
  
  
  noStroke(); 
  
  fill(255);
  textSize(18);
  text("-", width*0.5-130/2-20, height*0.8);
  text("+", width*0.5+130/2+20, height*0.8); 
  
  fill(thermcol);
  
  ellipse(width/2, height*0.8, 90, 90); 
  quad(width/2-rectwidth, height*0.8, width/2+rectwidth, height*0.8, 
    width/2+rectwidth, height*0.8-rectheight, width/2-rectwidth, height*0.8-rectheight); 


  if (rectheight > newheight) {
    rectheight -= 0.125; 

    fill(255); 
    arc(width/2, height*0.8, 80, 80, -PI/2, timer, PIE);
    noStroke();

    textSize(20);
    text("Target:", width*0.7, height*0.8-newheight);
    textSize(30);
    text(int(targettemp)+ "°F", width*0.7, height*0.8-newheight+30);
  }

  if (rectheight < newheight) {
    rectheight += 0.125; 

    fill(255);  
    arc(width/2, height*0.8, 80, 80, -PI/2, timer, PIE);
    noStroke();
    textSize(20);
    text("Target:", width*0.7, height*0.8-newheight);
    textSize(30);
    text(int(targettemp)+ "°F", width*0.7, height*0.8-newheight+30);
  }

  strokeWeight(4); 
  stroke(255);
  line(width/2-rectwidth, height*0.8-newheight, width/2+rectwidth, height*0.8-newheight);
  noStroke(); 

  fill(255); 
  textSize(20);
  text("Room:", width*0.5, height*0.15);
  textSize(30);
  text(int(roomtemp)+ "°F", width*0.5, height*0.15+30); 
  
  textSize(13);
  text("Fan "+fanMode[mode], width*0.5, height*0.95); 
  
  fill(fanCol[mode]); 
  rect(width*0.5, height*0.91, 60, 22, 10);
   
}
