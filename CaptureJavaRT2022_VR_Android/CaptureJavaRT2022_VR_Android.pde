import hypermedia.net.*;
import processing.vr.*;
import ipcapture2.*;

//Herausgezogene wichtige Parameter des Systems
boolean TAUSCHE_ANTRIEB_LINKS_RECHTS = true;
float VORTRIEB = 0.9;
float ASYMMETRIE = 1; // 1.0==voll symmetrisch, >1, LINKS STAERKER, <1 RECHTS STAERKER

//VERSION FÜR TP-Link_59C2

//Zugriff auf Konfiguration:
//  http://tplinkwifi.net
//  ODER
//  http://192.168.0.1
//  ODER
//  http://192.168.1.1
//  PASSWORT FÜR ADMINISTRATION: TP-Link_59C2
//  EINRICHTUNG:
//  als Access Point
//  static IP
//  DHCP server enabled

//  Zugang zum access point:

//  hotspot
//  12345678

//  Fahrzeug Kramann: 192.168.0.102

String NACHRICHT = "";
//String TEMPERATUR = "";
//String IP = "192.168.137.92";
//String IP = "192.168.0.102";
String IP = "192.168.137.157";
//String IP = "192.168.137.222";
int PORT = 6000;

//UDP udp;  // define the UDP object
UDPcomfort udpcomfort;  // define the UDP object
Antrieb antrieb;
IPCapture2 cam;
VRCamera camera;
//Bildverarbeitung bildverarbeitung;
Regler regler;

SensorM sensorData;

long currTime = System.currentTimeMillis();
long maxDuration = 10000;
float tilt_thres = -0.2;
boolean stats = true;

int w = 320;
int h = 240;
float largerRectWidth = w * 0.03f;
float largerRectHeight = h * 0.3f;

float sensorValX = 0;
float sensorValY = 0;
float sensorValZ = 0;

void setup()
{
  //size(320,240);
  cameraUp();
  camera = new VRCamera(this);
  fullScreen(VR);

  //cam = new IPCapture2(this, "http://192.168.178.45:4747/video", "", "");
  cam = new IPCapture2(this, "http://"+IP+":81/stream", "", "");

  cam.setMode(Mode.ANDROID);
  cam.start();

  sensorData = new SensorM(this);

  udpcomfort = new UDPcomfort(IP, PORT);
  antrieb = new Antrieb(udpcomfort);
  regler = new Regler(antrieb, sensorData);

  frameRate(5);
}


boolean AKTIV = false;

void draw()
{
  background(0);
  if (cam.isAvailable()) {
    cam.read();
  } //else println("camerror");
  camera.setPosition(0, 0, 400);

  camera.sticky();
  imageMode(CENTER);
  translate(0, 0, 200);
  long timeDiff = System.currentTimeMillis() - currTime;

  if (timeDiff <= maxDuration) {
    drawStartScreen(timeDiff);
  } else {
    drawMainScreen();
    regler.fahren();
  }
  textSize(35);
  camera.noSticky();
  delay(16);
}

void drawStartScreen(long timeDiff) {

  background(0);
  textSize(25);

  long remainingTime = maxDuration - timeDiff;
  if (remainingTime >= 0) {
    text("Start in " + Math.round(remainingTime / 1000), -100, 0);
    text("Kopf nicht bewegen, bis der Timer abgelaufen ist", -250, -40);
  }
}

void drawMainScreen() {

  //recheck the sensor value in case exceeding range
  sensorValX = ((sensorData.x) / 90.0f)-regler.offSetX;
  sensorValY = ((sensorData.y) / 90.0f)-regler.offSetY;
  sensorValZ = ((sensorData.z) / 180.0f)-regler.offSetZ;

  // Limit the values to the range of -1 to 1
  if (sensorValX < -1)
    sensorValX = -1;
  else if (sensorValX > 1)
    sensorValX = 1;

  if (sensorValY < -1)
    sensorValY = -1;
  else if (sensorValY > 1)
    sensorValY = 1;

  if (sensorValZ < -1) {
    float range = 1 - (-1); // Calculate the range between -1 and 1
    sensorValZ = sensorValZ + range; // Wrap around by adding the range
  } else if (sensorValZ > 1) {
    float range = 1 - (-1); // Calculate the range between -1 and 1
    sensorValZ = sensorValZ - range; // Wrap around by subtracting the range
  }

  rotate(PI);
  rotateY(PI);
  image(cam, 0, 0);

  // region: show Text in Image
  drawIndicator(true, sensorValZ, largerRectWidth, largerRectHeight, 200, 0, 255, 255);
  drawIndicator(false, sensorValY, largerRectWidth, largerRectHeight, 200, 0, 0, 255);

  rotate(PI);
  rotateY(PI);

  if (stats) {
    fill(0, 0, 0);
    rect(-200, 0, 100, 60);
    fill(255, 255, 255);
    textSize(15);
    text("X Norm:" + nf(sensorValX, 0, 2), -200, 0);
    text("Y Norm:" + nf(sensorValY, 0, 2), -200, 20);
    text("Z Norm:" + nf(sensorValZ, 0, 2), -200, 40);
  }

  if ((((sensorData.x) / 90.0f)-regler.offSetX > tilt_thres || regler.stop) && !regler.start) {
    fill(255, 0, 0);
    rect(150, 130, 50, 50);
  } else if (regler.start && !regler.stop) {
    fill(0, 255, 0);
    rect(150, 130, 50, 50);
  } else {
    fill(255, 0, 0);
    rect(150, 130, 50, 50);
  }
}

void drawIndicator(boolean isHorizontal, float sensorData, float largerRectWidth, float largerRectHeight, int offset, int rSmall, int gSmall, int bSmall) {

  float smallerRectWidth = largerRectWidth;
  float smallerRectHeight = 10;
  float smallerRectX, smallerRectY;

  if (isHorizontal) {
    smallerRectX = map(sensorData, -1, 1, -offset, (largerRectHeight - smallerRectWidth) - offset);
    smallerRectY = largerRectHeight / 2 - smallerRectHeight / 2;
  } else {
    smallerRectX = (w / 10.0f)-offset;
    smallerRectY = map(sensorData, -1, 1, largerRectHeight, 0);
  }

  // Draw the outer rectangular indicator
  fill(200, 128);
  noStroke();
  if (isHorizontal) {
    rect(0-offset, (largerRectHeight / 2) - (smallerRectHeight / 2), largerRectHeight, largerRectWidth);

    // Draw the smaller rectangle
    fill(rSmall, gSmall, bSmall);
    rect(smallerRectX, smallerRectY, smallerRectWidth, smallerRectHeight);
  } else {
    float centerX = w / 5.0f;
    float centerY = 0.0f;
    rect((centerX / 2)-offset, centerY, largerRectWidth, largerRectHeight);

    // Draw the smaller rectangle
    fill(rSmall, gSmall, bSmall);
    rect(smallerRectX, smallerRectY-smallerRectHeight/2, smallerRectWidth, smallerRectHeight);
  }
}
