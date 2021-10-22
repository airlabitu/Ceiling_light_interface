import controlP5.*;
import processing.serial.*;

Serial MyPort; // Serial object

ControlP5 cp5;

CheckBox RGB_Checkbox;
CheckBox DimmerBlock_Checkbox;
CheckBox Flood_Checkbox;

long lastUpdate;
int updateRate = 50; // speed of DMX update for sliders

int [] RGBLampAddresses = {301, 307, 313, 319, 325, 331, 337, 343};
int [] DimmBlockAddresses = {432, 433, 434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447}; // 432; chan <= 447
int [] FloodLampAddresses = {464, 466, 468, 470, 472, 474, 476, 478}; // 464; chan <= 479

int sliderRed;
int sliderGreen;
int sliderBlue;
int sliderAlpha;

int sliderWarm;
int sliderCold;

float [] FloodLamps = new float [8]; // for storing on/off state of flood lamps

float [] RGBLamps = new float [8]; // for storing on/off state of RGB lamps


void setup() {
  size(900, 800);
  background(0);
  noStroke();
  println(Serial.list());
  
  // --- INTERFACE GROUPE BOXES ---
  noFill();
  stroke(255);
  textSize(30);
    // RGB spots
  rect(20, 50, 310, 300);
  text("RGB spots", 40, 85);
    // Flood lamps
  rect(420, 50, 350, 300);
  text("Flood lamps", 440, 85);
    // Dimmer blocks
  rect(20, 370, 350, 300);
  text("Dimmer blocks", 40, 405);
  
  
  // --- CONNECTION TO SERIAL DEVICES ---
  for (int i = 0; i < Serial.list().length; i++){ // Arduino connected to universe 2
    println(Serial.list()[i]);
      //if (Serial.list()[i].indexOf("/dev/ttyACM0") != -1) {
      if (Serial.list()[i].indexOf("/dev/tty.usbmodem") != -1) {
      println("Serial connection to: ", Serial.list()[i]);
      MyPort = new Serial(this, Serial.list()[i], 9600);
    }
  }
  

  // --- GUI SETUP ---
  
  cp5 = new ControlP5(this);
  
  // on/off checkboxes for RGB spots
  RGB_Checkbox = cp5.addCheckBox("checkBox_RGB")
    .setPosition(40, 230)
    .setSize(40, 40)
    .setItemsPerRow(4)
    .setSpacingColumn(30)
    .setSpacingRow(20)
    .addItem("RGB 1", 1)
    .addItem("RGB 2", 2)
    .addItem("RGB 3", 3)
    .addItem("RGB 4", 4)
    .addItem("RGB 5", 5)
    .addItem("RGB 6", 6)
    .addItem("RGB 7", 7)
    .addItem("RGB 8", 8)
    ;
  
  // on/off checkboxes for Flood lamps
  Flood_Checkbox = cp5.addCheckBox("checkBox_Flood")
    .setPosition(440, 230)
    .setSize(40, 40)
    .setItemsPerRow(4)
    .setSpacingColumn(40)
    .setSpacingRow(20)
    .addItem("Flood 1", 1)
    .addItem("Flood 2", 2)
    .addItem("Flood 3", 3)
    .addItem("Flood 4", 4)
    .addItem("Flood 5", 5)
    .addItem("Flood 6", 6)
    .addItem("Flood 7", 7)
    .addItem("Flood 8", 8)
    ;
  
  // on/off checkboxes for dimmer blocks
  DimmerBlock_Checkbox = cp5.addCheckBox("checkBox_dimm")
    .setPosition(40, 430)
    .setSize(40, 40)
    .setItemsPerRow(4)
    .setSpacingColumn(40)
    .setSpacingRow(20)
    .addItem("Dimm 1", 1)
    .addItem("Dimm 2", 2)
    .addItem("Dimm 3", 3)
    .addItem("Dimm 4", 4)
    .addItem("Dimm 5", 5)
    .addItem("Dimm 6", 6)
    .addItem("Dimm 7", 7)
    .addItem("Dimm 8", 8)
    .addItem("Dimm 9", 8)
    .addItem("Dimm 10", 8)
    .addItem("Dimm 11", 8)
    .addItem("Dimm 12", 8)
    .addItem("Dimm 13", 8)
    .addItem("Dimm 14", 8)
    .addItem("Dimm 15", 8)
    .addItem("Dimm 16", 8)
    ;


  // Toggle for dimmer blocks giving power to flood lamps
  cp5.addToggle("toggle").setCaptionLabel("  ON    /  OFF")
    .setPosition(440, 50+50)
    .setSize(50, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    ;
    
// --- Flood lamp sliders ---
  // add a vertical slider
  cp5.addSlider("Warm")
    .setPosition(440, 50+50+25+25)
    .setSize(200, 20)
    .setRange(0, 255)
    .setValue(sliderWarm)
    ;

  // add a vertical slider
  cp5.addSlider("Cold")
    .setPosition(440, 75+50+25+25)
    .setSize(200, 20)
    .setRange(0, 255)
    .setValue(sliderCold)
    ;


// --- RGB Lamp sliders ---
  // add a vertical slider
  cp5.addSlider("Red")
    .setPosition(40, 50+50)
    .setSize(200, 20)
    .setRange(0, 255)
    .setValue(sliderRed)
    ;

  // add a vertical slider
  cp5.addSlider("Green")
    .setPosition(40, 75+50)
    .setSize(200, 20)
    .setRange(0, 255)
    .setValue(sliderGreen)
    ;

  // add a vertical slider
  cp5.addSlider("Blue")
    .setPosition(40, 100+50)
    .setSize(200, 20)
    .setRange(0, 255)
    .setValue(sliderBlue)
    ;

  // add a vertical slider
  cp5.addSlider("Alpha")
    .setPosition(40, 125+50)
    .setSize(200, 20)
    .setRange(0, 255)
    .setValue(sliderAlpha)
    ;
}

// --- GUI EVENT FUNCTIONS ---
void Red(int theColor) {
  sliderRed = theColor;
  updateRGBLamps("RED", sliderRed); // update lamps with new color
}

void Green(int theColor) {
  sliderGreen = theColor;
  updateRGBLamps("GREEN", sliderGreen); // update lamps with new color
}

void Blue(int theColor) {
  sliderBlue = theColor;
  updateRGBLamps("BLUE", sliderBlue); // update lamps with new color
}

void Alpha(int theColor) {
  sliderAlpha = theColor;
  updateRGBLamps("ALPHA", sliderAlpha); // update lamps with new color
}

void toggle(int state){
  println("test");
  MyPort.write((DimmBlockAddresses[0]) + "c" + (int)(state*255) + "w");
}

void Warm(int theColor){
  sliderWarm = theColor;
  updateFloodLamps("WARM", sliderWarm);
}

void Cold(int theColor){
  sliderCold = theColor;
  updateFloodLamps("COLD", sliderCold);
}

void toggle(boolean theFlag) {
  if (theFlag){
    DimmerBlock_Checkbox.activate(0);
    DimmerBlock_Checkbox.activate(12);
  }
  else {
    DimmerBlock_Checkbox.deactivate(0);
    DimmerBlock_Checkbox.deactivate(12);
  }
  // send commands out on DMX controllers
  MyPort.write((DimmBlockAddresses[0]) + "c" + (int(theFlag)*255) + "w");
  MyPort.write((DimmBlockAddresses[12]) + "c" + (int(theFlag)*255) + "w");
}

void checkBox_RGB(float[] a) {
  RGBLamps = a;
}

void checkBox_dimm(float[] a){
  for (int i = 0; i < 16; i++){
    //println((int)(a[i]*255)); 
    MyPort.write((DimmBlockAddresses[i]) + "c" + (int)(a[i]*255) + "w");
  }
}

void checkBox_Flood(float [] a){
  FloodLamps = a;
}

// update function that updates all active RGB lamps with a new color
void updateRGBLamps(String col, int val) {
  if (lastUpdate + updateRate < millis()){
    for (int i = 0; i < 8; i++) {
      if (RGBLamps[i] == 1.0) { // if the lamp is turned on
        // send dmx command to lamp
        if (col == "ALPHA") MyPort.write((RGBLampAddresses[i]) + "c" + val + "w");
        else if (col == "RED") MyPort.write((RGBLampAddresses[i]+1) + "c" + val + "w");
        else if (col == "GREEN") MyPort.write((RGBLampAddresses[i]+2) + "c" + val + "w");
        else if (col == "BLUE") MyPort.write((RGBLampAddresses[i]+3) + "c" + val + "w");
      }
    }
    lastUpdate=millis();
  }
  
}

void updateFloodLamps(String col, int val){
  if (lastUpdate + updateRate < millis()){
   for (int i = 0; i < 8; i++) {
      if (FloodLamps[i] == 1.0) { // if the lamp is turned on
        // send dmx command to lamp
        if (col == "WARM") MyPort.write((FloodLampAddresses[i]+1) + "c" + val + "w");
        else if (col == "COLD") MyPort.write((FloodLampAddresses[i]) + "c" + val + "w");
      }
    }
  lastUpdate=millis();
  }
}

void draw() {
}
