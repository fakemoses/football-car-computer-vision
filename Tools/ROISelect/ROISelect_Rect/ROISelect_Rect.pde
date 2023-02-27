import ipcapture.*;


// camera Parameters
int camWidth = 320;
int camHeight = 240;

IPCapture cam;
String IP = "192.168.178.48";

ArrayList<PVector> points = new ArrayList<PVector>();

void setup() {
    size(320, 240);
    cam = new IPCapture(this, "http://" + IP + ":81/stream", "", "");
    cam.start();
    frameRate(10);
}

void draw() {
    if (cam.isAvailable()) {
        cam.read();
        cam.updatePixels();
    }
    image(cam, 0, 0);
    
    for (PVector p : points) {
        fill(255, 0, 0);
        ellipse(p.x, p.y, 10, 10);
    }
    
    if (points.size() == 2) {
        PVector p1 = points.get(0);
        PVector p2 = points.get(1);
        int w = (int) p2.x - (int) p1.x;
        int h = (int) p2.y - (int) p1.y;
        // stroke(255, 0, 0,0.2);
        noStroke();
        fill(255, 0, 0,50);
        rect(p1.x, p1.y, w,h);
    }
}

void mousePressed() {
    if (points.size() <= 1) {
        points.add(new PVector(mouseX, mouseY));
    } else {
        points.remove(1);
        points.add(new PVector(mouseX, mouseY));
    }
}

void keyPressed() {
    if (key == 'c') {
        points.clear();
    }
    
    if (key == 's') {
        if (points.size() != 2) {
            println("Please select 2 points");
            return;
        }
        for (PVector p : points) {
            println(p.x + "," + p.y);
        }
    }
}
