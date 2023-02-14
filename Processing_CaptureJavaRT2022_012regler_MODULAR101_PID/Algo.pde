public class Algo {
    
    private IPCapture cam;
    Bildverarbeitung bildverarbeitung;
    LineDetection lineDetection;
    BallDetection ballDetection;
    CarDetection carDetection;
    GoalDetection goalDetection;
    
    
    public Algo(IPCapture cam, Bildverarbeitung bildverarbeitung, LineDetection lineDetection, BallDetection ballDetection, CarDetection carDetection, GoalDetection goalDetection) {
        // in constructor -> start all thread
        this.cam = cam;
        this.bildverarbeitung = bildverarbeitung;
        this.lineDetection = lineDetection;
        this.ballDetection = ballDetection;
        this.carDetection = carDetection;
        this.goalDetection = goalDetection;
    }
    
    public void startALL() {
        /* should bileVerarbaitung also run on different thread?
        Right now it is running on main Thread by runColorDetection();
        bildverarbeitung.start(); */
        lineDetection.startThread();
        ballDetection.startThread();
        carDetection.startThread();
        goalDetection.startThread();
    }
    
    public void runColorExtraction() {
        bildverarbeitung.extractColorRGB(cam);
        lineDetection.setPoints(bildverarbeitung.getRedList());
        // then maybe pakai getter -> set semua RGB dekat sini
        // bolehpass RGB dekat Thread for calculation kalau nak
    }
    
    public PImage getGoalDetectionResult(int[]c, int thickness) {
        Rectangle rect = goalDetection.getBoundingBox();
        PImage image = bildverarbeitung.getCameraImage();
        return rect != null ? drawRect(image, rect, thickness,c) : image;
    }
    
    public PImage getLineDetectionResult(int[]c, int thickness) {
        Line line = lineDetection.getRansacLine();
        PImage image = bildverarbeitung.getCameraImage();
        return line != null ? drawLine(image, line, thickness,c) : image;
    }
    
    
    private PImage drawRect(PImage image, Rectangle rect, int thickness, int[] c) { 
        PImage returnImage = image.copy();        
        ArrayList<Point> points = new ArrayList<Point>();
        
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
        
        for (Point p : points) {
            returnImage.set(p.x, p.y, color(c[0], c[1], c[2]));
        }
        
        return returnImage;
    }
    
    private PImage drawLine(PImage image, Line line, int thickness, int[] c) { 
        PImage returnImage = image.copy();        
        ArrayList<Point> points = line.getPoints(thickness);
        
        for (Point p : points) {
            returnImage.set(p.x, p.y, color(c[0], c[1], c[2]));
        }
        
        return returnImage;
    }
}

// todo : Thread race / Sync ?
