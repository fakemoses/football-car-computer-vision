public class Bildverarbeitung
{
  int[][] bild = new int[240][320];
  int[][] bildOut = new int[240][320];
  int[][] bildR = new int[240][320];
  int[][] bildG = new int[240][320];
  int[][] bildB = new int[240][320];
  int[][] bildY = new int[240][320];
  int ANHEBUNG = 30;

  private IPCapture cam;
  public Bildverarbeitung(IPCapture cam)
  {
    this.cam = cam;
  }

  public int[][] holeFarbeBild(String col)
  {
    if (cam.isAvailable())
    {
      cam.read();
      //image(cam,0,0);
      cam.updatePixels();
      int[] pix = cam.pixels;
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

            u++;
          }
        }
      }
    }

    if (col == "ROT")
      bildOut = bildR;
    if (col == "GRUEN")
      bildOut = bildG;
    if (col == "BLAU")
      bildOut = bildB;


    return bildOut;
  }


  public int [][] holeBildHSV() {
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
        
        
        colorMode(HSB, 360, 100, 100);

        for (int i = 0; i < cam.pixels.length; i++) {
          float h = hue(cam.pixels[i]);
          float s = saturation(cam.pixels[i]);
          float v = brightness(cam.pixels[i]);
          cam.pixels[i] = color(h, s, v);
        }

        // Set the range of hue values for yellow (60-90 degrees)
        int minHue = 0; //60
        int maxHue = 30; // 90

        // Set the threshold values for saturation and value
        int minSat = 10;
        int minVal = 10;

        // Extract the yellow pixels from the image
        for (int x = 0; x < cam.width; x++) {
          for (int y = 0; y < cam.height; y++) {
            int i = x + y * cam.width;
            float h = hue(cam.pixels[i]);
            float s = saturation(cam.pixels[i]);
            float v = brightness(cam.pixels[i]);
            
            if (h >= minHue && h <= maxHue && s >= minSat && v >= minVal) {
              bildY[y][x] = cam.pixels[i]; // save the pixel value in the result array
            } else {
              bildY[y][x] = 0; // set the pixel to black
            }
          }
        }
        //back to RGB just incase
        colorMode(RGB, 255, 255, 255);
      }
    }
    
    return bildY;
  }
}
