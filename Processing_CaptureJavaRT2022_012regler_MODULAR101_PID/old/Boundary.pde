/*
* IDEA:
1. Mat always start with Blank Images
-> Fill with Green
2. the first Line set should be always have smaller region 
*/

public class Boundary {
    private PImage image;
    private Line currentLine;
    private Line prevLine = null;
    private final int maxPixelsCount;
    private double threshhold = 0.3;
    private int greenCount = 0;
    
    public Boundary(PImage image) {
        this(image.width, image.height);              
    }
    
    public Boundary(int width, int height) {
        this.image = new PImage(width, height, RGB);
        // int[] pixels = this.image.loadPixels;
        for (int i = 0; i < width; i++) {
            for (int j = 0; j < height; j++) {
                this.image.pixels[i + j * image.width] = color(0, 255, 0);
            }
        }
        this.image.updatePixels();
        this.maxPixelsCount = image.width * image.height;                 
    }
    
    public PImage updateImage(Line l) {
        greenCount = 0;
        if (l == null) {
            greenCount = maxPixelsCount;
            return allGood();
        }
        this.currentLine = l;
        if (prevLine != null) {
            // int[] pixels = image.loadPixels();
            for (int i = 0; i < image.width; i++) {
                for (int j = 0; j < image.height; j++) {
                    int region = whereAmI(new Point(i, j));
                    if (region == 1) {
                        this.image.pixels[i + j * image.width] = color(0, 255, 0);
                        greenCount++;
                    } else if (region == 2) {
                        this.image.pixels[i + j * image.width] = color(255, 0, 0);
                    } else {
                        this.image.pixels[i + j * image.width] = color(0, 0, 255);
                    }
                }
            }
            image.updatePixels();
        }
        prevLine = currentLine;
        return image;
    }
    
    public PImage allGood() {
        // int[] pixels = image.loadPixels();
        for (int i = 0; i < image.width; i++) {
            for (int j = 0; j < image.height; j++) {
                this.image.pixels[i + j * image.width] = color(0, 255, 0);
            }
        }
        image.updatePixels();
        return image;
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
    
    public boolean isHelpNeeded() {
        if (greenCount == 0) {
            return false;
        }
        double percentage = (double)greenCount / maxPixelsCount;
        // println("Green Pixels: " + greenCount + " / " + maxPixelsCount + " = " + percentage + " < " + threshhold + " = " + result);
        return percentage < threshhold;
    }
}