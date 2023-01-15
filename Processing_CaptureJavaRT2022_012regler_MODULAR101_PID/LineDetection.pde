// Example implementation of a thread

public class LineDetection implements Interface, Runnable{
    
    //Basic
    private Thread myThread = null;
    private boolean STARTED = false;
    private int evalValue;
    
    public void startThread() {
        if (myThread == null) {
            myThread = new Thread(this);
            myThread.start();
        }
        
        STARTED = true;
    }
    
    public void stopThread() {
        STARTED = false;
        
        // todo maybe set back to initial value ?
    }
    
    public void run() {
        while(STARTED) {
            // do something
            // all codes run here
        }
    }
    
    // getters for evaluation for EVAL()
    public int getEvalValue() { return evalValue;}
    
}
