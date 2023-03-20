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
    
    public GoalDetection(MotorControl motorControl, ColorFilter colorFilter, Detector<Rectangle> objectDetector) {
        super(motorControl, colorFilter);
        this.objectDetector = objectDetector;
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
            for (int i = previousBoundingBoxes.length-1; i >= 0; i--) {
                if (previousBoundingBoxes[i] != null) {
                    numNullBboxes++;
                }
            }

            Rectangle isBboxAvailable = boundingBox;
            for (int i = previousBoundingBoxes.length-1; i >= 0; i--) {
                if (previousBoundingBoxes[i] != null) {
                    isBboxAvailable = previousBoundingBoxes[i];
                    break;
                }
            }

            if (isBboxAvailable != null && numNullBboxes > 2) {
                int xCenter = getXPos(isBboxAvailable);
                float motorSignal = toMotorSignalLinear(xCenter);
                motorControl.notify(this,motorControl.Forward(motorSignal));
            } else{
                motorControl.notify(this,motorControl.Turn());
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
