class CascadeDetector extends PApplet implements ObjectDetector{
    OpenCV opencv;
    private final String cf = "ball_detection4.xml";
    private int max_rects = 10;
    
    double scaleFactor = 1.25;
    int minNeighbors = 4;
    int flags = 0;
    int minSize = 30;
    int maxSize = 300;
    double MAX_THRESHOLD = 20;
    
    CascadeDetector(int w, int h) {
        opencv = new OpenCV(this, w, h);
        opencv.loadCascade(cf);
    }
    
    public ArrayList<Rectangle> detect(PImage image, PImage mask) {
        return detectCascade(image);
    }
    
    private ArrayList<Rectangle> detectCascade(PImage image) {
        opencv.loadImage(image);
        Rectangle[] rects = opencv.detect(scaleFactor, minNeighbors, flags, minSize, maxSize);
        ArrayList<Rectangle> rects_list = new ArrayList<Rectangle>();
        
        Arrays.sort(rects, new Comparator<Rectangle>() {
            @Override
            public int compare(Rectangle r1, Rectangle r2) {
                return(r1.width * r1.height) - (r2.width * r2.height);
            }
        });
        
        int Limit = Math.min(max_rects, rects.length);
        
        for (int i = 0; i < Limit; i++) {
            rects_list.add(rects[i]);
        }
        
        return rects_list;
    }
}