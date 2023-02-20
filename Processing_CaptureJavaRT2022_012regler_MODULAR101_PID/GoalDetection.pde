// Example implementation of a thread

public class GoalDetection implements ThreadInterface, Runnable{
    
    //Basic
    private Thread myThread = null;
    private boolean STARTED = false;
    private MotorControl motorControl;
    Bildverarbeitung bv;
    private ColorHSV yellowCV;  
    private ArrayList<Contour> contours;
    private final int MIN_WIDTH = 10;
    private final int MIN_HEIGHT = 10;
    private Rectangle boundingBox;
    PImage yellowMask;
    
    private PWindow window;
    
    
    public GoalDetection(MotorControl motorControl , Bildverarbeitung bv, ColorHSV yellowCV) {
        this.motorControl = motorControl;
        this.bv = bv;
        this.yellowCV = yellowCV;
        
    }
    
    public void startThread() {
        if (myThread == null) {
            myThread = new Thread(this);
            myThread.start();
        }
        
        STARTED = true;
    }
    
    public void stopThread() {
        STARTED = false;
    }
    
    public String getThreadName() {
        return "GoalDetection";
    }
    
    public void run() {
        while(STARTED) {
            yellowMask = yellowCV.getMask(bv.getCameraImage(),false);
            contours = yellowCV.getContour();
            boundingBox = isValid();
            motorControl.notify(this,motorControl.Turn());
            delay(50);
        }
    }
    
    public Rectangle getBoundingBox() {
        return boundingBox;
    }
    
    public PImage getYellowMask() {
        return yellowMask;
    }
    
    public double countWhitePixels(int x, int y, int w, int h, int[][] bild) {
        int white_count = 0;
        
        for (int i = y; i < y + h; i++) {
            for (int j = x; j < x + w; j++) {
                int val = bild[j][i];
                if (val != 0) {
                    // white_count++;
                    println("Bild: " + bild[j][i]);
                    white_count++;
                }
            }
        }
        double area_white;
        println("white count: " + white_count);
        println("w: " + w + " h: " + h);
        area_white = ((double)white_count / (w * h)) * 100;
        println("white % : " + area_white);
        return area_white;
    }
    
    public double countWhitePixels(int x, int y, int w, int h, PImage bild) {
        int white_count = 0;
        
        int pix[] = bild.pixels;
        
        for (int i = 0; i < pix.length; i++) {
            if (pix[i] == color(255, 255, 255)) {
                white_count++;
            }
        }
        double area_white;
        println("white count: " + white_count);
        area_white = ((double)white_count / (w * h)) * 100;
        // println("white % : " + area_white);
        return area_white;
    }
    
    public Rectangle isValid() {
        if (contours == null || contours.size() == 0) {
            return null;
        }
        Contour biggestContour = contours.get(0);
        Rectangle r = biggestContour.getBoundingBox();
        if (r.width < MIN_WIDTH || r.height < MIN_HEIGHT) {
            return null;
        }
        return r;
    }
}
