public class BallDetection extends DetectionThread {
    
    private ArrayList<Rectangle> rects;
    private Rectangle boundingBox;
    
    private MemoryArray<Rectangle> memory;
    private final int MEMORY_SIZE = 15;
    
    Detector<Rectangle> objectDetector;
    Comm comm;
    
    private final color boxColorOut = color(0, 0, 255);
    private final color boxColorIn = color(0, 255, 0);
    private final int boxThickness = 2;
    
    private final color roiColor = color(255, 0, 0);
    private final int roiThickness = 2;
    
    PVector Start = new PVector(95,175);
    PVector End = new PVector(225, 236);
    Rectangle roi;
    
    private boolean isTurn = false;
    private boolean isBallWithinROI = false;
    
    private float motorPower = 1.0f;
    private Rectangle lastMemory;
    
    public BallDetection(MotorControl motorControl , ColorFilter colorFilter, Detector<Rectangle> objectDetector, Comm comm) {
        super(motorControl, colorFilter);
        this.objectDetector = objectDetector;
        
        int w = (int)(End.x - Start.x);
        int h = (int)(End.y - Start.y);
        this.roi = new Rectangle((int) Start.x,(int) Start.y, w, h);
        
        this.memory = new MemoryArray<Rectangle>(MEMORY_SIZE);
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
            
            Rectangle result = getRectangleFromDetectionResult(rects);
            memory.addCurrentMemory(result);
            
            // TODO: Refactor this
            // IDEA: Move Logic to MotorControl
            // DetectionThread should have less clutter
            lastMemory = memory.getLastRememberedMemory(); 
            
            if (lastMemory == null) {
                isTurn = true;
                // motorControl.notify(this, HandlerPriority.PRIORITY_LOW,motorControl.Turn(1));  
                motorControl.notify(this, HandlerPriority.PRIORITY_LOWEST,motorControl.randomHandler(10, 3));  
                continue;
            }
            
            float motorSignal = toMotorSignalLinear((int)lastMemory.getCenterX());
            
            if (isTurn) {
                isTurn = false;
                motorControl.notify(this, HandlerPriority.PRIORITY_HIGH, motorControl.Stop(15), motorControl.Forward(2, motorSignal, 0.9f));
                continue;
            }
            
            if (isRectInROI(lastMemory)) {
                isBallWithinROI = true;
                motorControl.disableBallNoti();
                continue;
            }
            
            motorPower = 0.85f;
            isBallWithinROI = false;
            motorControl.enableBallNoti();
            motorControl.notify(this, HandlerPriority.PRIORITY_MEDIUM, motorControl.Forward(2, motorSignal, motorPower));
            continue;            
        }
    }
    
    public Rectangle getBoundingBox() {
        return boundingBox;
    }
    
    private Rectangle getRectangleFromDetectionResult(ArrayList<Rectangle> rects) {
        if (rects == null || rects.size() == 0) {
            return null;
        }
        return rects.get(0);
    }
    
    private boolean isRectInROI(Rectangle rect) {
        return roi.contains(rect.getCenterX(), rect.getCenterY());
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
        results[0] = lastMemory == null ? retImage : drawRect(retImage, lastMemory, boxThickness, boxColor, false);
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
}
