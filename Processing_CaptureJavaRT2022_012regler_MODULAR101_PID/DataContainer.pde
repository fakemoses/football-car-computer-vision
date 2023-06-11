public class DataContainer {
    
    private final ReentrantReadWriteLock rwl;
    private final Lock readLock;
    private final Lock writeLock;
    
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
    private boolean isSearch;
    private boolean isShot;
    
    
    public DataContainer() {
        this.rwl = new ReentrantReadWriteLock();
        this.readLock = rwl.readLock();
        this.writeLock = rwl.writeLock();
        
        this.ballMemory = new MemoryArray<Rectangle>(BALL_MEMORY_SIZE);        
        this.goalMemory = new MemoryArray<Rectangle>(GOAL_MEMORY_SIZE);
        
        this.isBallInRoi = false;
        this.isGoalInRoi = false;
    }
    
    public void update(DetectionThread instance, Shape shape) {
        try {
            writeLock.lock();
            route(instance, shape);
        } finally {
            writeLock.unlock();
        }
    }
    
    private void route(DetectionThread instance, Shape shape) {
        if (instance instanceof BallDetection) {
            ballDetectionRoute((Rectangle) shape);
        } 
        
        if (instance instanceof GoalDetection) {
            goalDetectionRoute((Rectangle) shape);
        } 
        
        if (instance instanceof LineDetection) {
            lineDetectionRoute((Line) shape);
        } 
        
        throw new IllegalArgumentException("Unknown instance type. Check Implementation");
    }
    
    private void ballDetectionRoute(Rectangle shape) {
        ballMemory.addCurrentMemory(shape);
    }
    
    private void goalDetectionRoute(Rectangle shape) {
        goalMemory.addCurrentMemory(shape);
    }
    
    private void lineDetectionRoute(Line line) {
        latestLineMemory = line;
    }
    
    private Rectangle getLatestBallMemory() {
        try{
            readLock.lock();
            return latestBallMemory;
        } finally {
            readLock.unlock();
        }
    }
    
    private Rectangle getLatestGoalMemory() {
        try{
            readLock.lock();
            return latestGoalMemory;
        } finally {
            readLock.unlock();
        }
    }
    
    private Line getLatestLineMemory() {
        try{
            readLock.lock();
            return latestLineMemory;
        } finally {
            readLock.unlock();
        }
    }
    
    public boolean isBallDetected() {
        try{
            readLock.lock();
            return latestBallMemory != null;
        } finally {
            readLock.unlock();
        }
    }
    
    public boolean isGoalDetected() {
        try{
            readLock.lock();
            return latestGoalMemory != null;
        } finally {
            readLock.unlock();
        }
    }
    
    public boolean isLineDetected() {
        try{
            readLock.lock();
            return latestLineMemory != null;
        } finally {
            readLock.unlock();
        }
    }
    
    public void setIsBallInRoi(boolean isBallInRoi) {
        try{
            writeLock.lock();
            this.isBallInRoi = isBallInRoi;
        } finally {
            writeLock.unlock();
        }
    }
    
    public boolean isBallInRoi() {
        try{
            readLock.lock();
            return isBallInRoi;
        } finally {
            readLock.unlock();
        }
    }
    
    public void setIsGoalInRoi(boolean isGoalInRoi) {
        try{
            writeLock.lock();
            this.isGoalInRoi = isGoalInRoi;
        } finally {
            writeLock.unlock();
        }
    }
    
    public boolean isGoalInRoi() {
        try{
            readLock.lock();
            return isGoalInRoi;
        } finally {
            readLock.unlock();
        }
    }
    
    public void setIsSearch(boolean isSearch) {
        try{
            writeLock.lock();
            this.isSearch = isSearch;
        } finally {
            writeLock.unlock();
        }
    }
    
    public boolean isSearch() {
        try{
            readLock.lock();
            return isSearch;
        } finally {
            readLock.unlock();
        }
    }
    
    public void setIsShot(boolean isShot) {
        try{
            writeLock.lock();
            this.isShot = isShot;
        } finally {
            writeLock.unlock();
        }
    }
    
    public boolean isShot() {
        try{
            readLock.lock();
            return isShot;
        } finally {
            readLock.unlock();
        }
    }     
}