// This class serve as another window for Cascade Object Detection as it only detects when the window size is equal to the source size
// ! @Deprecated
import java.awt.Frame;
import processing.awt.PSurfaceAWT;
import processing.awt.PSurfaceAWT.SmoothCanvas;
import ipcapture.*;
import gab.opencv.*;
import java.awt.*;
import processing.video.*;

class PWindow extends PApplet {
    
    OpenCV opencv;
    // OpenCV opencv2;
    IPCapture cam;
    
    int x, y, w, h;
    boolean setLocation, setTitle, makeResizable;
    String title;
    
    boolean run = false;
    
    
    //Method that should be called in this case
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
        PApplet.runSketch(new String[] {this.getClass().getSimpleName()} , this);
    };
    
    void settings() {
        if (w > 0 &&  h > 0)size(w, h);
        else{size(320, 240);}
    };
    
    void setup() {
        frameRate(10);
        //if(setLocation)surface.setLocation(x, y);
        if (setTitle)surface.setTitle(title);
        //if(makeResizable)surface.setResizable(true);
        opencv = new OpenCV(this, this.cam);
        opencv.loadCascade("ball_detection4.xml");
    };
    
    void draw() {
        // this.cam.read();
        // opencv.loadImage(this.cam);
        //! duplicate call ?
        Rectangle[] balls = this.detectObject();
        image(opencv.getInput(), 0, 0);
        noFill();
        stroke(0, 255, 0);
        strokeWeight(3);
        if (balls != null) {
            println("balls: " + balls.length);
            for (int i = 0; i < balls.length; i++) {
                rect(balls[i].x, balls[i].y, balls[i].width, balls[i].height);
            }
        }
        // todo:huh?
        run = true;
    };
    
    public void setImage(PImage img) {
        opencv.loadImage(img);
    }
    
    //get the bbox here
    public Rectangle[] detectObject() {
        if (run)
            { Rectangle[] balls = opencv.detect(1.25, 4, 0, 30, 300);
            return balls;}
        return null;
    }
    
    
    public Rectangle[] detectObject(PImage img) {
        println("detecting");
        opencv.loadImage(img.copy());
        return opencv.detect(1.25, 4, 0, 30, 300);
        // return opencv.detect(1.05, 1, 0, 0, 100);
        // return opencv.detect();
    }
};