import ipcapture.*;
import hypermedia.net.*;
import gab.opencv.*;
import processing.video.*;
import processing.awt.PSurfaceAWT;
import processing.awt.PSurfaceAWT.SmoothCanvas;
import java.awt.*;
import java.awt.Frame;
import java.util.Collections;
import java.util.Arrays;
import java.util.Comparator;
import java.awt.geom.Line2D;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.awt.Shape;
import java.awt.Point;

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

Algo algo;
MotorControl motorControl;

ColorFilter blueHSV;
ColorFilter redHSV;
ColorFilter redRGB;
ColorFilter yellowHSV;
Detector<Rectangle> goalDetector;
Detector<Rectangle> ballDetector;
Detector<Line> lineDetector;
Boundary boundary;
DetectionThread lineDetection;
DetectionThread goalDetection;
DetectionThread ballDetection;

OscP5 oscP5;
NetAddress myRemoteLocation;
Comm comm;
String isBall = "/isBall";


// camera Parameters
int camWidth = 320;
int camHeight = 240;

//Ransac Parameters
int r_maxIteration = 500;
float r_threshhold = 0.2;

void setup() {
    size(1280,720);
    frameRate(15);
    
    cam = new IPCapture(this, "http://" + IP + ":81/stream", "", "");
    cam.start();
    
    surface.setLocation( -5, 0);
    
    // oscP5 = new OscP5(this,12000); // Port that the client will listen to
    // myRemoteLocation = new NetAddress("192.168.178.43",12000); // IP and port of the server that the client will send to
    // comm = new Comm(oscP5,myRemoteLocation,isBall); // Unique id for the communication
    
    // win = new PWindow(cam, 320, 0, 320, 240, "Cascade Detection");
    // mainWin = new DrawWindow();
    
    udpcomfort = new UDPcomfort(IP, PORT);
    antrieb = new Antrieb(udpcomfort, antriebMultiplier);    
    
    motorControl = new MotorControl(antrieb);
    
    blueHSV = new HSVFilter(HSVColorRangeR.YELLOW);
    goalDetector = new ContourDetector(camWidth, camHeight);
    goalDetection = new GoalDetection(motorControl, blueHSV, goalDetector);
    
    redHSV = new HSVFilter(HSVColorRangeR.combine(HSVColorRangeR.RED1, HSVColorRangeR.RED2));
    redRGB = new RGBFilter(RGBType.RED, 30);
    lineDetector = new RansacDetector(r_maxIteration,r_threshhold, 400,camWidth,camHeight);
    boundary = new Boundary(camWidth,camHeight);
    lineDetection = new LineDetection(motorControl, redRGB, lineDetector, boundary);
    
    yellowHSV = new HSVFilter(HSVColorRangeR.YELLOW);
    ballDetector = new ContourDetector(camWidth, camHeight);
    ballDetection = new BallDetection(motorControl, yellowHSV, ballDetector);
    
    motorControl.register(lineDetection,1);
    motorControl.register(ballDetection,2);
    motorControl.register(goalDetection,3);
    
    algo = new Algo(lineDetection, ballDetection, goalDetection);
    algo.startALL();
}


boolean AKTIV = false;

void draw() {
    
    try {
        if (cam.isAvailable()) {
            cam.read();
            cam.updatePixels();
            algo.updateImage(cam);
        } else {
            throw new RuntimeException("Camera not available");
        }
    }
    catch(Exception e) {
        e.printStackTrace();
    }
    
    // ld_result = algo.getLineDetectionResult(ld_color, ld_thickness);
    // redMask = algo.bildverarbeitung.getRedMask();
    // boundary_result = algo.lineDetection.bimg;
    // bd_result = algo.getBallDetectionResult(bd_color, bd_roi_color ,bd_thickness);
    // blueMask = algo.ballDetection.getYellowMask();
    // blueMask2 = algo.bildverarbeitung.getBlueMask();
    // gd_result = algo.getGoalDetectionResult(gd_color, gd_thickess);
    // yellowMask = algo.goalDetection.getYellowMask();
    // greenMask = algo.bildverarbeitung.getGreenMask();
    
    // image(cam, 0, 0);
    // image(ld_result, camWidth, 0);
    // image(redMask, camWidth, camHeight);
    // image(boundary_result, camWidth, camHeight * 2);
    // image(bd_result, camWidth * 2, 0);
    // image(blueMask, camWidth * 2, camHeight);
    // image(blueMask2, camWidth * 2, camHeight * 2);
    // image(gd_result, camWidth * 3, 0);
    // image(yellowMask, camWidth * 3, camHeight);
    // image(greenMask, camWidth * 3, camHeight * 2);
    
    PImage[][] res = algo.getTIResult();
    for (int i = 0; i < res.length; i++) {
        for (int j = 0; j < res[i].length; j++) {
            image(res[i][j], camWidth * i, camHeight * j);
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
