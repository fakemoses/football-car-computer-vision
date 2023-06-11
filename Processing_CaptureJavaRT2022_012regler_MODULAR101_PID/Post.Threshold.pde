public class Threshold implements PostFilter{
    final int threshold;
    
    Threshold(int threshold) {
        this.threshold = threshold;
    }
    
    public PImage apply(PImage img) {
        PImage result = img.get();
        
        for (int i = 0; i < result.pixels.length; i++) {
            int c = result.pixels[i];
            int r = (int) red(c);
            
            result.pixels[i] = r < threshold ? 0xFF000000 : 0xFFFFFFFF;
        }
        
        return result;
    }
}