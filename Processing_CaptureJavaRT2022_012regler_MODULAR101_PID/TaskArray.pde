class TaskArray<T extends TaskProperties> extends ArrayList<T> {
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
            if (task.getLoopCount() > 0) {
                return true;
            }
        }
        return false;
    }
    
    public void updateTask(ThreadInterface sender, MotorHandler handler, int loopCount) {
        for (T task : this) {
            if (task.getInstance() == sender) {
                task.setLoopCount(loopCount);
                task.setHandler(handler);
                return;
            }
        }
        println("Error updating task");
    }
    
    public void execute() {
        T task = getHighestPriorityTask();
        if (task == null) {
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
        for (T task : this) {
            task.loop();
        }
    }
}