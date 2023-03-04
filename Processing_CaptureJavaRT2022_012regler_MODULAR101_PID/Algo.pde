public class Algo {
    
    // private IPCapture cam;
    Bildverarbeitung bildverarbeitung;
    // LineDetection lineDetection;
    // BallDetection2 ballDetection;
    // CarDetection carDetection;
    // GoalDetection goalDetection;
    
    DetectionThread[] tis;
    
    
    // public Algo(IPCapture cam, Bildverarbeitung bildverarbeitung, LineDetection lineDetection, BallDetection2 ballDetection, CarDetection carDetection, GoalDetection goalDetection,DetectionThread[] threads) {
    public Algo(Bildverarbeitung bildverarbeitung, DetectionThread[] threads) {
        // in constructor -> start all thread
        // this.cam = cam;
        this.bildverarbeitung = bildverarbeitung;
        // this.lineDetection = lineDetection;
        // this.ballDetection = ballDetection;
        // this.carDetection = carDetection;
        // this.goalDetection = goalDetection;
        this.tis = threads;
    }
    
    public void startALL() {
        /* 
        * should bildVerarbaitung also run on different thread?
        * Right now it is running on main Thread by runColorDetection();
        */
        // lineDetection.startThread();
        // ballDetection.startThread();
        // carDetection.startThread();
        // goalDetection.startThread();
        
        for (DetectionThread ti : tis) {
            ti.startThread();
        }
    }
    
    public void runColorExtraction() {
        bildverarbeitung.extractColorRGB(cam);
        
        for (DetectionThread ti : tis) {
            ti.setImage(bildverarbeitung.getCameraImage());
        }
    }
    
    // public PImage getGoalDetectionResult(color c, int thickness) {
    //  Rectangle rect = goalDetection.getBoundingBox();
    //  PImage image = bildverarbeitung.getCameraImage();
    //  return rect != null ? drawRect(image, rect, thickness,c, false) : image;
// }
    
    // public PImage getLineDetectionResult(color c, int thickness) {
    //  Line line = lineDetection.getRansacLine();
    //  PImage image = bildverarbeitung.getCameraImage();
    //  return line != null ? drawLine(image, line, thickness,c) : image;
// }
    
    // public PImage getBallDetectionResult(color c, color rc, int thickness) {
    //  Rectangle rect = ballDetection.getBoundingBox();
    //  Rectangle roi = ballDetection.getROI();
    //  PImage image = bildverarbeitung.getCameraImage();
    //  PImage retImage = drawRect(image, roi, 1,rc, false);
    //  c = ballDetection.isBallWithinROI() ? color(0, 255, 0) : c;
    //  return rect != null ? drawRect(retImage, rect, thickness,c, false) : retImage;
// }
    
    
    // private PImage drawRect(PImage image, Rectangle rect, int thickness, color c, boolean fill) { 
    //  PImage returnImage = image.copy();        
    //  PointArray<Point> points = new PointArray<Point>();
    
    //  if (thickness > 0) {
    //  for (int i = rect.x; i <= rect.x + rect.width; i++) {
    //  for (int j = ceil(rect.y - (thickness / 2)); j <= floor(rect.y + (thickness / 2)); j++) {
    //  points.add(new Point(i, j));
    //  points.add(new Point(i, j + rect.height));
    //  }
    //  }
    
    //  for (int i = rect.y; i <= rect.y + rect.height; i++) {
    //  for (int j = ceil(rect.x - (thickness / 2)); j <= floor(rect.x + (thickness / 2)); j++) {
    //  points.add(new Point(j, i));
    //  points.add(new Point(j + rect.width, i));
    //  }
    //  } 
    //     }
    
    //  if (fill) {
    //  for (int i = rect.x; i <= rect.x + rect.width; i++) {
    //  for (int j = rect.y; j <= rect.y + rect.height; j++) {
    //  points.add(new Point(i, j));
    //  }
    //  }
    //     }
    
    //  returnImage.loadPixels();
    //  for (Point p : points) {
    //  // println("p: " + p.toString());
    //  returnImage.pixels[p.x + p.y * returnImage.width] = c;
    //     }
    //  returnImage.updatePixels();
    
    //  return returnImage;
// }
    
    // private PImage drawLine(PImage image, Line line, int thickness, color c) { 
    //  PImage returnImage = image.copy();        
    //  PointArray<Point> points = line.getPoints(thickness);
    
    //  for (Point p : points) {
    //  returnImage.set((int)p.getX(),(int)p.getY(), c);
    //     }
    
    //  return returnImage;
// }
    
    public PImage[][] getTIResult() {
        PImage[][] images = new PImage[tis.length][];
        for (int i = 0; i < tis.length; i++) {
            PImage[] t = tis[i].getResults();
            images[i] = t != null ? t : new PImage[0];
        }
        return images;
    }
}

// todo : Thread race / Sync ?
