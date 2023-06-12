public class HSVFilter  {
    private final int MAX_HUE = 180;
    private final int MAX_SATURATION = 255;
    private final int MAX_VALUE = 255;
    
    public HSVFilter() {     
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
