package ipcapture2;

import processing.core.PImage;

public abstract class FrameBuffer {
  public abstract boolean isValid();
  public abstract int getWidth();
  public abstract int getHeight();
  public abstract void writePixels(int[] pixels, int w, int h);
  
  public void toPImage(PImage img) {
	if (!isValid()) return;
	int w = getWidth();
	int h = getHeight();
	if (w <= 0 || h <= 0) return;
	if (w != img.width || h != img.height) {
	  System.out.println("Frame resize: from " + img.width + "x" + img.height + " to " + w + "x" + h);
	  img.init(w, h, PImage.RGB); 
    }
    img.loadPixels();
    writePixels(img.pixels, w, h);
	img.updatePixels();
  }
}