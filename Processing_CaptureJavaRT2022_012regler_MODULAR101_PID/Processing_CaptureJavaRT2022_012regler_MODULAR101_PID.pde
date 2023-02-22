import ipcapture.*;
import hypermedia.net.*;
import java.awt.*;
import processing.video.*;
import gab.opencv.*;
import java.awt.Frame;
import processing.awt.PSurfaceAWT;
import processing.awt.PSurfaceAWT.SmoothCanvas;
import java.util.Collections;

//Herausgezogene wichtige Parameter des Systems
boolean TAUSCHE_ANTRIEB_LINKS_RECHTS = false;
float VORTRIEB = 0.7;
float PROPORTIONALE_VERSTAERKUNG = 0.50;
float INTEGRALE_VERSTAERKUNG = 0.15f;
float DIFFERENTIALE_VERSTAERKUNG = 0.1f;
float ASYMMETRIE = 1.0; // 1.0==voll symmetrisch, >1, LINKS STAERKER, <1 RECHTS STAERKER
// float ASYMMETRIE = 1.01; // 1.0==voll symmetrisch, >1, LINKS STAERKER, <1 RECHTS STAERKER

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
String IP = "192.168.178.48";
int PORT = 6000;

double antriebMultiplier = 0.8;
// double antriebMultiplier = 0.75;

//UDP udp;  // define the UDP object
UDPcomfort udpcomfort;  // define the UDP object
Antrieb antrieb;
IPCapture cam;
Bildverarbeitung bildverarbeitung;
Regler regler;
Algo algo;
LineDetection lineDetection;
BallDetection ballDetection;
CarDetection carDetection;
GoalDetection goalDetection;
DrawWindow mainWin;
MotorControl motorControl;
Ransac ransac;
Boundary boundary;
ColorHSV yellowCV;
// Class for new window -> OpenCV Cascade
PWindow win;
OscP5 oscP5;
NetAddress myRemoteLocation;
Comm comm;
String isBall = "/isBall";

// HSV Color Extraction
boolean yellow = false;
ColorHSV maskYellow;
PImage img, out1;
PImage redMask, yellowMask, boundary_result;
PImage gd_result;
PImage ld_result;


// camera Parameters
int camWidth = 320;
int camHeight = 240;

//Ransac Parameters
int r_maxIteration = 500;
float r_threshhold = 0.2;

// Image Draw Parameters
int[] ld_color = {255, 0, 0};
int ld_thickness = 2;

int[] gd_color = {255, 255, 0};
int gd_thickess = 2;

void setup() {
    size(960,720);
    frameRate(10);
    
    redMask = createImage(camWidth, camHeight, RGB);
    
    cam = new IPCapture(this, "http://" + IP + ":81/stream", "", "");
    cam.start();
    surface.setLocation( -5, 0);
    
    // oscP5 = new OscP5(this,12000); // Port that the client will listen to
    // myRemoteLocation = new NetAddress("192.168.178.43",12000); // IP and port of the server that the client will send to
    // comm = new Comm(oscP5,myRemoteLocation,isBall); // Unique id for the communication
    
    win = new PWindow(cam, 320, 0, 320, 240, "Cascade Detection");
    // mainWin = new DrawWindow();
    
    bildverarbeitung = new Bildverarbeitung();
    udpcomfort = new UDPcomfort(IP, PORT);
    antrieb = new Antrieb(udpcomfort, antriebMultiplier);
    regler = new Regler(antrieb);
    
    motorControl = new MotorControl(antrieb);
    
    ransac = new Ransac(r_maxIteration,r_threshhold,camWidth,camHeight);
    boundary = new Boundary(camWidth,camHeight);
    lineDetection = new LineDetection(motorControl, ransac, boundary);
    
    ballDetection = new BallDetection(motorControl, win, bildverarbeitung);
    
    carDetection = new CarDetection(motorControl, win, bildverarbeitung);
    
    yellowCV = new ColorHSV(camWidth, camHeight, HsvColorRange.YELLOW.getRange());
    goalDetection = new GoalDetection(motorControl, bildverarbeitung, yellowCV);
    
    motorControl.register(lineDetection,1);
    motorControl.register(ballDetection,3);
    motorControl.register(goalDetection,2);
    
    algo = new Algo(cam, bildverarbeitung, lineDetection, ballDetection, carDetection, goalDetection);
    algo.startALL();
}


boolean AKTIV = false;

void draw() {
    algo.runColorExtraction();
    
    ld_result = algo.getLineDetectionResult(ld_color, ld_thickness);
    redMask = algo.bildverarbeitung.getRedMask();
    boundary_result = algo.lineDetection.bimg;
    gd_result = algo.getGoalDetectionResult(gd_color, gd_thickess);
    yellowMask = algo.goalDetection.getYellowMask();
    
    Rectangle[] rects = win.detectObject();
    
    image(cam, 0, 0);
    image(ld_result, 0, camHeight);
    image(redMask, camWidth, camHeight);
    image(boundary_result, camWidth * 2, camHeight);
    image(gd_result, 0, camHeight * 2);
    image(yellowMask, camWidth, camHeight * 2);
    
    motorControl.run();
    // mainWin.draw();    
}

//event handler for OSC messages
void oscEvent(OscMessage theOscMessage) {
    // /* check if theOscMessage has the address pattern we are looking for. */
    comm.onEventRun(theOscMessage);       
}

void keyPressed() {
    if (key == ' ') {
        if (cam.isAlive()) {
            cam.stop();
            NACHRICHT = "Kamera gestoppt";
        } else {
            cam.start();
            NACHRICHT = "Kamera gestartet";
        }
    } else if (key ==  '0') {//stopp
        antrieb.fahrt(0.0, 0.0);
        motorControl.stop();
        NACHRICHT = "Fahrt gestoppt";
        AKTIV = false;
    } else if (key ==  '1') {//beide vor
        // antrieb.fahrt(1.0, 1.0);
        motorControl.start();
        NACHRICHT = "Fahrt VORWÄRTS";
        AKTIV = true;
    } else if (key ==  '2') { //beide rueck 
        antrieb.fahrt( -1.0, -1.0);
        NACHRICHT = "Fahrt RÜCKWÄRTS";
    } else if (key ==  '3') { //links langsam vor
        antrieb.fahrt(0.85, 0.0);
        NACHRICHT = "Fahrt LINKSlangsamvor";
    } else if (key ==  '4') { //rechts langsam vor
        antrieb.fahrt(0.0, 0.85);
        NACHRICHT = "Fahrt RECHTS langsam vor";
    } else if (key ==  '5') { //links langsam rück
        antrieb.fahrt( -0.93, 0.0);
        NACHRICHT = "Fahrt LINKSlangsamzurück";
    } else if (key ==  '6') { //rechts langsam rück
        antrieb.fahrt(0.0, -0.93);
        NACHRICHT = "Fahrt RECHTS langsam zurück";
    } else if (key ==  '7') { //Kameralicht AN
        udpcomfort.send(4, 1);
        NACHRICHT = "KameralichtAN";
    } else if (key ==  '8') { //Kameralicht AUS 
        udpcomfort.send(4, 0);
        NACHRICHT = "KameralichtAUS";
    }
}

void captureEvent(Capture c) {
    c.read();
}
