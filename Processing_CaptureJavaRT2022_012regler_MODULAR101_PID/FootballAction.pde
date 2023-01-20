/* plan for robot action:
 
 neutralMode() is default state
 
 if player has ball, player switches to attackerMode()
 
 if not, means opponent has the ball
 
 if opponent has the ball, player switches to goalkeeperMode()
 
 if opponent does not have the ball, switch back to neutralMode()  */
import java.awt.*;
import gab.opencv.*;

public class FootballAction {
  PWindow window ;

  public FootballAction(PWindow window) {
    this.window = window;
  }


  void detectBall() {
    // check if bounding box appears at lower half of screen (assumption to decide if it is nearer to robot)

    Rectangle[] balls = window.detectObject();
    if (balls.length != 0) {
      println(balls.length);
      //balls detected
      //focus on one of the rect and give it to spx -> get the length and use this as the max iterator number


      //turn everything else aside from the rect in the image into black -> need a function
      restBlack();

      //check if image is actually a ball. Like check the color. If it is a ball then call SPX to get direction
      // (new idea) count white pixels to detect ball
      if (countWhitePixels(white_total >= 50)) {
        computeColor();
      } else if ((bildverarbeitung.getRed() || bildverarbeitung.getGreen() || bildverarbeitung.getBlue() || bildverarbeitung.getYellow()) = BILD) {
        regler.holeSchwerpunkt();
      } else if {
        for (int i = 0; i < balls.length; i++) {
          //println(balls[i].x + "," + balls[i].y);
          rect(balls[i].x, balls[i].y, balls[i].width, balls[i].height);
        }
        //if not a ball then go to the next rect. If only 1 rect then no ball is detected.
      } else {
        //if no balls detected turn 360 slowly
        antrieb.fahrt(1.0, 0.0);
      }
    }
  }


  // function to convert non ROI to black
  void restBlack() {
    int[][] BILD;
    // part here missing
    for (int i = 0; i<240; j++) {
      for (int j = 0; j<320; i++) {
        for (bildR = 0; bildR <= 255; bildR++) {
          bildR = 0;
          for (bildG = 0; bildG <= 255; bildG++) {
            bildG = 0;
            for (bildB = 0; bildB <= 255; bildB++) {
              bildB = 0;
            }
          }
        }
      }
    }
  }

  //function to count white pixels (I mixed this from few websites, so some part are missing/inaccurate)
  void countWhitePixels() {
    int white_count = 0;
    int white_total;
    image_width = image.getWidth();
    image_height = image.getHeight();

    for (int i=0; i<image_height; i++) {
      int ii = i;
      for (int j=0; j<image_width; j++) {
        int jj= j;
        int pixel_coordinate = image.getPixel(ii, jj);
        int r = bildverarbeitung.getRed(pixel_coordinate);
        int g = bildverarbeitung.getGreen(pixel_coordinate);
        int b = bildverarbeitung.getBlue(pixel_coordinate);
        if ( r == 255 && g == 255 && b == 255) {
          white_count++;
        }
      }
    }
    return white_total;
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
  void neutralMode() {
    detectBall();
  }



  // player moves only if it detect ball is true
  void attackerMode() {
    antrieb.fahrt(1.0, 1.0);
    //goalkeeperMode();
    // need to determine how many seconds it pushes the ball forward
  }


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
}
