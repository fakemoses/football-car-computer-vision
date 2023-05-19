import ipcapture.*;
import hypermedia.net.*;

//Herausgezogene wichtige Parameter des Systems
boolean TAUSCHE_ANTRIEB_LINKS_RECHTS = false;
float VORTRIEB = 0.9;
float ASYMMETRIE = 1.01; // 1.0==voll symmetrisch, >1, LINKS STAERKER, <1 RECHTS STAERKER

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
String IP = "192.168.178.68";
int PORT = 6000;

//UDP udp;  // define the UDP object
UDPcomfort udpcomfort;  // define the UDP object
Antrieb antrieb;
IPCapture cam;
//Bildverarbeitung bildverarbeitung;
Regler regler;

// Controller
Controller control;
String controllerName = "carControl";


void setup() 
{
     size(320,240);
     cam = new IPCapture(this, "http://"+IP+":81/stream", "", "");
     cam.start();
     control = new Controller(this, controllerName);

     if (!control.isDeviceAvailable()) {
          println("No suitable device configured");
          System.exit(-1); // End the program NOW!
     }
     udpcomfort = new UDPcomfort(IP,PORT);
     antrieb = new Antrieb(udpcomfort);  
     regler = new Regler(antrieb,control);  
     
     frameRate(15);
}


boolean AKTIV = false;

void draw() 
{   
     
    cam.read();
    image(cam,0,0); 
    regler.fahren();
}

void keyPressed() 
{
  if (key == ' ') 
  {
    if (cam.isAlive()) 
    {
        cam.stop();
        NACHRICHT = "Kamera gestoppt";
    }    
    else
    {
        cam.start();
        NACHRICHT = "Kamera gestartet";
    }    
  }
  else if(key=='0') //stopp
  {
       antrieb.fahrt(0.0,0.0);
       NACHRICHT = "Fahrt gestoppt";
       AKTIV=false;
  }
  else if(key=='1') //beide vor
  {
       antrieb.fahrt(1.0,1.0);
       NACHRICHT = "Fahrt VORWÄRTS";
       AKTIV=true; 
  }
  else if(key=='2') //beide rueck
  {
       antrieb.fahrt(-1.0,-1.0);
       NACHRICHT = "Fahrt RÜCKWÄRTS";
  }
  else if(key=='3') //links langsam vor
  {
       antrieb.fahrt(0.85,0.0);
       NACHRICHT = "Fahrt LINKS langsam vor";
  }
  else if(key=='4') //rechts langsam vor
  {
       antrieb.fahrt(0.0,0.85);
       NACHRICHT = "Fahrt RECHTS langsam vor";
  }
  else if(key=='5') //links langsam rück
  {
       antrieb.fahrt(-0.93,0.0);
       NACHRICHT = "Fahrt LINKS langsam zurück";
  }
  else if(key=='6') //rechts langsam rück
  {
       antrieb.fahrt(0.0,-0.93);
       NACHRICHT = "Fahrt RECHTS langsam zurück";
  }
  else if(key=='7') //Kameralicht AN
  {
       udpcomfort.send(4,1);
       NACHRICHT = "Kameralicht AN";
  }
  else if(key=='8') //Kameralicht AUS
  {
       udpcomfort.send(4,0);
       NACHRICHT = "Kameralicht AUS";
  }
  
}