import gab.opencv.*;

public class Bildverarbeitung
{
    int[][] bild = new int[240][320];
    int[][] bildOut = new int[240][320];
    int[][] bildR = new int[240][320];
    int[][] bildG = new int[240][320];
    int[][] bildB = new int[240][320];
    int[][] bildY = new int[240][320];
    int ANHEBUNG = 30;
    
    private ArrayList<Point> redList = new ArrayList<Point>();
    
    public Bildverarbeitung()
        {
    }
    
    private void computeColor(int[] pix) {
        //println("OKAY");
        int u = 0;
        for (int i = 0; i < bild.length; i++)
            for (int k = 0; k < bild[i].length; k++)
                bild[i][k] = pix[u++];
        u = 0;
        for (int i = 0; i < bild.length; i++)
            {
            for (int k = 0; k < bild[i].length; k++)
                {
                int wert = pix[u];
                
                // Using"right shift" as a faster technique than red(), green(), and blue()
                int ROT = (wert  >> 8) & 0xFF;
                int GRUEN  = wert & 0xFF;
                int BLAU = (wert >> 16) & 0xFF;
                
                bildR[i][k] = 2 * ROT - GRUEN - BLAU + ANHEBUNG;
                if (bildR[i][k] < 0) bildR[i][k] =-  bildR[i][k];
                else bildR[i][k] = 0;
                bildG[i][k] = 2 * GRUEN - BLAU - ROT + ANHEBUNG;
                if (bildG[i][k] < 0) bildG[i][k] =-  bildG[i][k];
                else bildG[i][k] = 0;
                bildB[i][k] = 2 * BLAU - ROT - GRUEN + 35;
                if (bildB[i][k] < 0) bildB[i][k] =-  bildB[i][k];
                else bildB[i][k] = 0;
                
                // Yellow = 50% R and 50% G
                int avg = (ROT + GRUEN) / 2;
                bildY[i][k] = avg;
                
                u++;
            }
        }
    }
    
    //only when extracting non RGB
    
    public void extractColorRGB(IPCapture cam)
        {
        if (cam.isAvailable()) {
            cam.read();
            // image(cam,0,0);
            cam.updatePixels();
            int[] pix = cam.pixels;
            if (pix!= null)
                {
                computeColor(pix);
            }
        }
    }
    
    //HSV Method
    public void extractColorHSV(PImage cam)
        {
        int[] pix = cam.pixels;
        if (pix!= null)
            {
            computeColor(pix);
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
    
    public int[][] getYellow() {
        return bildY;
    }
    
    
    // temp
    public PImage toPImage(int[][] b) {
        resetList();
        PImage mask = new PImage(b[0].length, b.length);
        int pixMask[] = mask.pixels;
        int max = 0;
        // int max = 20;
        // convert back to PImage
        int u = 0;
        for (int i = 0; i < b.length; i++)
        {
            for (int k = 0; k < b[i].length; k++)
            {
                // set to max white if value is above threshold
                if (b[i][k] > max) {
                    b[i][k] = 255;
                    redList.add(new Point(k, i));
                    // redList.add(new Point(i, k));
                }
                else{b[i][k] = 0;}
                pixMask[u] = color(b[i][k], b[i][k], b[i][k]);
                u++;
            }
        }
        mask.updatePixels();
        return mask;
    }
    
    //temp
    public PImage getCameraImage() {
        return cam;
    }
    
    //temp
    public PImage getRedMask() {
        return toPImage(bildR);
    }
    
    //temp
    public PImage getBlueMask() {
        return toPImage(bildB);
    }
    
    //temp
    public PImage getGreenMask() {
        return toPImage(bildG);
    }
    
    //temp
    public PImage getYellowMask() {
        return toPImage(bildY);
    }
    
    //temp
    private void resetList() {
        redList = new ArrayList<Point>();
    }
    
    //temp 
    public ArrayList<Point> getRedList() {
        return redList;
    }
}
