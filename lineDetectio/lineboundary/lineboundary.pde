/*
* Line Detection with RANSAC
* UPDATE V2
*   - added Boundary for Line Seperation
todo:
- improve threshhold**
- consider canny**
- improve evaluation**
- improve LineBoundary conside 4 Lines*
- add boundary to Line -> for car
- add ROI for Line Detection
* - solve Blue Region
* - Add 4th Region to seperate added or remove
*/ 

// n or m to change image

ArrayList<Line> lines;

final int IMG_COUNT = 4;
final int MAX_COLS = 3;
final String DATA_PATH = "../data/flow/1/";

int s = 0;
int lcount = 0;
RANSAC r;
Boundary b;

PImage[] imageCollection = new PImage[IMG_COUNT];
PImage[] computeCollection = new PImage[IMG_COUNT];
PImage img, canny, bimage;

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
    b = new Boundary(320,240);
    bimage = new PImage(320,240);
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
    Point[] intersectionPoint = l.intersectionAtImageBorder();
    
    bimage = b.updateImage(l);
    image(bimage, 320, 0);
    
    stroke(255,0,0);
    strokeWeight(3);
    // noLoop();
    line(intersectionPoint[0].x, intersectionPoint[0].y, intersectionPoint[1].x, intersectionPoint[1].y);
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
    // countthenumber of red pixels
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
}
