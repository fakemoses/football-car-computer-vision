/**
 * This code captures video from an IP camera and displays it in Processing.
 *
 * Credits:
 * - Repo (https://github.com/singintime/ipcapture)
 *
 * Notes:
 * - Implementation was modified to set Android Mode manually
 * - the original implementation was unable to detect the device when running in Android mode.
 */

import ipcapture2.*;

String IP = "192.168.178.65";

IPCapture2 cam;

void setup() {
  size(1280, 720);
  frameRate(15);

  cam = new IPCapture2(this, "http://" + IP + ":81/stream", "", "");
  cam.start();
}

void draw() {
  if (cam.isAvailable()) {
    cam.read();
  }

  image(cam, 0, 0);
}
