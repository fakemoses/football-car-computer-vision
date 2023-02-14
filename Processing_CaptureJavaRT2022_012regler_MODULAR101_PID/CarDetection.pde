public class CarDetection implements ThreadInterface, Runnable {
    private Thread myThread = null;
    private boolean STARTED = false;
    private MotorControl motorControl;
    Bildverarbeitung bv;
    
    private PWindow window;

    public CarDetection(MotorControl motorControl, PWindow window, Bildverarbeitung bv) {
        this.motorControl = motorControl;
        this.window = window;
        this.bv = bv;
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
        return "CarDetection";
    }

    public void run() {
        // currently only known rectangle
        Rectangle[] rect = window.detectObject();
        int direction = 0;
        if (rect != null) {
            // since no color, how to move to object?
            // assuming that the cascade returns one rectangle

            // calculate coord center of rectangle
            int x = rect[0].x + rect[0].width / 2;

            if(x > width/2 - 10 && x < width/2 + 10){
                direction = 0;
            }
            else if(x < width/2 - 10){
                direction = -1;
            }
            else if(x > width/2 + 10){
                direction = 1;
            }
        }

        delay(500);
        // motorControl.notify(this,direction);
        
    }
}