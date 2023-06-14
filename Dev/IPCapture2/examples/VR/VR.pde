/**
 * This code captures video from an IP camera and displays it in virtual reality using Processing VR.
 *
 * IMPORTANT:
 * - Please enable Android mode in Processing and VR mode is selected.
 * - Make sure Internet permission is enabled either in AndroidManifest.xml or at tab Android > Sketch permission.
 * - If you are using http unsecure IP camera please add android:usesCleartextTraffic="true" in <application> in AndroidManifest.xml.
 *
 * Credits:
 * - Repo (https://github.com/singintime/ipcapture)
 *
 * Notes:
 * - Implementation was modified to set Android Mode manually
 * - the original implementation was unable to detect the device when running in Android mode.
 */

import processing.vr.*;
import ipcapture2.*;

VRCamera cam;

String IP = "192.168.178.65";

IPCapture2 camera;


public void setup() {
  cameraUp();
  cam = new VRCamera(this);

  fullScreen(VR);

  camera = new IPCapture2(this, "http://" + IP + ":81/stream", "", "");
  camera.setMode(Mode.ANDROID);
  camera.start();
}

public void draw() {
  background(0);

  if (camera.isAvailable()) {
    camera.read();
  }
  cam.setPosition(0, 0, 400);

  cam.sticky();
  imageMode(CENTER);
  translate(0, 0, 200);
  image(camera, 0, 0);

  textSize(35);
  cam.noSticky();
}
