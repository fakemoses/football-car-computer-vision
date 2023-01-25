import ipcapture.*;
import hypermedia.net.*;
import java.awt.*;
import processing.video.*;
import gab.opencv.*;
import java.awt.Frame;
import processing.awt.PSurfaceAWT;
import processing.awt.PSurfaceAWT.SmoothCanvas;

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
DrawWindow mainWin;
RANSAC ransac;

// Class for new window -> OpenCV Cascade
PWindow win;

// HSV Color Extraction
boolean yellow = false;
ColorHSV maskYellow;
PImage img, out1;
PImage redMask, camI;

void setup()
{
    size(640, 640);
    cam = new IPCapture(this, "http://" + IP + ":81/stream", "", "");
    cam.start();
    // win = new PWindow(cam, 320, 0, 320, 240, "Cascade Detection");
    surface.setLocation( -5, 0);
    bildverarbeitung = new Bildverarbeitung();
    udpcomfort = new UDPcomfort(IP, PORT);
    antrieb = new Antrieb(udpcomfort);
    regler = new Regler(antrieb);
    
    lineDetection = new LineDetection();
    // mainWin = new DrawWindow();
    algo = new Algo(cam, bildverarbeitung, lineDetection, antrieb);
    algo.startALL();
    ransac = new RANSAC(500,0.2,320,240);
    redMask = createImage(320, 240, RGB);
    camI = createImage(320, 240, RGB);
    frameRate(60);
}


boolean AKTIV = false;

void draw()
{
    algo.runColorExtraction();
    int evalValue = algo.getEvalResult();
    camI = algo.bildverarbeitung.getCameraImage();
    redMask = algo.bildverarbeitung.getRedMask();
    image(cam, 0, 0);
    image(redMask, 320, 0);
    PImage bimg;
    bimg = algo.lineDetection.bimg;
    image(bimg, 0, 240);
    stroke(255, 0, 0);
    strokeWeight(3);
    
    Point[] intersectionPoint = algo.lineDetection.getIntersectionPoints();
    line(intersectionPoint[0].x, intersectionPoint[0].y, intersectionPoint[1].x, intersectionPoint[1].y);    
    
    
    if (AKTIV) {
        algo.controlMotor();
    }
    // -> set evalValue to motor
    // mainWin.draw();
    // antrieb.fahrt(0.0, 0.0);
    
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
        NACHRICHT = "Fahrt gestoppt";
        AKTIV = false;
    } else if (key ==  '1') //beide vor
        {
        // antrieb.fahrt(1.0, 1.0);
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
