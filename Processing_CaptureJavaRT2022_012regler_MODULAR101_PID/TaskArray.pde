class TaskArray<E extends ITask> extends ArrayList<E> {
    public E getHighestPriorityTask() {
        for (E task : this) {
            if (task.getLoopCount() > 0) {
                return task;
            }
        }
        return null;
    }
    
    public boolean isTaskAvailable() {
        for (E task : this) {
            if (task.getLoopCount() > 0) {
                return true;
            }
        }
        return false;
    }
    
    public void updateTask(DetectionThread sender, MotorHandler handler, int loopCount) {
        for (E task : this) {
            if (task.getInstance() == sender) {
                
                if (task.getLoopCount() == 0) {
                    task.setLoopCount(loopCount);
                    task.setHandler(handler);
                    return;
                }
                
                // override condition
                // if current handler priority is lower or same as new handler priority
                // e.g. turnhandler has priority 1, and movehandler has priority 2
                // if movehandler requests update, it will override turnhandler
                // if turnhandler requests update, it will not override movehandler
                if (task.getHandler().getPriority().isLowerOrSamePriorityAs(handler.getPriority())) {
                    task.setLoopCount(loopCount);
                    task.setHandler(handler);
                    return;
                }
                
                else 
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