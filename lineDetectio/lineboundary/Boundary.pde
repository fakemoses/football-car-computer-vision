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
    
    public Boundary(PImage image) {
        this.image = new PImage(image.width, image.height, RGB);
        for (int i = 0; i < image.width; i++) {
            for (int j = 0; j < image.height; j++) {
                this.image.set(i, j, color(0, 255, 0));
            }
        }
        this.maxPixelsCount = image.width * image.height;                 
    }
    
    public Boundary(int width, int height) {
        this.image = new PImage(width, height, RGB);
        for (int i = 0; i < width; i++) {
            for (int j = 0; j < height; j++) {
                this.image.set(i, j, color(0, 255, 0));
            }
        }
        this.maxPixelsCount = image.width * image.height;                 
        
    }
    
    public PImage updateImage(Line l) {
        this.currentLine = l;
        if (prevLine.isDefined()) {
            for (int i = 0; i < image.width; i++) {
                for (int j = 0; j < image.height; j++) {
                    int region = whereAmI(new Point(i, j));
                    if (region == 1) {
                        image.set(i, j, color(0, 255, 0));
                    } else if (region == 2) {
                        image.set(i, j, color(255, 0, 0));
                    } else {
                        image.set(i, j, color(0, 0, 255));
                    }
                }
            }
        }
        prevLine = currentLine;
        return image;
    }
    
    
    // !MAX SUS CODE -> MORE TESTING NEEDED
    public int whereAmI(Point p) {
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
}