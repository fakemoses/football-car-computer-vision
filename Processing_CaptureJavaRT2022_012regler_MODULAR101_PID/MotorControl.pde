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
    
    public ReverseHandler[] Reverse(int loop) {
        ReverseHandler[] returnHandler = new ReverseHandler[loop];
        Arrays.fill(returnHandler, new ReverseHandler(antrieb));
        return returnHandler;
    }
    
    
    public ForwardHandler[] Forward(int loop, float d, float motorPower) {
        ForwardHandler[] returnHandler = new ForwardHandler[loop];
        Arrays.fill(returnHandler, new ForwardHandler(antrieb, d, motorPower));
        return returnHandler;
    }
    
    
    public TurnHandler[] Turn(int loop) {
        TurnHandler[] returnHandler = new TurnHandler[loop];
        Arrays.fill(returnHandler, new TurnHandler(antrieb));
        return returnHandler;
    }       
    
    public StopForGoalHandler[] StopForGoal(int loop) {
        StopForGoalHandler[] returnHandler = new StopForGoalHandler[loop];
        Arrays.fill(returnHandler, new StopForGoalHandler(antrieb));
        return returnHandler;
    }
    
    public StopHandler[] Stop(int loop) {
        StopHandler[] returnHandler = new StopHandler[loop];
        Arrays.fill(returnHandler, new StopHandler(antrieb));
        return returnHandler;
    }
    
    public MotorHandler[] randomHandler(int loop, int randomHandlerCount) {
        
        if (loop < 1 || randomHandlerCount < 1) {
            throw new IllegalArgumentException("loop and randomHandlerCount must be greater than 0");
        }
        
        MotorHandler[] returnHandler = new MotorHandler[loop * randomHandlerCount];
        
        // random
        for (int i = 0; i < randomHandlerCount; i++) {
            float random = (float)(Math.random());            
            if (random <=  0.75) {
                float direction = (float)(Math.random() * 2 - 1);
                Arrays.fill(returnHandler, loop * i, loop * (i + 1), new ForwardHandler(antrieb, direction, 0.85f));
            } else {
                Arrays.fill(returnHandler, loop * i, loop * (i + 1), new TurnHandler(antrieb));
            }
        }
        return returnHandler;
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
    
    private MotorHandler[] flatten(MotorHandler[]...handlers) {
        return Arrays.stream(handlers)
           .flatMap(row -> Arrays.stream(row))
           .toArray(MotorHandler[] ::  new);
    }
    
    @Override
    public void notify(DetectionThread sender, HandlerPriority handlerPriority, MotorHandler[]...handler) {
        
        //TODO Refractor
        if ((isGoal)) {
            return;
        }
        if ((isBall && sender instanceof BallDetection)) {
            return;
        }
        
        tasks.updateTask(sender, handlerPriority, flatten(handler));
    }
    
    public void run() {
        if (!MOTOR_RUNNING) {
            return;
        }
        tasks.execute();
    }
}

