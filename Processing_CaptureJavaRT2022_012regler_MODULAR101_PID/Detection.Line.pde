public class LineDetection extends DetectionThread {
    
    private Detector<Line> lineDetector;
    DataContainer data;
    
    private Boundary boundary;
    private PImage boundaryResult;
    
    private ArrayList<Line> lines;
    private Line detectedLine;
    
    private final color lineColor = color(255, 0, 0);
    private final int lineThickness = 2;
    
    public LineDetection(MotorControl motorControl, DataContainer data, ColorFilter colorFilter, Detector<Line> lineDetector, Boundary boundary) {
        super(motorControl, colorFilter);
        
        this.data = data;
        
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
            lines = lineDetector.detect(image, mask);
            
            Line result = getLineFromDetectionResult(lines);
            
            detectedLine = (Line)data.update(this, result);
            
            // TODO: boundary method seperate, -> update, isHelpNeeded
            if (boundary.isHelpNeeded(detectedLine)) {
                motorControl.notify(this, HandlerPriority.PRIORITY_HIGH, motorControl.Reverse(5));
            }
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
    
    private Line getLineFromDetectionResult(ArrayList<Line> lines) {
        if (lines == null || lines.size() == 0) {
            return null;
        }
        return lines.get(0);
    }
}
