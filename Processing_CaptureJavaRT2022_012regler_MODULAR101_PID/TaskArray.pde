class TaskArray<E extends ITask> extends ArrayList<E> {
    public E getHighestPriorityTask() {
        for (E task : this) {
            if (task.getHandlerSize() > 0) {
                return task;
            }
        }
        return null;
    }
    
    public boolean isTaskAvailable() {
        for (E task : this) {
            if (task.getHandlerSize() > 0) {
                return true;
            }
        }
        return false;
    }
    
    public void updateTask(DetectionThread sender, HandlerPriority newHandlerPriority, MotorHandler...handlers) {
        for (E task : this) {
            if (task.getInstance() == sender) {
                
                if (task.isQueueEmpty()) {
                    // task.setLoopCount(loopCount);
                    task.setHandler(handlers);
                    task.setHandlerPriority(newHandlerPriority);
                    return;
                }
                
                // override condition
                // if current handler priority is lower or same as new handler priority
                // e.g. turnhandler has priority 1, and movehandler has priority 2
                // if movehandler requests update, it will override turnhandler
                // if turnhandler requests update, it will not override movehandler
                HandlerPriority currHandlerPriority = task.getHandlerPriority();
                println("Current handler priority: " + currHandlerPriority);
                if (currHandlerPriority.isLowerOrSamePriorityAs(newHandlerPriority)) {
                    // task.setLoopCount(loopCount);
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