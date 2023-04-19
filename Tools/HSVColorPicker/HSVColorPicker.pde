String fileName = "rgbtest2.jpg";

PImage image;
PImage hsv;

HSVFilter filter = new HSVFilter();

// 0 = color picker
// 1 = range picker

color p1;
color p2;

int posx1 = 0;
int posy1 = 0;

int posx2 = 0;
int posy2 = 0;

int mode = 0;

void setup() {
    println("Hello World");
    size(640, 480);
    image = loadImage(fileName);
}

void draw() {
    hsv = filter.filter(image);
    image(hsv, 0, 0);
    image(image, image.width, 0);
    
    
    if (mode == 1 && posx1 != 0 && posy1 != 0 && posx2 != 0 && posy2 != 0) {
        stroke(255, 0, 0);
        noFill();
        int w = Math.abs(posx1 - posx2);
        int h = Math.abs(posy1 - posy2);
        int x = Math.min(posx1, posx2);
        int y = Math.min(posy1, posy2);
        rect(x, y, w, h);
    }
}

void mousePressed() {
    posx1 = mouseX;
    posy1 = mouseY;

    posy2 = 0;
    posx2 = 0;
    p1 = hsv.get(posx1, posy1);

    if (mode == 1){
        return;
    }
    
    int h = (int)red(p1);
    int s = (int)green(p1);
    int v = (int)blue(p1);
    
    println("H: " + h + " S: " + s + " V: " + v);
}

void mouseReleased() {
    if (mode == 0) {return;}

    posx2 = mouseX;
    posy2 = mouseY;
    
    p2 = hsv.get(posx2, posy2);
    
    int h1 = (int)red(p1);
    int s1 = (int)green(p1);
    int v1 = (int)blue(p1);
    
    int h2 = (int)red(p2);
    int s2 = (int)green(p2);
    int v2 = (int)blue(p2);
    
    if (Math.min(h1, h2) ==  h1) {
        println("H: " + h1 + " - " + h2);
    } else{
        println("H: " + h2 + " - " + h1);
    }
    
    if (Math.min(s1, s2) ==  s1) {
        println("S: " + s1 + " - " + s2);
    } else{
        println("S: " + s2 + " - " + s1);
    }
    
    if (Math.min(v1, v2) ==  v1) {
        println("V: " + v1 + " - " + v2);
    } else{
        println("V: " + v2 + " - " + v1);
    }
    
}


void keyPressed() {
    if (key == ' ') {
        switchMode();
    }    
}

void switchMode() {
    mode = (mode + 1) % 2;
    
    if (mode == 0) {
        println("Color Picker");
    } else {
        println("Range Picker");
    }
}