public class GoalDetection extends DetectionThread{
    
    private ArrayList<Rectangle> rects;
    private Rectangle boundingBox;

    private MemoryArray<Rectangle> memory;
    private final int MEMORY_SIZE = 15;

    Detector<Rectangle> objectDetector;

    private boolean isFull;
    private boolean isShot;

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
    
    private boolean isGoalWithinROI = false;
    private float motorPower = 1.0f;

    private Rectangle lastMemory;
    
    public GoalDetection(MotorControl motorControl, ColorFilter colorFilter, Detector<Rectangle> objectDetector) {
        super(motorControl, colorFilter);
        this.objectDetector = objectDetector;
        
        int w = (int)(End.x - Start.x);
        int h = (int)(End.y - Start.y);
        this.roi = new Rectangle((int) Start.x,(int) Start.y, w, h);
        this.memory = new MemoryArray<Rectangle>(MEMORY_SIZE);

        isFull = false;
        isShot = false;
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
            memory.addCurrentMemory(result);

            lastMemory = memory.getLastRememberedMemory(); 

            if (lastMemory != null) {
                float motorSignal = toMotorSignalLinear((int)lastMemory.getCenterX());
                double bboxArea = lastMemory.getWidth() * lastMemory.getHeight();	
                
                if (bboxArea > 12000.0 && !isShot) {
                    isGoalWithinROI = true;
                    isShot = true;
                    startTime = System.currentTimeMillis();
                    motorControl.notify(this, HandlerPriority.PRIORITY_HIGH, motorControl.StopForGoal(1));
                    //motorControl.disableGoalNoti();
                } else if(isShot){
                    endTime = System.currentTimeMillis();
                    duration = (endTime - startTime);
                    if(duration > 1000 && duration < 3000){
                       motorControl.notify(this, HandlerPriority.PRIORITY_HIGH ,motorControl.Reverse(5)); 
                    }
                    else if(duration > 3000 && duration < 4000){
                        motorControl.notify(this, HandlerPriority.PRIORITY_HIGH ,motorControl.Turn(1));
                    }
                    else if(duration > 4000){
                        isShot = false;
                        //motorControl.enableGoalNoti();
                    }
                }
                else{
                    isGoalWithinROI = false;
                    motorControl.notify(this, HandlerPriority.PRIORITY_MEDIUM ,motorControl.Forward(1,motorSignal,motorPower));
                }
                continue;
            } else {
                motorControl.notify(this, HandlerPriority.PRIORITY_LOWEST,motorControl.randomHandler(10, 3));  
            }
            delay(50);
        }
    }

    private Rectangle getRectangleFromDetectionResult(ArrayList<Rectangle> rects) {
        if (rects == null || rects.size() == 0) {
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
        results[0] = lastMemory == null ? image : drawRect(image, lastMemory, boxThickness, boxColor, false);
        results[1] = mask;
        return results;
    }
    
    public float toMotorSignalLinear(int xCenter) {
        int MAXWIDTH = 320; // todo: set variable 
        return(float)(xCenter - (MAXWIDTH / 2)) / (MAXWIDTH / 2);
    }
}
