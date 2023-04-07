public interface IDetectionThread {
    public abstract void startThread();
    public abstract void stopThread();
    public abstract String getThreadName();
    public abstract void setImage(PImage image);
    public abstract PImage[] getResults();
}

interface Mediator {
    public abstract void notify(DetectionThread sender, HandlerPriority handlerPriority, MotorHandler[]...handler);
}

interface ITask{  
    public abstract DetectionThread getInstance();
    
    public abstract MotorHandler[] getHandler();
    public abstract MotorHandler getFrontHandler();
    public abstract void setHandler(MotorHandler...handlers);
    public abstract int getHandlerSize();
    public abstract boolean isQueueEmpty();
    
    public abstract HandlerPriority getHandlerPriority();
    public abstract void setHandlerPriority(HandlerPriority handlerPriority);
    
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