
// TODO variable names
public class RansacDetectorRect implements Detector<Rectangle> {     
    private double best_inliers;
    private double confidence;
    
    // TODO debug - temp
    boolean isEvalSize = true;
    
    private int numIterations;;
    private int minPoints;
    
    public RansacDetectorRect(int numIterations, int minPoints) {
        this.numIterations = numIterations;
        this.minPoints = minPoints;
    }
    
    public ArrayList<Rectangle> detect(PImage image, PImage mask) { 
        ArrayList<Point> points = maskToPoints(mask);
        ArrayList<Rectangle> bester = new ArrayList<Rectangle>();
        Rectangle bestrects = null;
        
        if (points.size() <= minPoints) {
            return null;
        }  
        
        best_inliers = 0;
        for (int i = 0; i < numIterations; i++) {
            
            Point2D p1 = points.get((int)(Math.random() * points.size()));
            Point2D p2 = points.get((int)(Math.random() * points.size()));
            Rectangle tryRect = generateRectangleFromTwoPoints(p1, p2);
            
            PointArray<Point2D> inliers = new PointArray<Point2D>();
            for (Point2D p : points) {
                if (tryRect.contains(p)) {
                    inliers.add(p);
                }
            }
            
            double ratio = fillRatio(tryRect, inliers);
            if (ratio > best_inliers) {
                best_inliers = ratio;
                bestrects = tryRect;
                bester.add(tryRect);
            }
            
            if (bestrects == null || !isEvalSize) {
                continue;
            }
            
            if (ratio >= best_inliers && tryRect.width * tryRect.height > bestrects.width * bestrects.height) {
                best_inliers = ratio;
                bestrects = tryRect;
                bester.add(tryRect);
            }
            
        }
        confidence = (double)best_inliers / points.size();
        
        Collections.reverse(bester);
        return bester.size() > 0 ? bester : null;
    }
    
    private ArrayList<Point> maskToPoints(PImage mask) {
        PointArray<Point> points = new PointArray<Point>(mask.width, mask.height);
        for (int x = 0; x < mask.width; x++) {
            for (int y = 0; y < mask.height; y++) {
                if (mask.get(x, y) == 0xFFFFFFFF) {
                    points.add(new Point(x, y));
                }
            }
        }       
        return points;
    }
    
    private Rectangle generateRectangleFromTwoPoints(Point2D p1, Point2D p2) {
        double x = p1.getX();
        double y = p1.getY();
        double w = p2.getX() - p1.getX();
        double h = p2.getY() - p1.getY();
        
        return new Rectangle((int)x,(int)y,(int)w,(int)h);
    }
    
    private double fillRatio(Rectangle rect, PointArray<Point2D> points) {
        int count = points.size();
        int total = rect.width * rect.height;
        
        return(double)count / total;
    }
}
