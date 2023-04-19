class Padding implements PostFilter {
    private final int top;
    private final int bottom;
    private final int right;
    private final int left;
    
    public Padding(int top, int bottom, int right, int left) {
        this.top = top;
        this.bottom = bottom;
        this.right = right;
        this.left = left;
    }
    
    public PImage process(PImage image) {
        PImage result = image.copy();
        
        for (int i = 0; i < result.width; i++) {          
            for (int j = 0; j < result.height; j++) {
                if (i < left || i >= result.width - right || j < top || j >= result.height - bottom) {
                    result.pixels[i + j * result.width] = 0;
                }   
            }
        }
        
        return result;
    }
    
}