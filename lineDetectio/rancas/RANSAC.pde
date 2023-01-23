public class RANSAC {
    
    private final int numIterations;
    private final double threshold;
    
    private int best_inliers;
    private double confidence;
    
    private final int imgWidth;
    private final int imgHeight;
    
    private Line best_line;
    
    public RANSAC(int numIterations, double threshold, PImage image) {
        this.numIterations = numIterations;
        this.threshold = threshold;
        this.imgWidth = image.width;
        this.imgHeight = image.height;
    }
    public RANSAC(int numIterations, double threshold, int imgWidth, int imgHeight) {
        this.numIterations = numIterations;
        this.threshold = threshold;
        this.imgWidth = imgWidth;
        this.imgHeight = imgHeight;
    }
    
    public void run(ArrayList<Point> points) {
        best_inliers = 0;
        for (int i = 0; i < numIterations; i++) {
            Point p1 = points.get((int)(Math.random() * points.size()));
            Point p2 = points.get((int)(Math.random() * points.size()));
            Line line = new Line(p1, p2);
            
            ArrayList<Point> inliers = new ArrayList<Point>();
            for (Point p : points) {
                if (distanceFromLine(line, p) < threshold) {
                    inliers.add(p);
                }
            }
            
            if (inliers.size() > best_inliers) {
                best_inliers = inliers.size();
                best_line = line;
            }
        }
        
        confidence = (double)best_inliers / points.size();
    }
    
    public double distanceFromLine(Line line, Point p) {
        double x1 = line.a.x;
        double y1 = line.a.y;
        double x2 = line.b.x;
        double y2 = line.b.y;
        double x0 = p.x;
        double y0 = p.y;
        
        return Math.abs((y2 - y1) * x0 - (x2 - x1) * y0 + x2 * y1 - y2 * x1) / Math.sqrt(Math.pow(y2 - y1, 2) + Math.pow(x2 - x1, 2));
    }
    
    public Line getBestLine() {
        best_line.process();
        return best_line;
    }
}

class Point {
    int x;
    int y;
    
    Point(int x, int y) {
        this.x = x;
        this.y = y;
    }
    
    public String toString() {
        return "(" + x + ", " + y + ")";
    }
}

class Line {
    Point a;
    Point b;
    
    Point p1;
    Point p2;
    
    Line(Point a, Point b) {
        this.a = a;
        this.b = b;
    }
    
    public double[] ymxac() {
        double[] ymxac = new double[3];
        ymxac[0] = a.y - b.y;
        ymxac[1] = b.x - a.x;
        ymxac[2] = a.x * b.y - b.x * a.y;
        return ymxac;
    }
    
    public void process() {
        double[] ymxac = ymxac();
        double x = ymxac[0];
        double y = ymxac[1];
        double c = -ymxac[2];
        double m = y / x;
        double b = c / x;
        p1 = new Point(0,(int)(c / y));
        // println("x: " + x + ", y: " + y + ", c: " + c + " m: " + m + ", b: " + b);
        if (b < 0) {
            p2 = new Point((int)((y * 240 - c) / - x),240);
            // println("b : " + b);
        }
        else{
            p2 = new Point((int)b,0);
        }
    }
    
    public String toString() {
        return "y = " + a + "x + " + b;
    }
    
    public Point getP1() {
        return p1;
    }
    
    public Point getP2() {
        return p2;
    }
    
}
