public class GetColors {

  int[][] bild = new int[240][320];
  int[][] bildR = new int[240][320];
  int[][] bildG = new int[240][320];
  int[][] bildB = new int[240][320];
  int[][] bildY = new int[240][320];
  int ANHEBUNG = 30;

  public GetColors() {
    //maybe init with image
  }

  public void extractColor(PImage img) {
    int[] pix = img.pixels;
    if (pix!=null)
    {
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
          int ROT    = (wert  >> 8) & 0xFF;
          int GRUEN  = wert & 0xFF;
          int BLAU   = (wert >> 16) & 0xFF;
          
         
          bildR[i][k] = 2*ROT - GRUEN - BLAU + ANHEBUNG;
          if (bildR[i][k]<0) bildR[i][k]=-bildR[i][k];
          else bildR[i][k]=0;
          bildG[i][k] = 2*GRUEN - BLAU - ROT + ANHEBUNG;
          if (bildG[i][k]<0) bildG[i][k]=-bildG[i][k];
          else bildG[i][k]=0;
          bildB[i][k] = 2*BLAU - ROT - GRUEN + ANHEBUNG;
          if (bildB[i][k]<0) bildB[i][k]=-bildB[i][k];
          else bildB[i][k]=0;

          int avg = (ROT + GRUEN)/2;
          bildY[i][k] = avg;

          u++;
        }
      }
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
