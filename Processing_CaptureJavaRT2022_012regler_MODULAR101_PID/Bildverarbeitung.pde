public class Bildverarbeitung
{
    int[][] bild;
    int[][] bildR;
    int[][] bildG;
    int[][] bildB;
    
    PImage redMask;
    PImage greenMask;
    PImage blueMask;
    final int ANHEBUNG = 30;
    
    private ArrayList<Point> redList = new ArrayList<Point>();
    
    public Bildverarbeitung(int width, int height) {
        bild = new int[height][width];
        bildR = new int[height][width];
        bildG = new int[height][width];
        bildB = new int[height][width];
        
        redMask = new PImage(width, height, ALPHA);
        greenMask = new PImage(width, height, ALPHA);
        blueMask = new PImage(width, height, ALPHA);
    }
    
    private void computeColor(int[] pix) {
        redList.clear();
        int[] redpix = redMask.pixels;
        int[] bluepix = blueMask.pixels;
        // int[] greenpix = greenMask.pixels;
        
        int u = 0;
        for (int i = 0; i < bild.length; i++) {
            for (int k = 0; k < bild[i].length; k++) {
                int wert = pix[u];
                
                // Using"right shift" as a faster technique than red(), green(), and blue()
                int ROT = (wert  >> 8) & 0xFF;
                int GRUEN  = wert & 0xFF;
                int BLAU = (wert >> 16) & 0xFF;
                
                bildR[i][k] = 2 * ROT - GRUEN - BLAU + ANHEBUNG;
                if (bildR[i][k] < 0) {
                    bildR[i][k] =-  bildR[i][k];
                    redpix[u] = color(0xFF);
                    redList.add(new Point(k, i));
                } else {
                    bildR[i][k] = 0;
                    redpix[u] = color(0x00);
                }
                
                bildG[i][k] = 2 * GRUEN - BLAU - ROT + ANHEBUNG;
                if (bildG[i][k] < 0) {
                    bildG[i][k] =-  bildG[i][k];
                    // greenpix[u] = color(0xFF);
                } else {
                    bildG[i][k] = 0;
                    // greenpix[u] = color(0x00);
                }
                
                bildB[i][k] = 2 * BLAU - ROT - GRUEN + 35;
                if (bildB[i][k] < 0) {
                    bildB[i][k] =-  bildB[i][k];
                    bluepix[u] = color(0xFF);
                } else {
                    bildB[i][k] = 0;
                    bluepix[u] = color(0x00);
                }
                
                u++;
            }
        }
        redMask.updatePixels();
        blueMask.updatePixels();
        // greenMask.updatePixels();
    }
    
    public void extractColorRGB(IPCapture cam) {
        if (cam.isAvailable()) {
            cam.read();
            cam.updatePixels();
            int[] pix = cam.pixels;
            if (pix != null) {
                computeColor(pix);
            }
        }
    }
    
    public int[][] getRed() {
        return bildR;
    }
    
    public int[][] getBlue() {
        return bildB;
    }
    
    public int[][] getGreen() {
        return bildG;
    }
    
    public PImage getCameraImage() {
        return cam;
    }
    
    public PImage getRedMask() {
        return redMask;
    }
    
    public PImage getBlueMask() {
        return blueMask;
    }
    
    public PImage getGreenMask() {
        return greenMask;
    }
    
    public ArrayList<Point> getRedList() {
        return redList;
    }
}
