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
