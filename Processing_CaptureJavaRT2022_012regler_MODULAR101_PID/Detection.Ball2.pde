// Example implementation of a thread

public class BallDetection2 implements ThreadInterface, Runnable{
    
    //Basic
    private Thread myThread = null;
    private boolean STARTED = false;
    private MotorControl motorControl;
    Bildverarbeitung bildverarbeitung;
    private ColorHSV yellowCV;  
    private ArrayList<Contour> contours;
    private final int MIN_WIDTH = 10;
    private final int MIN_HEIGHT = 10;
    private final int MIN_AREA = 100;
    private Rectangle boundingBox;
    PImage yellowMask;    
    PVector Start = new PVector(58,159);
    PVector End = new PVector(299, 236);
    Rectangle roi;
    private boolean isBallWithinROI = false;
    private float IDEAL_RATIO = 0.85f;
    private final float IDEAL_RATIO_TOLERANCE = 0.25f;
    
    
    public BallDetection2(MotorControl motorControl , Bildverarbeitung bildverarbeitung, ColorHSV yellowCV) {
        this.motorControl = motorControl;
        this.bildverarbeitung = bildverarbeitung;
        this.yellowCV = yellowCV;
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
        return "BallDetection2";
    }
    
    public PVector midPoint(Rectangle r) {
        return new PVector(r.x + r.width / 2, r.y + r.height / 2);   
    }
    
    public void run() {
        while(STARTED) {
            // Rectangle res = yellowCV.detect(bildverarbeitung.getCameraImage().copy());
            // boundingBox = isValid(res);
            Rectangle[] ress;
            try {
                ress = yellowCV.det2(bildverarbeitung.getCameraImage().copy());
            } catch(Exception e) {
                println("Exception in BallDetection2: " + e);
                continue;
            }
            boundingBox = isValid(ress);
            
            if (boundingBox != null) {
                
                // int w = boundingBox.width;
                // int h = boundingBox.height;
                // double rat = (double)w / (double)h;
                // println("rat: " + rat);
                PVector mid = midPoint(boundingBox);
                if (roi.contains(mid.x, mid.y)) {
                    isBallWithinROI = true;
                    motorControl.disableBallNoti();
                } else {
                    isBallWithinROI = false;
                    motorControl.enableBallNoti();
                }
                motorControl.notify(this,motorControl.Forward((toMotorSignalLinear((int)mid.x))));
                // delay(70);
                // continue;
            } else {    
                
                motorControl.notify(this,motorControl.Turn());
            }
            yellowMask = yellowCV.getMask();
            delay(40);
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
    
    public Rectangle isValid(Rectangle r) {
        if (r == null) {
            return null;
        }
        if (r.width < MIN_WIDTH ||  r.height < MIN_HEIGHT) {
            return null;
        }
        
        if (r.width * r.height < MIN_AREA) {
            return null;
        }
        return r;
    }
    
    public Rectangle isValid(Rectangle[]rects) {
        if (rects == null) {
            return null;
        }
        for (Rectangle r : rects) {
            if (r == null) {
                continue;
            }
            
            float calc = abs(((float)r.width / (float)r.height) - IDEAL_RATIO);
            // println("r.width: " + r.width);
            // println("r.height: " + r.height);
            // println("r.width / r.height: " + r.width / r.height);
            // println("IDEAL_RATIO: " + IDEAL_RATIO);
            // println("calc: " + calc);
            if (calc > IDEAL_RATIO_TOLERANCE) {
                continue;
            }
            if (r.width < MIN_WIDTH ||  r.height < MIN_HEIGHT) {
                continue;
            }
            
            if (r.width * r.height < MIN_AREA) {
                continue;
            }
            return r;
        }
        return null;
    }
    
    public int getXPos(Rectangle r) {
        return r.x + r.width / 2;
        
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
