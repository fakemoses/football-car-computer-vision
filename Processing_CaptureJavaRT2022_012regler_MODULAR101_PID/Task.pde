class Task implements Comparable<Task>, TaskProperties{
    private final int priority;
    private final ThreadInterface instance;
    
    /*
    * loopCount indicate that task is available for execution
    * if loopCount is 0, try to execute next task
    * some tasks require more loops to be executed
    * for example, reverse or turning
    */
    private int loopCount;
    
    private MotorHandler handler;
    
    public Task(ThreadInterface instance, int priority) {
        this.instance = instance;
        this.priority = priority;	
        this.loopCount = 0;
    }
    
    @Override
    public int compareTo(Task t) {
        return this.priority - t.priority;
    }
    
    public int getLoopCount() {
        return loopCount;
    }
    
    public void setLoopCount(int count) {
        this.loopCount = count;
    }
    
    public ThreadInterface getInstance() {
        return this.instance;
    }
    
    public void setHandler(MotorHandler handler) {
        this.handler = handler;
    }
    
    public MotorHandler getHandler() {
        return this.handler;
    }
    
    /*
    * indicate that a task is executing
    */
    public void loop() {
        this.loopCount = this.loopCount == 0 ? 0 : this.loopCount - 1;
    }
    
    public void execute() {
        println("Executing task: " + this.instance.getThreadName() + " handler name: " + this.handler.getHandlerName());
        handler.execute();
    }
    
}