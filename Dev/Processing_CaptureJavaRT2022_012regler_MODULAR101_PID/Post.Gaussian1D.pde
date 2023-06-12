public class GaussianFilter1D implements PostFilter{  
    
    private double[] gaussianKernel;
    private int kernelSize;
    private int halfSize;
    final private ImageBorderAdder borderAdder;
    
    public GaussianFilter1D(int kernelSize, double sigma, BorderType borderType) {
        if (kernelSize % 2 == 0) {
            throw new IllegalArgumentException("kernelSize must be odd");
        }
        
        this.kernelSize = kernelSize;
        this.halfSize = kernelSize / 2;
        
        this.gaussianKernel = calculateGaussianKernel(sigma);
        this.borderAdder = new ImageBorderAdder(borderType);
    } 
    
    public PImage apply(final PImage img) {
        PImage convX = convoluteInX(img);
        return convoluteInY(convX);
    }
    
    private PImage convoluteInX(PImage src) {
        PImage result = src.copy();
        
        PImage imageWithBorder = borderAdder.addBorder(src, halfSize);
        result.loadPixels();
        
        for (int y = 0; y < src.height; y++) {
            for (int x = 0; x < src.width; x++) {
                float sum = 0;
                for (int i = 0; i < kernelSize; i++) {
                    int px = x + i;
                    int py = y + halfSize;
                    
                    int kernelIdx = imageWithBorder.width * py + px;
                    int c = imageWithBorder.pixels[kernelIdx];
                    
                    double weight = gaussianKernel[i];
                    sum += weight * (c >> 16 & 0xFF);
                }
                int idx = src.width * y + x;
                result.pixels[idx] = color(sum);
            }
        }
        return result;
    }
    
    private PImage convoluteInY(PImage src) {
        PImage result = src.copy();
        
        PImage imageWithBorder = borderAdder.addBorder(src, halfSize);
        result.loadPixels();
        
        for (int y = 0; y < src.height; y++) {
            for (int x = 0; x < src.width; x++) {
                float sum = 0;
                for (int i = 0; i < kernelSize; i++) {
                    int px = x + halfSize;
                    int py = y + i;
                    
                    int kernelIdx = imageWithBorder.width * py + px;
                    int c = imageWithBorder.pixels[kernelIdx];
                    
                    double weight = gaussianKernel[i];
                    sum += weight * (c >> 16 & 0xFF);
                }
                int idx = src.width * y + x;
                result.pixels[idx] = color(sum);
            }
        }
        return result;
    }
    
    private double[] calculateGaussianKernel(double sigma) {
        double[] gaussianKernel = new double[kernelSize];
        
        double sum = 0;
        for (int i = 0; i < kernelSize; i++) {
            gaussianKernel[i] = (double) Math.exp( -0.5 * Math.pow((i - halfSize) / sigma, 2)) / (sigma * Math.sqrt(2 * Math.PI));
            sum += gaussianKernel[i];
        }
        
        for (int i = 0; i < kernelSize; i++) {
            gaussianKernel[i] /= sum;
        }
        
        return gaussianKernel;
    }
}