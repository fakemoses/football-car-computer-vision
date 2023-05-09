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
//String IP = "192.168.178.65";
String IP = "192.168.137.222";
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
  } else println("camerror");
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

  //redesign this shit to a better GUI
  // include those roation, cam mode etc
  // nod to start -> stay still till timer is done -> play

  background(0);
  //rotate(PI);
  //image(cam, 0, 0);
  textSize(25);

  long remainingTime = maxDuration - timeDiff;
  if (remainingTime >= 0){
    text("Starting in " + Math.round(remainingTime / 1000), -100, 0);
    text("Don't move your head till the timer ends", -250, -40);
  }
}

void drawMainScreen(){

  rotate(PI);
    rotateY(PI);
    image(cam, 0, 0);

    // region: show Text in Image

    rotate(PI);
    rotateY(PI);

    if(stats){
      fill(0,0,0);
      rect(-200,0,100,60);
      fill(255,255,255);
      textSize(15);
      text("X Norm:" + nf(((sensorData.x) / 90.0f)-regler.offSetX, 0, 2), -200, 0);
      text("Y Norm:" + nf(((sensorData.y) / 90.0f)-regler.offSetY, 0, 2), -200, 20);
      text("Z Norm:" + nf(((sensorData.z) / 180.0f)-regler.offSetZ, 0, 2), -200, 40);
    }   

    if((((sensorData.x) / 90.0f)-regler.offSetX > tilt_thres || regler.stop) && !regler.start){
      fill(255, 0, 0);
      rect(150, 130, 50, 50);
    } else if(regler.start && !regler.stop){
      fill(0, 255, 0);
      rect(150, 130, 50, 50);
    } else{
      fill(255, 0, 0);
      rect(150, 130, 50, 50);
    }
    
}
