// Example implementation of a thread

public class LineDetection implements Interface, Runnable{
    
    //Basic
    private Thread myThread = null;
    private boolean STARTED = false;
    private int evalValue;
    private ArrayList<Point> points = new ArrayList<Point>();
    RANSAC ransac = new RANSAC(500,0.2,320,240);
    
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
            // println("Thread running");
            // do something
            // all codes run here
            ransac.run(points);
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
        // return  new Point[] {new Point(0,0), new Point(100,0)};
    }
    
}
