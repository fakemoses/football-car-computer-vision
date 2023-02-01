public class ROIFIXED  {
    private final double ROIAREA = 0.333;
    private final int ANGLE_LIMIT = 20;
    private PImage HORIZONTAL_ROI;
    private PImage VERTICAL_ROI;
    private ROILine line;
    private Line prevLine = new Line();
    private Box vBox;
    private Box hBox;
    private int type = -1;
    private Point midPoint = new Point( -1, -1);
    
    public ROIFIXED(PImage img) {
        HORIZONTAL_ROI = new PImage(img.width, img.height);
        VERTICAL_ROI = new PImage(img.width, img.height);
        vBox = new Box(0,(int)(img.height * (1 - ROIAREA)), img.width,(int)(img.height * ROIAREA));
        hBox = new Box((int)(img.width * ROIAREA),0,(int)(img.width * ROIAREA),img.height);
    }
    
    public ROIFIXED(int width, int height) {
        HORIZONTAL_ROI = new PImage(width, height);
        VERTICAL_ROI = new PImage(width, height);
        vBox = new Box(0,(int)(height * (1 - ROIAREA)), width,(int)(height * ROIAREA));
        hBox = new Box((int)(width * ROIAREA),0,(int)(width * ROIAREA),height);
    }
    
    
    public void updatePixels(PImage img, Line line) {
        updateVar(line);
        
        // not necessary to update the whole image
        HORIZONTAL_ROI.loadPixels();
        VERTICAL_ROI.loadPixels();
        for (int i = 0; i < img.pixels.length; i++) {
            int x = i % img.width;
            int y = i / img.width;
            
            if (x < img.width * (1 - ROIAREA) && x > img.width * ROIAREA) {
                HORIZONTAL_ROI.pixels[i] = img.pixels[i];
            } else {
                HORIZONTAL_ROI.pixels[i] = color(100);
            }
            
            if (y > img.height * (1 - ROIAREA)) {
                VERTICAL_ROI.pixels[i] = img.pixels[i];
            } else {
                VERTICAL_ROI.pixels[i] = color(100);
            }
        }
        HORIZONTAL_ROI.updatePixels();
        VERTICAL_ROI.updatePixels();
        
        if (prevLine.isDefined()) {            
            if (type == 0) {        
                if (vBox.contain(midPoint)) {
                    println("vertical");
                } 
                return;
            }
            
            if (hBox.contain(midPoint)) {
                int LOR = fromLeftOrRight();
                if (LOR == 1) {
                    println("from right");
                } else if (LOR == -1) {
                    println("from left");
                }
        } }
        
        
        // ! Possible bug -> if the car moves too fast, the line will be too short to be detected
        prevLine = line;
    }
    
    public void updateVar(Line l) {
        this.type = verticalorhorizontal(l);
        this.midPoint = getMidPoint(l);
    }
    
    public PImage getHorizontalROI() {
        return HORIZONTAL_ROI;
    }
    
    public PImage getVerticalROI() {
        return VERTICAL_ROI;
    }
    
    public int fromLeftOrRight() {
        Point prevMid = getMidPoint(prevLine);
        if (prevMid.x < midPoint.x) {
            // from left
            return - 1;
        } else if (prevMid.x > midPoint.x) {
            return 1;
        }
        // something wrong or no change
        println("Max SUS");
        return 0;
    }
    
    public int verticalorhorizontal(Line line) {
        Point s = line.p1;
        Point e = line.p2;
        
        // calculate the angle of the line
        double angle = atan2(e.y - s.y, e.x - s.x);
        angle = angle * 180 / PI;
        if (angle < 0) {
            angle = 360 + angle;
        }
        if (angle > ANGLE_LIMIT && angle < 180 - ANGLE_LIMIT) {
            // horizontal
            return 1;
        } else {
            return 0;
        }
    }
    
    public Point getMidPoint(Line line) {
        Point s = line.p1;
        Point e = line.p2;
        return new Point((s.x + e.x) / 2,(s.y + e.y) / 2);
    }
    
    public Point getMidPoint() {
        return midPoint;
    }
    
    public int getType() {
        return type;
    }
}

class ROILine extends Line{
    double angle;
    int type = 0;
    
}

class Box {
    int x;
    int y;
    int w;
    int h;
    
    Box(int x, int y, int w, int h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }
    
    boolean contain(Point p) {
        return(p.x > x && p.x < x + w && p.y > y && p.y < y + h);
    }
    
}
