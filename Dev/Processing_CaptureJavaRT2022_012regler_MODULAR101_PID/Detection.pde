
abstract class DetectionThread implements IDetectionThread, Runnable {
    protected Thread myThread = null;
    protected boolean STARTED = false;
    
    protected MotorControl motorControl;
    protected DataContainer data;
    
    protected ImageUtils imageUtils;
    
    PImage image;
    PImage mask;   
    
    /**
    * Constructor
    * @param motorControl The MotorControl object
    * @param data The DataContainer object
    */
    public DetectionThread(MotorControl motorControl, DataContainer data) {
        this.motorControl = motorControl;
        this.data = data;
        
        this.imageUtils = new ImageUtils();
    }
    
    public void startThread() {
        if (myThread == null) {
            myThread = new Thread(this);
            myThread.start();
        }   
        STARTED = true;
    }
    
    public void stopThread() {
        STARTED = false;
    }
    
    public void setImage(PImage image) {
        this.image = image.copy();
    }
    
    public abstract String getThreadName();
    
    public abstract void run();
    
    public abstract PImage[] getResults();
}