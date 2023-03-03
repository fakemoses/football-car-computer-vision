import ipcapture.*;
import hypermedia.net.*;
import java.awt.*;
import processing.video.*;
import gab.opencv.*;
import java.awt.Frame;
import processing.awt.PSurfaceAWT;
import processing.awt.PSurfaceAWT.SmoothCanvas;
import java.util.Collections;
import java.util.Arrays;
import java.util.Comparator;

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

double antriebMultiplier = 0.9;

UDPcomfort udpcomfort;  
Antrieb antrieb;
IPCapture cam;
Bildverarbeitung bildverarbeitung;
Algo algo;
LineDetection lineDetection;
BallDetection2 ballDetection;
CarDetection carDetection;
GoalDetection goalDetection;
DetectionThread goalDetection2;
MotorControl motorControl;
Ransac ransac;
Boundary boundary;
ColorHSV yellowCV;
ColorHSV blueCV;

ColorFilter blueHSV;
ColorFilter redHSV;
ObjectDetector goalDetector;
LineDetector lineDetector;
Boundary2 boundary2;
DetectionThread lineDetection2;
CascadeDetection ballCascade;
OscP5 oscP5;
NetAddress myRemoteLocation;
Comm comm;
String isBall = "/isBall";

// HSV Color Extraction
boolean yellow = false;
ColorHSV maskYellow;
PImage img, out1;
PImage redMask, yellowMask, boundary_result, blueMask, blueMask2, greenMask;
PImage gd_result;
PImage ld_result;
PImage bd_result;


// camera Parameters
int camWidth = 320;
int camHeight = 240;

//Ransac Parameters
int r_maxIteration = 500;
float r_threshhold = 0.2;

// Image Draw Parameters
color ld_color = color(255, 0, 0);
int ld_thickness = 2;

color gd_color = color(0, 255, 0);
int gd_thickess = 2;

color bd_color = color(0, 0, 255);
color bd_roi_color = color(255, 0, 0, 20);
int bd_thickness = 2;

void setup() {
    size(1280,720);
    frameRate(15);
    
    redMask = createImage(camWidth, camHeight, RGB);
    
    cam = new IPCapture(this, "http://" + IP + ":81/stream", "", "");
    cam.start();
    
    surface.setLocation( -5, 0);
    
    // oscP5 = new OscP5(this,12000); // Port that the client will listen to
    // myRemoteLocation = new NetAddress("192.168.178.43",12000); // IP and port of the server that the client will send to
    // comm = new Comm(oscP5,myRemoteLocation,isBall); // Unique id for the communication
    
    // win = new PWindow(cam, 320, 0, 320, 240, "Cascade Detection");
    // mainWin = new DrawWindow();
    
    bildverarbeitung = new Bildverarbeitung(camWidth, camHeight);
    udpcomfort = new UDPcomfort(IP, PORT);
    antrieb = new Antrieb(udpcomfort, antriebMultiplier);    
    
    motorControl = new MotorControl(antrieb);
    
    ransac = new Ransac(r_maxIteration,r_threshhold,camWidth,camHeight);
    boundary = new Boundary(camWidth,camHeight);
    lineDetection = new LineDetection(motorControl, bildverarbeitung, ransac, boundary);
    
    ballCascade = new CascadeDetection(camWidth, camHeight);
    blueCV = new ColorHSV(camWidth, camHeight, HsvColorRange.BLUE.getRange());
    yellowCV = new ColorHSV(camWidth, camHeight, HsvColorRange.YELLOW.getRange());
    ballDetection = new BallDetection2(motorControl, bildverarbeitung, yellowCV);
    
    carDetection = new CarDetection(motorControl, bildverarbeitung);
    
    goalDetection = new GoalDetection(motorControl, bildverarbeitung, blueCV);
    
    blueHSV = new HSVFilter(HSVColorRangeR.YELLOW);
    goalDetector = new ContourDetector(camWidth, camHeight);
    goalDetection2 = new GoalDetection2(motorControl, blueHSV, goalDetector);
    
    redHSV = new HSVFilter(HSVColorRangeR.combine(HSVColorRangeR.RED1, HSVColorRangeR.RED2));
    lineDetector = new RansacDetector(r_maxIteration,r_threshhold, 400,camWidth,camHeight);
    boundary2 = new Boundary2(camWidth,camHeight);
    lineDetection2 = new LineDetection2(motorControl, redHSV, lineDetector, boundary2);
    motorControl.register(lineDetection,1);
    motorControl.register(ballDetection,2);
    motorControl.register(goalDetection,3);
    
    DetectionThread[] tis = {goalDetection2, lineDetection2};
    algo = new Algo(cam, bildverarbeitung, lineDetection, ballDetection, carDetection, goalDetection, tis);
    algo.startALL();
}


boolean AKTIV = false;

void draw() {
    algo.runColorExtraction();
    
    ld_result = algo.getLineDetectionResult(ld_color, ld_thickness);
    redMask = algo.bildverarbeitung.getRedMask();
    boundary_result = algo.lineDetection.bimg;
    bd_result = algo.getBallDetectionResult(bd_color, bd_roi_color ,bd_thickness);
    blueMask = algo.ballDetection.getYellowMask();
    blueMask2 = algo.bildverarbeitung.getBlueMask();
    gd_result = algo.getGoalDetectionResult(gd_color, gd_thickess);
    yellowMask = algo.goalDetection.getYellowMask();
    greenMask = algo.bildverarbeitung.getGreenMask();
    
    image(cam, 0, 0);
    image(ld_result, camWidth, 0);
    image(redMask, camWidth, camHeight);
    image(boundary_result, camWidth, camHeight * 2);
    image(bd_result, camWidth * 2, 0);
    image(blueMask, camWidth * 2, camHeight);
    image(blueMask2, camWidth * 2, camHeight * 2);
    image(gd_result, camWidth * 3, 0);
    image(yellowMask, camWidth * 3, camHeight);
    image(greenMask, camWidth * 3, camHeight * 2);
    
    PImage[] res = algo.getTIResult();
    if (res!= null) {
        for (int i = 0; i < res.length; i++) {
            image(res[i], 0, camHeight * (i));
        }
    }
    
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
        println("Fahrt gestoppt");
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
