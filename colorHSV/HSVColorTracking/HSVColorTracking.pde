/**
 * HSVColorTracking
 * Greg Borenstein
 * https://github.com/atduskgreg/opencv-processing-book/blob/master/code/hsv_color_tracking/HSVColorTracking/HSVColorTracking.pde
 *
 * Modified by Jordi Tost @jorditost (color selection)
 *
 * University of Applied Sciences Potsdam, 2014
 */

import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;

Capture video;
OpenCV opencv, opencv2, opencv3, opencv4;
PImage img, img2, imghsv;
PImage lowerH1, lowerV1, lowerS1;
PImage lowerH2, lowerV2, lowerS2;
PImage diff1, diff2, diff3, diff4;
PImage mask1, mask2, total;
PImage src, colorFilteredImage;
ArrayList<Contour> contours;
PImage returnimg;


int lowerRed1[] = {0, 50, 50};
int higherRed1[] = {10, 255, 255};

int lowerRed2[] = {170, 50, 50};
int higherRed2[] = {180, 255, 255};


void setup() {
  img = loadImage("./data/redLine.jpg");

  opencv = new OpenCV(this, img);
  opencv2 = new OpenCV(this, img);

  total = createImage(img.width, img.height, RGB);

  size(1920, 800);
}

void draw() {
  opencv.loadImage(img);
  opencv.useColor(HSB);

  opencv.setGray(opencv.getH().clone());
  opencv.inRange(0, 10);
  lowerH1 = opencv.getSnapshot();

  opencv.setGray(opencv.getS().clone());
  opencv.inRange(50, 255);
  lowerS1 = opencv.getSnapshot();

  opencv.diff(lowerH1);
  opencv.threshold(0);
  opencv.invert();
  diff1 = opencv.getSnapshot();

  opencv.setGray(opencv.getV().clone());
  opencv.inRange(50, 255);
  lowerV1 = opencv.getSnapshot();

  opencv.diff(diff1);
  opencv.threshold(0);
  opencv.invert();
  diff2 = opencv.getSnapshot();

  opencv2.loadImage(img);
  opencv2.useColor(HSB);

  opencv2.setGray(opencv2.getH().clone());
  opencv2.inRange(170, 180);
  lowerH2 = opencv2.getSnapshot();

  opencv2.setGray(opencv2.getS().clone());
  opencv2.inRange(50, 255);
  lowerS2 = opencv2.getSnapshot();

  opencv2.diff(lowerH2);
  opencv2.threshold(0);
  opencv2.invert();
  diff3 = opencv2.getSnapshot();

  opencv2.setGray(opencv2.getV().clone());
  opencv2.inRange(50, 255);
  lowerV2 = opencv2.getSnapshot();

  opencv2.diff(diff3);
  opencv2.threshold(0);
  opencv2.invert();
  diff4 = opencv2.getSnapshot();

  int c1 = 0;
  int c2 = 0;
  for (int i = 0; i< diff4.width; i++) {
    for (int j=0; j< img.height; j++) {
      color c = diff4.get(i, j);
      color d = diff2.get(i, j);
      if (c == -16777216) {
        total.set(i, j, c);
        c1++;
        continue;
      }

      if (d == -16777216) {
        total.set(i, j, d);
        continue;
      }

      //total.set(i, j, d);
    }
  }

  println(c1);
  println(c2);

  // <8> Display background images

  image(img, 0, 0);
  image(lowerH1, img.width, 0);
  image(lowerS1, img.width*2, 0);
  image(lowerV1, img.width*3, 0);
  image(diff1, img.width*4, 0);
  image(diff2, img.width*5, 0);

  image(img, 0, img.height);
  image(lowerH2, img.width, img.height);
  image(lowerS2, img.width*2, img.height);
  image(lowerV2, img.width*3, img.height);
  image(diff3, img.width*4, img.height);
  image(diff4, img.width*5, img.height);
  image(total, 0, img.height*2);
}

PImage getMask(PImage img, int low[], int high[]) {
  opencv = new OpenCV(this, img);
  opencv.loadImage(img);
  opencv.useColor(HSB);

  opencv.setGray(opencv.getH().clone());
  opencv.inRange(low[0], high[0]);
  opencv.threshold(50);
  lowerH1 = opencv.getSnapshot();

  opencv.setGray(opencv.getS().clone());
  opencv.inRange(low[1], high[1]);
  opencv.threshold(50);
  lowerS1 = opencv.getSnapshot();

  opencv.diff(lowerS1);
  opencv.threshold(0);
  opencv.invert();
  diff1 = opencv.getSnapshot();

  opencv.setGray(opencv.getV().clone());
  opencv.inRange(low[2], high[2]);
  opencv.threshold(50);
  lowerV1 = opencv.getSnapshot();

  opencv.diff(diff1);
  opencv.threshold(0);
  opencv.invert();
  diff2 = opencv.getSnapshot();

  return diff2;
}
