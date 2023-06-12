class CascadeDetector extends PApplet implements Detector<Rectangle>{
    OpenCV opencv;
    private final String cf = "ball_detection4.xml";
    private int max_rects = 10;
    
    double scaleFactor = 1.25;
    int minNeighbors = 4;
    int flags = 0;
    int minSize = 30;
    int maxSize = 300;
    double MAX_THRESHOLD = 20;
    
    CascadeDetector(int w, int h) {
        opencv = new OpenCV(this, w, h);
        opencv.loadCascade(cf);
    }
    
    public ArrayList<Rectangle> detect(PImage image, PImage mask) {
        return detectCascade(image);
    }
    
    private ArrayList<Rectangle> detectCascade(PImage image) {
        opencv.loadImage(image);
        Rectangle[] rects = opencv.detect(scaleFactor, minNeighbors, flags, minSize, maxSize);
        ArrayList<Rectangle> rects_list = new ArrayList<Rectangle>();
        
        Arrays.sort(rects, new Comparator<Rectangle>() {
            @Override
            public int compare(Rectangle r1, Rectangle r2) {
                return(r1.width * r1.height) - (r2.width * r2.height);
            }
        });
        
        int Limit = Math.min(max_rects, rects.length);
        
        for (int i = 0; i < Limit; i++) {
            rects_list.add(rects[i]);
        }
        
        return rects_list;
    }
}

public class ContourDetector extends PApplet implements Detector<Rectangle> {
    private OpenCV opencv;
    private int max_rects = 10;
    
    ContourDetector() {
    }
    
    ContourDetector(int w, int h) {
        opencv = new OpenCV(this, w, h);
    }   
    
    public ContourDetector setMaxRects(int max_rects) {
        this.max_rects = max_rects;
        return this;
    }
    
    public ArrayList<Rectangle> detect(PImage image, PImage mask) {
        if (image.width != mask.width || image.height != mask.height) {
            throw new IllegalArgumentException("Image and mask must be the same size");
        }
        
        if (opencv == null) {
            opencv = new OpenCV(this, image.width, image.height);
        }
        
        ArrayList<Contour> contours = this.detectContours(mask);
        
        ArrayList<Rectangle> rects = new ArrayList<Rectangle>();
        
        for (Contour contour : contours) {
            Rectangle rect = contour.getBoundingBox();
            rects.add(rect);
        }
        
        return rects;
    }
    
    private ArrayList<Contour> detectContours(PImage mask) {
        opencv.loadImage(mask);
        ArrayList<Contour> contours = opencv.findContours(true, true);
        
        if (contours.size() <= max_rects) {
            return contours;
        }
        
        return new ArrayList<Contour>(contours.subList(0, max_rects));
        
        // return contours.size() > max_rects ? contours.subList(0,max_rects) : contours;
    }
}



public class RansacRectangleDetector implements Detector<Rectangle> {     
    private double best_inliers;
    private double confidence;
    
    private int numIterations;
    private int minPoints;
    
    public RansacRectangleDetector(int numIterations, int minPoints) {
        this.numIterations = numIterations;
        this.minPoints = minPoints;
    }
    
    public ArrayList<Rectangle> detect(PImage image, PImage mask) { 
        ArrayList<Point> points = maskToPoints(mask);
        
        if (points.size() <= minPoints) {
            return null;
        }  
        
        ArrayList<Rectangle> goodRectCollection = new ArrayList<Rectangle>();
        Rectangle bestRectangle = null;
        
        best_inliers = 0;
        for (int i = 0; i < numIterations; i++) {
            
            Point2D p1 = points.get((int)(Math.random() * points.size()));
            Point2D p2 = points.get((int)(Math.random() * points.size()));
            Rectangle hyphRectangle = generateRectangleFromTwoPoints(p1, p2);
            
            ArrayList<Point2D> inliers = new ArrayList<Point2D>();
            for (Point2D p : points) {
                if (hyphRectangle.contains(p)) {
                    inliers.add(p);
                }
            }
            
            double ratio = calculateDensityRatio(hyphRectangle, inliers);
            if (ratio > best_inliers) {
                best_inliers = ratio;
                bestRectangle = hyphRectangle;
                goodRectCollection.add(hyphRectangle);
            }
            
            if (bestRectangle == null) {
                continue;
            }
            
            if (ratio >= best_inliers && hyphRectangle.width * hyphRectangle.height > bestRectangle.width * bestRectangle.height) {
                best_inliers = ratio;
                bestRectangle = hyphRectangle;
                goodRectCollection.add(hyphRectangle);
            }
            
        }
        
        confidence = (double)best_inliers / points.size();
        
        Collections.reverse(goodRectCollection);
        return goodRectCollection.size() > 0 ? goodRectCollection : null;
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
    
    private Rectangle generateRectangleFromTwoPoints(Point2D p1, Point2D p2) {
        double x = p1.getX();
        double y = p1.getY();
        double w = p2.getX() - p1.getX();
        double h = p2.getY() - p1.getY();
        
        return new Rectangle((int)x,(int)y,(int)w,(int)h);
    }
    
    private double calculateDensityRatio(Rectangle rect, ArrayList<Point2D> points) {
        int count = points.size();
        int total = rect.width * rect.height;
        
        return(double)count / total;
    }
}


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

