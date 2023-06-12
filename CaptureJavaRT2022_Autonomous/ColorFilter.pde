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

public class HSVFilter implements ColorFilter {
    private final int MAX_HUE = 180;
    private final int MAX_SATURATION = 255;
    private final int MAX_VALUE = 255;
    
    private ArrayList<PostFilter> postFilters;
    private ArrayList<HSVRange> ranges;
    
    public HSVFilter(ArrayList<HSVRange> ranges) {
        this.ranges = ranges;
        postFilters = new ArrayList<PostFilter>();
    }
    
    public HSVFilter(HSVRange range) {
        this(new ArrayList<HSVRange>() {{
                add(range);
        } });
    }
    
    public HSVFilter(HSVColorRange range) {
        this(range.getHSVRange());
    }
    
    public HSVFilter addPostFilter(PostFilter filter) {
        postFilters.add(filter);
        return this;
    }
    
    public PImage filter(PImage image) {
        PImage hsv = createImage(image.width, image.height, RGB);
        int[] pix = hsv.pixels;
        for (int i = 0; i < image.pixels.length; i++) {
            int c = image.pixels[i];
            
            float h = 0.0f;
            float s = 0.0f;
            float v = 0.0f;
            
            float r = c >> 16 & 0xFF;
            float g = c >> 8 & 0xFF;
            float b = c & 0xFF;
            
            float rF = (float) r / (float) MAX_VALUE;
            float gF = (float) g / (float) MAX_VALUE;
            float bF = (float) b / (float) MAX_VALUE;
            
            float max = Math.max(Math.max(rF, gF), bF);
            float min = Math.min(Math.min(rF, gF), bF);
            
            float delta = max - min;
            
            // Calculate Hue
            if (delta == 0) {
                h = 0;
            } else if (max == rF) {
                h = (((gF - bF) / delta) % 6) * 60f;
            } else if (max == gF) {
                h = (((bF - rF) / delta) + 2) * 60f;
            } else if (max == bF) {
                h = (((rF - gF) / delta) + 4) * 60f;
            }
            
            if (h < 0) {
                h += 360f;
            }
            
            h = (h / 360f) * MAX_HUE;
            
            
            int c1 = 0;
            for (HSVRange range : ranges) {
                if (!range.h.inRange(h)) {
                    c1++;
                }
            }
            
            if (c1 == ranges.size()) {
                pix[i] = 0x00000000;
                continue;
            }
            
            
            // Calculate Saturation
            if (max == 0) {
                s = 0;
            } else {
                s = delta / max;
            }
            s *=  MAX_SATURATION;
            
            int c2 = 0;
            for (HSVRange range : ranges) {
                if (!range.s.inRange(s)) {
                    c2++;     
                }
            }
            
            if (c2 == ranges.size()) {
                pix[i] = 0x00000000;
                continue;
            }
            
            v = max;
            v *=  MAX_VALUE;
            
            int c3 = 0;
            for (HSVRange range : ranges) {
                if (!range.v.inRange(v)) {
                    c3++;
                }
            }
            
            if (c3 == ranges.size()) {
                pix[i] = 0x00000000;
                continue;
            }
            
            
            pix[i] = 0xFFFFFFFF;
        }
        return executePostFilters(hsv);
    }
    
    private PImage executePostFilters(PImage image) {
        for (PostFilter filter : postFilters) {
            image = filter.apply(image);
        }
        return image;
    }
    
    public PImage rgbToHsv(PImage image) {
        PImage hsv = createImage(image.width, image.height, RGB);
        int[] pix = hsv.pixels;
        for (int i = 0; i < image.pixels.length; i++) {
            int c = image.pixels[i];
            
            float h = 0.0f;
            float s = 0.0f;
            float v = 0.0f;
            
            float r = c >> 16 & 0xFF;
            float g = c >> 8 & 0xFF;
            float b = c & 0xFF;
            
            float rF = (float) r / (float) MAX_VALUE;
            float gF = (float) g / (float) MAX_VALUE;
            float bF = (float) b / (float) MAX_VALUE;
            
            float max = Math.max(Math.max(rF, gF), bF);
            float min = Math.min(Math.min(rF, gF), bF);
            
            float delta = max - min;
            
            // Calculate Hue
            if (delta == 0) {
                h = 0;
            } else if (max == rF) {
                h = (((gF - bF) / delta)) * 60f;
                // h = (((gF - bF) / delta) % 6) * 60f;
            } else if (max == gF) {
                h = (((bF - rF) / delta) + 2) * 60f;
            } else if (max == bF) {
                h = (((rF - gF) / delta) + 4) * 60f;
            }
            
            if (h < 0) {
                h += 360f;
            }
            
            h = (h / 360f) * MAX_HUE;   
            
            // Calculate Saturation
            if (max == 0) {
                s = 0;
            } else {
                s = delta / max;
            }
            s *=  MAX_SATURATION;
            
            v = max;
            v *=  MAX_VALUE;
            
            
            pix[i] = color(h, s, v);    
        }
        return hsv;
    }
}

// myHSV
// 1 ranges -> 2ms
// 2 ranges -> 2ms
// 3 ranges -> 4ms


// Wrapper for OpenCV HSV filtering
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
            image = filter.apply(image);
        }
        return image;
    }
}

// cvHSV
// 1 ranges -> 5ms
// 2 ranges -> 8ms
// 3 ranges -> 10ms

public enum HSVColorRange{
    RED1(new HSVRange(0, 10, 100, 255, 100, 255)),
        RED2(new HSVRange(170, 180, 100, 255, 100, 255)),
        YELLOW(new HSVRange(25, 35, 50, 255, 70, 255)),
        YELLOW3(new HSVRange(20, 40, 50, 255, 70, 255)),
        YELLOW2(new HSVRange(25, 35, 81, 89, 170, 220)),
        GREEN(new HSVRange(36, 86, 35, 255, 70, 255)),
        BLUE(new HSVRange(90, 128, 95, 255, 70, 255)),
        BLUE2(new HSVRange(90, 128, 95, 255, 30, 255));
    
    private HSVRange hsvRange;
    
    private static final HashMap<HSVColorRange, HSVRange> hsvRangeMap = new HashMap<HSVColorRange, HSVRange>();
    
    static {
        for (HSVColorRange hsvEnumRange : HSVColorRange.values()) {
            hsvRangeMap.put(hsvEnumRange, hsvEnumRange.getHSVRange());
        }
    }
    
    HSVColorRange(HSVRange hsvRange) {
        this.hsvRange = hsvRange;
    }
    
    public HSVRange getHSVRange() {
        return hsvRange;
    }
    
    static ArrayList<HSVRange> combine(HSVColorRange...hsvColorRanges) {
        ArrayList<HSVRange> hsvRanges = new ArrayList<HSVRange>();
        for (HSVColorRange hsvColorRange : hsvColorRanges) {
            hsvRanges.add(hsvRangeMap.get(hsvColorRange));
        }
        return hsvRanges;
    }
}

static class HSVRange {
    Range h;
    Range s;
    Range v;
    
    class Range {
        int upper;
        int lower;
        
        Range(int upper, int lower) {
            
            if (upper < lower) {
                throw new IllegalArgumentException("Upper bound must be greater than lower bound");
            }
            
            this.upper = upper;
            this.lower = lower;
        }
        
        public boolean inRange(int value) {
            return value >= lower && value <= upper;
        }
        
        public boolean inRange(float value) {
            return value >= lower && value <= upper;
        }
        
        public String toString() {
            return "Upper: " + upper + " Lower: " + lower;
        }
    }
    
    public HSVRange(Range h, Range s, Range v) {
        this.h = h;
        this.s = s;
        this.v = v;
    }
    
    public HSVRange(int hLower, int hUpper, int sLower, int sUpper, int vLower, int vUpper) {
        this.h = new Range(hUpper, hLower);
        this.s = new Range(sUpper, sLower);
        this.v = new Range(vUpper, vLower);
    }
    
    public String toString() {
        return "H: " + h.toString() + " S: " + s.toString() + " V: " + v.toString();
    }
}


