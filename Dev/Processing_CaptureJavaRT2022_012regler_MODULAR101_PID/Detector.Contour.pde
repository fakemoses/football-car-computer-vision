public class ContourDetector extends PApplet implements Detector<Rectangle> {
    private OpenCV opencv;
    private int max_rects = 10;
    
    ContourDetector() {
    }
    
    ContourDetector(int w, int h) {
        opencv = new OpenCV(this, w, h);
    }   
    
    public ContourDetector setMaxRects(int max_rects) {
        this.max_rects = max_rects;
        return this;
    }
    
    public ArrayList<Rectangle> detect(PImage image, PImage mask) {
        if (image.width != mask.width || image.height != mask.height) {
            throw new IllegalArgumentException("Image and mask must be the same size");
        }
        
        if (opencv == null) {
            opencv = new OpenCV(this, image.width, image.height);
        }
        
        ArrayList<Contour> contours = this.detectContours(mask);
        
        ArrayList<Rectangle> rects = new ArrayList<Rectangle>();
        
        for (Contour contour : contours) {
            Rectangle rect = contour.getBoundingBox();
            rects.add(rect);
        }
        
        return rects;
    }
    
    private ArrayList<Contour> detectContours(PImage mask) {
        opencv.loadImage(mask);
        ArrayList<Contour> contours = opencv.findContours(true, true);
        
        if (contours.size() <= max_rects) {
            return contours;
        }
        
        return new ArrayList<Contour>(contours.subList(0, max_rects));
        
        // return contours.size() > max_rects ? contours.subList(0,max_rects) : contours;
    }
}
