public class CarDetection extends DetectionThread {
    
    private Detector<Rectangle> objectDetector;
    private ColorFilter colorFilter;
    
    public CarDetection(MotorControl motorControl, DataContainer data, ColorFilter colorFilter, Detector<Rectangle> objectDetector) {
        super(motorControl, data);
        
        this.objectDetector = objectDetector;
        this.colorFilter = colorFilter;
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