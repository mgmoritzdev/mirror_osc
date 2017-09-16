/**
 * Mirror 
 * by Daniel Shiffman.  
 *
 * Each pixel from the video source is drawn as a rectangle with rotation based on brightness.   
 */

import processing.video.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress remote;

int i = 0;
float j = 0;

// Size of each cell in the grid
int cellSize = 20;

// Number of columns and rows in our system
int cols, rows;

int rOn = 1, gOn = 1, bOn = 1;
int colorOn = 0;
boolean capturing = true;


// Variable for capture device
Capture video;


void setup() {
  size(640, 480);
  frameRate(30);
  cols = width / cellSize;
  rows = height / cellSize;


  colorMode(RGB, 255, 255, 255, 100);

  // This the default video input, see the GettingStartedCapture 
  // example if it creates an error
  video = new Capture(this, width, height);

  // Start capturing the images from the camera
  video.start();  

  background(0);

  oscP5 = new OscP5(this, 12000);
  remote = new NetAddress("10.0.0.108", 8080);
}


void draw() { 
  if (video.available() && capturing) {
    video.read();
    video.loadPixels();

    // Begin loop for columns
    for (int i = 0; i < cols; i++) {
      // Begin loop for rows
      for (int j = 0; j < rows; j++) {

        // Where are we, pixel-wise?
        int x = i*cellSize;
        int y = j*cellSize;
        int loc = (video.width - x - 1) + y*video.width; // Reversing x to mirror the image

        float r = red(video.pixels[loc]);
        float g = green(video.pixels[loc]);
        float b = blue(video.pixels[loc]);
        // Make a new color with an alpha component
        color c = color(r * rOn, g * gOn, b * bOn, 75);

        // Code for drawing a single rect
        // Using translate in order for rotation to work properly
        pushMatrix();
        translate(x+cellSize/2, y+cellSize/2);
        // Rotation formula based on brightness
        rotate((2 * PI * brightness(c) / 255.0));
        rectMode(CENTER);
        fill(c);
        noStroke();
        // Rects are larger than the cell for some overlap
        int overlap = floor((float) cellSize / 2.5);
        rect(0, 0, cellSize+overlap, cellSize+overlap);
        popMatrix();
      }
    }
  }
}

void oscEvent(OscMessage theOscMessage) {
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());

  if (theOscMessage.checkAddrPattern("/hslider")) {
    String s = theOscMessage.get(0).stringValue();
    println(s);
    s = s.replace(',', '.');
    j = Float.parseFloat(s);
    cellSize = floor(map(j, 0, 1, 3, 60));

    cols = width / cellSize;
    rows = height / cellSize;
    println(cellSize);
  }

  if (theOscMessage.checkAddrPattern("button")) {
    handleButton();
  }

  if (theOscMessage.checkAddrPattern("/toggle")) {
    capturing = theOscMessage.get(0).intValue() == 1;
  }
}


void handleButton() {
  colorOn++;
  colorOn %= 4;
  switch(colorOn) {
  case 0:
    rOn = 1;
    gOn = 1;
    bOn = 1;
    break;
  case 1:
    rOn = 1;
    gOn = 0;
    bOn = 0;
    break;
  case 2:
    rOn = 0;
    gOn = 1;
    bOn = 0;
    break;
  case 3:
    rOn = 0;
    gOn = 0;
    bOn = 1;
    break;
  default:
    rOn = 1;
    gOn = 1;
    bOn = 1;
    break;
  }
}