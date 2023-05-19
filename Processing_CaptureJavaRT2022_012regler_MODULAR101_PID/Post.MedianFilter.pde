public class MedianFilter implements PostFilter {
    int kernelSize;
    MedianFilter(int kernelSize) {
        if (kernelSize % 2 == 0) {
            throw new IllegalArgumentException("Kernel size must be odd");
        }
        this.kernelSize = kernelSize;
    }
    
    public PImage apply(PImage image) {
        int width = image.width;
        int height = image.height;
        int radius = kernelSize / 2;
        
        PImage result = createImage(width, height, RGB);        
        int[] pixels = image.pixels.clone();
        
        for (int y = radius; y < height - radius; y++) {
            for (int x = radius; x < width - radius; x++) {
                // Create a window of pixels
                int[] window = new int[kernelSize * kernelSize];
                int index = 0;
                
                for (int j = -radius; j <= radius; j++) {
                    for (int i = -radius; i <= radius; i++) {
                        int pixel = pixels[(y + j) * width + x + i];
                        window[index++] = pixel;
                    }
                }
                
                Arrays.sort(window);
                int median = window[window.length / 2];
                
                result.pixels[y * width + x] = median;
            }
        }
        return result;
    }
}