public class Algo {
    DetectionThread[] threads;
    
    public Algo(DetectionThread...threads) {
        this.threads = threads;
    }
    
    public void startALL() {
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