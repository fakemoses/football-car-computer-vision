abstract class DetectionThread implements IDetectionThread, Runnable {
    protected Thread myThread = null;
    protected boolean STARTED = false;
    
    protected MotorControl motorControl;
    protected DataContainer data;
    
    protected ImageUtils imageUtils;
    
    PImage image;
    PImage mask;   
    
    public DetectionThread(MotorControl motorControl, DataContainer data) {
        this.motorControl = motorControl;
        this.data = data;
        
        this.imageUtils = new ImageUtils();
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
    
    public void setImage(PImage image) {
        this.image = image.copy();
    }
    
    public abstract String getThreadName();
    
    public abstract void run();
    
    public abstract PImage[] getResults();
}

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


public class GoalDetection extends DetectionThread{
    
    private Detector<Rectangle> objectDetector;
    private ColorFilter colorFilter;
    
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
        super(motorControl, data);
        
        this.objectDetector = objectDetector;
        this.colorFilter = colorFilter;       
        
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
            
            data.update(this, result);
            lastMemory = data.getLatestGoalMemory();
            
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
        results[0] = lastMemory == null ? image : imageUtils.drawRect(image, lastMemory, boxThickness, boxColor, false);
        results[1] = mask;
        return results;
    }
    
    public float toMotorSignalLinear(int xCenter) {
        int MAXWIDTH = 320; // todo: set variable 
        return(float)(xCenter - (MAXWIDTH / 2)) / (MAXWIDTH / 2);
    }
}


public class LineDetection extends DetectionThread {
    
    private Detector<Line> lineDetector;
    private ColorFilter colorFilter;
    
    private Boundary boundary;
    private PImage boundaryResult;
    
    private ArrayList<Line> lines;
    private Line detectedLine;
    
    private final color lineColor = color(255, 0, 0);
    private final int lineThickness = 2;
    
    public LineDetection(MotorControl motorControl, DataContainer data, ColorFilter colorFilter, Detector<Line> lineDetector, Boundary boundary) {
        super(motorControl, data);
        
        this.lineDetector = lineDetector;
        this.colorFilter = colorFilter;
        
        this.boundary = boundary;
    }
    
    public String getThreadName() {
        return "LineDetection";
    }
    
    public void run() {
        while(STARTED) {
            if (image == null) {
                delay(50);
                continue;
            }
            
            mask = colorFilter.filter(image);
            lines = lineDetector.detect(image, mask);
            
            Line result = getLineFromDetectionResult(lines);
            
            data.update(this, result);
            detectedLine = data.getLatestLineMemory();
            
            if (boundary.isHelpNeeded(detectedLine)) {
                motorControl.notify(this, HandlerPriority.PRIORITY_HIGH, motorControl.Reverse(5));
            }
        }
    }
    
    public PImage[] getResults() {
        if (image == null || mask == null) {
            return null;
        }
        PImage[] results = new PImage[3];
        
        results[0] = detectedLine == null ? image : imageUtils.drawLine(image, detectedLine, lineThickness, lineColor);
        results[1] = mask;
        results[2] = boundary.getBoundaryResult();
        return results;
    }
    
    private Line getLineFromDetectionResult(ArrayList<Line> lines) {
        if (lines == null || lines.size() == 0) {
            return null;
        }
        return lines.get(0);
    }
}


public class ThreadController {
    DetectionThread[] threads;
    
    public ThreadController(DetectionThread...threads) {
        this.threads = threads;
    }
    
    public void startAllThread() {
        for (DetectionThread t : threads) {
            t.startThread();
        }
    }
    
    public void updateImage(PImage image) {   
        for (DetectionThread t : threads) {
            t.setImage(image);
        }
    }
    
    public PImage[][] getDetectionResults() {
        PImage[][] images = new PImage[threads.length][];
        for (int i = 0; i < threads.length; i++) {
            PImage[] result = threads[i].getResults();
            images[i] = result != null ? result : new PImage[0];
        }
        return images;
    }
}

public class CarDetection extends DetectionThread {
    
    private Detector<Rectangle> objectDetector;
    private ColorFilter colorFilter;
    
    public CarDetection(MotorControl motorControl, DataContainer data, ColorFilter colorFilter, Detector<Rectangle> objectDetector) {
        super(motorControl, data);
        
        this.objectDetector = objectDetector;
        this.colorFilter = colorFilter;
    }
    
    public String getThreadName() {
        return "CarDetection";
    }
    
    public void run() {
        throw new UnsupportedOperationException("Method not implemented yet.");
    }
    
    public PImage[] getResults() {
        throw new UnsupportedOperationException("Method not implemented yet.");
    }
}

