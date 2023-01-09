public class ColorHSV extends PApplet {

  private OpenCV opencv;
  private int hsvRange[][];
  private PImage maskHS, maskHSV;
  private PImage H, S, V;
  private HashMap<String, int[][]> hsvMap = new HashMap<String, int[][]>()
  {
    {
      put("Red1", new int[][]{{0, 50, 50}, {10, 255, 255}});
      put("Red2", new int[][]{{170, 50, 50}, {180, 255, 255}});
      put("Yellow", new int[][]{{25, 50, 70}, {35, 255, 255}});
      put("Green", new int[][]{{89, 255, 255}, {36, 50, 70}}); // not tested
      put("Blue", new int[][]{{90, 50, 70}, {128, 255, 255}});
    }
  };

  public ColorHSV(String type, PImage img) {
    this.opencv = new OpenCV(this, img);
    opencv.useColor(HSB);

    this.hsvRange = hsvMap.get(type);
  }

  public PImage getMask(PImage img, boolean withColor) {
    opencv.loadImage(img);

    opencv.setGray(opencv.getH().clone());
    opencv.inRange(hsvRange[0][0], hsvRange[1][0]);
    H = opencv.getSnapshot();

    opencv.setGray(opencv.getS().clone());
    opencv.inRange(hsvRange[0][1], hsvRange[1][1]);
    S = opencv.getSnapshot();

    opencv.diff(H);
    opencv.threshold(0);
    opencv.invert();
    maskHS = opencv.getSnapshot();

    opencv.setGray(opencv.getV().clone());
    opencv.inRange(hsvRange[0][2], hsvRange[1][2]);
    V = opencv.getSnapshot();

    opencv.diff(maskHS);
    opencv.threshold(0);
    opencv.invert();
    maskHSV = opencv.getSnapshot();
    if (!withColor) {
      return maskHSV;
    }

    PImage colorMask =createImage(maskHSV.width, maskHSV.height, RGB);

    for (int i = 0; i< maskHSV.width; i++) {
      for (int j=0; j< maskHSV.height; j++) {
        color c = maskHSV.get(i, j);
        color ori = img.get(i, j);
        if (c != -16777216) {
          colorMask.set(i, j, ori);
          continue;
        }
        colorMask.set(i, j, c);
      }
    }
    return colorMask;
  };

  public PImage combineMask(PImage mask2, PImage img) {
    PImage returnMask = createImage(maskHSV.width, maskHSV.height, RGB);
    for (int i = 0; i< maskHSV.width; i++) {
      for (int j=0; j< maskHSV.height; j++) {
        color c = maskHSV.get(i, j);
        color d = mask2.get(i, j);
        color ori = img.get(i, j);
        if (c != -16777216) {
          returnMask.set(i, j, ori);
          continue;
        } else if (d != -16777216) {
          returnMask.set(i, j, ori);
          continue;
        }
        returnMask.set(i, j, d);
      }
    }
    return returnMask;
  }

  public ArrayList<Contour> getContour() {
    return opencv.findContours(true, true);
  }

  public PImage getH() {
    return H;
  }
  public PImage getS() {
    return S;
  }
  public PImage getV() {
    return V;
  }
}