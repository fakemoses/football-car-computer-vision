/* plan for robot action:
 
 neutralMode() is default state
 
 if player has ball, player switches to attackerMode()
 
 if not, means opponent has the ball
 
 if opponent has the ball, player switches to goalkeeperMode()
 
 if opponent does not have the ball, switch back to neutralMode()  */
import java.awt.*;
import gab.opencv.*;
import processing.awt.PSurfaceAWT;
import processing.awt.PSurfaceAWT.SmoothCanvas;

public class FootballAction {
  PWindow window ;

  public FootballAction(PWindow window) {
    this.window = window;
  }



  void detectBall() {
    // check if bounding box appears at lower half of screen (assumption to decide if it is nearer to robot)
    int[][] b = window.getBild();
    boolean is_rect = false;
    int idx = 0;

    Rectangle[] balls = window.detectObject();
    if (balls.length != 0) {
      println(balls.length);
      //balls detected
      //focus on one of the rect and give it to spx -> get the length and use this as the max iterator number

      //check if image is actually a ball. Like check the color. If it is a ball then call SPX to get direction
      // (new idea) count white pixels to detect ball
      double threshold = 20.0;

      for (int i = 0; i < balls.length; i++) {
        double white_percent = countWhitePixels(balls[i].x, balls[i].y, balls[i].width, balls[i].height, b);
        if (white_percent > threshold) {
          is_rect = true;
          idx = i;
        }
      }
      if (!is_rect) {
        print("nothing detected");
      } else {
        // process whole thing inside here
        regler.erzeugeStellsignalAusRotbild(b);
      }
    }
  }


  //function to count white pixels (I mixed this from few websites, so some part are missing/inaccurate)
  public double countWhitePixels(int x, int y, int w, int h, int[][] bild) {
    int white_count = 0;

    for (int i=y; i<h; i++) {
      for (int j=x; j<w; j++) {
        if (bild[j][i] > 0) {
          white_count++;
        }
      }
    }
    double area_white;
    area_white = ((double)white_count/(w*h))*100;
    return area_white;
  }
}


  //void detectOpponent() {
  //  // check if bounding box appears at different sections of screen (assumption to decide distance to robot)
  //  // upper third = opponent is far away
  //  // middle third = opponent is near
  //  // lower third = opponent is too near

  //  Rectangle[] opponent = this.detectObject();
  //  for (int i = 0; i < opponent.length; i++) {
  //    if (opponent[i].y >= 2*height/3) {
  //      println("The detected opponent is too close to player.");
  //      //reverse car slowly
  //    } else if ((opponent[i].y < 2*height/3) && (opponent[i].y >= height/3)) {
  //      println("The detected opponent is near to the player.");
  //      goalkeeperMode();
  //    } else if (opponent < height/3) {
  //      println("The detected opponent is far away from the player");
  //      attackerMode();
  //    }
  //  }
  //}


  // player does not move yet, but checks if it has ball
  //void neutralMode() {
  //  detectBall();
  //}



  // player moves only if it detect ball is true
  //void attackerMode() {
  //  antrieb.fahrt(1.0, 1.0);
  //  //goalkeeperMode();
  //  // need to determine how many seconds it pushes the ball forward
  //}


  //// called only when detect ball is false
  //void goalkeeperMode() {
  //  antrieb.fahrt(0.0, 0.0);

  //  if (balls != 0) {
  //    attackerMode();
  //  } else if (balls = 0) {
  //    // player rotates slowly until ball is detected again (clockwise)
  //    antrieb.fahrt(0.5, 0.0);

  //    if (balls != 0) {
  //      attackerMode();
  //    } else if (balls = 0) {
  //      goalkeeperMode();
  //    }
  //  }
  //}
