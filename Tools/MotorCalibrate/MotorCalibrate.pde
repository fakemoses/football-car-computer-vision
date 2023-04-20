import hypermedia.net.*;

boolean TAUSCHE_ANTRIEB_LINKS_RECHTS = false;
float VORTRIEB = 0.83;
int mode = 0;

UDPcomfort udpcomfort;  
Antrieb antrieb;

String IP = "192.168.178.73";
int PORT = 6000;

CalibBase calib;

float initCalibForward = 0.0;
float valueCalibForward = 0.0;
CalibForward calibForward;

float valueCalibFromRest = 0.0;
CalibFromRest calibFromRest;

float initCalibStraight = 0.0;
float valueCalibStraight = 0.0;
CalibStraight calibStraight;

float valueCalibTurn = 0.0;
CalibTurn calibTurn;

float ASYMMETRIE = 1.01;
CalibSymmetrie calibSymmetrie;

double antriebMultiplier = 1.0;

String current;

boolean motorStart = false;

void setup() {
    size(640, 170);
    frameRate(15);
    
    udpcomfort = new UDPcomfort(IP, PORT);
    antrieb = new Antrieb(udpcomfort, antriebMultiplier);
    
    calibFromRest = new CalibFromRest(antrieb, valueCalibFromRest);
    
    calibForward = new CalibForward(antrieb, valueCalibForward, initCalibForward);
    
    calibStraight = new CalibStraight(antrieb, valueCalibStraight, initCalibStraight);
    
    calibTurn = new CalibTurn(antrieb, valueCalibTurn);
    
    calibSymmetrie = new CalibSymmetrie(antrieb, ASYMMETRIE, VORTRIEB);
}

void draw() {
    if (calib == null) {
        current = "No Calibration";
    }
    background(0);
    textSize(30);
    
    fill(255);
    text(current, 10, 30);
    
    String motorText;
    if (motorStart) {
        motorText = "ON";
        fill(0, 255, 0);
        // calib.execute();
    }
    else {
        motorText = "OFF";
        fill(255, 0, 0);
    }
    text(motorText, 10, 60);
    
    if (calib != null) {
        String[] calibText = calib.getValues();   
        
        fill(255);
        for (int i = 0; i < calibText.length; i++) {
            text(calibText[i], 10, 90 + i * 30);
        }
    }
    
}

void keyPressed() {
    if (key == '1') {
        calib = calibFromRest;
        current = calib.getCalibName();
        motorStart = false;
    }
    
    if (key == '2') {
        calib = calibForward;
        current = calib.getCalibName();
        motorStart = false;
    }
    
    if (key == '3') {
        calib = calibStraight;
        current = calib.getCalibName();
        motorStart = false;
    }
    
    if (key == '4') {
        calib = calibTurn;
        current = calib.getCalibName();
        motorStart = false;
    }
    
    if (key == '0') {
        calib = null;
        motorStart = false;
    }
    
    
    if (key == '8') {
        if (calib ==  null) {
            return;
        }
        calib.smallIncrement();
    }
    
    if (key == '9') {
        if (calib ==  null) {
            return;
        }
        calib.largeIncrement();
    }
    
    if (key == '5') {
        if (calib ==  null) {
            return;
        }
        calib.smallDecrement();
    }
    
    if (key == '6') {
        if (calib ==  null) {
            return;
        }
        calib.largeDecrement();
    }
    
    if (key == ' ') {
        motorStart = true;
    }
    
}