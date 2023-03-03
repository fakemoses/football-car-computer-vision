// Example implementation of a thread

public class LineDetection implements ThreadInterface, Runnable{
    
    //Basic
    private Thread myThread = null;
    private boolean STARTED = false;
    private ArrayList<Point> points;
    private Line ransacLine;
    private int minPointsSize = 500;
    PImage bimg = new PImage(camWidth,camHeight);
    
    private Ransac ransac;
    private Boundary boundary;
    private MotorControl motorControl;
    private Bildverarbeitung bildverarbeitung;
    
    public LineDetection(MotorControl motorControl, Bildverarbeitung bildverarbeitung,Ransac ransac, Boundary boundary) {
        this.motorControl = motorControl;
        this.bildverarbeitung = bildverarbeitung;
        this.ransac = ransac;
        this.boundary = boundary;
        this.points = new ArrayList<Point>();
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
        return "LineDetection";
    }
    
    public void run() {
        while(STARTED) {
            points = (ArrayList<Point>)bildverarbeitung.getRedList().clone();
            // println("LineDetection: " + points.size());
            if (points.size() < minPointsSize) {
                ransacLine = null;
            } else {
                ransac.run(points);
                ransacLine = ransac.getBestLine();
            }
            bimg = boundary.updateImage(ransacLine);
            if (boundary.isHelpNeeded()) {
                motorControl.notify(this, motorControl.Reverse(), 7);
            }
            delay(50);
        }
    }
    
    public Line getRansacLine() {
        return ransacLine != null ? ransacLine : null;
    }
    
    public void setMinPointsSize(int minPointsSize) {
        this.minPointsSize = minPointsSize;
    }
}
