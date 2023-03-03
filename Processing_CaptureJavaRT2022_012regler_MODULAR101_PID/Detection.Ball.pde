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
            PImage cameraImage = bildverarbeitung.getCameraImage();
            PImage blueMask = bildverarbeitung.getBlueMask();
            // rects = cascade.detect(cameraImage);
            boundingBox = cascade.detect(cameraImage, blueMask);
            if (boundingBox != null) {
                PVector mid = midPoint(boundingBox);
                if (roi.contains(mid.x, mid.y)) {
                    isBallWithinROI = true;
                } else {
                    isBallWithinROI = false;
                }
                motorControl.notify(this,motorControl.Forward((toMotorSignalLinear((int)mid.x))));
                delay(70);
                continue;
            }
            motorControl.notify(this,motorControl.Turn());
            delay(70);
        }
    }
    
    public Rectangle[] getRects() {
        return rects;
    }
    
    public PVector midPoint(Rectangle r) {
        return new PVector(r.x + r.width / 2, r.y + r.height / 2);   
    }
    
    public Rectangle getBoundingBox() {
        return boundingBox;
    }
    
    public Rectangle getROI() {
        return roi;
    }
    
    public float toMotorSignalLinear(int xCenter) {
        int MAXWIDTH = 320; // todo: set variable 
        return(float)(xCenter - (MAXWIDTH / 2)) / (MAXWIDTH / 2);
    }
    
    public boolean isBallWithinROI() {
        return isBallWithinROI;
    }
}
