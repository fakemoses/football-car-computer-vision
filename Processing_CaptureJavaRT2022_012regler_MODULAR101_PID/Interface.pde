public interface ThreadInterface {
    public abstract void startThread();
    public abstract void stopThread();
    public abstract String getThreadName();
}

interface Mediator {
    public abstract void notify(ThreadInterface sender, MotorHandler handler, int loopCount);
    public abstract void notify(ThreadInterface sender, MotorHandler handler);
}

interface MotorHandler{
    public abstract void execute();
    public abstract String getHandlerName();
}

interface TaskProperties{
    public abstract void setLoopCount(int count);
    public abstract int getLoopCount();
    
    public abstract ThreadInterface getInstance();
    public abstract MotorHandler getHandler();
    public abstract void setHandler(MotorHandler handler);
    
    public abstract void loop();
    public abstract void execute();
}

interface ObjectDetector{
    public abstract Rectangle detect(PImage image, PImage mask);
    public abstract Rectangle detect(PImage image);
    // public abstract PImage getMask();
}