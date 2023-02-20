public interface ThreadInterface {
    public abstract void startThread();
    public abstract void stopThread();
    public abstract String getThreadName();
}

interface Mediator {
    void notify(ThreadInterface sender, float direction);
}

interface MotorHandler{
    void execute();
}

interface Loopable{
    int loopCount = 0;
    void setLoopCount(int count);
    int getLoopCount();
    void loop();
    void execute();
}