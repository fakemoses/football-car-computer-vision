// Example implementation of a thread

public class BallDetection implements ThreadInterface, Runnable{
    
    //Basic
    private Thread myThread = null;
    private boolean STARTED = false;
    private MotorControl motorControl;
    Bildverarbeitung bildverarbeitung;
    
    private PWindow window;
    
    
    public BallDetection(MotorControl motorControl, Bildverarbeitung bildverarbeitung, PWindow window) {
        this.motorControl = motorControl;
        this.bildverarbeitung = bildverarbeitung;
        this.window = window;
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
        return "BallDetection";
    }
    
    public void run() {
        while(STARTED) {
            Rectangle[] rect = null;
            // Rectangle[] rect = window.detectObject();
            int[][] bild = bildverarbeitung.getRed();
            PImage redmask = bildverarbeitung.getBlueMask();
            double threshold = 15.0;
            boolean is_rect = false;
            float direction = 0;
            
            if (rect != null) {
                int idx = 0;
                for (int i = 0; i < rect.length; i++) {
                    PImage sub = redmask.get(rect[i].x, rect[i].y, rect[i].width, rect[i].height);
                    Rectangle r = rect[i];
                    double white_percent = countWhitePixels(r.x, r.y, r.width, r.height, sub);
                    if (white_percent > threshold) {
                        is_rect = true;
                        idx = i;
                        direction = (rect[idx].x + rect[idx].width / 2) - (320 / 2);
                        break;
                    }
                } 
                if (direction > 0) {
                    // println("turn right");
                } else {
                    // println("turn left");
                }
            }
            
            delay(500);
            // println("direction: " + direction);
            motorControl.notify(this,motorControl.Forward(0));
        }
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
        // println("white count: " + white_count);
        // println("w: " + w + " h: " + h);
        area_white = ((double)white_count / (w * h)) * 100;
        // println("white % : " + area_white);
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
        area_white = ((double)white_count / (w * h)) * 100;
        return area_white;
    }
}
