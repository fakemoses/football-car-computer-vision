public enum RGBType{
    RED, GREEN, BLUE;
}

class RGBFilter implements ColorFilter{
    protected RGBType type;
    protected int threshold;
    
    private ArrayList<PostFilter> postFilters;
    
    public RGBFilter(RGBType type, int threshold) {
        this.type = type;
        this.threshold = threshold;
        postFilters = new ArrayList<PostFilter>();
    }
    
    public RGBFilter addPostFilter(PostFilter filter) {
        postFilters.add(filter);
        return this;
    }
    
    public PImage filter(PImage image) {
        PImage mask = createImage(image.width, image.height, RGB);
        int[] rgbPixel = image.pixels;
        int[] maskPixel = mask.pixels;
        for (int i = 0; i < rgbPixel.length; i++) {
            maskPixel[i] = evaluate(rgbPixel[i]) ? 0xFFFFFFFF : 0xFF000000;
        }
        return executePostFilters(mask);
    }
    
    public boolean evaluate(color c) {
        int r = c >> 16 & 0xFF;
        int g = c >> 8 & 0xFF;
        int b = c & 0xFF;
        
        if (type == RGBType.RED) {
            return 2 * r - g - b > threshold;
        } else if (type == RGBType.GREEN) {
            return 2 * g - r - b > threshold;
        } else if (type == RGBType.BLUE) {
            return 2 * b - r - g > threshold;
        }
        return false;
    }
    
    private PImage executePostFilters(PImage image) {
        for (PostFilter filter : postFilters) {
            image = filter.apply(image);
        }
        return image;
    }
}

// original implementation from Prof.
class RGBFilterOld extends RGBFilter {   
    public RGBFilterOld(RGBType type, int threshold) {
        super(type, threshold);
    }
    
    @Override
    public boolean evaluate(color c) {
        int ROT = (c  >> 8) & 0xFF;
        int GRUEN  = c & 0xFF;
        int BLAU = (c >> 16) & 0xFF;
        
        if (type == RGBType.RED) {
            return  2 * ROT - GRUEN - BLAU + threshold < 0;
        } else if (type == RGBType.GREEN) {
            return 2 * GRUEN - ROT - BLAU + threshold < 0;
        } else if (type == RGBType.BLUE) {
            return 2 * BLAU - ROT - GRUEN + threshold < 0;
        }
        return false;
    }
}