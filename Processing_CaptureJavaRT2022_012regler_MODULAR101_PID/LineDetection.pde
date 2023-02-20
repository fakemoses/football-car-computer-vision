// Example implementation of a thread

public class LineDetection implements ThreadInterface, Runnable{
    
    //Basic
    private Thread myThread = null;
    private boolean STARTED = false;
    private int evalValue;
    private ArrayList<Point> points = new ArrayList<Point>();
    private Line ransacLine;
    PImage bimg = new PImage(320,240);
    
    Ransac ransac;
    Boundary boundary;
    private MotorControl motorControl;
    
    public LineDetection(MotorControl motorControl, Ransac ransac, Boundary boundary) {
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
                ransacLine = null;
                continue;
            }
            ransac.run(points);
            ransacLine = ransac.getBestLine();
            if (ransacLine != null) {
                bimg = boundary.updateImage(ransacLine);
                
            }
            if (boundary.isHelpNeeded()) {
                motorControl.notify(this, motorControl.Reverse(),3);
            }
            delay(100);
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
    
    public Line getRansacLine() {
        return ransacLine != null ? ransacLine : null;
    }
}
