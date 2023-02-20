public class MotorControl implements Mediator {
    private Antrieb antrieb;
    private boolean MOTOR_RUNNING = false;
    private TaskArray<Task> tasks;
    
    
    
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
    
    
    
    public MotorControl(Antrieb antrieb) {
        this.antrieb = antrieb;
        tasks = new TaskArray();
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

class TaskArray<T extends Loopable> extends ArrayList<T> {
    public T getHighestPriorityTask() {
        for (T task : this) {
            if (task.getLoopCount() > 0) {
                return task;
            }
        }
        return null;
    }
    
    public boolean isTaskAvailable() {
        for (T task : this) {
            // if (((Task)task).getLoopCount() > 0) {
            if (task.getLoopCount() > 0) {
                return true;
            }
        }
        return false;
    }
    
    private void loopAll() {
        for (T task : this) {
            task.loop();
        }
    }
    
    public void execute() {
        T task = getHighestPriorityTask();
        if (task == null) {
            return;
        }
        task.execute();
        loopAll();
    }
}

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

