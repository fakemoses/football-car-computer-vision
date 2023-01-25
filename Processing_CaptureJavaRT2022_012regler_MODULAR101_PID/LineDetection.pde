// Example implementation of a thread

public class LineDetection implements ThreadInterface, Runnable{
    
    //Basic
    private Thread myThread = null;
    private boolean STARTED = false;
    private int evalValue;
    private ArrayList<Point> points = new ArrayList<Point>();
    private MotorControl motorControl;
    PImage bimg = new PImage(320,240);
    
    // private long startTime = Systems.currentTimeMillis();
    // int frames = 0;
    
    // ! Object should be declared here ?!
    // no modularity innit ?
    RANSAC ransac = new RANSAC(500,0.2,320,240);
    Boundary boundary = new Boundary(320,240);
    
    public LineDetection(MotorControl motorControl) {
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
                motorControl.notify(this, 0);
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
