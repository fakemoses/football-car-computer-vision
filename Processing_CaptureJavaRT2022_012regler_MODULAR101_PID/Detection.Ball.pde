public class BallDetection extends DetectionThread {
    
    private ArrayList<Rectangle> rects;
    private Rectangle boundingBox;
    private Rectangle[] previousBoundingBoxes;
    private boolean isFull;
    
    Detector<Rectangle> objectDetector;
    Comm comm ;
    
    private final int MIN_WIDTH = 10;
    private final int MIN_HEIGHT = 10;
    private final int MIN_AREA = 200;
    
    private final color boxColorOut = color(0, 0, 255);
    private final color boxColorIn = color(0, 255, 0);
    private final int boxThickness = 2;
    
    private final color roiColor = color(255, 0, 0);
    private final int roiThickness = 2;
    
    PVector Start = new PVector(58,159);
    PVector End = new PVector(299, 236);
    Rectangle roi;
    
    private boolean isBallWithinROI = false;
    private float IDEAL_RATIO = 0.85f;
    private final float IDEAL_RATIO_TOLERANCE = 0.25f;
    
    
    public BallDetection(MotorControl motorControl , ColorFilter colorFilter, Detector<Rectangle> objectDetector, Comm comm) {
        super(motorControl, colorFilter);
        this.objectDetector = objectDetector;
        
        int w = (int)(End.x - Start.x);
        int h = (int)(End.y - Start.y);
        this.roi = new Rectangle((int) Start.x,(int) Start.y, w, h);
        this.previousBoundingBoxes = new Rectangle[5];
        this.isFull = false;
    }
    
    public String getThreadName() {
        return "BallDetection";
    }
    
    public void run() {
        while(STARTED) {
            if (image == null) {
                delay(50);
                continue;
            }
            mask = colorFilter.filter(image);
            rects = objectDetector.detect(image, mask);
            boundingBox = isValid(rects);
            updateBbox(boundingBox);
            int numNullBboxes = 0;
            Rectangle isBboxAvailable = boundingBox;
            for (int i = previousBoundingBoxes.length-1; i >= 0; i--) {
                if (previousBoundingBoxes[i] != null) {
                    numNullBboxes++;
                }
            }

            for (int i = previousBoundingBoxes.length-1; i >= 0; i--) {
                if (previousBoundingBoxes[i] != null) {
                    isBboxAvailable = previousBoundingBoxes[i];
                    break;
                }
            }
            
            if (isBboxAvailable != null && numNullBboxes > 2) {
                if (roi.contains(isBboxAvailable.getCenterX(), isBboxAvailable.getCenterY())) {
                    isBallWithinROI = true;
                    motorControl.disableBallNoti();
                } else {
                    isBallWithinROI = false;
                    motorControl.enableBallNoti();
                    motorControl.notify(this,motorControl.Forward((toMotorSignalLinear((int)isBboxAvailable.getCenterX()))));
                }
                //delay(70);
                continue;
            } else { 
                motorControl.notify(this,motorControl.Turn());
            }
            delay(40);
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
            if (r == null) {
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
        if (image == null || mask == null) {
            return null;
        }
        PImage[] results = new PImage[2];
        PImage retImage = drawRect(image, roi, roiThickness, roiColor, false);
        color boxColor = isBallWithinROI ? boxColorIn : boxColorOut;
        results[0] = boundingBox == null ? retImage : drawRect(retImage, boundingBox, boxThickness, boxColor, false);
        results[1] = mask;
        return results;
    }
    
    
    public float toMotorSignalLinear(int xCenter) {
        int MAXWIDTH = 320; // todo: set variable 
        return(float)(xCenter - (MAXWIDTH / 2)) / (MAXWIDTH / 2);
    }
    
    public boolean isBallWithinROI() {
        return isBallWithinROI;
    }

    public void updateBbox(Rectangle value) {
        if (!isFull) {
            // Array is not full, so simply add new value to next available slot
            for (int i = 0; i < previousBoundingBoxes.length; i++) {
                if (previousBoundingBoxes[i] == null) {
                    previousBoundingBoxes[i] = value;
                    break;
                }
            }
            // Check if array is now full
            isFull = (previousBoundingBoxes[previousBoundingBoxes.length-1] != null);
        } else {
            // Shift all values down one slot
            for (int i = 0; i < previousBoundingBoxes.length-2; i++) {
                previousBoundingBoxes[i] = previousBoundingBoxes[i+1];
            }
            previousBoundingBoxes[previousBoundingBoxes.length-1] = value;
        }
    }
    
}
