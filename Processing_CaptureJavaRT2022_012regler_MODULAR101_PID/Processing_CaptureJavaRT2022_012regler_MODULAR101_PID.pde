import ipcapture.*;
import hypermedia.net.*;
import gab.opencv.*;
import processing.video.*;
import processing.awt.PSurfaceAWT;
import processing.awt.PSurfaceAWT.SmoothCanvas;
import java.awt.*;
import java.awt.Frame;
import java.awt.geom.Line2D;
import java.awt.geom.Point2D;
import java.awt.geom.Rectangle2D;
import java.awt.Shape;
import java.awt.Point;
import java.awt.image.BufferedImage;
import java.util.Collections;
import java.util.Arrays;
import java.util.Comparator;
import java.util.ListIterator;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import java.net.*;
import java.io.*;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import javax.imageio.ImageIO;

//Herausgezogene wichtige Parameter des Systems
boolean TAUSCHE_ANTRIEB_LINKS_RECHTS = true;
// float VORTRIEB = 0.72;
float VORTRIEB = 0.83;
float ASYMMETRIE = 1.01; // 1.0==voll symmetrisch, >1, LINKS STAERKER, <1 RECHTS STAERKER
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
//String IP = "192.168.178.70";
String IP = "192.168.178.65";
int PORT = 6000;

double antriebMultiplier = 1.0;

UDPcomfort udpcomfort;  
Antrieb antrieb;
CustomCam cam;

Algo algo;
MotorControl motorControl;

DataContainer dataContainer;

Boundary boundary;
ColorFilter goalFilter;
ColorFilter lineFilter;
ColorFilter ballFilter;
Detector<Line> lineDetector;
Detector<Rectangle> goalDetector;
Detector<Rectangle> ballDetector;
LineDetection lineDetection;
GoalDetection goalDetection;
BallDetection ballDetection;

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
    
    cam = new CustomCam(this, "http://" + IP + ":81/stream", "", "");
    cam.start();
    
    surface.setLocation( -5, 0);
    
    // oscP5 = new OscP5(this,12000); // Port that the client will listen to
    // myRemoteLocation = new NetAddress("192.168.178.43",12000); // IP and port of the server that the client will send to
    // comm = new Comm(oscP5,myRemoteLocation,isBall); // Unique id for the communication
    
    udpcomfort = new UDPcomfort(IP, PORT);
    antrieb = new Antrieb(udpcomfort, antriebMultiplier);    
    
    motorControl = new MotorControl(antrieb);
    
    dataContainer = new DataContainer();
    
    lineFilter = new HSVFilter(HSVColorRange.combine(HSVColorRange.RED1, HSVColorRange.RED2));
    boundary = new Boundary(camWidth,camHeight);
    lineDetector = new RansacDetector(r_maxIteration,r_threshhold, 400,camWidth,camHeight);
    lineDetection = new LineDetection(motorControl, dataContainer, lineFilter, lineDetector, boundary);
    
    ballFilter = new HSVFilter(HSVColorRange.YELLOW3).addPostFilter(new MedianFilter(3)).addPostFilter(new GaussianFilter1D(5, 100)).addPostFilter(new Padding(50,0,0,0));
    ballDetector = new RansacDetectorRect(1000,150);
    ballDetection = new BallDetection(motorControl, dataContainer, ballFilter, ballDetector, comm);
    
    goalFilter = new HSVFilter(HSVColorRange.GREEN).addPostFilter(new MedianFilter(9)).addPostFilter(new GaussianFilter1D(5, 200)).addPostFilter(new Padding(50,0,0,0));
    goalDetector = new  RansacDetectorRect(1000,50);
    goalDetection = new GoalDetection(motorControl, dataContainer, goalFilter, goalDetector);
    
    motorControl.register(lineDetection,1);
    motorControl.register(ballDetection,2);
    motorControl.register(goalDetection,3);
    
    // algo = new Algo(ballDetection);
    algo = new Algo(lineDetection, ballDetection,goalDetection);
    // algo = new Algo(goalDetection);
    algo.startALL();
}

boolean AKTIV = false;

void draw() {   
    
    if (cam.isDown()) {
        noLoop();
        println("Camera is down");
        println("Reconnecting...");
        cam.reconnect();
        delay(5000);
        loop();
    }
    
    
    if (cam.isAvailable()) {
        cam.read();
        // is it possible that the pixels updated during grabbing image? need locking ?
        algo.updateImage(cam);
    }
    
    drawResults(algo.getDetectionResults());
    
    motorControl.run();
}

// //event handler for OSC messages
// void oscEvent(OscMessage theOscMessage) {
//     // /* check if theOscMessage has the address pattern we are looking for. */
//     comm.onEventRun(theOscMessage);       
// }

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

void drawResults(PImage[][] results) {
    for (int i = 0; i < results.length; i++) {
        for (int j = 0; j < results[i].length; j++) {
            image(results[i][j],camWidth * i, camHeight * j);
        }
    }
}
