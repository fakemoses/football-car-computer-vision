// Example implementation of a thread

public class LineDetection2 extends DetectionThread{
    
    private Line detectedLine;
    private int minPointsSize = 500;
    
    private LineDetector lineDetector;
    private Boundary2 boundary;
    private  PImage boundaryResult;
    
    public LineDetection2(MotorControl motorControl, ColorFilter colorFilter, LineDetector lineDetector, Boundary2 boundary) {
        super(motorControl, colorFilter);
        this.lineDetector = lineDetector;
        this.boundary = boundary;
    }
    
    public String getThreadName() {
        return "LineDetection2";
    }
    
    public void run() {
        while(STARTED) {
            if (image == null) {
                delay(50);
                continue;
            }
            
            mask = colorFilter.filter(image);
            detectedLine = lineDetector.detect(image, mask);
            if (boundary.isHelpNeeded(detectedLine)) {
                println("Help needed");
            }
            delay(50);
        }
    }
    
    public PImage[] getResults() {
        if (image == null || mask == null) {
            return null;
        }
        PImage[] results = new PImage[3];
        
        results[0] = detectedLine == null ? image : drawLine(image, detectedLine, 2, color(255, 0, 0));
        results[1] = mask;
        results[2] = boundary.getBoundaryResult();
        return results;
    }
}
