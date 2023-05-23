public class Threshhold implements PostFilter{
    final int threshhold;
    
    Threshhold(int threshhold) {
        this.threshhold = threshhold;
    }
    
    public PImage apply(PImage img) {
        PImage result = img.get();
        
        for (int i = 0; i < result.pixels.length; i++) {
            int c = result.pixels[i];
            int r = (int) red(c);
            
            result.pixels[i] = r < threshhold ? 0xFF000000 : 0xFFFFFFFF;
        }
        
        return result;
    }
}