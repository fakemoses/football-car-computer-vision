public interface ThreadInterface {
    public abstract void startThread();
    public abstract void stopThread();
    public abstract String getThreadName();
}

interface Mediator {
    void notify(ThreadInterface sender, int direction);
}

interface MotorHandler{
    void execute();
}