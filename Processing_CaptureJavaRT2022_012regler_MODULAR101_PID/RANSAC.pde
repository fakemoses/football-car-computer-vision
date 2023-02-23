public class Ransac {
    
    private final int numIterations;
    private final double threshold;
    
    private int best_inliers;
    private double confidence;
    
    private final int imgWidth;
    private final int imgHeight;
    
    private Line best_line;
    private int temp = 0;
    
    public Ransac(int numIterations, double threshold, PImage image) {
        this(numIterations, threshold, image.width, image.height);
    }
    
    public Ransac(int numIterations, double threshold, int imgWidth, int imgHeight) {
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
                if (Math.abs(line.distanceFromLine(p)) < threshold) {
                    inliers.add(p);
                }
            }
            
            if (inliers.size() > best_inliers) {
                best_inliers = inliers.size();
                best_line = line;
            }
            confidence = (double)best_inliers / points.size();
        }
    }
    
    public Line getBestLine() {
        return best_line;
    }
}

class Point {
    int x;
    int y;
    
    Point() {
        this( -1, -1);
    }
    
    Point(int x, int y) {
        this.x = x;
        this.y = y;
    }
    
    public String toString() {
        return "(" + x + ", " + y + ")";
    }
}


// todo: use phi, rho instead of m, c -> no infinite slope
class Line {
    Point a;
    Point b;
    double m;
    double c;
    
    Line() {
        this(new Point(), new Point());
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
    
    public Point[] intersectionAtImageBorder() {
        /*
        * start is start point
        * end isend point
        
        * start ideally would start on left image boundary
        * if not it will located at top image boundary
        * if not it will located at bottom image boundary
        * start will NEVER be located at right image boundary
        
        * end ideally would end on right image boundary
        * if not it willlocated at bottom image boundary
        * if not it willlocated at top image boundary
        * end will NEVERbe located at left image boundary
        */
        
        // todo : set variable size from global ?
        Point start;
        Point end;
        
        if (a.x == b.x) {
            // vertical line
            start = new Point(a.x,0);
            end = new Point(a.x,240);
            return new Point[] {start, end};
        }
        
        Point iLeft = intersectionPoint(new Line(new Point(0,0), new Point(0,240)), this);
        Point iTop = intersectionPoint(new Line(new Point(0,0), new Point(320,0)), this);
        Point iBottom = intersectionPoint(new Line(new Point(0,240), new Point(320,240)), this);
        Point iRight = intersectionPoint(new Line(new Point(320,0), new Point(320,240)), this);
        
        if (iLeft.y >= 0 && iLeft.y <= 240 - 1) {
            start = iLeft;
        } else {
            start = (iLeft.y < 0) ? iTop : iBottom;
        }
        
        if (iRight.y >= 0 && iRight.y <= 240 - 1) {
            end = iRight;
        } else {
            end = (iRight.y < 0) ? iTop : iBottom;
        }
        return new Point[] {start, end};
    }
    
    public boolean isDefined() {
        return a.x != -1 && a.y != -1 && b.x != -1 && b.y != -1;
    }
    
    public String toString() {
        return a.toString() + " -> " + b.toString();
    }
    
    private Point intersectionPoint(Line l1, Line l2) {
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
    
    public double distanceFromLine(Point p) {
        // src: https://brilliant.org/wiki/dot-product-distance-between-point-and-a-line/
        return Math.abs((b.y - a.y) * p.x - (b.x - a.x) * p.y + b.x * a.y - b.y * a.x) / Math.sqrt(Math.pow(b.y - a.y, 2) + Math.pow(b.x - a.x, 2));
    }
    
    public ArrayList<Point> getPoints(int thickness) {
        ArrayList<Point> points = new ArrayList<Point>();
        Point[] intersectionPoints = intersectionAtImageBorder();
        Point start = intersectionPoints[0];
        Point end = intersectionPoints[1];
        for (int x = start.x; x <= end.x; x++) {
            int y = (int)(m * x + c);
            for (int i = ceil(y - thickness / 2); i <= floor(y + thickness / 2); i++) {
                points.add(new Point(x,i));
            }
        }
        
        if (start.y <= end.y) {
            for (int y = start.y; y <= end.y; y++) {
                int x = (int)((y - c) / m);
                for (int i = ceil(x - thickness / 2); i <= floor(x + thickness / 2); i++) {
                    points.add(new Point(i,y));
                }
            }
        }
        else {
            for (int y = start.y; y >= end.y; y--) {
                int x = (int)((y - c) / m);
                for (int i = ceil(x - thickness / 2); i <= floor(x + thickness / 2); i++) {
                    points.add(new Point(i,y));
                }
            }
        }
        return points;
    }   
}


