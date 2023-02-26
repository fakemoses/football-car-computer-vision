// Example implementation of a thread

public class BallDetection implements ThreadInterface, Runnable{
    
    //Basic
    private Thread myThread = null;
    private boolean STARTED = false;
    private MotorControl motorControl;
    Bildverarbeitung bildverarbeitung;
    
    PVector Start = new PVector(58,159);
    PVector End = new PVector(299, 236);
    Rectangle roi;
    
    private CascadeDetection cascade;
    
    private Rectangle[] rects;
    private Rectangle boundingBox;
    private boolean isBallWithinROI = false;
    
    
    public BallDetection(MotorControl motorControl, Bildverarbeitung bildverarbeitung, CascadeDetection cascade) {
        this.motorControl = motorControl;
        this.bildverarbeitung = bildverarbeitung;
        this.cascade = cascade;
        this.cascade.setMaxThreshold(5);
        
        int w = (int)(End.x - Start.x);
        int h = (int)(End.y - Start.y);
        this.roi = new Rectangle((int) Start.x,(int) Start.y, w, h);
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
            PImage cameraImage = bildverarbeitung.getCameraImage();
            PImage blueMask = bildverarbeitung.getBlueMask();
            rects = cascade.detect(cameraImage);
            boundingBox = cascade.getValidRect(rects, blueMask);
            if (boundingBox != null) {
                int midX = boundingBox.x + boundingBox.width / 2;
                int midY = boundingBox.y + boundingBox.height / 2;
                if (roi.contains(midX, midY)) {
                    isBallWithinROI = true;
                } else {
                    isBallWithinROI = false;
                }
            }
            delay(100);
            motorControl.notify(this,motorControl.Turn());
        }
    }
    
    public Rectangle[] getRects() {
        return rects;
    }
    
    public Rectangle getBoundingBox() {
        return boundingBox;
    }
    
    public Rectangle getROI() {
        return roi;
    }
    
    public boolean isBallWithinROI() {
        return isBallWithinROI;
    }
}
