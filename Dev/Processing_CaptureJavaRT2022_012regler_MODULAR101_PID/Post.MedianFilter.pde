public class MedianFilter implements PostFilter {
    final int kernelSize;
    final int halfSize;
    final ImageBorderAdder borderAdder;
    
    MedianFilter(int kernelSize, BorderType borderType) {
        if (kernelSize % 2 == 0) {
            throw new IllegalArgumentException("Kernel size must be odd");
        }
        this.kernelSize = kernelSize;
        this.halfSize = kernelSize / 2;
        
        this.borderAdder = new ImageBorderAdder(borderType);
    }
    
    public PImage apply(final PImage image) {        
        PImage result = image.copy();      
        
        PImage imageWithBorder = borderAdder.addBorder(result, halfSize);
        result.loadPixels();
        
        for (int y = 0; y < image.height; y++) {
            for (int x = 0; x < image.width; x++) {
                
                int[] kernel = new int[kernelSize * kernelSize];
                int index = 0;
                
                for (int j = 0; j < kernelSize; j++) {
                    for (int i = 0; i < kernelSize; i++) {
                        int px = x + i;
                        int py = y + j;
                        
                        int kernelIdx = imageWithBorder.width * py + px;
                        int pixelValue = imageWithBorder.pixels[kernelIdx];
                        
                        kernel[index++] = pixelValue;
                    }
                }
                
                Arrays.sort(kernel);
                int median = kernel[kernel.length / 2];
                
                int idx = image.width * y + x;
                result.pixels[idx] = median;
            }
        }
        return result;
    }
}