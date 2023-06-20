package ipcapture2;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;

public class JavaFrameBuffer extends FrameBuffer {
  BufferedImage buffer;
  
  public JavaFrameBuffer(ByteArrayInputStream in) {
	try {
	  this.buffer = ImageIO.read(in);
	}
	catch (Exception e) {
	  buffer = null;
	}
  }
  
  public boolean isValid() {
	return buffer != null;
  }
  
  public int getWidth() {
	return buffer.getWidth();
  }
  
  public int getHeight() {
	return buffer.getHeight();
  }
  
  public void writePixels(int[] pixels, int w, int h) {
	buffer.getRGB(0, 0, w, h, pixels, 0, w);
  }
}