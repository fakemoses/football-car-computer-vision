

import gab.opencv.*;
import processing.video.*;
import java.awt.Rectangle;

Capture video;
OpenCV opencv, opencv2;
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


GetColors extract;

void setup() {
  img = loadImage("./data/redLine.jpg");

  opencv = new OpenCV(this, img);
  opencv2 = new OpenCV(this, img);

  total = createImage(img.width, img.height, RGB);

  extract = new GetColors();

  maskRED1 = new ColorHSV("Red1", img);
  maskRED2 = new ColorHSV("Red2", img);
  maskBlue = new ColorHSV("Blue", imgBlue);
  maskYellow = new ColorHSV("Yellow", imgYellow);

  // red
  out1 = maskRED1.getMask(img, false);
  out2 = maskRED2.getMask(img, false);
  out3 = maskRED2.combineMask(out1, img);

  //blue yellow
  out4 = maskBlue.getMask(imgBlue, false);
  out5 = maskYellow.getMask(imgYellow, false);

  //if color
  out6 = maskBlue.getMask(imgBlue, true);
  out7 = maskYellow.getMask(imgYellow, true);

  extract.extractColor(out7);

  size(1280, 720);
  frameRate(10);
}

void draw() {

  image(img, 0, 0);
  image(out1, img.width, 0);
  image(out2, img.width*2, 0);
  image(out3, img.width*3, 0);
  image(imgBlue, 0, img.height);
  image(out4, img.width, img.height);
  image(out6, img.width*2, img.height);
  image(imgYellow, 0, img.height*2);
  image(out5, img.width, img.height*2);
  image(out7, img.width*2, img.height*2);

  int [][] BILD = extract.getYellow();
  float dx = (width/4)/(float)BILD[0].length;
  float dy = (height/3)/(float)BILD.length;
  noStroke();
  fill(200);
  rect(img.width*3, img.height, img.width, img.height);
  fill(0);
  for (int i=0; i<BILD.length; i++)
  {
    for (int k=0; k<BILD[i].length; k++)
    {
      if (BILD[i][k]==0)
      {
        rect(img.width*3+(float)k*dx, img.height+(float)i*dy, dx, dy);
      }
    }
  }

  contours = maskRED2.getContour();

  if (contours.size() > 0) {
    Contour biggestContour = contours.get(0);
    Rectangle r = biggestContour.getBoundingBox();

    noFill();
    strokeWeight(2);
    stroke(0, 255, 0);
    rect(r.x, r.y, r.width, r.height);

    noStroke();
    fill(0, 255, 0);
    ellipse(r.x + r.width/2, r.y + r.height/2, 10, 10);
  }

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
