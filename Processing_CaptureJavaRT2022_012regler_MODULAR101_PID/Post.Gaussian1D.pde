public class GaussianFilter1D implements PostFilter{  
    
    private double[] gaussianKernel;
    private int threshold;
    private int kernelSize;
    private int halfSize;
    
    public GaussianFilter1D(double sigma, int threshold) {
        this.threshold = threshold;
        this.gaussianKernel = calculateGaussianKernel(sigma);
    } 
    
    public PImage process(PImage img) {
        PImage convX = convoluteInX(img);
        return convoluteInYWithThreshhold(convX, img);
    }
    
    private PImage convoluteInX(PImage img) {
        PImage returnImage = createImage(img.width, img.height, ALPHA);
        returnImage.loadPixels();
        
        for (int y = 0; y < img.height; y++) {
            for (int x = halfSize; x < img.width - halfSize; x++) {
                float sumR = 0;
                for (int i = 0; i < kernelSize; i++) {
                    int kernelIdx = img.width * y + x - halfSize + i;
                    int c = img.pixels[kernelIdx];
                    double weight = gaussianKernel[i];
                    sumR += weight * (c >> 16 & 0xFF);
                }
                int idx = img.width * y + x;
                returnImage.pixels[idx] = color(sumR);
            }
        }
        return returnImage;
    }
    
    private PImage convoluteInY(PImage img) {
        PImage returnImage = createImage(img.width, img.height, ALPHA);
        returnImage.loadPixels();
        
        for (int y = halfSize; y < img.height - halfSize; y++) {
            for (int x = 0; x < img.width; x++) {
                float sumR = 0, sumG = 0, sumB = 0, sumA = 0;
                for (int i = 0; i < kernelSize; i++) {
                    int kernelIdx = img.width * (y - halfSize + i) + x;
                    int c = img.pixels[kernelIdx];
                    double weight = gaussianKernel[i];
                    sumR += weight * (c >> 16 & 0xFF);
                }
                int idx = img.width * y + x;
                returnImage.pixels[idx] = color(sumR);
            }
        }
        return returnImage;
    }
    
    private PImage convoluteInYWithThreshhold(PImage img, PImage src) {
        PImage returnImage = src.copy();
        returnImage.loadPixels();
        for (int y = halfSize; y < img.height - halfSize; y++) {
            for (int x = 0; x < img.width; x++) {
                float sumR = 0;
                for (int i = 0; i < kernelSize; i++) {
                    int kernelIdx = img.width * (y - halfSize + i) + x;
                    int c = img.pixels[kernelIdx];
                    double weight = gaussianKernel[i];
                    sumR += weight * (c >> 16 & 0xFF);
                }
                int idx = img.width * y + x;
                returnImage.pixels[idx] = sumR > threshold ? 0xFFFFFFFF : 0xFF000000;
            }
        }
        return returnImage;
    }
    
    private double[] calculateGaussianKernel(double sigma) {
        this.kernelSize = calculateKernelSize(sigma);
        this.halfSize = kernelSize / 2;
        double[] gaussianKernel = new double[kernelSize];
        
        double sum = 0;
        for (int i = 0; i < kernelSize; i++) {
            gaussianKernel[i] = (double) Math.exp( -0.5 * Math.pow((i - halfSize) / sigma, 2));
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