public class GaussianFilter2D implements PostFilter{  
    
    private double[][] gaussianKernel;
    private int kernelSize;
    private int halfSize;
    final private ImageBorderAdder borderAdder;
    
    public GaussianFilter2D(int kernelSize, double sigma, BorderType borderType) {
        if (kernelSize % 2 == 0) {
            throw new IllegalArgumentException("kernelSize must be odd");
        }
        
        this.kernelSize = kernelSize;
        this.halfSize = kernelSize / 2;
        
        this.gaussianKernel = calculateGaussianKernel(sigma);
        this.borderAdder = new ImageBorderAdder(borderType);
    } 
    
    public PImage apply(final PImage image) {
        return conv2D(image);
    }
    
    private PImage conv2D(PImage src) {
        PImage result = src.copy();
        
        PImage imageWithBorder = borderAdder.addBorder(src, halfSize);
        result.loadPixels();
        
        // iterate over each pixel in the image
        for (int y = 0; y < src.height; y++) {
            for (int x = 0; x < src.width; x++) {
                float sum = 0.0;
                
                // Expensive computation, O(n^2)
                // Alternative: Use GaussianFilter1D instead
                // Result should be the same ?
                // slightly different results, due to floating point precision
                for (int j = 0; j < kernelSize; j++) {
                    for (int i = 0; i < kernelSize; i++) {
                        int px = x + i;
                        int py = y + j;
                        
                        int kernelIdx = imageWithBorder.width * py + px;
                        int c = imageWithBorder.pixels[kernelIdx];
                        
                        double weight = gaussianKernel[j][i];
                        sum += weight * (c >> 16 & 0xFF);
                    }
                }
                int idx = src.width * y + x;
                result.pixels[idx] = color(sum);
            }
        }      
        return result;
    }
    
    private double[][] calculateGaussianKernel(double sigma) {        
        double[][] gaussianKernel = new double[kernelSize][kernelSize];
        
        double sum = 0;
        
        for (int j = 0; j < kernelSize; j++) {
            for (int i = 0; i < kernelSize; i++) {
                double exponent = (double) Math.exp( -0.5 * ((Math.pow((i - halfSize), 2.0) + Math.pow((j - halfSize), 2.0)) / Math.pow(sigma,2.0))) / (2 * Math.PI * sigma * sigma);
                
                // double exponent = -0.5 * (Math.pow((i - halfSize) / sigma, 2.0) + Math.pow((j - halfSize) / sigma, 2.0));
                gaussianKernel[j][i] = exponent;
                sum += gaussianKernel[j][i];
            }
        }
        
        // normalize the kernel so that it sums to 1
        for (int j = 0; j < kernelSize; j++) {
            for (int i = 0; i < kernelSize; i++) {
                gaussianKernel[j][i] /= sum;
            }
        }
        
        return gaussianKernel;
    }  
}