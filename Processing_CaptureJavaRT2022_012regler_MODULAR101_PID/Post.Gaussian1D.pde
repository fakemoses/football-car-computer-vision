public class GaussianFilter1D implements PostFilter{  
    
    private double[] gaussianKernel;
    private int threshold;
    private int kernelSize;
    private int halfSize;
    
    public GaussianFilter1D(double sigma, int threshold) {
        this.threshold = threshold;
        this.kernelSize = calculateKernelSize(sigma);
        this.gaussianKernel = calculateGaussianKernel(sigma);
    } 
    
    public PImage process(PImage img) {
        // Copy the input image into a new output image
        PImage output = img.copy();
        
        // Apply the gaussianKernel in the x-direction
        PImage temp = createImage(img.width, img.height, ALPHA);
        temp.loadPixels();
        
        for (int y = 0; y < img.height; y++) {
            for (int x = halfSize; x < img.width - halfSize; x++) {
                float sumR = 0, sumG = 0, sumB = 0, sumA = 0;
                for (int i = 0; i < kernelSize; i++) {
                    int idx = img.width * y + x - halfSize + i;
                    int c = img.pixels[idx];
                    double w = gaussianKernel[i];
                    sumR += w * red(c);
                    sumG += w * green(c);
                    sumB += w * blue(c);
                    sumA += w * alpha(c);
                }
                int idx = img.width * y + x;
                temp.pixels[idx] = color(sumR, sumG, sumB, sumA);
            }
        }
        
        // Apply the gaussianKernel in the y-direction
        for (int y = halfSize; y < img.height - halfSize; y++) {
            for (int x = 0; x < img.width; x++) {
                float sumR = 0, sumG = 0, sumB = 0, sumA = 0;
                for (int i = 0; i < kernelSize; i++) {
                    int idx = img.width * (y - halfSize + i) + x;
                    int c = temp.pixels[idx];
                    double w = gaussianKernel[i];
                    sumR += w * red(c);
                    sumG += w * green(c);
                    sumB += w * blue(c);
                    sumA += w * alpha(c);
                }
                int idx = img.width * y + x;
                
                // Threshold the alpha channel
                color res;
                if (sumA < threshold) {
                    res = color(0, 0, 0, 0);
                } else {
                    res = color(255, 255, 255, 255);
                }
                output.pixels[idx] = res;
            }
        }
        
        output.updatePixels();
        return output;
    }
    
    private double[] calculateGaussianKernel(double sigma) {
        this.kernelSize = calculateKernelSize(sigma);
        this.halfSize = kernelSize / 2;
        double[] gaussianKernel = new double[kernelSize];
        float sum = 0;
        for (int i = 0; i < kernelSize; i++) {
            gaussianKernel[i] = (float) Math.exp( -0.5 * Math.pow((i - halfSize) / sigma, 2));
            sum += gaussianKernel[i];
        }
        // Normalize the gaussianKernel
        for (int i = 0; i < kernelSize; i++) {
            gaussianKernel[i] /= sum;
        }
        return gaussianKernel;
    }
    
    private int calculateKernelSize(double sigma) {
        return(int) Math.ceil(sigma * 3) * 2 + 1;
    }
    
}