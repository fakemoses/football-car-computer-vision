public class DataContainer {
    
    private ReentrantLock lock;
    
    // TODO: MotorState -> state controlled by MotorControl
    // TODO: Should ROI also use MemoryArray?
    
    // Ball Memory
    private final int BALL_MEMORY_SIZE = 15;
    private MemoryArray<Rectangle> ballMemory;
    private Rectangle latestBallMemory;
    
    // Goal Memory
    private final int GOAL_MEMORY_SIZE = 15;
    private MemoryArray<Rectangle> goalMemory;
    private Rectangle latestGoalMemory;
    
    // Line Memory
    private Line latestLineMemory;
    
    // Object State
    private boolean isBallInRoi;
    private boolean isGoalInRoi;
    
    // Motor State 
    //TODO: Should this be combined together? sync with MotorState
    private boolean isTurn;
    private boolean isShot;
    
    
    public DataContainer() {
        this.lock = new ReentrantLock();
        
        this.ballMemory = new MemoryArray<Rectangle>(BALL_MEMORY_SIZE);
        this.goalMemory = new MemoryArray<Rectangle>(GOAL_MEMORY_SIZE);
        
        this.isBallInRoi = false;
        this.isGoalInRoi = false;
    }
    
    public Shape update(DetectionThread instance, Shape shape) {
        try {
            lock.lock();
            return route(instance, shape);
        } finally {
            lock.unlock();
        }
    }
    
    private Shape route(DetectionThread instance, Shape shape) {
        if (instance instanceof BallDetection) {
            return ballDetectionRoute((Rectangle) shape);
        } 
        
        if (instance instanceof GoalDetection) {
            return goalDetectionRoute((Rectangle) shape);
        } 
        
        if (instance instanceof LineDetection) {
            return lineDetectionRoute((Line) shape);
        } 
        
        throw new IllegalArgumentException("Unknown instance type. Check Implementation");
        
    }
    
    private Rectangle ballDetectionRoute(Rectangle shape) {
        ballMemory.addCurrentMemory(shape);
        latestBallMemory = ballMemory.getLastRememberedMemory();
        return latestBallMemory;
    }
    
    private Rectangle goalDetectionRoute(Rectangle shape) {
        goalMemory.addCurrentMemory(shape);
        latestGoalMemory = goalMemory.getLastRememberedMemory();
        return latestGoalMemory;
    }
    
    private Line lineDetectionRoute(Line line) {
        latestLineMemory = line;
        return latestLineMemory;
    }
    
    private Rectangle getLatestBallMemory() {
        try{
            lock.lock();
            return latestBallMemory;
        } finally {
            lock.unlock();
        }
    }
    
    private Rectangle getLatestGoalMemory() {
        try{
            lock.lock();
            return latestGoalMemory;
        } finally {
            lock.unlock();
        }
    }
    
    private Line getLatestLineMemory() {
        try{
            lock.lock();
            return latestLineMemory;
        } finally {
            lock.unlock();
        }
    }
    
    public boolean isBallDetected() {
        try{
            lock.lock();
            return latestBallMemory != null;
        } finally {
            lock.unlock();
        }
    }
    
    public boolean isGoalDetected() {
        try{
            lock.lock();
            return latestGoalMemory != null;
        } finally {
            lock.unlock();
        }
    }
    
    public boolean isLineDetected() {
        try{
            lock.lock();
            return latestLineMemory != null;
        } finally {
            lock.unlock();
        }
    }
    
    public void setIsBallInRoi(boolean isBallInRoi) {
        try{
            lock.lock();
            this.isBallInRoi = isBallInRoi;
        } finally {
            lock.unlock();
        }
    }
    
    public boolean isBallInRoi() {
        try{
            lock.lock();
            return isBallInRoi;
        } finally {
            lock.unlock();
        }
    }
    
    public void setIsGoalInRoi(boolean isGoalInRoi) {
        try{
            lock.lock();
            this.isGoalInRoi = isGoalInRoi;
        } finally {
            lock.unlock();
        }
    }
    
    public boolean isGoalInRoi() {
        try{
            lock.lock();
            return isGoalInRoi;
        } finally {
            lock.unlock();
        }
    }
    
    public void setIsTurn(boolean isTurn) {
        try{
            lock.lock();
            this.isTurn = isTurn;
        } finally {
            lock.unlock();
        }
    }
    
    public boolean isTurn() {
        try{
            lock.lock();
            return isTurn;
        } finally {
            lock.unlock();
        }
    }
    
    public void setIsShot(boolean isShot) {
        try{
            lock.lock();
            this.isShot = isShot;
        } finally {
            lock.unlock();
        }
    }
    
    public boolean isShot() {
        try{
            lock.lock();
            return isShot;
        } finally {
            lock.unlock();
        }
    }
    
    
}