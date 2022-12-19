import gab.opencv.*;
import ipcapture.*;
import java.awt.*;
import processing.video.*;

public class Detection {

  OpenCV opencv;
  IPCapture cam;

  public Detection(OpenCV opencv, IPCapture cam, String cascade) {
    this.opencv = opencv;
    opencv.loadCascade(cascade);
    this.cam = cam;
  }

  public void draw() {
    // if (cam.isAvailable()) {
    //  cam.read();
    //  image(cam,0,0);
    //}
    cam.read();
    opencv.loadImage(cam);
    Rectangle[] balls = opencv.detect(1.3, 5, 0, 30, 300);
    image(opencv.getInput(), 0, 0);
    noFill();
    stroke(0, 255, 0);
    strokeWeight(3);
    //println(balls.length);
    for (int i = 0; i < balls.length; i++) {
      println(balls[i].x + "," + balls[i].y);
      rect(balls[i].x, balls[i].y, balls[i].width, balls[i].height);
    }
  }
}
