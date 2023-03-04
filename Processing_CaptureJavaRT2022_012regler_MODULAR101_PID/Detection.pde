abstract class DetectionThread implements IDetectionThread, Runnable {
    protected Thread myThread = null;
    protected boolean STARTED = false;
    
    protected MotorControl motorControl;
    protected ColorFilter colorFilter;
    
    PImage image;
    PImage mask;   
    
    // public DetectionThread(MotorControl motorControl, ColorFilter colorFilter) {
    public DetectionThread(MotorControl motorControl, ColorFilter colorFilter) {
        this.motorControl = motorControl;
        this.colorFilter = colorFilter;
        // this.objectDetector = objectDetector;
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
    
    protected PImage drawRect(PImage image, Rectangle rect, int thickness, color c, boolean fill) { 
        PointArray<Point> points = new PointArray<Point>();
        
        if (thickness > 0) {
            for (int i = rect.x; i <= rect.x + rect.width; i++) {
                for (int j = ceil(rect.y - (thickness / 2)); j <= floor(rect.y + (thickness / 2)); j++) {
                    points.add(new Point(i, j));
                    points.add(new Point(i, j + rect.height));
                }
            }
            
            for (int i = rect.y; i <= rect.y + rect.height; i++) {
                for (int j = ceil(rect.x - (thickness / 2)); j <= floor(rect.x + (thickness / 2)); j++) {
                    points.add(new Point(j, i));
                    points.add(new Point(j + rect.width, i));
                }
            } 
        }
        
        if (fill) {
            for (int i = rect.x; i <= rect.x + rect.width; i++) {
                for (int j = rect.y; j <= rect.y + rect.height; j++) {
                    points.add(new Point(i, j));
                }
            }
        }
        
        return drawPoint(image, points, c);
    }
    
    protected PImage drawLine(PImage image, Line line, int thickness, color c) { 
        PointArray<Point> points = line.getPoints(thickness);
        
        return drawPoint(image, points, c);
    }
    
    protected PImage drawPoint(PImage image, PointArray<Point> points ,color c) { 
        PImage returnImage = image.copy();
        int[] pixels = returnImage.pixels;        
        // println("Drawing " + points.size() + " points");
        for (Point p : points) {
            // println("Drawing point " + p.x + ", " + p.y);
            pixels[p.x + p.y * returnImage.width] = c;
        }
        return returnImage;
    }
    
    public void setImage(PImage image) {
        this.image = image.copy();
    }
    
    public abstract String getThreadName();
    
    public abstract void run();
    
    public abstract PImage[] getResults();
}