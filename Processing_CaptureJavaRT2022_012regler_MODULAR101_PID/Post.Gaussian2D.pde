public class GaussianFilter2D implements PostFilter{  
    
    private double[][] gaussianKernel;
    private int threshold;
    private int kernelSize;
    
    public GaussianFilter2D(double sigma, int threshold) {
        this.threshold = threshold;
        this.kernelSize = calculateKernelSize(sigma);
        this.gaussianKernel = calculateGaussianKernel(sigma);
    } 
    
    public PImage process(PImage image) {
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
        double[][] kernel = new double[kernelSize][kernelSize];
        
        double sum = 0.0;
        for (int j = -kernelSize / 2; j <= kernelSize / 2; j++) {
            for (int i = -kernelSize / 2; i <= kernelSize / 2; i++) {
                double exponent = -((i * i + j * j) / (2 * sigma * sigma));
                kernel[j + kernelSize / 2][i + kernelSize / 2] = Math.exp(exponent);
                sum += kernel[j + kernelSize / 2][i + kernelSize / 2];
            }
        }
        
        // normalize the kernel so that it sums to 1
        for (int j = 0; j < kernelSize; j++) {
            for (int i = 0; i < kernelSize; i++) {
                kernel[j][i] /= sum;
            }
        }
        
        return kernel;
    }
    
    private int calculateKernelSize(double sigma) {
        return(int) Math.ceil(sigma * 3) * 2 + 1;
    }
    
}