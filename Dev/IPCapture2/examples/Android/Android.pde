/**
 * This code captures video from an IP camera and displays it in android device.
 *
 * IMPORTANT:
 * - Please enable Android mode in Processing and Android mode is selected.
 * - Make sure Internet permission is enabled either in AndroidManifest.xml or at tab Android > Sketch permission.
 * - If you are using http unsecure IP camera add android:usesCleartextTraffic="true" in <application> in AndroidManifest.xml.
 *
 * Credits:
 * - Repo (https://github.com/singintime/ipcapture)
 *
 * Notes:
 * - Implementation was modified to set Android Mode manually
 * - the original implementation was unable to detect the device when running in Android mode.
 */

import ipcapture2.*;

IPCapture2 cam;

String IP = "192.168.178.65";


void setup() {
  cam = new IPCapture2(this, "http://" + IP + ":81/stream", "", "");
  cam.setMode(Mode.ANDROID);
  cam.start();
}

void draw() {
  if (cam.isAvailable()) {
    cam.read();
  }

  image(cam, 0, 0);
}
