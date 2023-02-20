public class MotorControl implements Mediator {
    private Antrieb antrieb;
    private boolean MOTOR_RUNNING = false;
    private TaskArray<Task> tasks;
    
    public MotorControl(Antrieb antrieb) {
        this.antrieb = antrieb;
        tasks = new TaskArray();
    }
    
    
    class ReverseHandler implements MotorHandler {
        @Override
        public void execute() {
            antrieb.fahrt( -1, -1);
        }
    }
    
    public ReverseHandler Reverse() {
        return new ReverseHandler();
    }
    
    class ForwardHandler implements MotorHandler {
        @Override
        public void execute() {
            antrieb.fahrt(1, 1);
        }
    }
    
    public ForwardHandler Forward2() {
        return new ForwardHandler();
    }
    
    class ForwardHandler2 implements MotorHandler {
        float direction;
        ForwardHandler2(float d) {
            this.direction = d;
            println("MotorControl: direction: " + direction);
        }
        @Override
        public void execute() {
            if (direction >  0) {
                println("MotorControl: Turning right");
                antrieb.fahrt(0,1);
            } else if (direction < 0) {
                println("MotorControl: Turning left");
                antrieb.fahrt(1,0);
            } else
            { 
                println("MotorControl: Going straight");
                antrieb.fahrt(1,1);
            }
        }
    }
    
    public ForwardHandler2 Forward(float d) {
        return new ForwardHandler2(d);
    }
    
    class TurnHandler implements MotorHandler {
        @Override
        public void execute() {
            antrieb.fahrt(0, 1);
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
    
    public void register(ThreadInterface instance, int priority) {
        println("Registering: " + instance.getThreadName() + " --> priority: " + priority);
        tasks.add(new Task(instance, priority));
        if (tasks.size() > 1) {
            // just in case, if the registered task is not accordingly to priority
            sortTasks();
        }
    }
    
    private void sortTasks() {
        Collections.sort(tasks);
    }
    
    private void updateTasks(ThreadInterface instance, int loopCount, MotorHandler handler) {
        for (Task task : tasks) {
            // ignore if the loopCount is not 0(alreadyin execution)
            if (task.instance == instance && task.loopCount == 0) {
                println("MotorControl: Succesfully update Task: " + task.instance.getThreadName());
                task.loopCount = loopCount;
                task.handler = handler;
                return;
            }
        }
        println("Failed to update tasks");
    }
    
    // direction is used for turning
    private void updateTasks(ThreadInterface instance, int loopCount, double direction) {
        for (Task task : tasks) {
            // ignore if the loopCount is not 0 (already in execution)
            if (task.instance == instance && task.loopCount == 0) {
                task.loopCount = loopCount;
            }
        }
    }
    
    @Override
    public void notify(ThreadInterface sender, float direction) {
        int loopCount = 10;
        println("Received notification from " + sender.getThreadName() + " --> direction: " + direction);
        if (sender instanceof LineDetection) {
            updateTasks(sender, loopCount, new ReverseHandler());
        }
        
        if (sender instanceof BallDetection) {
            updateTasks(sender, 1, new ForwardHandler2(direction));
        }
        if (sender instanceof CarDetection) {
            updateTasks(sender, 1, new ForwardHandler2(direction));
        }
    }
    
    public void notify(ThreadInterface sender, float direction, MotorHandler handler) {
        int loopCount = 10;
        println("Received notification from " + sender.getThreadName() + " --> direction : " + direction);
        if (sender instanceof LineDetection) {
            updateTasks(sender, loopCount, handler);
        }
        
        if (sender instanceof BallDetection) {
            updateTasks(sender, 1, handler);
        }
        if (sender instanceof CarDetection) {
            updateTasks(sender, 1, new ForwardHandler2(direction));
        }
    }
    
    
    public void run() {
        if (!MOTOR_RUNNING) {
            // println("MotorControl : Motor is not running");
            return;
        }
        tasks.execute();
    }
    
}

