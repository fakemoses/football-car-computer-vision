public class ThreadController {
    DetectionThread[] threads;
    
    public ThreadController(DetectionThread...threads) {
        this.threads = threads;
    }
    
    public void startAllThread() {
        for (DetectionThread t : threads) {
            t.startThread();
        }
    }
    
    public void updateImage(PImage image) {   
        for (DetectionThread t : threads) {
            t.setImage(image);
        }
    }
    
    public PImage[][] getDetectionResults() {
        PImage[][] images = new PImage[threads.length][];
        for (int i = 0; i < threads.length; i++) {
            PImage[] result = threads[i].getResults();
            images[i] = result != null ? result : new PImage[0];
        }
        return images;
    }
}