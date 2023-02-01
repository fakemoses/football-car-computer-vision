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
        best_line.process2();
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
    double m;
    double c;
    
    Point p1;
    Point p2;
    
    Point start;
    Point end;
    
    Line() {
        this.a = new Point( -1, -1);
        this.b = new Point( -1, -1);
    }
    
    Line(Point a, Point b) {
        this.a = a;
        this.b = b;
        if (a.x == b.x) {
            this.m = 123;
            this.c = a.x;
            return;
        }
        this.m = (double)(b.y - a.y) / (b.x - a.x);
        this.c = a.y - m * a.x; 
    }
    
    public boolean isDefined() {
        return a.x != -1 && a.y != -1 && b.x != -1 && b.y != -1;
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
        
        // if line is horizontal
        if (x == 0) {
            p1 = new Point(0,(int)(c / y));
            p2 = new Point(320,(int)(c / y));
            return;
        }
        double m = y / x;
        double b = c / x;
        p1 = new Point(0,(int)(c / y));
        println("x: " + x + ", y: " + y + ", c: " + c + " m: " + m + ", b: " + b);
        if (b < 0) {
            double xInterceptOnMaxH = (y * 240 - c) / - x;
            p2 = new Point((int)xInterceptOnMaxH,240);
            if (xInterceptOnMaxH > 320) {
                // interception occurs on the right side of the image
                double yInterceptOnMaxW = (x * 320 - c) / - y;
                p2 = new Point(320,(int)yInterceptOnMaxW);
            }
        }
        else{
            p2 = new Point((int)b,0);
        }
        
        if (p2.x > 1000) {
            println("NANI??");
            println("x: " + x + ", y: " + y + ", c: " + c + " m: " + m + ", b: " + b);
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
    
    public void process2() {
        // start is start point
        // end is end point
        
        // start ideally would start on left image boundary
        // if not it will located at top image boundary
        // if not it will located at bottom image boundary
        // start will NEVER be located at right image boundary
        
        // end ideally would end on right image boundary
        // if not it will located at bottom image boundary 
        // if not it will located at top image boundary
        // end will NEVER be located at left image boundary
        
        // calculation use values from p1 and p2
        // ?! ?!
        // println("A: " + a + ", B: " + b);
        if (a.x == b.x) {
            // vertical line
            p1 = new Point(a.x,0);
            p2 = new Point(a.x,240);
            return;
        }
        // p1 = new Point(0,0);
        // p2 = new Point(320,240);
        Point i1 = intersectionPoint(new Line(new Point(0,0), new Point(0,240)), this);
        if (i1.y >= 0 && i1.y <= 240 - 1) {
            p1 = i1;
        }
        else {
            if (i1.y < 0) {
                i1 = intersectionPoint(new Line(new Point(0,0), new Point(320,0)), this);
                p1 = i1;
            }
            else {
                i1 = intersectionPoint(new Line(new Point(0,240), new Point(320,240)), this);
                p1 = i1;
            }
        }
        
        Point i2 = intersectionPoint(new Line(new Point(320,0), new Point(320,240)), this);
        if (i2.y >= 0 && i2.y <= 240 - 1) {
            p2 = i2;
        }
        else {
            if (i2.y < 0) {
                i2 = intersectionPoint(new Line(new Point(0,0), new Point(320,0)), this);
                p2 = i2;
            }
            else {
                i2 = intersectionPoint(new Line(new Point(0,240), new Point(320,240)), this);
                p2 = i2;
            }
        }        
    }
    
    
}

// Line l1 = new Line(new Point(0,0), new Point(0,240)); // y intercept
// Line l2 = new Line(new Point(0,240), new Point(320,240));   // x intercept -maxH
// Line l3 = new Line(new Point(320,0), new Point(320,240));   // y intercept -maxW
// Line l4 = new Line(new Point(0,0), new Point(320,0));   // x intercept

// Point p1 = intersectionPoint(l1, new Line(a,b));
// Point p2 = intersectionPoint(l2, new Line(a,b));

public Point intersectionPoint(Line l1, Line l2) {
    // println("l1: " + l1);
    // println("l2: " + l2);
    double x1 = l1.a.x;
    double y1 = l1.a.y;
    double x2 = l1.b.x;
    double y2 = l1.b.y;
    double x3 = l2.a.x;
    double y3 = l2.a.y;
    double x4 = l2.b.x;
    double y4 = l2.b.y;
    
    double x = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));
    double y = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));
    
    return new Point((int)x,(int)y);
}   
