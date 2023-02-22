public class MotorControl implements Mediator {
    private Antrieb antrieb;
    private boolean MOTOR_RUNNING = false;
    private ArrayList<Task> tasks;
    
    class Task implements Comparable<Task>{
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
    }
    
    class ReverseHandler implements MotorHandler {
        @Override
        public void execute() {
            antrieb.fahrt( -1, -1);
        }
    }
    
    class ForwardHandler implements MotorHandler {
        @Override
        public void execute() {
            antrieb.fahrt(1, 1);
        }
    }
    class ForwardHandler2 implements MotorHandler {
        float direction;
        float motor_factor;
        float m_f;
        ForwardHandler2(float d) {
            this.direction = d;
            println("MotorControl: direction: " + direction); 
        }
        @Override
        public void execute() {
            this.motor_factor = m_f;
            if (direction >  0) {
                println("MotorControl: Turning right");
                //antrieb.fahrt(0.6,0.2); 
                antrieb.fahrt((1-m_f)*0.7,m_f*0.7);
            } else if (direction < 0) {
                println("MotorControl: Turning left");
                //antrieb.fahrt(0.2,0.6);
                antrieb.fahrt((-1)*m_f*0.7,(1-(m_f))*0.7);
            } else
            { 
                println("MotorControl: Going straight");
                antrieb.fahrt(1,1);
            }
        }
    }
    
    public MotorControl(Antrieb antrieb) {
        this.antrieb = antrieb;
        tasks = new ArrayList<Task>();
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
            // ignore if the loopCount is not 0 (already in execution)
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
    private void updateTasks(ThreadInterface instance, int loopCount, float direction) {
        for (Task task : tasks) {
            // ignore if the loopCount is not 0 (already in execution)
            if (task.instance == instance && task.loopCount == 0) {
                task.loopCount = loopCount;
            }
        }
    }
    
    @Override
    public void notify(ThreadInterface sender, float direction) {
        int loopCount = 50;
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
        
        else {
            println("MotorControl: Unknown sender // not registered");
        }
    }
    
    private boolean isTaskAvailable() {
        for (Task task : tasks) {
            if (task.loopCount > 0) {
                return true;
            }
        }
        return false;
    }
    
    private Task getHighestPriorityTask() {
        for (Task task : tasks) {
            if (task.loopCount > 0) {
                return task;
            }
        }
        return null;
    }
    
    public void run() {
        if (!MOTOR_RUNNING) {
            // println("MotorControl: Motor is not running");
            return;
        }
        Task task = getHighestPriorityTask();
        if (task == null) {
            println("MotorControl: No task available");
            return;
        }
        println("MotorControl: Executing task: " + task.instance.getThreadName());
        task.handler.execute();
        --task.loopCount;
        if (task.loopCount == 0) {
            // println("MotorControl: Task " + task.instance.getThreadName() + " is finished");
            // task = null;
        }
    }
    
}
