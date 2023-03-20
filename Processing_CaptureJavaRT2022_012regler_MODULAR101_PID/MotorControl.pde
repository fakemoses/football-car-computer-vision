public class MotorControl implements Mediator {
    private Antrieb antrieb;
    private boolean MOTOR_RUNNING = false;
    private TaskArray<Task> tasks;
    private boolean isBall = false;
    
    public MotorControl(Antrieb antrieb) {
        this.antrieb = antrieb;
        tasks = new TaskArray();
    }
    
    // todo: seperate the motor control from the motor handler
    class ReverseHandler implements MotorHandler {
        @Override
        public void execute() {
            antrieb.fahrt( -0.8, -0.8);
        }
        
        public String getHandlerName() {
            return "ReverseHandler";
        }
    }
    
    public ReverseHandler Reverse() {
        return new ReverseHandler();
    }
    
    // waiting Aaron
    class ForwardHandler implements MotorHandler {
        float direction;
        float links;
        float rechts;
        float mult = 0.15;
        ForwardHandler(float d) {
            this.direction = d;
        }
        @Override
        public void execute() {
            // rechts = 0.2f * direction + 0.8f;
            // links = -0.2f * direction + 0.8f;
            if (direction > 0.2) {
                rechts = 0.8f;
                links = 0.5f;
            } else if (direction < -0.2) {
                rechts = 0.5f;
                links = 0.8f;
            } else {
                rechts = 0.8f;
                links = 0.8f;
            }
            
            println("direction: " + direction + "  links: " + links + " rechts: " + rechts);
            antrieb.fahrt(links, rechts);
        }
        
        public String getHandlerName() {
            return "ForwardHandler";
        }
    }
    
    public ForwardHandler Forward(float d) {
        return new ForwardHandler(d);
    }
    
    class TurnHandler implements MotorHandler {
        @Override
        public void execute() {
            antrieb.fahrt(0, 0.8);
        }
        
        public String getHandlerName() {
            return "TurnHandler";
        }
    }
    
    public TurnHandler Turn() {
        return new TurnHandler();
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
        if (isBall && sender instanceof BallDetection) {
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
