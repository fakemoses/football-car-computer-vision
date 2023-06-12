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
                gaussianKernel[j][i] = (double) Math.exp( -0.5 * ((Math.pow((i - halfSize), 2.0) + Math.pow((j - halfSize), 2.0)) / Math.pow(sigma, 2.0))) / (2 * Math.PI * sigma * sigma);
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

public enum KERNEL_TYPE {
    SOBEL_3x3(new int[][] {
        { - 1, 0, 1} ,
        { - 2, 0, 2} ,
        { - 1, 0, 1} 
    }),
    SOBEL_5x5(new int[][] {
        { - 1, -2, 0, 2, 1} ,
        { - 4, -8, 0, 8, 4} ,
        { - 6, -12, 0, 12, 6} ,
        { - 4, -8, 0, 8, 4} ,
        { - 1, -2, 0, 2, 1}
    }),
    SCHARR_3x3(new int[][] {
        { 47, 0, -47} ,
        {162, 0, -162} ,
        {47, 0, -47} 
    });
    
    private final int[][] kernel;
    private final int[][] kernelX;
    private final int[][] kernelY;
    
    private KERNEL_TYPE(int[][] kernel) {
        this.kernel = kernel;
        
        int size = kernel.length;
        this.kernelX = new int[size][size];
        this.kernelY = new int[size][size];
        
        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size; j++) {
                kernelX[i][j] = kernel[size - 1 - j][i];
                kernelY[i][j] = kernel[size - 1 - i][size - 1 - j];
            }
        }
    }
    
    public int[][] getKernel() {
        return kernel;
    }
    
    public int[][] getKernelX() {
        return kernelX;
    }
    
    public int[][] getKernelY() {
        return kernelY;
    }
    
    public int getKernelSize() {
        return kernel.length;
    }
}


public class Sobel implements PostFilter {
    // https://de.wikipedia.org/wiki/Sobel-Operator
    
    private final int[][] kernelX;
    private final int[][] kernelY;
    
    private final int lowThreshold;
    private final int highThreshold;
    
    private final int halfLength;
    
    public Sobel(KERNEL_TYPE kernelType, int lowThreshold, int highThreshold) {
        this.kernelX = kernelType.getKernelX();
        this.kernelY = kernelType.getKernelY();
        this.lowThreshold = lowThreshold;
        this.highThreshold = highThreshold;
        
        halfLength = kernelX.length / 2;
    }
    
    public PImage apply(PImage image) {
        int width = image.width;
        int height = image.height;
        
        int[][] magnitude = new int[height][width];
        int[][] orientation = new int[height][width];
        
        for (int y = halfLength; y < height - halfLength; y++) {
            for (int x = halfLength; x < width - halfLength; x++) {
                int gx = 0;
                int gy = 0;
                
                for (int j = -halfLength; j <= halfLength; j++) {
                    for (int i = -halfLength; i <= halfLength; i++) {
                        int pixel = image.pixels[(y + j) * width + x + i] & 0xff;
                        gx += kernelX[j + halfLength][i + halfLength] * pixel;
                        gy += kernelY[j + halfLength][i + halfLength] * pixel;
                    }
                }
                
                magnitude[y][x] = (int) Math.sqrt(gx * gx + gy * gy);
                orientation[y][x] = (int) Math.atan2(gy, gx);
            }
        }
        
        return hysteresis(image, magnitude, orientation);
    }
    
    private PImage hysteresis(PImage image, int[][] magnitude, int[][] orientation) {
        int width = image.width;
        int height = image.height;
        
        PImage hystResult = new PImage(width, height);
        
        for (int y = 1; y < height - 1; y++) {
            for (int x = 1; x < width - 1; x++) {
                int mag = magnitude[y][x];
                if (mag < lowThreshold) {
                    hystResult.pixels[y * width + x] = color(0);
                } else if (mag > highThreshold) {
                    hystResult.pixels[y * width + x] = color(255);
                } else {
                    // Check if at least one neighbor has high gradient magnitude
                    boolean hasHighNeighbor = false;
                    for (int j = -1; j <= 1; j++) {
                        for (int i = -1; i <= 1; i++) {
                            int neighborMag = magnitude[y + j][x + i];
                            int neighborOrientation = orientation[y + j][x + i];
                            if (neighborMag > highThreshold && 
                               (orientation[y][x] - neighborOrientation) % 180 <= 45) {
                                hasHighNeighbor = true;
                                break;
                            }
                        }
                        if (hasHighNeighbor) {
                            break;
                        }
                    }
                    hystResult.pixels[y * width + x] = hasHighNeighbor ? color(255) : color(0);
                }
            }
        }
        
        hystResult.updatePixels();
        return hystResult;
    }
}

public class Threshold implements PostFilter{
    final int threshold;
    
    Threshold(int threshold) {
        this.threshold = threshold;
    }
    
    public PImage apply(PImage img) {
        PImage result = img.get();
        
        for (int i = 0; i < result.pixels.length; i++) {
            int c = result.pixels[i];
            int r = (int) red(c);
            
            result.pixels[i] = r < threshold ? 0xFF000000 : 0xFFFFFFFF;
        }
        
        return result;
    }
}
