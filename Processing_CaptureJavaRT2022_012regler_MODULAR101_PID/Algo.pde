public class Algo {
    
    private IPCapture cam;
    Bildverarbeitung bildverarbeitung;
    LineDetection lineDetection;
    private int EVALRESULT;
    public Algo(IPCapture cam, Bildverarbeitung bildverarbeitung, LineDetection lineDetection) {
        // in constructor -> start all thread
        this.cam = cam;
        this.bildverarbeitung = bildverarbeitung;
        this.lineDetection = lineDetection;
    }
    
    public void startALL() {
        /* should bileVerarbaitung also run on different thread?
        Right now it is running on main Thread by runColorDetection();
        bildverarbeitung.start(); */
        lineDetection.startThread();
    }
    
    public void runColorExtraction() {
        bildverarbeitung.extractColorRGB(cam);
        
        // then maybe pakai getter -> set semua RGB dekat sini
        // boleh pass RGB dekat Thread for calculation kalau nak
    }
    
    
    
    public void Eval() {
        // Here will run evaluation
        if (lineDetection.getEvalValue() > 0) {
            // calc eval ?
            //something something
            // if pass -> set EVALRESULT
            // return;
        }
        
        // if (otherClass.getEvalValue())
        // same thing
        // early return if pass 
        
        // and so on..
    }
    
    public int getEvalResult() {
        return EVALRESULT;
    }
    
}

// todo : maybe add a method which Control which thread to Start/Stop accoring to Mode Neutral o. Attack
// eg. if Neutral -> LineDetection + BallSearch + PlayerSearch
// Attack -> LineDetection + GoalSearch + maybe BallSearchs


// todo: Thread race / Sync ?
