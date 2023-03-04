public class CarDetection extends DetectionThread {
    
    Detector<Rectangle> objectDetector;
    
    public CarDetection(MotorControl motorControl, ColorFilter colorFilter, Detector<Rectangle> objectDetector) {
        super(motorControl, colorFilter);
        this.objectDetector = objectDetector;
    }
    
    public String getThreadName() {
        return "CarDetection";
    }
    
    public void run() {
        throw new UnsupportedOperationException("Method not implemented yet.");
    }
    
    public PImage[] getResults() {
        throw new UnsupportedOperationException("Method not implemented yet.");
    }
}