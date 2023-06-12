public class RansacLineDetector implements Detector<Line> {   
    private final int numIterations;
    private final double threshold;
    
    private int best_inliers;
    private double confidence;
    private int min_point;
    
    public RansacLineDetector(int numIterations, double threshold, int min_point) {
        this.numIterations = numIterations;
        this.threshold = threshold;
        this.min_point = min_point;
    }
    
    public ArrayList<Line> detect(PImage image, PImage mask) { 
        ArrayList<Point> points = maskToPoints(mask);
        Line best_line = null;
        
        if (points.size() < min_point) {
            return null;
        }
        
        best_inliers = 0;
        for (int i = 0; i < numIterations; i++) {
            Point2D p1 = points.get((int)(Math.random() * points.size()));
            Point2D p2 = points.get((int)(Math.random() * points.size()));
            Line line = new Line(p1, p2);
            
            ArrayList<Point2D> inliers = new ArrayList<Point2D>();
            for (Point2D p : points) {
                if (line.ptLineDistSq(p) < threshold) {
                    inliers.add(p);
                }
            }
            
            if (inliers.size() > best_inliers) {
                best_inliers = inliers.size();
                best_line = line;
            }
        }
        confidence = (double)best_inliers / points.size();
        
        // must return result as array
        return new ArrayList<Line>(Arrays.asList(best_line.intersectionAtImageBorder()));
    }
    
    private ArrayList<Point> maskToPoints(PImage mask) {
        ArrayList<Point> points = new ArrayList<Point>();
        for (int x = 0; x < mask.width; x++) {
            for (int y = 0; y < mask.height; y++) {
                if (mask.get(x, y) == 0xFFFFFFFF) {
                    points.add(new Point(x, y));
                }
            }
        }        
        return points;
    }
}