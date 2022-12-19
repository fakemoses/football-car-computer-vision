public class Filtering {

  private IPCapture cam;

  int[][] bild = new int[240][320];
  int[][] bildPost = new int[240][320];
  int ANHEBUNG = 30;

  public Filtering(IPCapture cam) {
    this.cam = cam;
  }

  public int[][] filterColor(int r, int g, int b) {
    int rF, gF, bF = 0;
    //faktor in int berechnen
    rF = (r/255) * 100;
    gF = (g/255) * 100;
    bF = (b/255) * 100;
    
    if (cam.isAvailable())
    {
      cam.read();
      //image(cam,0,0);
      cam.updatePixels();
      int[] pix = cam.pixels;
      if (pix!=null)
      {
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

            bildPost[i][k] = rF*ROT - gF*GRUEN - bF*BLAU + ANHEBUNG;
            if (bildPost[i][k]<0) bildPost[i][k]=-bildPost[i][k];
            else bildPost[i][k]=0;

            u++;
          }
        }
      }
    }

  

    return bildPost; //ROTES Bild zeigen
  }
}
