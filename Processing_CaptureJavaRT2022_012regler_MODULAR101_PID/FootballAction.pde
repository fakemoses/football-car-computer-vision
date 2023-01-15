/* plan for robot action:
 
 neutralMode() is default state
 
 if player has ball, player switches to attackerMode()
 
 if not, means opponent has the ball
 
 if opponent has the ball, player switches to goalkeeperMode()
 
 if opponent does not have the ball, switch back to neutralMode()  */

import PWindow; // do i need to include extends PApplet?
import gab.opencv.*;

OpenCV opencv;

public class FootballAction {


  //get the bbox here
  public Rectangle[] detectObject() {
    Rectangle[] balls = opencv.detect(1.3, 4, 0, 30, 300);
    return balls;
  }
  
  void detectBall() {
    // check if bounding box appears at lower half of screen (assumption to decide if it is nearer to robot)

    Rectangle[] balls = this.detectObject();
    for (int i = 0; i < balls.length; i++) {
      if (balls[i].y > height/2) {
        println("The detected ball is close to player.");
        //attackerMode();
      }
    }
  }

  void detectOpponent() {
    // check if bounding box appears at different sections of screen (assumption to decide distance to robot)
    // upper third = opponent is far away
    // middle third = opponent is near
    // lower third = opponent is too near

    Rectangle[] opponent = this.detectObject();
    for (int i = 0; i < opponent.length; i++) {
      if (opponent[i].y >= 2*height/3) {
        println("The detected opponent is too close to player.");
        //reverse car slowly
      }
      else if ((opponent[i].y < 2*height/3) && (opponent[i].y >= height/3)) {
        println("The detected opponent is near to the player.");
        goalkeeperMode();
    }
    else if (opponent < height/3) {
      println("The detected opponent is far away from the player");
      attackerMode();
  }





/*
  // player does not move yet, but checks if it has ball
  void neutralMode() {
    detectBall();
  }



  // player moves only if it detect ball is true
  void attackerMode() {
    antrieb.fahrt(1.0, 1.0);
    goalkeeperMode();
    // need to determine how many seconds it pushes the ball forward
  }


  // called only when detect ball is false
  void goalkeeperMode() {
    antrieb.fahrt(0.0, 0.0);

    if (balls != 0) {
      attackerMode();
    } else if (balls = 0) {
      // player rotates slowly until ball is detected again (clockwise)
      antrieb.fahrt(0.5, 0.0);

      if (balls != 0) {
        attackerMode();
      } else if (balls = 0) {
        goalkeeperMode();
      }
    }
  }
  
  */
}
