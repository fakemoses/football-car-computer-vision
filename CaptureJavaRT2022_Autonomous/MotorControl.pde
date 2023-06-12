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
        // if ((isBall)) {
        //     return;
        // }
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
        try {
            handlersQueue.clear();
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

/**
* TaskArray.java
*/
class TaskArray<E extends ITask> extends ArrayList<E> {
    public E getHighestPriorityTask() {
        for (E task : this) {
            if (task.getHandlerSize() > 0) {
                return task;
            }
        }
        return null;
    }
    
    /**
    * Returns true if there is a task available
    */
    public boolean isTaskAvailable() {
        for (E task : this) {
            if (task.getHandlerSize() > 0) {
                return true;
            }
        }
        return false;
    }
    
    /**
    * Returns true if there is a task available
    * with the specified handler
    
    @param sender The handler to check
    */
    public void updateTask(DetectionThread sender, HandlerPriority newHandlerPriority, MotorHandler...handlers) {
        for (E task : this) {
            if (task.getInstance() == sender) {
                
                if (task.isQueueEmpty()) {
                    task.setHandler(handlers);
                    task.setHandlerPriority(newHandlerPriority);
                    return;
                }
                
                // override condition is:
                // if current handler priority is lower or same as new handler priority
                // e.g. turnhandler has priority 1, and movehandler has priority 2
                // if movehandler requests update, it will override turnhandler
                // if turnhandler requests update, it will not override movehandler
                HandlerPriority currHandlerPriority = task.getHandlerPriority();
                if (currHandlerPriority.isLowerOrSamePriorityAs(newHandlerPriority)) {
                    task.setHandler(handlers);
                    task.setHandlerPriority(newHandlerPriority);
                }
                return;
                
                // should be unreachable
                //throw new RuntimeException("Cannot update task. Check implementation");
                
            }
        }
        println("Error updating task");
    }
    
    public void execute() {
        E task = getHighestPriorityTask();
        if (task == null) {
            println("No task available");
            return;
        }
        task.execute();
        loopAll();
    }
    
    private void loopAll() {
        for (E task : this) {
            task.loop();
        }
    }
}

public enum HandlerPriority {
    PRIORITY_HIGH,
    PRIORITY_MEDIUM,
    PRIORITY_LOW,
    
    
    PRIORITY_LOWEST; // temporary priority for random handlers <- should be avoided to override
    
    public boolean isHigherPriorityThan(HandlerPriority otherPriority) {
        return compareTo(otherPriority) < 0;
    }
    
    public boolean isLowerPriorityThan(HandlerPriority otherPriority) {
        return compareTo(otherPriority) > 0;
    }
    
    public boolean isSamePriorityAs(HandlerPriority otherPriority) {
        return compareTo(otherPriority) == 0;
    }
    
    public boolean isNotSamePriorityAs(HandlerPriority otherPriority) {
        return !isSamePriorityAs(otherPriority);
    }
    
    public boolean isHigherOrSamePriorityAs(HandlerPriority otherPriority) {
        return isSamePriorityAs(otherPriority) || isHigherPriorityThan(otherPriority);
    }
    
    public boolean isLowerOrSamePriorityAs(HandlerPriority otherPriority) {
        if (this == PRIORITY_LOWEST && otherPriority == PRIORITY_LOWEST) { // temporary priority for random handlers. avoid overriding
            return false;
        }
        return isSamePriorityAs(otherPriority) || isLowerPriorityThan(otherPriority);
    }
}

abstract class MotorHandler{
    private Antrieb antrieb;
    
    public MotorHandler(Antrieb antrieb) {
        this.antrieb = antrieb;
    }
    
    public abstract void execute();
    public abstract String getHandlerName();
}

class ReverseHandler extends MotorHandler {
    
    public ReverseHandler(Antrieb antrieb) {
        super(antrieb);
    }
    
    @Override
    public void execute() {
        antrieb.fahrt( -VORTRIEB, -VORTRIEB);
    }
    
    public String getHandlerName() {
        return "ReverseHandler";
    }
}

class StopHandler extends MotorHandler {
    
    public StopHandler(Antrieb antrieb) {
        super(antrieb);
    }
    
    @Override
    public void execute() {
        antrieb.fahrt(0, 0);
    }
    
    public String getHandlerName() {
        return "StopHandler";
    }
}

class ForwardHandler extends MotorHandler {
    
    float direction;
    float links;
    float rechts;
    float mult = 0.2f;
    float motorPower;
    
    ForwardHandler(Antrieb antrieb, float d, float motorPower) {
        super(antrieb);
        this.direction = d;
        this.motorPower = motorPower;
    }
    
    @Override
    public void execute() {
        if (direction > 0.2) {
            rechts = motorPower * (VORTRIEB + (mult * direction));
            links = motorPower * (VORTRIEB - (mult * direction));
        } else if (direction < - 0.2) {
            rechts = motorPower * (VORTRIEB - (mult * abs(direction)));
            links = motorPower * (VORTRIEB + (mult * abs(direction)));
        } else {
            rechts = VORTRIEB * 0.95f;
            links = VORTRIEB * 0.95f;
        }
        
        if (TAUSCHE_ANTRIEB_LINKS_RECHTS)
            println("direction: " + direction + "  links: " + rechts + " rechts: " + links + " Motor Power: " + motorPower);
        else
            println("direction: " + direction + "  links: " + links + " rechts: " + rechts + " Motor Power: " + motorPower);
        rechts *= (2.0 - ASYMMETRIE);
        links *= ASYMMETRIE;
        
        antrieb.fahrt(links, rechts);
    }
    
    public String getHandlerName() {
        return "ForwardHandler";
    }
}


class TurnHandler extends MotorHandler {
    
    boolean executed = false;
    
    TurnHandler(Antrieb antrieb) {
        super(antrieb);
    }
    
    @Override
    public void execute() {
        if (!executed) {
            antrieb.fahrt(0, VORTRIEB);
            executed = true;
        }  
        antrieb.fahrt(0, VORTRIEB * 0.92f);
    }
    
    public String getHandlerName() {
        return "TurnHandler";
    }
}

class StopForGoalHandler extends MotorHandler {
    
    StopForGoalHandler(Antrieb antrieb) {
        super(antrieb);
    }
    
    @Override
    public void execute() {
        antrieb.fahrt(0, 0);
    }
    
    public String getHandlerName() {
        return "StopForGoalHandler";
    }
}

