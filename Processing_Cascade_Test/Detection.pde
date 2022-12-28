import gab.opencv.*;
import ipcapture.*;
import java.awt.*;
import processing.video.*;

public class Detection {

  OpenCV opencv;
  IPCapture cam;

  public Detection(OpenCV opencv, String cascade) {
    this.opencv = opencv;
    this.opencv.loadCascade(cascade);
  }

  public void draw() {

    Rectangle[] balls = opencv.detect(1.3, 5, 0, 30, 300);
    image(opencv.getInput(), 0, 0);
    noFill();
    stroke(0, 255, 0);
    strokeWeight(3);
    //println(balls.length);
    if (balls.length > 0) {
      for (int i = 0; i < balls.length; i++) {
        println(balls[i].x + "," + balls[i].y);
        rect(balls[i].x, balls[i].y, balls[i].width, balls[i].height);
      }
    }
  }
}
