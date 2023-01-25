// Example implementation of a thread

public class BallDetection implements ThreadInterface, Runnable{
    
    //Basic
    private Thread myThread = null;
    private boolean STARTED = false;
    private MotorControl motorControl;
    
    
    public BallDetection(MotorControl motorControl) {
        this.motorControl = motorControl;
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
    
    public String getThreadName() {
        return "BallDetection";
    }
    
    public void run() {
        while(STARTED) {
            // implementation here
            /*
            *
            *
            *
            *
            */
            delay(500);
            // independently notify the motorControl thread
            motorControl.notify(this,0);
        }
    }
}
