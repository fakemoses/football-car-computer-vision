public class GoalDetection extends DetectionThread{
    
    private ArrayList<Rectangle> rects;
    private Rectangle boundingBox;
    private Rectangle[] previousBoundingBoxes;
    private boolean isFull;
    
    private Detector<Rectangle> objectDetector;
    
    private final int MIN_WIDTH = 30;
    private final int MIN_HEIGHT = 30;
    private final int MIN_AREA = 900; 
    
    private final color boxColor = color(0, 255, 0);
    private final int boxThickness = 2;
    
    PVector Start = new PVector(40, 120);
    PVector End = new PVector(299, 160);
    Rectangle roi;
    
    private boolean isGoalWithinROI = false;
    private float motorPower = 1.0f;
    
    public GoalDetection(MotorControl motorControl, ColorFilter colorFilter, Detector<Rectangle> objectDetector) {
        super(motorControl, colorFilter);
        this.objectDetector = objectDetector;
        
        int w = (int)(End.x - Start.x);
        int h = (int)(End.y - Start.y);
        this.roi = new Rectangle((int) Start.x,(int) Start.y, w, h);
        previousBoundingBoxes = new Rectangle[5];
        isFull = false;
    }
    
    public String getThreadName() {
        return "GoalDetection";
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
            double bboxArea = 0.0;
            for (int i = previousBoundingBoxes.length - 1; i >= 0; i--) {
                if (previousBoundingBoxes[i] != null) {
                    bboxArea += previousBoundingBoxes[i].getWidth() * previousBoundingBoxes[i].getHeight();	
                    numNullBboxes++;
                }
            }
            bboxArea = bboxArea / numNullBboxes;
            
            for (int i = previousBoundingBoxes.length - 1; i >= 0; i--) {
                if (previousBoundingBoxes[i] != null) {
                    isBboxAvailable = previousBoundingBoxes[i];
                    break;
                }
            }
            
            if (isBboxAvailable != null && numNullBboxes > 2) {
                
                if (bboxArea > 12000.0) {
                    isGoalWithinROI = true;
                    motorControl.notify(this, HandlerPriority.PRIORITY_HIGH, motorControl.StopForGoal(1));
                    motorControl.disableGoalNoti();
                } else{
                    isGoalWithinROI = false;
                    motorControl.notify(this, HandlerPriority.PRIORITY_MEDIUM ,motorControl.Forward(1,(toMotorSignalLinear((int)isBboxAvailable.getCenterX())),motorPower));
                    // motorControl.enableGoalNoti();
                }
                continue;
            } else {
                motorControl.notify(this, HandlerPriority.PRIORITY_LOW, motorControl.Turn(1));
            }
            delay(50);
        }
    }
    
    public Rectangle isValid(ArrayList<Rectangle> rects) {
        if (rects == null) {
            return null;
        }
        
        for (Rectangle r : rects) {
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
    
    public PImage[] getResults() {
        if (image == null || mask == null) {
            return null;
        }
        PImage[] results = new PImage[2];
        results[0] = boundingBox == null ? image : drawRect(image, boundingBox, boxThickness, boxColor, false);
        results[1] = mask;
        return results;
    }
    
    public float toMotorSignalLinear(int xCenter) {
        int MAXWIDTH = 320; // todo: set variable 
        return(float)(xCenter - (MAXWIDTH / 2)) / (MAXWIDTH / 2);
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
            isFull = (previousBoundingBoxes[previousBoundingBoxes.length - 1] != null);
        } else {
            // Shift all values down one slot
            for (int i = 0; i < previousBoundingBoxes.length - 1; i++) {
                previousBoundingBoxes[i] = previousBoundingBoxes[i + 1];
            }
            previousBoundingBoxes[previousBoundingBoxes.length - 1] = value;
        }
    }
}
