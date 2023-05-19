public class GaussianFilter2D implements PostFilter{  
    
    private double[][] gaussianKernel;
    private int threshold;
    private int kernelSize;
    private int halfSize;
    
    public GaussianFilter2D(double sigma, int threshold) {
        this.threshold = threshold;
        this.gaussianKernel = calculateGaussianKernel(sigma);
    } 
    
    public PImage apply(PImage image) {
        int w = image.width;
        int h = image.height;
        PImage result = createImage(w, h, RGB);
        
        // iterate over each pixel in the image
        for (int y = 0; y < h; y++) {
            for (int x = 0; x < w; x++) {
                double sum = 0.0;
                double weightSum = 0.0;
                
                // iterate over each pixel in the kernel
                for (int j = -gaussianKernel.length / 2; j <= gaussianKernel.length / 2; j++) {
                    for (int i = -gaussianKernel[0].length / 2; i <= gaussianKernel[0].length / 2; i++) {
                        int px = x + i;
                        int py = y + j;
                        
                        // check if the pixel is inside the image
                        // Expensive computation, O(n^2)
                        // Alternative: Use GaussianFilter1D instead
                        // Does it differ ?
                        if (px >= 0 && py >= 0 && px < w && py < h) {
                            // get the pixel value and weight from the kernel
                            double pixelValue = brightness(image.pixels[py * w + px]);
                            double weight = gaussianKernel[j + gaussianKernel.length / 2][i + gaussianKernel[0].length / 2];
                            
                            // accumulate the sum and weight sum
                            sum += pixelValue * weight;
                            weightSum += weight;
                        }
                    }
                }
                
                // calculate the new pixel value as the weighted average
                int newValue = (int)(sum / weightSum);
                result.pixels[y * w + x] = color(newValue);
            }
        }
        
        result.updatePixels();
        return result;
    }
    
    private double[][] calculateGaussianKernel(double sigma) {
        this.kernelSize = calculateKernelSize(sigma);
        this.halfSize = kernelSize / 2;
        
        double[][] gaussianKernel = new double[kernelSize][kernelSize];
        
        double sum = 0;
        
        for (int j = 0; j < kernelSize; j++) {
            for (int i = 0; i < kernelSize; i++) {
                double exponent = -0.5 * (Math.pow((i - halfSize) / sigma, 2.0) + Math.pow((j - halfSize) / sigma, 2.0));
                gaussianKernel[j][i] = Math.exp(exponent);
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
    
    private int calculateKernelSize(double sigma) {
        return(int) Math.ceil(sigma * 3) * 2 + 1;
    }
    
}