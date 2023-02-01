
// ignore me Onichan
import gab.opencv.*;

OpenCV opencv;
ArrayList<Line> lines;

final int MID_COUNT = 5;
final int RED_COUNT = 5;
final int MAX_COLS = 3;
final String DATA_PATH = "../data/";

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
    
    opencv = new OpenCV(this, computeCollection[1]);
    // opencv.findCannyEdges(20,100);
    canny = opencv.getSnapshot();
    lines = opencv.findLines(10, 1, 100);
    
    println("Found " + lines.size() + " lines.");
    
    TEST();
}

void draw() {
    
    for (int i = 0; i < computeCollection.length; i++) {
        int x = i % MAX_COLS;
        int y = i / MAX_COLS;
        int w = computeCollection[i].width;
        int h = computeCollection[i].height;
        image(computeCollection[i], x * w, y * h);
    }
    image(canny, 0, 0);
    strokeWeight(3);
    for (Line line : lines) {  
        stroke(255, 0, 0);
        line(line.start.x, line.start.y, line.end.x, line.end.y);
    } 
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

void processImage(PImage img, boolean useCanny) {
    PImage output = createImage(img.width, img.height, RGB);
    
    ArrayList<Line> lines;
    
    opencv = new OpenCV(this, img);
    
    if (useCanny) {
        opencv.findCannyEdges(20,100);
    }
    
    output = opencv.getSnapshot();
    lines = opencv.findLines(10, 1, 100);   
    println("Found " + lines.size() + " lines.");
    
    Line line = lines.get(0);
    
    Point[] intersection = getIntersectionTopBottom(img, line);

    // draw the line
    strokeWeight(3);
    stroke(255, 0, 0);
    line(line.start.x, line.start.y, line.end.x, line.end.y);
    
    
}

ArrayList<PVector> getLineVector()

Point[] getIntersectionTopBottom(PImage img, Line l) {
    Line top = new Line(new Point(0, 0), new Point(img.width, 0));
    Line bottom = new Line(new Point(0, img.height), new Point(img.width, img.height));
    
    Point[] intersection = new Point[2];
    intersection[0] = getIntersection(l, top);
    intersection[1] = getIntersection(l, bottom);
    
    return intersection;
}

Point getIntersection(Line line1, Line line2) {
    Point intersection = new Point();
    float x1 = line1.start.x;
    float y1 = line1.start.y;
    float x2 = line1.end.x;
    float y2 = line1.end.y;
    float x3 = line2.start.x;
    float y3 = line2.start.y;
    float x4 = line2.end.x;
    float y4 = line2.end.y;
    
    float x = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));
    float y = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));
    
    intersection.x = x;
    intersection.y = y;
    
    return intersection;
}
