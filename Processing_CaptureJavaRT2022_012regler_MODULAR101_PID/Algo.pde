public class Algo {
    
    private IPCapture cam;
    Bildverarbeitung bildverarbeitung;
    LineDetection lineDetection;
    Antrieb antrieb;
    private int EVALRESULT;
    boolean isHelpNeeded = false;
    int reverseCount = 0;
    
    public Algo(IPCapture cam, Bildverarbeitung bildverarbeitung, LineDetection lineDetection, Antrieb antrieb) {
        // in constructor -> start all thread
        this.cam = cam;
        this.bildverarbeitung = bildverarbeitung;
        this.lineDetection = lineDetection;
        this.antrieb = antrieb;
    }
    
    public void startALL() {
        /* should bileVerarbaitung also run on different thread?
        Right now it is running on main Thread by runColorDetection();
        bildverarbeitung.start(); */
        lineDetection.startThread();
    }
    
    public void runColorExtraction() {
        // println("runColorExtraction");
        bildverarbeitung.extractColorRGB(cam);
        lineDetection.setPoints(bildverarbeitung.getRedList());
        // then maybe pakai getter -> set semua RGB dekat sini
        // bolehpass RGB dekat Thread for calculation kalau nak
    }
    
    public void controlMotor() {
        if (lineDetection.boundary.isHelpNeeded() && !isHelpNeeded) {
            println("help");
            isHelpNeeded = true;
            reverseCount = 0;
            antrieb.fahrt( -1, -1);
        }
        
        if (isHelpNeeded) {
            ++reverseCount;
            println("helping " + reverseCount);
            if (reverseCount > 50) {
                isHelpNeeded = false;
            }
        }
        else{
            println("fahrt");
            antrieb.fahrt(1,1);
        }
    }
    
    
    public void Eval() {
        // Here willrun evaluation
        // todo: implement Mediator pattern
        // alternative Chain of Responsibility
        // or Strategy pattern
        // if (lineDetection.getEvalValue() > 0) {
        
        // println("eval");
        if (lineDetection.boundary.isHelpNeeded()) {
            println("help");
            antrieb.fahrt(0, 0);
            return;
            
        }
        println("fahrt");
        antrieb.fahrt(1,1);
        
        // if (otherClass.getEvalValue())
        // same thing
        // early return if pass 
        
        // and so on..
    }
    
    public int getEvalResult() {
        return EVALRESULT;
    }
    
}

// todo : maybe add a method which Control which thread to Start / Stop accoring to Mode Neutral o.Attack
// eg.ifNeutral -> LineDetection + BallSearch + PlayerSearch
// Attack ->LineDetection + GoalSearch + maybe BallSearchs


// todo : Thread race / Sync ?
