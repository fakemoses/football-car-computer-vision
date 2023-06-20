package ipcapture2;

import java.io.ByteArrayInputStream;
import android.graphics.BitmapFactory;
import android.graphics.Bitmap;

public class AndroidFrameBuffer extends FrameBuffer {
  Bitmap buffer;
  
  public AndroidFrameBuffer(ByteArrayInputStream in) {
	try {
	  this.buffer = BitmapFactory.decodeStream(in);
	}
	catch (Exception e) {
	  this.buffer = null;
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
	buffer.getPixels(pixels, 0, w, 0, 0, w, h);
  }
}