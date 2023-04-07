public interface IDetectionThread {
    public abstract void startThread();
    public abstract void stopThread();
    public abstract String getThreadName();
    public abstract void setImage(PImage image);
    public abstract PImage[] getResults();
}

interface Mediator {
    public abstract void notify(DetectionThread sender, MotorHandler handler, int loopCount);
    public abstract void notify(DetectionThread sender, MotorHandler handler);
}

interface ITask{
    public abstract void setLoopCount(int count);
    public abstract int getLoopCount();
    
    public abstract DetectionThread getInstance();
    public abstract MotorHandler getHandler();
    public abstract void setHandler(MotorHandler handler);
    
    public abstract void loop();
    public abstract void execute();
}

interface ColorFilter {
    public abstract PImage filter(PImage image);
}

interface Detector<T extends Shape>{
    public abstract ArrayList<T> detect(PImage image, PImage mask);
}

interface PostFilter {
    public abstract PImage process(PImage image);
}