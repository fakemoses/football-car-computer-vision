// Example implementation of a thread

public class GoalDetection implements ThreadInterface, Runnable{
    
    //Basic
    private Thread myThread = null;
    private boolean STARTED = false;
    private MotorControl motorControl;
    Bildverarbeitung bildverarbeitung;
    private ColorHSV yellowCV;  
    private ArrayList<Contour> contours;
    private final int MIN_WIDTH = 10;
    private final int MIN_HEIGHT = 10;
    private final int MIN_AREA = 200;
    private Rectangle boundingBox;
    PImage yellowMask;    
    
    public GoalDetection(MotorControl motorControl , Bildverarbeitung bildverarbeitung, ColorHSV yellowCV) {
        this.motorControl = motorControl;
        this.bildverarbeitung = bildverarbeitung;
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
            yellowMask = yellowCV.getMask(bildverarbeitung.getCameraImage(),false);
            contours = yellowCV.getContour();
            boundingBox = isValid();
            if (boundingBox!= null) {
                int xCenter = getXPos(boundingBox);
                float motorSignal = toMotorSignalLinear(xCenter);
                motorControl.notify(this,motorControl.Forward(motorSignal));
            } else{
                motorControl.notify(this,motorControl.Turn());
            }
            delay(50);
        }
    }
    
    public Rectangle getBoundingBox() {
        return boundingBox;
    }
    
    public PImage getYellowMask() {
        return yellowMask;
    }
    
    public Rectangle isValid() {
        if (contours == null || contours.size() == 0) {
            return null;
        }
        Contour biggestContour = contours.get(0);
        Rectangle r = biggestContour.getBoundingBox();
        if (r.width < MIN_WIDTH ||  r.height < MIN_HEIGHT) {
            return null;
        }
        
        if (r.width * r.height < MIN_AREA) {
            return null;
        }
        return r;
    }
    
    public int getXPos(Rectangle r) {
        return r.x + r.width / 2;
        
    }
    
    
    public float toMotorSignalLinear(int xCenter) {
        int MAXWIDTH = 320; // todo: set variable 
        return(float)(xCenter - (MAXWIDTH / 2)) / (MAXWIDTH / 2);
    }
    
}
