public class BallDetection extends DetectionThread {
    
    Detector<Rectangle> objectDetector;
    private ColorFilter colorFilter;
    
    private ArrayList<Rectangle> rects;
    private Rectangle lastMemory;
    
    private final color boxColorOut = color(0, 0, 255);
    private final color boxColorIn = color(0, 255, 0);
    private final int boxThickness = 2;
    
    private final color roiColor = color(255, 0, 0);
    private final int roiThickness = 2;
    
    PVector Start = new PVector(95,175);
    PVector End = new PVector(225, 236);
    Rectangle roi;
    
    private float motorPower = 1.0f;
    
    public BallDetection(MotorControl motorControl , DataContainer data, ColorFilter colorFilter, Detector<Rectangle> objectDetector) {
        super(motorControl, data);
        
        this.objectDetector = objectDetector;
        this.colorFilter = colorFilter;
        
        int w = (int)(End.x - Start.x);
        int h = (int)(End.y - Start.y);
        this.roi = new Rectangle((int) Start.x,(int) Start.y, w, h);
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
            
            data.update(this, result);
            lastMemory = data.getLatestBallMemory();
            
            if (lastMemory == null) {
                data.setIsSearch(true);
                motorControl.notify(this, HandlerPriority.PRIORITY_LOWEST,motorControl.randomHandler(10, 3));  
                continue;
            }
            
            float motorSignal = toMotorSignalLinear((int)lastMemory.getCenterX());
            
            if (data.isSearch()) {
                data.setIsSearch(false);
                motorControl.notify(this, HandlerPriority.PRIORITY_HIGH, motorControl.Stop(15), motorControl.Forward(2, motorSignal, 0.9f));
                continue;
            }
            
            data.setIsBallInRoi(isRectInROI(lastMemory));
            
            if (data.isBallInRoi()) {
                motorControl.disableBallNoti();
                continue;
            }
            
            motorPower = 0.85f;
            motorControl.enableBallNoti();
            motorControl.notify(this, HandlerPriority.PRIORITY_MEDIUM, motorControl.Forward(2, motorSignal, motorPower));
            continue;            
        }
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
        
        PImage retImage = imageUtils.drawRect(image, roi, roiThickness, roiColor, false);
        
        color boxColor = data.isBallInRoi() ? boxColorIn : boxColorOut;
        
        results[0] = lastMemory == null ? retImage : imageUtils.drawRect(retImage, lastMemory, boxThickness, boxColor, false);
        results[1] = mask;
        
        return results;
    }
    
    public float toMotorSignalLinear(int xCenter) {
        int MAXWIDTH = 320; // TODO: set variable 
        return(float)(xCenter - (MAXWIDTH / 2)) / (MAXWIDTH / 2);
    }
    
    public boolean isBallInRoi() {
        return data.isBallInRoi();
    } 
}
