// Example implementation of a thread

public class GoalDetection implements ThreadInterface, Runnable{
    
    //Basic
    private Thread myThread = null;
    private boolean STARTED = false;
    private MotorControl motorControl;
    Bildverarbeitung bv;
    private ColorHSV yellowMask;  
    private ArrayList<Contour> contours;
    PImage yellowImage;
    
    private PWindow window;
    
    
    public GoalDetection(MotorControl motorControl , Bildverarbeitung bv, ColorHSV yellowMask) {
        this.motorControl = motorControl;
        this.bv = bv;
        this.yellowMask = yellowMask;
        
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
            // implementation here
            println("GoalDetection");
            yellowImage = yellowMask.getMask(bv.getCameraImage(),false);
            contours = yellowMask.getContour();
            
            if (contours.size() > 0) {
                Contour biggestContour = contours.get(0);
                Rectangle r = biggestContour.getBoundingBox();
                
                noFill();
                strokeWeight(2);
                stroke(0, 255, 0);
                rect(r.x, r.y, r.width, r.height);
                
                noStroke();
                fill(0, 255,0);
                ellipse(r.x + r.width / 2, r.y + r.height / 2, 10, 10);
            } 
            
            delay(100);
            // motorControl.notify(this,direction);
        }
    }
    
    public Rectangle getBoundingBox() {
        if (contours == null || contours.size() == 0) {
            return null;
        }
        Contour biggestContour = contours.get(0);
        Rectangle r = biggestContour.getBoundingBox();
        return r;
    }
    
    public PImage getYellowImage() {
        return yellowImage;
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
}
