public class LineDetection extends DetectionThread{
    
    private Line detectedLine;
    private int minPointsSize = 500;
    
    private Detector<Line> lineDetector;
    private Boundary boundary;
    private  PImage boundaryResult;
    
    private final color lineColor = color(255, 0, 0);
    private final int lineThickness = 2;
    
    public LineDetection(MotorControl motorControl, ColorFilter colorFilter, Detector<Line> lineDetector, Boundary boundary) {
        super(motorControl, colorFilter);
        this.lineDetector = lineDetector;
        this.boundary = boundary;
    }
    
    public String getThreadName() {
        return "LineDetection";
    }
    
    public void run() {
        while(STARTED) {
            if (image == null) {
                delay(50);
                continue;
            }
            
            mask = colorFilter.filter(image);
            ArrayList<Line> detectedLinesArray = lineDetector.detect(image, mask);
            detectedLine = detectedLinesArray == null ? null : detectedLinesArray.get(0);
            if (boundary.isHelpNeeded(detectedLine)) {
                // println("Help needed");
                motorControl.notify(this, motorControl.Reverse(), 5);
            }
            delay(50);
        }
    }
    
    public PImage[] getResults() {
        if (image == null || mask == null) {
            return null;
        }
        PImage[] results = new PImage[3];
        
        results[0] = detectedLine == null ? image : drawLine(image, detectedLine, lineThickness, lineColor);
        results[1] = mask;
        results[2] = boundary.getBoundaryResult();
        return results;
    }
}