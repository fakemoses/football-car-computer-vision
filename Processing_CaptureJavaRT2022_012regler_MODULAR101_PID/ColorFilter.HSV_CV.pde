public class HSVFilterCV extends PApplet implements ColorFilter {
    private OpenCV opencv;
    
    private ArrayList<PostFilter> postFilters;
    private ArrayList<HSVRange> ranges;
    
    public HSVFilterCV(ArrayList<HSVRange> ranges) {
        opencv = new OpenCV(this, 320,240);
        this.ranges = ranges;
    }
    
    public HSVFilterCV(HSVRange range) {
        this(new ArrayList<HSVRange>() {{
                add(range);
        } });
    }
    
    public HSVFilterCV(HSVColorRange range) {
        this(range.getHSVRange());
    }
    
    public HSVFilterCV addPostFilter(PostFilter filter) {
        postFilters.add(filter);
        return this;
    }
    
    public PImage filter(PImage image) {
        PImage[] array = new PImage[ranges.size()];
        for (int i = 0; i < ranges.size(); i++) {
            array[i] = mask(ranges.get(i), image);
        }
        PImage returnImage = combinemask(array);
        return executePostFilters(returnImage);
    }
    
    private PImage mask(HSVRange r, PImage img) {
        opencv.loadImage(img);
        opencv.useColor(HSB);
        
        opencv.setGray(opencv.getH().clone());
        opencv.inRange(r.h.lower, r.h.upper);
        PImage H = opencv.getSnapshot();
        
        opencv.setGray(opencv.getS().clone());
        opencv.inRange(r.s.lower, r.s.upper);
        PImage S = opencv.getSnapshot();
        
        opencv.diff(H);
        opencv.threshold(0);
        opencv.invert();
        PImage maskHS = opencv.getSnapshot();
        
        opencv.setGray(opencv.getV().clone());
        opencv.inRange(r.v.lower, r.v.upper);
        PImage V = opencv.getSnapshot();
        
        opencv.diff(maskHS);
        opencv.threshold(0);
        opencv.invert();
        return opencv.getSnapshot();
    }
    
    private PImage combinemask(PImage...masks) {
        PImage returnImage = createImage(masks[0].width, masks[0].height, RGB);
        int[] pix = returnImage.pixels;
        for (int i = 0; i < pix.length; i++) {
            for (PImage mask : masks) {
                if (mask.pixels[i] == 0xFFFFFFFF) {
                    pix[i] = 0xFFFFFFFF;
                    break;
                }
            }
        }
        return returnImage;
    }
    
    private PImage executePostFilters(PImage image) {
        for (PostFilter filter : postFilters) {
            image = filter.process(image);
        }
        return image;
    }
}

// cvHSV
// 1 ranges -> 5ms
// 2 ranges -> 8ms
// 3 ranges -> 10ms