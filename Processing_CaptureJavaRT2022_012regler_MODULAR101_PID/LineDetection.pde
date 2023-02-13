// Example implementation of a thread

public class LineDetection implements ThreadInterface, Runnable{
    
    //Basic
    private Thread myThread = null;
    private boolean STARTED = false;
    private int evalValue;
    private ArrayList<Point> points = new ArrayList<Point>();
    PImage bimg = new PImage(320,240);
    
    RANSAC ransac;
    Boundary boundary;
    private MotorControl motorControl;
    
    public LineDetection(MotorControl motorControl, RANSAC ransac, Boundary boundary) {
        this.motorControl = motorControl;
        this.ransac = ransac;
        this.boundary = boundary;
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
        
        // todo maybe set back to initial value ?
    }
    
    public String getThreadName() {
        return "LineDetection";
    }
    
    public void run() {
        while(STARTED) {
            if (points.size() < 400) {
                delay(50);
                continue;
            }
            ransac.run(points);
            Line l = ransac.getBestLine();
            if (l != null) {
                bimg = boundary.updateImage(l);
            }
            if (boundary.isHelpNeeded()) {
                // motorControl.notify(this, 0);
            }
        }
    }
    
    public void setPoints(ArrayList<Point> points) {
        this.points = points;
    }
    
    // getters for evaluation for EVAL()
    public int getEvalValue() { return evalValue;}
    
    public Point[] getIntersectionPoints() {
        Line l = ransac.getBestLine();
        if (l == null) return new Point[] {new Point(0,0), new Point(100,0)};
        return  l.intersectionAtImageBorder();
    }
    
}
