/*
* Line Detection with RANSAC
todo:
- improve threshhold**
- consider canny**
- improve evaluation**
- improve LineBoundary conside 4 Lines*
- add boundary to Line -> for car
- add ROI for Line Detection
*/ 

// n or m to change image

ArrayList<Line> lines;

final int MID_COUNT = 5;
final int RED_COUNT = 5;
final int MAX_COLS = 3;
final String DATA_PATH = "../data/";

int s = 0;

RANSAC r;

PImage[] imageCollection = new PImage[MID_COUNT + RED_COUNT];
PImage[] computeCollection = new PImage[MID_COUNT + RED_COUNT];
PImage img, canny;

boolean[] expected = new boolean[MID_COUNT + RED_COUNT];
boolean[] evaluated = new boolean[MID_COUNT + RED_COUNT];

void setup() {
    size(1000,1000);
    
    // * Load the image
    int d = 0;
    while(d < RED_COUNT) {
        String redPath = DATA_PATH + "redline (" + (d + 1) + ").jpg";
        imageCollection[d] = loadImage(redPath);
        expected[d] = true;
        d++;
    }
    
    int c = 0;
    while(c < MID_COUNT) {
        String midPath = DATA_PATH + "mid (" + (c + 1) + ").jpg";
        imageCollection[RED_COUNT + c] = loadImage(midPath);
        expected[RED_COUNT + c] = false;
        c++;
    }
    
    
    for (int i = 0; i < imageCollection.length; i++) {
        computeCollection[i] = computeColor(imageCollection[i]);
        evaluated[i] = eval(computeCollection[i]);
    }    
    
    TEST();
    
    r = new RANSAC(500,0.2,320,240);
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
    println("Time: " + (endtime - starttime));
    
    PImage copy = createImage(selected.width, selected.height, RGB);
    copy.copy(selected, 0, 0, selected.width, selected.height, 0, 0, selected.width, selected.height);
    image(copy, 0, 0);
    
    r.run(list);
    Line l = r.getBestLine();
    Point p1 = l.getP1();
    Point p2 = l.getP2();
    
    stroke(255,0,0);
    strokeWeight(3);
    line(p1.x, p1.y, p2.x, p2.y);
    // noLoop();
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

public void TEST() {
    int pass = 0;
    for (int i = 0; i < evaluated.length; i++) {
        if (evaluated[i]!= expected[i]) {
            println("Test failed for image " + i);
            println("Expected: " + expected[i] + " but got " + evaluated[i]);
            continue;
        }
        pass++;
    }
    println("Passed " + pass + " out of " + evaluated.length + " tests.");
} 

void keyPressed() {
    if (key == 'n') {
        s = s < RED_COUNT - 1 ? s + 1 : 0;
    }
    
    if (key == 'm') {
        s = s<= 0 ? RED_COUNT - 1 : s - 1;
    }
}
