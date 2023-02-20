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