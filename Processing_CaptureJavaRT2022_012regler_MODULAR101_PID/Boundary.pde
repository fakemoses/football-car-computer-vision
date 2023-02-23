/*
* IDEA:
1. Mat always start with Blank Images
-> Fill with Green
2. the first Line set should be always have smaller region 
*/

public class Boundary {
    private PImage image;
    private Line currentLine;
    private Line prevLine = new Line();
    private final int maxPixelsCount;
    private double threshhold = 0.3;
    private int greenCount = 0;
    
    public Boundary(PImage image) {
        this(image.width, image.height);              
    }
    
    public Boundary(int width, int height) {
        this.image = new PImage(width, height, RGB);
        int[] pixels = this.image.loadPixels();
        for (int i = 0; i < width; i++) {
            for (int j = 0; j < height; j++) {
                pixels[i + j * image.width] = color(0, 255, 0);
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
        if (prevLine.isDefined()) {
            int[] pixels = image.loadPixels();
            for (int i = 0; i < image.width; i++) {
                for (int j = 0; j < image.height; j++) {
                    int region = whereAmI(new Point(i, j));
                    if (region == 1) {
                        pixels[i + j * image.width] = color(0, 255, 0);
                        greenCount++;
                    } else if (region == 2) {
                        pixels[i + j * image.width] = color(255, 0, 0);
                    } else {
                        pixels[i + j * image.width] = color(0, 0, 255);
                    }
                }
            }
            image.updatePixels();
        }
        prevLine = currentLine;
        return image;
    }
    
    public PImage allGood() {
        int[] pixels = image.loadPixels();
        for (int i = 0; i < image.width; i++) {
            for (int j = 0; j < image.height; j++) {
                pixels[i + j * image.width] = color(0, 255, 0);
            }
        }
        image.updatePixels();
        return image;
    }
    
    
    // !MAX SUS CODE -> MORE TESTING NEEDED
    /*
    * 1 = green -> Available
    * 2 = red -> Unavailable
    * 3 = blue -> Border Change
    */
    private int whereAmI(Point p) {
        if (currentLine.m == 123 && prevLine.m == 123) {
            if (p.x < currentLine.c && p.x < prevLine.c) {
                return 2;
            } else if (p.x > currentLine.c && p.x > prevLine.c) {
                return 1;
            } else {
                return 3;  
            }
        }
        
        if (currentLine.m == 123) {
            if (p.x < currentLine.c) {
                if (prevLine.m * p.x + prevLine.c > p.y) {
                    return 1;
                } else {
                    return 2;
                }
            }
            else {
                if (prevLine.m * p.x + prevLine.c > p.y) {
                    return 3;
                } else {
                    return 2;
                }
            }
        }
        
        if (prevLine.m == 123) {
            if (p.x < prevLine.c) {
                if (currentLine.m * p.x + currentLine.c > p.y) {
                    return 1;
                } else {
                    return 2;
                }
            }
            else {
                if (currentLine.m * p.x + currentLine.c > p.y) {
                    return 3;
                } else {
                    return 2;
                }
            }
        }
        
        if (p.y > currentLine.m * p.x + currentLine.c && p.y > prevLine.m * p.x + prevLine.c) {
            return 1;
        } else if (p.y < currentLine.m * p.x + currentLine.c && p.y < prevLine.m * p.x + prevLine.c) {
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