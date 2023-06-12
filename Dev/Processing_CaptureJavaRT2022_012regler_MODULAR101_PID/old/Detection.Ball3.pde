public class BallDetection3 extends DetectionThread {
    
    private ArrayList<Rectangle> rects;
    private Rectangle boundingBox;
    private Rectangle[] previousBoundingBoxes;
    private boolean isFull;
    private boolean isTurn = false;
    
    Detector<Rectangle> objectDetector;
    Comm comm;
    
    private final int MIN_WIDTH = 10;
    private final int MIN_HEIGHT = 10;
    private final int MIN_AREA = 200;
    
    private final color boxColorOut = color(0, 0, 255);
    private final color boxColorIn = color(0, 255, 0);
    private final int boxThickness = 2;
    
    private final color roiColor = color(255, 0, 0);
    private final int roiThickness = 2;
    
    PVector Start = new PVector(95,175);
    PVector End = new PVector(225, 236);
    Rectangle roi;
    
    private boolean isBallWithinROI = false;
    private float IDEAL_RATIO = 0.85f;
    private final float IDEAL_RATIO_TOLERANCE = 0.25f;
    
    private long startTime = System.currentTimeMillis();
    private long endTime = 0;
    private long duration = 0;
    private float motorPower = 1.0f;
    
    Rectangle isBboxAvailable;
    
    
    
    public BallDetection3(MotorControl motorControl , ColorFilter colorFilter, Detector<Rectangle> objectDetector, Comm comm) {
        super(motorControl, colorFilter);
        this.objectDetector = objectDetector;
        
        int w = (int)(End.x - Start.x);
        int h = (int)(End.y - Start.y);
        this.roi = new Rectangle((int) Start.x,(int) Start.y, w, h);
        this.previousBoundingBoxes = new Rectangle[60];
        this.isFull = false;
    }
    
    public String getThreadName() {
        return "BallDetection3";
    }
    
    public void run() {
        while(STARTED) {
            
            if (image == null) {
                delay(50);
                continue;
            }
            mask = colorFilter.filter(image);
            rects = objectDetector.detect(image, mask);
            
            if (rects == null || rects.size() == 0) {
                boundingBox = null;
                // println("Rects is null");
                // continue;
            }
            else{
                println(rects.size());
                boundingBox = rects.get(0);
            }
            
            
            // TODO: Refactor this
            // IDEA: Move Logic to MotorControl
            // DetectionThread should have less clutter
            if (boundingBox != null) {
                // if (roi.contains(boundingBox.getCenterX(), boundingBox.getCenterY())) {
                //     isBallWithinROI = true;
                //     motorControl.disableBallNoti();
            // } else {
                //     isBallWithinROI = false;
                float motorSignal = toMotorSignalLinear((int)boundingBox.getCenterX());
                // endTime = System.currentTimeMillis();
                
                if (isTurn) {
                    isTurn = false;
                    motorControl.notify(this, HandlerPriority.PRIORITY_HIGH, motorControl.Stop(15), motorControl.Forward(2, motorSignal, 0.75f));
                    continue;
                }
                // if (isTurn && (endTime - startTime) < 1000) {
                //     motorPower = 0.0f;
            // } else if (isTurn && (endTime - startTime) > 1000 && (endTime - startTime) < 2000) {
                //     if (motorSignal > 0.6 || motorSignal < - 0.6) {
                //         motorPower = 0.7f;           
                //     }
            // }
                // else{
                //     isTurn = false;
                motorPower = 0.85f;
            // }
                motorControl.enableBallNoti();
                motorControl.notify(this, HandlerPriority.PRIORITY_MEDIUM, motorControl.Forward(2, motorSignal, motorPower));
            // }
                //delay(70);
                continue;
            } else { 
                isTurn = true;
                // startTime = System.currentTimeMillis();
                println("Turn");
                motorControl.notify(this, HandlerPriority.PRIORITY_LOW,motorControl.Turn(1));  
            }
        }
    }
    
    
    public Rectangle getBoundingBox() {
        return boundingBox;
    }
    
    public Rectangle isValid(ArrayList<Rectangle> rects) {
        if (rects == null) {
            return null;
        }
        for (Rectangle r : rects) {
            if (r ==  null) {
                continue;
            }
            float calc = abs(((float)r.width / (float)r.height) - IDEAL_RATIO);
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
    
    public PImage[] getResults() {
        if (image == null ||  mask == null) {
            return null;
        }
        PImage[] results = new PImage[2];
        PImage retImage = drawRect(image, roi, roiThickness, roiColor, false);
        color boxColor = isBallWithinROI ? boxColorIn : boxColorOut;
        if (boundingBox == null) {
            println("boundingBoxis null");
        }
        results[0] = boundingBox == null ? retImage : drawRect(retImage, boundingBox, boxThickness, boxColor, false);
        results[1] = mask;
        return results;
    }
    
    
    public float toMotorSignalLinear(int xCenter) {
        int MAXWIDTH = 320; // todo: setvariable 
        return(float)(xCenter - (MAXWIDTH / 2)) / (MAXWIDTH / 2);
    }
    
    public boolean isBallWithinROI() {
        return isBallWithinROI;
    }
    
    public void updateBbox(Rectangle value) {
        //      if (!isFull) {
        //          // Array is not full, so simply add new value to next available slot
        //          for (int i = 0; i < previousBoundingBoxes.length; i++) {
        //              if (previousBoundingBoxes[i] == null) {
        //                  previousBoundingBoxes[i] = value;
        //                  break;
        //              }
        //          }
        //          // Check if array is now full
        //          isFull = (previousBoundingBoxes[previousBoundingBoxes.length - 1] != null);
// } else {
        // Shift all values down one slot
        for (int i = 0; i < previousBoundingBoxes.length - 1; i++) {
            previousBoundingBoxes[i] = previousBoundingBoxes[i + 1];
        }
        previousBoundingBoxes[previousBoundingBoxes.length - 1] = value;
// }
}

}
