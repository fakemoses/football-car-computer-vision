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
    private boolean isTurn;
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
    
    public Shape update(DetectionThread instance, Shape shape) {
        try {
            writeLock.lock();
            return route(instance, shape);
        } finally {
            writeLock.unlock();
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
        
        // if (goalMemory.getLastRememberedMemory() == null) {
        //     latestGoalMemory = null;
        //     return null;
    // }
        // latestGoalMemory = trimmed(goalMemory.getAllMemory(), 20);
        latestGoalMemory = goalMemory.getLastRememberedMemory();
        return latestGoalMemory;
    }
    
    private Line lineDetectionRoute(Line line) {
        latestLineMemory = line;
        return latestLineMemory;
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
    
    public void setIsTurn(boolean isTurn) {
        try{
            writeLock.lock();
            this.isTurn = isTurn;
        } finally {
            writeLock.unlock();
        }
    }
    
    public boolean isTurn() {
        try{
            readLock.lock();
            return isTurn;
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
    
    public Rectangle trimmed(Rectangle[] all, double percentage) {
        Arrays.sort(all, new Comparator<Rectangle>() {
            @Override
            public int compare(Rectangle o1, Rectangle o2) {
                return(o1.width * o1.height) - (o2.width * o2.height);
            }
        });
        
        int trim = (int)(all.length * percentage);
        
        Rectangle[] trimmed = Arrays.copyOfRange(all, trim, all.length - trim);
        
        int x = 0, y = 0, width = 0, height = 0;
        for (Rectangle r : trimmed) {
            x += r.x;
            y += r.y;
            width += r.width;
            height += r.height;
        }
        
        return new Rectangle(x / trimmed.length, y / trimmed.length, width / trimmed.length, height / trimmed.length);
    }
    
    
}