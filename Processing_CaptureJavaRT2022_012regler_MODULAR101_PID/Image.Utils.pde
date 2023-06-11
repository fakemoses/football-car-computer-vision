class ImageUtils{
    
    public ImageUtils() {
    }
    
    PImage drawLine(PImage image, Line line, int thickness, color c) { 
        PointArray<Point> points = lineToPointArray(line, thickness);
        return drawPoint(image, points, c);
    }
    
    PointArray<Point> lineToPointArray(Line line, int thickness) { 
        PointArray<Point> points = line.getPoints(thickness);
        return points;
    }
    
    PImage drawRect(PImage image, Rectangle rect, int thickness, color c, boolean fill) { 
        PointArray<Point> points = rectToPointArray(rect, thickness, fill);
        return drawPoint(image, points, c);
    }
    
    PointArray<Point> rectToPointArray(Rectangle rect, int thickness, boolean fill) {
        PointArray<Point> points = new PointArray<Point>();
        if (thickness > 0) {
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
        }
        
        if (fill) {
            for (int i = rect.x; i <= rect.x + rect.width; i++) {
                for (int j = rect.y; j <= rect.y + rect.height; j++) {
                    points.add(new Point(i, j));
                }
            }
        }
        return points;
    }
    
    PImage drawPoint(PImage image, PointArray<Point> points ,color c) { 
        PImage returnImage = image.copy();
        int[] pixels = returnImage.pixels;        
        for (Point p : points) {
            pixels[p.x + p.y * returnImage.width] = c;
        }
        return returnImage;
    }
}