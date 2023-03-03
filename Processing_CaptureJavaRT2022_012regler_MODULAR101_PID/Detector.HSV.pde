// only for yellow color detection
// but also useable for other colors which can be expanded

public class ColorHSV extends PApplet implements ObjectDetector {
    
    private OpenCV opencv;
    private int hsvRange[][];
    private PImage maskHS, maskHSV;
    private PImage H, S, V;
    private int thickness = 10;
    private PointArray<Point> pointArray = new PointArray<Point>();
    public ColorHSV(PImage img, int[][] hsvRange) {
        this(img.width, img.height, hsvRange);
    }
    
    public ColorHSV(int w, int h, int[][] hsvRange) {
        this.opencv = new OpenCV(this, w, h);
        this.hsvRange = hsvRange;
        for (int i = 0; i < w; i++) {
            for (int j = 0; j < thickness; j++) {
                pointArray.add(new Point(i, j));
                pointArray.add(new Point(i, h - j));
            }
        }
        
        for (int i = 0; i < h; i++) {
            for (int j = 0; j < thickness; j++) {
                pointArray.add(new Point(j, i));
                pointArray.add(new Point(w - j, i));
            }
        }
    }
    
    public ColorHSV setHSVRange(int[][] hsvRange) {
        this.hsvRange = hsvRange;
        return this;
    }
    
    public Rectangle detect(PImage image) {
        processMask(image);
        ArrayList<Contour> contours = getContour();
        if (contours.size() == 0) {
            return null;
        }
        Contour biggest = contours.get(0);
        return biggest.getBoundingBox();
    }
    
    public Rectangle detect(PImage image, PImage mask) {
        return detect(image);
    }
    
    public Rectangle[] det2(PImage image) {
        processMask(image);
        ArrayList<Contour> contours = getContour();
        if (contours.size() == 0) {
            return null;
        }
        int Limit = min(5, contours.size());
        Rectangle[] rect = new Rectangle[Limit];
        for (int i = 0; i < Limit; i++) {
            rect[i] = contours.get(i).getBoundingBox();
        }
        return rect;
    }
    
    private void processMask(PImage image) {
        opencv.loadImage(image);
        opencv.useColor(HSB);
        
        opencv.setGray(opencv.getH().clone());
        opencv.inRange(hsvRange[0][0], hsvRange[1][0]);
        H = opencv.getSnapshot();
        
        opencv.setGray(opencv.getS().clone());
        opencv.inRange(hsvRange[0][1], hsvRange[1][1]);
        S = opencv.getSnapshot();
        
        opencv.diff(H);
        opencv.threshold(0);
        opencv.invert();
        maskHS = opencv.getSnapshot();
        
        opencv.setGray(opencv.getV().clone());
        opencv.inRange(hsvRange[0][2], hsvRange[1][2]);
        V = opencv.getSnapshot();
        
        opencv.diff(maskHS);
        opencv.threshold(0);
        opencv.invert();
        maskHSV = opencv.getSnapshot();
    }
    
    
    
    public PImage getMask() {   
        return maskHSV;
    }
    
    public PImage getMask(PImage image, boolean withColor) {
        if (!withColor) {
            return maskHSV;
        }
        
        PImage colorMask = createImage(maskHSV.width, maskHSV.height, RGB);
        
        for (int i = 0; i < maskHSV.width; i++) {
            for (int j = 0; j < maskHSV.height; j++) {
                color c = maskHSV.get(i, j);
                color ori = img.get(i, j);
                if (c !=-  16777216) {
                    colorMask.set(i, j, ori);
                    continue;
                }
                colorMask.set(i, j, c);
            }
        }
        return colorMask;
    };
    
    public PImage combineMask(PImage mask2, PImage img) {
        PImage returnMask = createImage(maskHSV.width, maskHSV.height, RGB);
        for (int i = 0; i < maskHSV.width; i++) {
            for (int j = 0; j < maskHSV.height; j++) {
                color c = maskHSV.get(i, j);
                color d = mask2.get(i, j);
                color ori = img.get(i, j);
                if (c !=-  16777216) {
                    returnMask.set(i, j, ori);
                    continue;
                } else if (d!= -16777216) {
                    returnMask.set(i, j, ori);
                    continue;
                }
                returnMask.set(i, j, d);
            }
        }
        return returnMask;
    }
    
    public ArrayList<Contour> getContour() {
        maskHSV.loadPixels();
        for (int i = 0; i < pointArray.size(); i++) {
            Point p = pointArray.get(i);
            maskHSV.pixels[p.x + p.y * maskHSV.width] = color(0, 0, 0);
        }    
        maskHSV.updatePixels();
        opencv.loadImage(maskHSV);
        return opencv.findContours(true, true);
    }
    
    public PImage getH() {
        return H;
    }
    public PImage getS() {
        return S;
    }
    public PImage getV() {
        return V;
    }
}
