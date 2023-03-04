// Example implementation of a thread

public class GoalDetection extends DetectionThread{
    
    private ArrayList<Rectangle> rects;
    private Rectangle boundingBox;
    
    private Detector<Rectangle> objectDetector;
    
    private final int MIN_WIDTH = 10;
    private final int MIN_HEIGHT = 10;
    private final int MIN_AREA = 200; 
    
    public GoalDetection(MotorControl motorControl, ColorFilter colorFilter, Detector<Rectangle> objectDetector) {
        super(motorControl, colorFilter);
        this.objectDetector = objectDetector;
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
            if (boundingBox != null) {
                int xCenter = getXPos(boundingBox);
                float motorSignal = toMotorSignalLinear(xCenter);
                // motorControl.notify(this,motorControl.Forward(motorSignal));
            } else{
                // motorControl.notify(this,motorControl.Turn());
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
        results[0] = boundingBox == null ? image : drawRect(image, boundingBox, 2, color(0, 255, 0), false);
        results[1] = mask;
        return results;
    }
    
    public float toMotorSignalLinear(int xCenter) {
        int MAXWIDTH = 320; // todo: set variable 
        return(float)(xCenter - (MAXWIDTH / 2)) / (MAXWIDTH / 2);
    }
}
