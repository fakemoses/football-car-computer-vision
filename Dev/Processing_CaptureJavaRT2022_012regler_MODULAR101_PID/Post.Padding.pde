class Padding implements PostFilter {
    private final int startX;
    private final int startY;
    private final int w;
    private final int h;
    
    public Padding(int startX, int startY, int w, int h) {
        this.startX = startX;
        this.startY = startY;
        this.w = w;
        this.h = h;
    }
    
    public PImage apply(PImage image) {
        PImage result = image.copy();
        
        for (int i = 0; i < result.width; i++) {          
            for (int j = 0; j < result.height; j++) {
                if (j < startY) {
                    continue;
                }
                if (j > startY + h) {
                    continue;
                }
                if (i < startX) {
                    continue;
                }
                if (i > startX + w) {
                    continue;
                }
                result.pixels[i + j * result.width] = 0xFF000000;
            }
        }
        
        return result;
    } 
}