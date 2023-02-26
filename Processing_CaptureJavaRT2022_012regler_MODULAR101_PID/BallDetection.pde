// Example implementation of a thread

public class BallDetection implements ThreadInterface, Runnable{
    
    //Basic
    private Thread myThread = null;
    private boolean STARTED = false;
    private MotorControl motorControl;
    Bildverarbeitung bildverarbeitung;
    
    private CascadeDetection cascade;
    
    private Rectangle[] rects;
    private Rectangle boundingBox;
    
    
    public BallDetection(MotorControl motorControl, Bildverarbeitung bildverarbeitung, CascadeDetection cascade) {
        this.motorControl = motorControl;
        this.bildverarbeitung = bildverarbeitung;
        this.cascade = cascade;
        this.cascade.setMaxThreshold(5);
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
            
            delay(100);
            motorControl.notify(this,motorControl.Forward(0));
        }
    }
    
    public Rectangle[] getRects() {
        return rects;
    }
    
    public Rectangle getBoundingBox() {
        return boundingBox;
    }
}
