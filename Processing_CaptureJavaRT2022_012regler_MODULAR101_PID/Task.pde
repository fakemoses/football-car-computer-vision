class Task implements Comparable<Task>, ITask{
    private final int taskPriority;
    private final DetectionThread instance;
    
    private BlockingQueue<MotorHandler> handlersQueue;
    
    private HandlerPriority handlerPriority;
    
    public Task(DetectionThread instance, int taskPriority) {
        this.instance = instance;
        this.taskPriority = taskPriority;	
        handlersQueue = new LinkedBlockingQueue<>();
    }
    
    @Override
    public int compareTo(Task t) {
        return this.taskPriority - t.taskPriority;
    }
    
    public DetectionThread getInstance() {
        return this.instance;
    }
    
    public HandlerPriority getHandlerPriority() {
        return this.handlerPriority;
    }
    
    public void setHandlerPriority(HandlerPriority handlerPriority) {
        this.handlerPriority = handlerPriority;
    }
    
    public void setHandler(MotorHandler...handlers) {
        // debug
        try {
            for (MotorHandler handler : handlers) {
                handlersQueue.put(handler);
            } 
        } catch(InterruptedException e) {
            Thread.currentThread().interrupt();
            println("Error Updating Handler");
        }
    }
    
    public MotorHandler[] getHandler() {
        return handlersQueue.toArray(new MotorHandler[0]);
    }
    
    public MotorHandler getFrontHandler() {
        return this.handlersQueue.peek();
    }
    
    public int getHandlerSize() {
        return this.handlersQueue.size();
    }
    
    public boolean isQueueEmpty() {
        return handlersQueue.size() ==  0;
    }
    
    public void execute() {
        
        // debug
        if (isQueueEmpty()) {
            throw new RuntimeException("Check Implementation");
        }
        
        MotorHandler handler = getFrontHandler();      
        handler.execute();
        println("Executing task: " + this.instance.getThreadName() + " handler name: " + handler.getHandlerName());
        
    }
    
    public void loop() {
        
        if (isQueueEmpty()) {
            return;
        }
        
        handlersQueue.remove();
    }
    
}