class CascadeDetection extends PApplet{
    OpenCV ocv;
    private final String cf = "ball_detection4.xml";
    
    double scaleFactor = 1.25;
    int minNeighbors = 4;
    int flags = 0;
    int minSize = 30;
    int maxSize = 300;
    double MAX_THRESHOLD = 20;
    
    CascadeDetection() {
        ocv = new OpenCV(this, 320, 240);
        ocv.loadCascade(cf);
    }
    
    public Rectangle[] detect(PImage img) {
        ocv.loadImage(img);
        return ocv.detect(scaleFactor, minNeighbors, flags, minSize, maxSize);
    }
    
    public void setScaleFactor(double scaleFactor) {
        this.scaleFactor = scaleFactor;
    }
    
    public void setMinNeighbors(int minNeighbors) {
        this.minNeighbors = minNeighbors;
    }
    
    public void setFlags(int flags) {
        this.flags = flags;
    }
    
    public void setMinSize(int minSize) {
        this.minSize = minSize;
    }
    
    public void setMaxSize(int maxSize) {
        this.maxSize = maxSize;
    }
    
    public void setMaxThreshold(double maxThreshold) {
        this.MAX_THRESHOLD = maxThreshold;
    }
    
    public Rectangle getValidRect(Rectangle[] rects, PImage mask) { 
        PImage m = mask.copy();
        for (Rectangle rect : rects) {
            if (getWhitePercentage(m, rect) > MAX_THRESHOLD) {
                return rect;
            }
        }
        return null;
    }
    
    private double getWhitePercentage(PImage mask, Rectangle r) {
        int white_count = 0;
        int w = r.width;
        int h = r.height;
        int pix[] = mask.pixels;
        for (int i = r.y; i < r.y + h; i++) {
            for (int j = r.x; j < r.x + w; j++) {
                if (pix[i * mask.width + j] == color(255)) {
                    white_count++;
                }
            }
        }
        return((double)white_count / (w * h)) * 100;
    }
}