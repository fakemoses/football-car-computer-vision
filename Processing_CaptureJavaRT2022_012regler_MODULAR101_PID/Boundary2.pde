/*
* IDEA:
1. Mat always start with Blank Images
-> Fill with Green
2. the first Line set should be always have smaller region 
*/

public class Boundary2 {
    
    private Line prevLine = new Line();
    private Line currentLine = new Line();
    
    private final int maxPixelsCount;
    private double threshhold = 0.3;
    private int greenCount = 0;
    private PImage greenImage;
    private PImage boundaryResult;
    
    public Boundary2(PImage image) {
        this(image.width, image.height);              
    }
    
    public Boundary2(int w, int h) {
        this.greenImage = new PImage(w, h, RGB);
        int[] pixels = greenImage.pixels;
        for (int i = 0; i < pixels.length; i++) {
            pixels[i] = color(0, 255, 0);
        }
        maxPixelsCount = pixels.length;
        boundaryResult = greenImage.copy();
    }
    
    public boolean isHelpNeeded(Line l) {
        boundaryResult = greenImage.copy();
        if (l == null) {
            greenCount = maxPixelsCount;
            return false;
        }   
        updateImage(l);
        double percentage = (double)greenCount / maxPixelsCount;
        return percentage < threshhold;
    }
    
    private void updateImage(Line l) {
        currentLine = l;
        if (!prevLine.isDefined()) {
            prevLine = l;
            return;
        }
        greenCount = 0;
        int[] pixels = boundaryResult.pixels;
        for (int i = 0; i < boundaryResult.width; i++) {
            for (int j = 0; j < boundaryResult.height; j++) {
                int region = whereAmI(new Point(i, j));
                if (region == 1) {
                    greenCount++;
                } else if (region == 2) {
                    pixels[i + j * boundaryResult.width] = color(255, 0, 0);
                } else {
                    pixels[i + j * boundaryResult.width] = color(0, 0, 255);
                }
            }
        }
        prevLine = currentLine;
    }
    
    public PImage getBoundaryResult() {
        return boundaryResult;
    }
    
    
    // !MAX SUS CODE -> MORE TESTING NEEDED
    // TODO: Better Implementation
    /*
    * 1 = green -> Available
    * 2 = red -> Unavailable
    * 3 = blue -> Border Change
    */
    private int whereAmI(Point p) {
        if (currentLine.isVertical() && prevLine.isVertical()) {
            if (p.x < currentLine.yIntercept() && p.x < prevLine.yIntercept()) {
                return 2;
            } else if (p.x > currentLine.yIntercept() && p.x > prevLine.yIntercept()) {
                return 1;
            } else {
                return 3;  
            }
        }
        
        if (currentLine.isVertical()) {
            if (p.x < currentLine.yIntercept()) {
                if (prevLine.gradient() * p.x + prevLine.yIntercept() > p.y) {
                    return 1;
                } else {
                    return 2;
                }
            }
            else {
                if (prevLine.gradient() * p.x + prevLine.yIntercept() > p.y) {
                    return 3;
                } else {
                    return 2;
                }
            }
        }
        
        if (prevLine.isVertical()) {
            if (p.x < prevLine.yIntercept()) {
                if (currentLine.gradient() * p.x + currentLine.yIntercept() > p.y) {
                    return 1;
                } else {
                    return 2;
                }
            }
            else {
                if (currentLine.gradient() * p.x + currentLine.yIntercept() > p.y) {
                    return 3;
                } else {
                    return 2;
                }
            }
        }
        
        if (p.y > currentLine.gradient() * p.x + currentLine.yIntercept() && p.y > prevLine.gradient() * p.x + prevLine.yIntercept()) {
            return 1;
        } else if (p.y < currentLine.gradient() * p.x + currentLine.yIntercept() && p.y < prevLine.gradient() * p.x + prevLine.yIntercept()) {
            return 2;
        } else {
            return 3;
        } 
    }
}