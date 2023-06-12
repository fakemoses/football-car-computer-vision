public enum BorderType {
    BLACK, REFLECT, REPLICATE
}

// Utility class for adding borders to images
// Used with ImageProcessing involving convolution / kernels
public class ImageBorderAdder {
    final private BorderType borderType;
    
    
    
    public ImageBorderAdder(BorderType borderType) {
        this.borderType = borderType; 
    }
    
    public PImage addBorder(PImage img, int borderSize) {        
        if (borderType == BorderType.REFLECT) {
            return addReflectBorder(img, borderSize);
        } 
        
        if (borderType == BorderType.REPLICATE) {
            return addReplicateBorder(img, borderSize);
        }      
        
        // default
        return addBlackBorder(img, borderSize);
    }
    
    
    private PImage addBlackBorder(PImage img, int borderSize) {
        PImage result = createImage(img.width + borderSize * 2, img.height + borderSize * 2, RGB);
        result.loadPixels();
        img.loadPixels();
        for (int x = 0; x < result.width; x++) {
            for (int y = 0; y < result.height; y++) {
                if (x < borderSize || x >= result.width - borderSize || y < borderSize || y >= result.height - borderSize) {
                    result.pixels[x + y * result.width] = color(0, 0, 0);
                } else{
                    result.pixels[x + y * result.width] = img.pixels[(x - borderSize) + (y - borderSize) * img.width];
                }
            }
        }
        result.updatePixels();
        return result;
    }
    
    private PImage addReflectBorder(PImage img, int borderSize) {
        PImage result = createImage(img.width + borderSize * 2, img.height + borderSize * 2, RGB);
        result.loadPixels();
        img.loadPixels();
        for (int x = 0; x < result.width; x++) {
            for (int y = 0; y < result.height; y++) {
                if (x < borderSize || x >= result.width - borderSize || y < borderSize || y >= result.height - borderSize) {
                    int x1 = x - borderSize;
                    int y1 = y - borderSize;
                    if (x1 < 0) {
                        x1 = -x1;
                    }
                    if (y1 < 0) {
                        y1 = -y1;
                    }
                    if (x1 >= img.width) {
                        x1 = img.width - (x1 - img.width) - 1;
                    }
                    if (y1 >= img.height) {
                        y1 = img.height - (y1 - img.height) - 1;
                    }
                    result.pixels[x + y * result.width] = img.pixels[x1 + y1 * img.width];
                } else {
                    result.pixels[x + y * result.width] = img.pixels[(x - borderSize) + (y - borderSize) * img.width];
                }
            }
        }   
        result.updatePixels();
        return result;
    }
    
    private PImage addReplicateBorder(PImage img, int borderSize) {
        PImage result = createImage(img.width + borderSize * 2, img.height + borderSize * 2, RGB);
        result.loadPixels();
        img.loadPixels();
        
        for (int x = 0; x < result.width; x++) {
            for (int y = 0; y < result.height; y++) {
                if (x < borderSize || x >= result.width - borderSize || y < borderSize || y >= result.height - borderSize) {
                    int x1 = x - borderSize;
                    int y1 = y - borderSize;
                    
                    if (x1 < 0) {
                        x1 = 0;
                    } else if (x1 >= img.width) {
                        x1 = img.width - 1;
                    }
                    
                    if (y1 < 0) {
                        y1 = 0;
                    } else if (y1 >= img.height) {
                        y1 = img.height - 1;
                    }
                    
                    result.pixels[x + y * result.width] = img.pixels[x1 + y1 * img.width];
                } else {
                    result.pixels[x + y * result.width] = img.pixels[(x - borderSize) + (y - borderSize) * img.width];
                }
            }
        }
        
        result.updatePixels();
        return result;
    }
}