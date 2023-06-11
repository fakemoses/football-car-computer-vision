/**

This class represents a thread for car detection.

It extends the DetectionThread class.
*/
public class CarDetection extends DetectionThread {
    
    private Detector<Rectangle> objectDetector;
    private ColorFilter colorFilter;
    
    /**
    
    Constructs a CarDetection object with the specified motor control,
    
    datacontainer, color filter, and object detector.
    
    @param motorControl the MotorControl for the car
    
    @param data the data container for storing detection results
    
    @param colorFilter the color filter for image processing
    
    @param objectDetector the object detector for car detection
    */
    public CarDetection(MotorControl motorControl, DataContainer data, ColorFilter colorFilter, Detector<Rectangle> objectDetector) {
        super(motorControl, data);
        
        this.objectDetector = objectDetector;
        this.colorFilter = colorFilter;
    }
    
    /** 
    
    Returns the name of the thread.
    @return the name of the thread
    */
    public String getThreadName() {
        return "CarDetection";
    }
    /**
    
    Runs the cardetection thread.
    This method is not implemented yet.
    @throws UnsupportedOperationException if the method is called
    */
    public void run() {
        throw new UnsupportedOperationException("Method not implemented yet.");
    }
    /**
    
    Gets the resultsof the car detection.
    This method is not implemented yet.
    @return an arrayof PImage containing the detection results
    @throws UnsupportedOperationException if the method is called
    */
    public PImage[] getResults() {
        throw new UnsupportedOperationException("Method not implemented yet.");
    }
}