public class GoalDetection extends DetectionThread{
    
    Detector<Rectangle> objectDetector;
    DataContainer data;
    
    private ArrayList<Rectangle> rects;
    private Rectangle lastMemory;
    
    //timer
    private long startTime;
    private long endTime;
    private long duration;
    
    private final int MIN_WIDTH = 30;
    private final int MIN_HEIGHT = 30;
    private final int MIN_AREA = 900; 
    
    private final color boxColor = color(0, 255, 0);
    private final int boxThickness = 2;
    
    PVector Start = new PVector(40, 120);
    PVector End = new PVector(299, 160);
    Rectangle roi;
    
    private float motorPower = 1.0f;
    private final double MIN_GOAL_AREA = 10000.0;
    
    
    public GoalDetection(MotorControl motorControl, DataContainer data, ColorFilter colorFilter, Detector<Rectangle> objectDetector) {
        super(motorControl, colorFilter);
        
        this.objectDetector = objectDetector;
        this.data = data;        
        
        int w = (int)(End.x - Start.x);
        int h = (int)(End.y - Start.y);
        this.roi = new Rectangle((int) Start.x,(int) Start.y, w, h);
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
            
            Rectangle result = getRectangleFromDetectionResult(rects);
            
            lastMemory = (Rectangle)data.update(this, result);
            
            if (lastMemory == null) {
                motorControl.notify(this, HandlerPriority.PRIORITY_LOW,motorControl.Turn(1));  
                continue;
            } 
            
            float motorSignal = toMotorSignalLinear((int)lastMemory.getCenterX());
            double bboxArea = lastMemory.getWidth() * lastMemory.getHeight();

            println("bboxArea: " + bboxArea);
            
            data.setIsGoalInRoi(bboxArea > MIN_GOAL_AREA);
            
            if (data.isGoalInRoi()) {
                motorControl.notify(this, HandlerPriority.PRIORITY_MEDIUM ,motorControl.Forward(1,motorSignal,motorPower));       
                continue;
            } 	
            
            if (!data.isShot()) {
                data.setIsShot(true);
                startTime = System.currentTimeMillis();
                motorControl.notify(this, HandlerPriority.PRIORITY_HIGH, motorControl.StopForGoal(1));
                //motorControl.disableGoalNoti();
                continue;
            } 
            
            if (data.isShot()) {
                // TODO:Refactor this
                endTime = System.currentTimeMillis();
                duration = (endTime - startTime);
                if (duration > 1000 && duration < 3000) {
                    motorControl.notify(this, HandlerPriority.PRIORITY_HIGH ,motorControl.Reverse(5)); 
                }
                else if (duration > 3000 && duration < 4000) {
                    motorControl.notify(this, HandlerPriority.PRIORITY_HIGH ,motorControl.Turn(1));
                }
                else if (duration > 4000) {
                    data.setIsShot(false);
                    //motorControl.enableGoalNoti();
                }
                continue;
            }
            
            //debug
            throw new RuntimeException("Should not reach here");
        }
    }
    
    private Rectangle getRectangleFromDetectionResult(ArrayList<Rectangle> rects) {
        if (rects == null || rects.size() == 0) {
            return null;
        }
        return rects.get(0);
    }
    
    
    public int getXPos(Rectangle r) {
        return r.x + r.width / 2;
        
    }
    
    public PImage[] getResults() {
        if (image == null || mask == null) {
            return null;
        }
        PImage[] results = new PImage[2];
        results[0] = lastMemory == null ? image : drawRect(image, lastMemory, boxThickness, boxColor, false);
        results[1] = mask;
        return results;
    }
    
    public float toMotorSignalLinear(int xCenter) {
        int MAXWIDTH = 320; // todo: set variable 
        return(float)(xCenter - (MAXWIDTH / 2)) / (MAXWIDTH / 2);
    }
}
