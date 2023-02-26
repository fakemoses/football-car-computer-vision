class CascadeDetection extends PApplet{
    OpenCV ocv;
    private final String cf = "ball_detection4.xml";
    
    double scaleFactor = 1.25;
    int minNeighbors = 4;
    int flags = 0;
    int minSize = 30;
    int maxSize = 300;
    
    CascadeDetection() {
        ocv = new OpenCV(this, 320, 240);
        ocv.loadCascade(cf);
    }
    
    public Rectangle[] detect(PImage img) {
        ocv.loadImage(img);
        return ocv.detect(scaleFactor, minNeighbors, flags, minSize, maxSize);
    }
}