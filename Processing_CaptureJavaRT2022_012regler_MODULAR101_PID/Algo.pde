public class Algo {
    DetectionThread[] threads;
    
    
    public Algo(DetectionThread...threads) {
        this.threads = threads;
    }
    
    public void startALL() {
        /* 
        * should bildVerarbaitung also run on different thread?
        * Right now it is running on main Thread by runColorDetection();
        */
        for (DetectionThread t : threads) {
            t.startThread();
        }
    }
    
    public void updateImage(PImage image) {   
        for (DetectionThread t : threads) {
            t.setImage(image);
        }
    }
    
    public PImage[][] getTIResult() {
        PImage[][] images = new PImage[threads.length][];
        for (int i = 0; i < threads.length; i++) {
            PImage[] result = threads[i].getResults();
            images[i] = result != null ? result : new PImage[0];
        }
        return images;
    }
}

// todo : Thread race / Sync ?
