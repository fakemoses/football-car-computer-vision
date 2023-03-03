class TaskArray<E extends TaskProperties> extends ArrayList<E> {
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
    
    public void updateTask(ThreadInterface sender, MotorHandler handler, int loopCount) {
        for (E task : this) {
            if (task.getInstance() == sender) {
                task.setLoopCount(loopCount);
                task.setHandler(handler);
                return;
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
    
    /*
    * Loop all tasks
    * indicating that atleast one task has been executed
    */
    private void loopAll() {
        for (E task : this) {
            task.loop();
        }
    }
}