/*
* Line Detection with RANSAC
* UPDATE V2 - 2 
*   - Implement fixed ROI
todo:
- improve threshhold**
- consider canny**
- improve evaluation**
- improve LineBoundary conside 4 Lines*
- add boundary to Line -> for car
- add ROI for Line Detection
! BIG BROBLEM, JITTERING can cause error in evaluation
*/ 

// n or m to change image

ArrayList<Line> lines;

final int IMG_COUNT = 4;
final int MAX_COLS = 3;
final String DATA_PATH = "../data/flow/3/";

int s = 0;
int t = 0;
int lcount = 0;
RANSAC r;
ROIFIXED roi;

PImage[] imageCollection = new PImage[IMG_COUNT];
PImage[] computeCollection = new PImage[IMG_COUNT];
PImage img, canny, hr, vr;

void setup() {
    size(1000,1000);
    frameRate(5);
    // * Load the image
    int d = 0;
    while(d < IMG_COUNT) {
        String redPath = DATA_PATH  + (d + 1) + ".jpg";
        imageCollection[d] = loadImage(redPath);
        d++;
    }
    
    
    for (int i = 0; i < imageCollection.length; i++) {
        computeCollection[i] = computeColor(imageCollection[i]);
    }    
    
    r = new RANSAC(500,0.2,320,240);
    roi = new ROIFIXED(320,240);
    
    hr = createImage(320, 240, RGB);
    vr = createImage(320, 240, RGB);
}

void draw() {
    double starttime = millis();
    for (int i = 0; i < computeCollection.length; i++) {
        int x = i % MAX_COLS;
        int y = i / MAX_COLS;
        int w = computeCollection[i].width;
        int h = computeCollection[i].height;
        image(computeCollection[i], x * w, y * h);
    }
    
    
    PImage selected = computeCollection[s];
    ArrayList<Point> list = new ArrayList<Point>();
    for (int i = 0; i < selected.width; i++) {
        for (int j = 0; j < selected.height; j++) {
            if (selected.pixels[i + j * selected.width] == color(255, 255, 255)) {
                list.add(new Point(i, j));
            }
        }
    }
    
    double endtime = millis();
    // println("Time: " + (endtime - starttime));
    
    PImage copy = createImage(selected.width, selected.height, RGB);
    copy.copy(selected, 0, 0, selected.width, selected.height, 0, 0, selected.width, selected.height);
    image(copy, 0, 0);
    
    r.run(list);
    Line l = r.getBestLine();
    Point p1 = l.getP1();
    Point p2 = l.getP2();
    
    roi.updatePixels(copy, l);
    vr = roi.getVerticalROI();
    hr = roi.getHorizontalROI();
    
    rectMode(CENTER);
    strokeWeight(3);
    noFill();
    image(vr, 0, vr.height);
    image(hr, vr.width, vr.height);
    Point mid = roi.getMidPoint();
    // if (t ==  0) {
    if (roi.getType() == 0) {
        stroke(0, 255, 0);
        rect(vr.width * 1 / 2, vr.height * 3 / 2, vr.width, vr.height);
        stroke(0, 255, 255);
        circle(mid.x, mid.y + vr.height, 10);
        stroke(255, 0, 0);
        line(0, mid.y + vr.height,  vr.width, mid.y + vr.height);
        line(mid.x, vr.height,  mid.x, vr.height * 2);
    } else {
        stroke(0, 255, 0);
        rect(vr.width * 3 / 2, vr.height * 3 / 2, vr.width, vr.height);
        stroke(0, 255, 255);
        circle(mid.x + vr.width, mid.y + vr.height, 10);
        stroke(255, 0, 0);
        line(vr.width, mid.y + vr.height,  vr.width * 2, mid.y + vr.height);
        line(mid.x + vr.width, vr.height,  mid.x + vr.width, vr.height * 2);
    } 
    
    stroke(255,0,0);
    // noLoop();
    line(p1.x, p1.y, p2.x, p2.y);
    // if (lcount == 3)
    //     noLoop();
    
    lcount++;
}


public PImage computeColor(PImage img) {
    PImage mask = createImage(img.width, img.height, RGB);
    int ANHEBUNG = 30;
    int u = 0;
    int pix[] = img.pixels;
    int pixMask[] = mask.pixels;
    int[][] bild = new int[img.width][img.height];
    int[][] bildR = new int[img.width][img.height];
    for (int i = 0; i < bild.length; i++)
        for (int k = 0; k < bild[i].length; k++)
            bild[i][k] = pix[u++];
    u = 0;
    for (int i = 0; i < bild.length; i++)
        {
        for (int k = 0; k < bild[i].length; k++)
            {
            int wert = pix[u];
            
            int ROT = (wert  >> 8) & 0xFF;
            int GRUEN  = wert & 0xFF;
            int BLAU = (wert >> 16) & 0xFF;
            
            bildR[i][k] = 2 * ROT - GRUEN - BLAU + ANHEBUNG;
            if (bildR[i][k] < 0) {bildR[i][k] =-  bildR[i][k];}
            else{bildR[i][k] = 0;}
            
            u++;
        }
    }
    
    int max = 20;
    // convert back to PImage
    u = 0;
    for (int i = 0; i < bild.length; i++)
        {
        for (int k = 0; k < bild[i].length; k++)
            {
            // set to max white if value is above threshold
            if (bildR[i][k] > max) {bildR[i][k] = 255;}
            else{bildR[i][k] = 0;}
            pixMask[u] = color(bildR[i][k], bildR[i][k], bildR[i][k]);
            u++;
        }
    }
    mask.updatePixels();
    return mask;
}

public boolean eval(PImage img) {
    
    final double THRESHOLD = 0.1;
    // count thenumber of red pixels
    int count = 0;
    int total = img.width * img.height;
    int pix[] = img.pixels;
    for (int i = 0; i < pix.length; i++) {
        if (pix[i] == color(255, 255, 255)) {
            count++;
        }
    }
    
    double ratio = (double)count / (double)total * 100.0;
    return ratio> THRESHOLD;
}


void keyPressed() {
    if (key == 'n') {
        s = s < IMG_COUNT - 1 ? s + 1 : 0;
    }
    
    if (key == 'm') {
        s = s<= 0 ? IMG_COUNT - 1 : s - 1;
    }
    
    if (key == 's') {
        t = t < 1 ? t + 1 : 0;
    }
}