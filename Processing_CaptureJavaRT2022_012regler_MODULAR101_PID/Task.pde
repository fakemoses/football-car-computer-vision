class Task implements Comparable<Task>, Loopable{
    ThreadInterface instance;
    int priority;
    int loopCount = 0;
    MotorHandler handler;
    
    public Task(ThreadInterface instance, int priority) {
        this.instance = instance;
        this.priority = priority;
    }
    
    @Override
    public int compareTo(Task t) {
        return this.priority - t.priority;
    }
    // loopCount indicate that task is available for execution
    // if loopCount is 0, try to execute next task
    // some tasks require more loops to be executed
    // for example, reverse or turning
    // to avoid thread lock
    
    public int getLoopCount() {
        return loopCount;
    }
    
    public void setLoopCount(int count) {
        this.loopCount = loopCount;
    }
    
    public void loop() {
        this.loopCount = this.loopCount == 0 ? 0 : this.loopCount - 1;
    }
    
    public void execute() {
        handler.execute();
    }
}