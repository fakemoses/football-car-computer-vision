public class MotorControl implements Mediator {
    private Antrieb antrieb;
    private boolean MOTOR_RUNNING = false;
    private TaskArray<Task> tasks;
    
    public MotorControl(Antrieb antrieb) {
        this.antrieb = antrieb;
        tasks = new TaskArray();
    }
    
    // todo: seperate the motor control from the motor handler
    class ReverseHandler implements MotorHandler {
        @Override
        public void execute() {
            antrieb.fahrt( -1, -1);
        }
    }
    
    public ReverseHandler Reverse() {
        return new ReverseHandler();
    }
    
    // waiting Aaron
    class ForwardHandler implements MotorHandler {
        float direction;
        ForwardHandler(float d) {
            this.direction = d;
            println("MotorControl: direction: " + direction);
        }
        @Override
        public void execute() {
            if (direction >  0) {
                println("MotorControl: Turning right");
                antrieb.fahrt(0.6,0.2); 
            } else if (direction < 0) {
                println("MotorControl: Turning left");
                antrieb.fahrt(0.2,0.6);
            } else { 
                println("MotorControl: Going straight");
                antrieb.fahrt(1,1);
            }
        }
    }
    
    public ForwardHandler Forward(float d) {
        return new ForwardHandler(d);
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
    
    @Override
    public void notify(ThreadInterface sender, MotorHandler handler, int loopCount) {
        println("Received notification from " + sender.getThreadName() + " --> direction : " + "not implements");
        tasks.updateTask(sender, handler, loopCount);
    }
    
    @Override
    public void notify(ThreadInterface sender, MotorHandler handler) {
        notify(sender, handler, 1);
    }
    
    public void run() {
        if (!MOTOR_RUNNING) {
            // println("MotorControl : Motor is not running");
            return;
        }
        println("MotorControl: Running");
        tasks.execute();
    }
}

