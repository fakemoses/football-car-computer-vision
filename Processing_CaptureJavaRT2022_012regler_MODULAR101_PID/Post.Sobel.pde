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
    
    public PImage process(PImage image) {
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