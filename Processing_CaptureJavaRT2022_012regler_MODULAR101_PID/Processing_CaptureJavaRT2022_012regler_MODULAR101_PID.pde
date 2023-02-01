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

//UDP udp;  // define the UDP object
UDPcomfort udpcomfort;  // define the UDP object
Antrieb antrieb;
IPCapture cam;
Bildverarbeitung bildverarbeitung;
Regler regler;
Algo algo;
LineDetection lineDetection;
BallDetection ballDetection;
DrawWindow mainWin;
MotorControl motorControl;
RANSAC ransac;
Boundary boundary;
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
PImage redMask, camI, bimg;

void setup()
{
    size(640, 640);
    frameRate(10);
    
    redMask = createImage(320, 240, RGB);
    camI = createImage(320, 240, RGB);
    bimg = createImage(320, 240, RGB);
    
    cam = new IPCapture(this, "http://" + IP + ":81/stream", "", "");
    cam.start();
    surface.setLocation( -5, 0);

    oscP5 = new OscP5(this,12000); // Port that the client will listen to
    myRemoteLocation = new NetAddress("192.168.178.43",12000); // IP and port of the server that the client will send to
    comm = new Comm(oscP5,myRemoteLocation,isBall); // Unique id for the communication
    
    win = new PWindow(cam, 320, 0, 320, 240, "Cascade Detection");
    // mainWin = new DrawWindow();
    
    bildverarbeitung = new Bildverarbeitung();
    udpcomfort = new UDPcomfort(IP, PORT);
    antrieb = new Antrieb(udpcomfort);
    regler = new Regler(antrieb);
    
    motorControl = new MotorControl(antrieb);
    
    ransac = new RANSAC(500,0.2,320,240);
    boundary = new Boundary(320,240);
    lineDetection = new LineDetection(motorControl, ransac, boundary);
    
    ballDetection = new BallDetection(motorControl, win, bildverarbeitung);
    
    motorControl.register(lineDetection,1);
    motorControl.register(ballDetection,2);
    
    algo = new Algo(cam, bildverarbeitung, lineDetection, ballDetection);
    algo.startALL();
}


boolean AKTIV = false;
PImage sub = null;

void draw()
{
    algo.runColorExtraction();
    // int evalValue = algo.getEvalResult();
    camI = algo.bildverarbeitung.getCameraImage();
    redMask = algo.bildverarbeitung.getBlueMask();
    int[][] red = algo.bildverarbeitung.getRed();
    bimg = algo.lineDetection.bimg;
    
    Rectangle[] rects = win.detectObject();
    
    image(cam, 0, 0);
    image(redMask, 320, 0);
    image(bimg, 0, 240);
    
    stroke(255, 0, 0);
    noFill();
    // if (rects != null) {    
    //     for (int i = 0;i < rects.length;i++) {
    //         rect(rects[i].x,rects[i].y,rects[i].width,rects[i].height);
    //         sub = redMask.get(rects[i].x, rects[i].y, rects[i].width, rects[i].height);
    //         double white = countWhitePixels(rects[i].x, rects[i].y, rects[i].width, rects[i].height, sub);
    //         println("White: " + white);
    //     } 
// }
    // strokeWeight(3);
    // if (sub != null) {
    //     image(sub, 320, 240);
// }
    
    Point[] intersectionPoint = algo.lineDetection.getIntersectionPoints();
    line(intersectionPoint[0].x, intersectionPoint[0].y, intersectionPoint[1].x, intersectionPoint[1].y);    
    
    motorControl.run();
    // mainWin.draw();    
}

//event handler for OSC messages
void oscEvent(OscMessage theOscMessage) {
   /* check if theOscMessage has the address pattern we are looking for. */
  comm.onEventRun(theOscMessage);       
}

public double countWhitePixels(int x, int y, int w, int h, int[][] bild) {
    int white_count = 0;
    int i = 0;
    int j = 0;
    
    for (i = y; i < y + h; i++) {
        for (j = x; j < x + w; j++) {
            int val = bild[j][i];
            if (val == 0) {
                // white_count++;
                // println("Bild: " + bild[j][i]);
                white_count++;
            }
        }
    }
    println("YJ: " + y + " " + j + " " + h + " " + w);
    double area_white;
    println("white count: " + white_count);
    area_white = ((double)white_count / (w * h)) * 100;
    // println("white % : " + area_white);
    return area_white;
}
public double countWhitePixels(int x, int y, int w, int h, PImage bild) {
    int white_count = 0;
    
    int pix[] = bild.pixels;
    
    for (int i = 0; i < pix.length; i++) {
        if (pix[i] == color(255, 255, 255)) {
            white_count++;
        }
    }
    double area_white;
    println("white count: " + white_count);
    area_white = ((double)white_count / (w * h)) * 100;
    // println("white % : " + area_white);
    return area_white;
}

void keyPressed()
    {
    if (key == ' ')
        {
        if (cam.isAlive())
            {
            cam.stop();
            NACHRICHT = "Kamera gestoppt";
        } else
            {
            cam.start();
            NACHRICHT = "Kamera gestartet";
        }
    } else if (key ==  '0') //stopp
        {
        antrieb.fahrt(0.0, 0.0);
        motorControl.stop();
        NACHRICHT = "Fahrt gestoppt";
        AKTIV = false;
    } else if (key ==  '1') //beide vor
        {
        // antrieb.fahrt(1.0, 1.0);
        motorControl.start();
        NACHRICHT = "Fahrt VORWÄRTS";
        AKTIV = true;
    } else if (key ==  '2') //beide rueck
        {
        antrieb.fahrt( -1.0, -1.0);
        NACHRICHT = "Fahrt RÜCKWÄRTS";
    } else if (key ==  '3') //links langsam vor
        {
        antrieb.fahrt(0.85, 0.0);
        NACHRICHT = "Fahrt LINKS langsamvor";
    } else if (key ==  '4') //rechts langsam vor
        {
        antrieb.fahrt(0.0, 0.85);
        NACHRICHT = "Fahrt RECHTS langsam vor";
    } else if (key ==  '5') //links langsam rück
        {
        antrieb.fahrt( -0.93, 0.0);
        NACHRICHT = "Fahrt LINKS langsamzurück";
    } else if (key ==  '6') //rechts langsam rück
        {
        antrieb.fahrt(0.0, -0.93);
        NACHRICHT = "Fahrt RECHTS langsam zurück";
    } else if (key ==  '7') //Kameralicht AN
        {
        udpcomfort.send(4, 1);
        NACHRICHT = "Kameralicht AN";
    } else if (key ==  '8') //Kameralicht AUS
        {
        udpcomfort.send(4, 0);
        NACHRICHT = "Kameralicht AUS";
    }
}

void captureEvent(Capture c) {
    c.read();
}
