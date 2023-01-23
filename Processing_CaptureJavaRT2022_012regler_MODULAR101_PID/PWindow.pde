// This class serve as another window for Cascade Object Detection as it only detects when the window size is equal to the source size

import java.awt.Frame;
import processing.awt.PSurfaceAWT;
import processing.awt.PSurfaceAWT.SmoothCanvas;
import ipcapture.*;
import gab.opencv.*;
import java.awt.*;
import processing.video.*;

public class PWindow extends PApplet {

  OpenCV opencv;
  IPCapture cam;

  int x, y, w, h;
  boolean setLocation, setTitle, makeResizable;
  String title;

  Bildverarbeitung bildverarbeitung;
  int [][] bild;
  
  // Method that should be called in this case
  PWindow(IPCapture cam, int x_, int y_, int ww, int hh, String s) {
    super();
    this.cam = cam;
    x = x_;
    y = y_;
    w = ww;
    h = hh;
    setLocation = true;
    title = s;
    setTitle = true;
    PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
  };

  void settings() {
    if (w>0&&h>0)size(w, h);
    else size(320, 240);
  };

  void setup() {
    frameRate(10);
    //if (setLocation)surface.setLocation(x, y);
    if (setTitle)surface.setTitle(title);
    //if (makeResizable)surface.setResizable(true);
    opencv = new OpenCV(this, this.cam);
    opencv.loadCascade("ball_detection.xml");
    bildverarbeitung = new Bildverarbeitung();
  };

  void draw() {
    this.cam.read();
    bildverarbeitung.extractColorRGB(cam);
    bild = bildverarbeitung.getRed(); 
    opencv.loadImage(this.cam);
    Rectangle[] balls = this.detectObject();
    image(opencv.getInput(), 0, 0);
    noFill();
    stroke(0, 255, 0);
    strokeWeight(3);
    //println(balls.length);
    for (int i = 0; i < balls.length; i++) {
      //println(balls[i].x + "," + balls[i].y);
      rect(balls[i].x, balls[i].y, balls[i].width, balls[i].height);
    }
    
    //since detection is done here, all other movements has to be done here.
    action.detectBall();
  };

  //get the bbox here
  public Rectangle[] detectObject() {
    Rectangle[] balls = opencv.detect(1.3, 4, 0, 30, 300);
    return balls;
  }
  
  public int[][] getBild() {
   return bild; 
  }

 
}
