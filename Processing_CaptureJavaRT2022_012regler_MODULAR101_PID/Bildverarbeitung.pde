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


  public Bildverarbeitung()
  {
  }

  private void computeColor(int [] pix) {
    //println("OKAY");
    int u=0;
    for (int i=0; i<bild.length; i++)
      for (int k=0; k<bild[i].length; k++)
        bild[i][k] = pix[u++];
    u=0;
    for (int i=0; i<bild.length; i++)
    {
      for (int k=0; k<bild[i].length; k++)
      {
        int wert = pix[u];

        // Using "right shift" as a faster technique than red(), green(), and blue()
        int ROT    = (wert  >> 8) & 0xFF;
        int GRUEN  = wert & 0xFF;
        int BLAU   = (wert >> 16) & 0xFF;

        bildR[i][k] = 2*ROT - GRUEN - BLAU + ANHEBUNG;
        if (bildR[i][k]<0) bildR[i][k]=-bildR[i][k];
        else bildR[i][k]=0;
        bildG[i][k] = 2*GRUEN - BLAU - ROT + ANHEBUNG;
        if (bildG[i][k]<0) bildG[i][k]=-bildG[i][k];
        else bildG[i][k]=0;
        bildB[i][k] = 2*BLAU - ROT - GRUEN + 35;
        if (bildB[i][k]<0) bildB[i][k]=-bildB[i][k];
        else bildB[i][k]=0;
        
        // Yellow = 50% R and 50% G
        int avg = (ROT + GRUEN)/2;
        bildY[i][k] = avg;

        u++;
      }
    }
  }

  //only when extracting non RGB
  
  public void extractColorRGB(IPCapture cam)
  {
    if (cam.isAvailable())
    {
      cam.read();
      //image(cam,0,0);
      cam.updatePixels();
      int[] pix = cam.pixels;
      if (pix!=null)
      {
        computeColor(pix);
      }
    }
  }

  // HSV Method
  public void extractColorHSV(PImage cam)
  {
    int[] pix = cam.pixels;
    if (pix!=null)
    {
      computeColor(pix);
    }
  }

  public int[][] getRed() {
    return bildR;
  }

  public int[][] getBlue() {
    return bildG;
  }

  public int[][] getGreen() {
    return bildB;
  }

  public int[][] getYellow() {
    return bildY;
  }
}
