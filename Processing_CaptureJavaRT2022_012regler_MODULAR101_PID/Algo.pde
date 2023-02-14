public class Algo {
    
    private IPCapture cam;
    Bildverarbeitung bildverarbeitung;
    LineDetection lineDetection;
    BallDetection ballDetection;
    CarDetection carDetection;
    
    
    public Algo(IPCapture cam, Bildverarbeitung bildverarbeitung, LineDetection lineDetection, BallDetection ballDetection, CarDetection carDetection) {
        // in constructor -> start all thread
        this.cam = cam;
        this.bildverarbeitung = bildverarbeitung;
        this.lineDetection = lineDetection;
        this.ballDetection = ballDetection;
        this.carDetection = carDetection;
    }
    
    public void startALL() {
        /* should bileVerarbaitung also run on different thread?
        Right now it is running on main Thread by runColorDetection();
        bildverarbeitung.start(); */
        lineDetection.startThread();
        // ballDetection.startThread();
        // carDetection.startThread();
    }
    
    public void runColorExtraction() {
        bildverarbeitung.extractColorRGB(cam);
        lineDetection.setPoints(bildverarbeitung.getRedList());
        // then maybe pakai getter -> set semua RGB dekat sini
        // bolehpass RGB dekat Thread for calculation kalau nak
    }
}

// todo : Thread race / Sync ?
