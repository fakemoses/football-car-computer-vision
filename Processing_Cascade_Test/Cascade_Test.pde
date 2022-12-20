import ipcapture.*;
import gab.opencv.*;
import java.awt.*;
import processing.video.*;

OpenCV opencv;
String IP = "192.168.178.70";
int PORT = 6000;
IPCapture cam;

void setup() 
{
  size(320,240);
  cam = new IPCapture(this, "http://"+IP+":81/stream", "", "");
  cam.start();
  
  //opencv part
  opencv = new OpenCV(this, cam);
  opencv.loadCascade("ball_detection.xml");
  
  frameRate(10);
}

void draw(){
  // if (cam.isAvailable()) {
  //  cam.read();
  //  image(cam,0,0);
  //}
  cam.read();
  opencv.loadImage(cam);
  Rectangle[] balls = opencv.detect(1.3, 5,0,30,300);
  image(opencv.getInput(),0,0); 
  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);
  println(balls.length);
  for (int i = 0; i < balls.length; i++) {
    //println(balls[i].x + "," + balls[i].y);
    rect(balls[i].x, balls[i].y, balls[i].width, balls[i].height);
  }
}

//void captureEvent(Capture c) {
//  c.read();
//}
