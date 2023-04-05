public class MotorControl implements Mediator {
    private Antrieb antrieb;
    private boolean MOTOR_RUNNING = false;
    private TaskArray<Task> tasks;
    private boolean isBall = false;
    private boolean isGoal = false;
    
    public MotorControl(Antrieb antrieb) {
        this.antrieb = antrieb;
        tasks = new TaskArray();
    }
    
    public ReverseHandler Reverse() {
        return new ReverseHandler(antrieb);
    }
    
    public ForwardHandler Forward(float d, float motorPower) {
        return new ForwardHandler(antrieb, d, motorPower);
    }  
    
    public TurnHandler Turn() {
        return new TurnHandler(antrieb);
    }   
    
    public StopForGoalHandler StopForGoal() {
        return new StopForGoalHandler(antrieb);
    }
    
    public void start() {
        if (!MOTOR_RUNNING) {
            MOTOR_RUNNING = true;
        }
    }
    
    public void stop() {
        if (MOTOR_RUNNING) {
            MOTOR_RUNNING = false;
        }
    }
    
    public void disableBallNoti() {
        if (!isBall) {
            println("DISABLE Notification from Ball Detection");
            isBall = true;
        }
    }
    
    public void enableBallNoti() {
        if (isBall) {
            println("ENABLE Notification from Ball Detection");
            isBall = false;
        }
    }
    
    public void disableGoalNoti() {
        if (!isGoal) {
            println("DISABLE Notification from Goal Detection");
            isGoal = true;
        }
    }
    
    public void enableGoalNoti() {
        if (isGoal) {
            println("ENABLE Notification from Goal Detection");
            isGoal = false;
        }
    }
    
    public void register(DetectionThread instance, int priority) {
        tasks.add(new Task(instance, priority));
        if (tasks.size() > 1) {
            sortTasks();
        }
    }
    
    private void sortTasks() {
        Collections.sort(tasks);
    }
    
    @Override
    public void notify(DetectionThread sender, MotorHandler handler, int loopCount) {
        if ((isGoal)) {
            return;
        }
        if ((isBall && sender instanceof BallDetection)) {
            return;
        }
        
        tasks.updateTask(sender, handler, loopCount);
    }
    
    @Override
    public void notify(DetectionThread sender, MotorHandler handler) {
        notify(sender, handler, 1);
    }
    
    public void run() {
        if (!MOTOR_RUNNING) {
            return;
        }
        tasks.execute();
    }
}
