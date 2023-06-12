class MemoryArray<T> extends ArrayList<T>{
    
    private int LIMIT = 2;
    
    MemoryArray(int size) {
        super();
        for (int i = 0; i < size; i++) {
            add(null);
        }
    }
    
    public void setLimit(int limit) {
        this.LIMIT = limit;
    }
    
    public int getLimit() {
        return LIMIT;
    }
    
    public void addCurrentMemory(T t) {
        remove(0);
        add(t);
    }
    
    public T getLastRememberedMemory() {
        int count = 0;
        T returnVal = null;
        
        ListIterator<T> iterator = listIterator(size());
        while(iterator.hasPrevious()) {
            T t = iterator.previous();
            if (t != null) {
                returnVal = returnVal == null ? t : returnVal;
                ++count;
            }
            
            if (count == LIMIT) {
                return returnVal;
            }
        }
        return null;
    }
    
    public T[] getAllMemory() {
        return(T[]) toArray();
    }
}

public class DataContainer {
    
    private final ReentrantReadWriteLock rwl;
    private final Lock readLock;
    private final Lock writeLock;
    
    // TODO: MotorState -> state controlled by MotorControl
    // TODO: Should ROI also use MemoryArray?
    
    // Ball Memory
    private final int BALL_MEMORY_SIZE = 15;
    private MemoryArray<Rectangle> ballMemory;
    private Rectangle latestBallMemory;
    
    // Goal Memory
    private final int GOAL_MEMORY_SIZE = 15;
    private MemoryArray<Rectangle> goalMemory;
    private Rectangle latestGoalMemory;
    
    // Line Memory
    private Line latestLineMemory;
    
    // Object State
    private boolean isBallInRoi;
    private boolean isGoalInRoi;
    
    // Motor State 
    //TODO: Should this be combined together? sync with MotorState
    private boolean isSearch;
    private boolean isShot;
    
    
    public DataContainer() {
        this.rwl = new ReentrantReadWriteLock();
        this.readLock = rwl.readLock();
        this.writeLock = rwl.writeLock();
        
        this.ballMemory = new MemoryArray<Rectangle>(BALL_MEMORY_SIZE);        
        this.goalMemory = new MemoryArray<Rectangle>(GOAL_MEMORY_SIZE);
        
        this.isBallInRoi = false;
        this.isGoalInRoi = false;
    }
    
    public void update(DetectionThread instance, Shape shape) {
        try {
            writeLock.lock();
            route(instance, shape);
        } finally {
            writeLock.unlock();
        }
    }
    
    private void route(DetectionThread instance, Shape shape) {
        if (instance instanceof BallDetection) {
            ballDetectionRoute((Rectangle) shape);
            return;
        } 
        
        if (instance instanceof GoalDetection) {
            goalDetectionRoute((Rectangle) shape);
            return;
            
        } 
        
        if (instance instanceof LineDetection) {
            lineDetectionRoute((Line) shape);
            return;
            
        }
        
        throw new IllegalArgumentException("Unknown instance type. Check Implementation");
    }
    
    private void ballDetectionRoute(Rectangle shape) {
        ballMemory.addCurrentMemory(shape);
        latestBallMemory = ballMemory.getLastRememberedMemory();
    }
    
    private void goalDetectionRoute(Rectangle shape) {
        goalMemory.addCurrentMemory(shape);
        latestGoalMemory = goalMemory.getLastRememberedMemory();
    }
    
    private void lineDetectionRoute(Line line) {
        latestLineMemory = line;
    }
    
    private Rectangle getLatestBallMemory() {
        try{
            readLock.lock();
            return latestBallMemory;
        } finally {
            readLock.unlock();
        }
    }
    
    private Rectangle getLatestGoalMemory() {
        try{
            readLock.lock();
            return latestGoalMemory;
        } finally {
            readLock.unlock();
        }
    }
    
    private Line getLatestLineMemory() {
        try{
            readLock.lock();
            return latestLineMemory;
        } finally {
            readLock.unlock();
        }
    }
    
    public boolean isBallDetected() {
        try{
            readLock.lock();
            return latestBallMemory != null;
        } finally {
            readLock.unlock();
        }
    }
    
    public boolean isGoalDetected() {
        try{
            readLock.lock();
            return latestGoalMemory != null;
        } finally {
            readLock.unlock();
        }
    }
    
    public boolean isLineDetected() {
        try{
            readLock.lock();
            return latestLineMemory != null;
        } finally {
            readLock.unlock();
        }
    }
    
    public void setIsBallInRoi(boolean isBallInRoi) {
        try{
            writeLock.lock();
            this.isBallInRoi = isBallInRoi;
        } finally {
            writeLock.unlock();
        }
    }
    
    public boolean isBallInRoi() {
        try{
            readLock.lock();
            return isBallInRoi;
        } finally {
            readLock.unlock();
        }
    }
    
    public void setIsGoalInRoi(boolean isGoalInRoi) {
        try{
            writeLock.lock();
            this.isGoalInRoi = isGoalInRoi;
        } finally {
            writeLock.unlock();
        }
    }
    
    public boolean isGoalInRoi() {
        try{
            readLock.lock();
            return isGoalInRoi;
        } finally {
            readLock.unlock();
        }
    }
    
    public void setIsSearch(boolean isSearch) {
        try{
            writeLock.lock();
            this.isSearch = isSearch;
        } finally {
            writeLock.unlock();
        }
    }
    
    public boolean isSearch() {
        try{
            readLock.lock();
            return isSearch;
        } finally {
            readLock.unlock();
        }
    }
    
    public void setIsShot(boolean isShot) {
        try{
            writeLock.lock();
            this.isShot = isShot;
        } finally {
            writeLock.unlock();
        }
    }
    
    public boolean isShot() {
        try{
            readLock.lock();
            return isShot;
        } finally {
            readLock.unlock();
        }
    }     
}

// Util class to visualize the boundary of the current line
public class Boundary {
    
    private Line prevLine = null;
    private Line currentLine = null;
    
    private final int maxPixelsCount;
    private double threshhold = 0.3;
    private int greenCount = 0;
    private PImage greenImage;
    private PImage boundaryResult;
    
    public Boundary(PImage image) {
        this(image.width, image.height);              
    }
    
    public Boundary(int w, int h) {
        this.greenImage = new PImage(w, h, RGB);
        int[] pixels = greenImage.pixels;
        for (int i = 0; i < pixels.length; i++) {
            pixels[i] = color(0, 255, 0);
        }
        maxPixelsCount = pixels.length;
        boundaryResult = greenImage.copy();
    }
    
    public boolean isHelpNeeded(Line l) {
        boundaryResult = greenImage.copy();
        if (l == null) {
            greenCount = maxPixelsCount;
            return false;
        }   
        updateImage(l);
        double percentage = (double)greenCount / maxPixelsCount;
        return percentage < threshhold;
    }
    
    private void updateImage(Line l) {
        currentLine = l;
        if (prevLine == null) {
            prevLine = l;
            return;
        }
        greenCount = 0;
        int[] pixels = boundaryResult.pixels;
        for (int i = 0; i < boundaryResult.width; i++) {
            for (int j = 0; j < boundaryResult.height; j++) {
                int region = whereAmI(new Point(i, j));
                if (region == 1) {
                    greenCount++;
                } else if (region == 2) {
                    pixels[i + j * boundaryResult.width] = color(255, 0, 0);
                } else {
                    pixels[i + j * boundaryResult.width] = color(0, 0, 255);
                }
            }
        }
        prevLine = currentLine;
    }
    
    public PImage getBoundaryResult() {
        return boundaryResult;
    }
    
    
    // !MAX SUS CODE -> MORE TESTING NEEDED
    // TODO: Better Implementation
    
    // 1 = green -> Available
    // 2 = red -> Unavailable
    // 3 = blue -> Border Change
    
    private int whereAmI(Point p) {
        if (currentLine.isVertical() && prevLine.isVertical()) {
            if (p.x < currentLine.yIntercept() && p.x < prevLine.yIntercept()) {
                return 2;
            } else if (p.x > currentLine.yIntercept() && p.x > prevLine.yIntercept()) {
                return 1;
            } else {
                return 3;  
            }
        }
        
        if (currentLine.isVertical()) {
            if (p.x < currentLine.yIntercept()) {
                if (prevLine.gradient() * p.x + prevLine.yIntercept() > p.y) {
                    return 1;
                } else {
                    return 2;
                }
            }
            else {
                if (prevLine.gradient() * p.x + prevLine.yIntercept() > p.y) {
                    return 3;
                } else {
                    return 2;
                }
            }
        }
        
        if (prevLine.isVertical()) {
            if (p.x < prevLine.yIntercept()) {
                if (currentLine.gradient() * p.x + currentLine.yIntercept() > p.y) {
                    return 1;
                } else {
                    return 2;
                }
            }
            else {
                if (currentLine.gradient() * p.x + currentLine.yIntercept() > p.y) {
                    return 3;
                } else {
                    return 2;
                }
            }
        }
        
        if (p.y > currentLine.gradient() * p.x + currentLine.yIntercept() && p.y > prevLine.gradient() * p.x + prevLine.yIntercept()) {
            return 1;
        } else if (p.y < currentLine.gradient() * p.x + currentLine.yIntercept() && p.y < prevLine.gradient() * p.x + prevLine.yIntercept()) {
            return 2;
        } else {
            return 3;
        } 
    }
}

public enum BorderType {
    BLACK, REFLECT, REPLICATE
}

// Utility class for adding borders to images
// Used with ImageProcessing involving convolution / kernels
public class ImageBorderAdder {
    final private BorderType borderType;
    
    
    
    public ImageBorderAdder(BorderType borderType) {
        this.borderType = borderType; 
    }
    
    public PImage addBorder(PImage img, int borderSize) {        
        if (borderType == BorderType.REFLECT) {
            return addReflectBorder(img, borderSize);
        } 
        
        if (borderType == BorderType.REPLICATE) {
            return addReplicateBorder(img, borderSize);
        }      
        
        // default
        return addBlackBorder(img, borderSize);
    }
    
    
    private PImage addBlackBorder(PImage img, int borderSize) {
        PImage result = createImage(img.width + borderSize * 2, img.height + borderSize * 2, RGB);
        result.loadPixels();
        img.loadPixels();
        for (int x = 0; x < result.width; x++) {
            for (int y = 0; y < result.height; y++) {
                if (x < borderSize || x >= result.width - borderSize || y < borderSize || y >= result.height - borderSize) {
                    result.pixels[x + y * result.width] = color(0, 0, 0);
                } else{
                    result.pixels[x + y * result.width] = img.pixels[(x - borderSize) + (y - borderSize) * img.width];
                }
            }
        }
        result.updatePixels();
        return result;
    }
    
    private PImage addReflectBorder(PImage img, int borderSize) {
        PImage result = createImage(img.width + borderSize * 2, img.height + borderSize * 2, RGB);
        result.loadPixels();
        img.loadPixels();
        for (int x = 0; x < result.width; x++) {
            for (int y = 0; y < result.height; y++) {
                if (x < borderSize || x >= result.width - borderSize || y < borderSize || y >= result.height - borderSize) {
                    int x1 = x - borderSize;
                    int y1 = y - borderSize;
                    if (x1 < 0) {
                        x1 = -x1;
                    }
                    if (y1 < 0) {
                        y1 = -y1;
                    }
                    if (x1 >= img.width) {
                        x1 = img.width - (x1 - img.width) - 1;
                    }
                    if (y1 >= img.height) {
                        y1 = img.height - (y1 - img.height) - 1;
                    }
                    result.pixels[x + y * result.width] = img.pixels[x1 + y1 * img.width];
                } else {
                    result.pixels[x + y * result.width] = img.pixels[(x - borderSize) + (y - borderSize) * img.width];
                }
            }
        }   
        result.updatePixels();
        return result;
    }
    
    private PImage addReplicateBorder(PImage img, int borderSize) {
        PImage result = createImage(img.width + borderSize * 2, img.height + borderSize * 2, RGB);
        result.loadPixels();
        img.loadPixels();
        
        for (int x = 0; x < result.width; x++) {
            for (int y = 0; y < result.height; y++) {
                if (x < borderSize || x >= result.width - borderSize || y < borderSize || y >= result.height - borderSize) {
                    int x1 = x - borderSize;
                    int y1 = y - borderSize;
                    
                    if (x1 < 0) {
                        x1 = 0;
                    } else if (x1 >= img.width) {
                        x1 = img.width - 1;
                    }
                    
                    if (y1 < 0) {
                        y1 = 0;
                    } else if (y1 >= img.height) {
                        y1 = img.height - 1;
                    }
                    
                    result.pixels[x + y * result.width] = img.pixels[x1 + y1 * img.width];
                } else {
                    result.pixels[x + y * result.width] = img.pixels[(x - borderSize) + (y - borderSize) * img.width];
                }
            }
        }
        
        result.updatePixels();
        return result;
    }
}

// Utility class for drawing lines and rectangles directly on Image
// By searching for the points that make up the line or rectangle, and then
// setting the color of those points, we can draw directly on the image
// without having to use the Processing drawing functions.
class ImageUtils{
    
    public ImageUtils() {
    }
    
    PImage drawLine(PImage image, Line line, int thickness, color c) { 
        PointArray<Point> points = lineToPointArray(line, thickness);
        return drawPoint(image, points, c);
    }
    
    PointArray<Point> lineToPointArray(Line line, int thickness) { 
        PointArray<Point> points = line.getPoints(thickness);
        return points;
    }
    
    PImage drawRect(PImage image, Rectangle rect, int thickness, color c, boolean fill) { 
        PointArray<Point> points = rectToPointArray(rect, thickness, fill);
        return drawPoint(image, points, c);
    }
    
    PointArray<Point> rectToPointArray(Rectangle rect, int thickness, boolean fill) {
        PointArray<Point> points = new PointArray<Point>();
        if (thickness > 0) {
            for (int i = rect.x; i <= rect.x + rect.width; i++) {
                for (int j = ceil(rect.y - (thickness / 2)); j <= floor(rect.y + (thickness / 2)); j++) {
                    points.add(new Point(i, j));
                    points.add(new Point(i, j + rect.height));
                }
            }
            
            for (int i = rect.y; i <= rect.y + rect.height; i++) {
                for (int j = ceil(rect.x - (thickness / 2)); j <= floor(rect.x + (thickness / 2)); j++) {
                    points.add(new Point(j, i));
                    points.add(new Point(j + rect.width, i));
                }
            } 
        }
        
        if (fill) {
            for (int i = rect.x; i <= rect.x + rect.width; i++) {
                for (int j = rect.y; j <= rect.y + rect.height; j++) {
                    points.add(new Point(i, j));
                }
            }
        }
        return points;
    }
    
    PImage drawPoint(PImage image, PointArray<Point> points ,color c) { 
        PImage returnImage = image.copy();
        int[] pixels = returnImage.pixels;        
        for (Point p : points) {
            pixels[p.x + p.y * returnImage.width] = c;
        }
        return returnImage;
    }
}

// Custom Line class with extra methods
class Line extends Line2D.Double {
    
    private int w = 320;
    private int h = 240;
    
    Line() {
        this(new Point(), new Point());
    }
    
    Line(Point2D p1, Point2D p2) {
        super(p1, p2);
    }
    
    public boolean isVertical() {
        return getX1() == getX2();
    }
    
    public boolean isHorizontal() {
        return getY1() == getY2();
    }
    
    public void setWidth(int w) {
        this.w = w;
    }
    
    public void setHeight(int h) {
        this.h = h;
    }
    
    public void setDimensions(int w, int h) {
        this.w = w;
        this.h = h;
    }
    
    public double gradient() {
        return(getY2() - getY1()) / (getX2() - getX1());
    }
    
    public double yIntercept() {
        return getY1() - gradient() * getX1();
    }
    
    public Line intersectionAtImageBorder() {
        /*
        * start is start point
        * end is end point
        
        * start ideally would start on left image boundary
        * if not it will located at top image boundary
        * if not it will located at bottom image boundary
        * start will NEVER be located at right image boundary
        
        * end ideally would end on right image boundary
        * if not it willlocated at bottom image boundary
        * if not it willlocated at top image boundary
        * end will NEVER be located at left image boundary
        */
        
        Point2D start;
        Point2D end;
        
        Point2D p1 = getP1();
        Point2D p2 = getP2();
        
        if (isVertical()) {
            start = new Point((int)p1.getX(),0);
            end = new Point((int)p1.getX(),h);
            setLine(start, end);
            return this;
        }
        Point2D iLeft = intersection(new Line2D.Double(new Point(0,0), new Point(0,h)));
        Point2D iTop = intersection(new Line2D.Double(new Point(0,0), new Point(w,0)));
        Point2D iBottom = intersection(new Line2D.Double(new Point(0,h), new Point(w,h)));
        Point2D iRight = intersection(new Line2D.Double(new Point(w,0), new Point(w,h)));
        
        if (iLeft.getY() >= 0 && iLeft.getY() <= h - 1) {
            start = iLeft;
        } else {
            start = (iLeft.getY() < 0) ? iTop : iBottom;
        }
        
        if (iRight.getY() >= 0 && iRight.getY() <= h - 1) {
            end = iRight;
        } else {
            end = (iRight.getY() < 0) ? iTop : iBottom;
        }
        setLine(start, end);
        return this;
    }
    
    public Point2D intersection(Line2D line) {
        double x1 = getX1();
        double y1 = getY1();
        double x2 = getX2();
        double y2 = getY2();
        double x3 = line.getX1();
        double y3 = line.getY1();
        double x4 = line.getX2();
        double y4 = line.getY2();
        
        double x = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));
        double y = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));
        
        return new Point2D.Double(x,y);
    }
    
    
    public String toString() {
        return getP1().toString() + " -> " + getP2().toString();
    }
    
    public PointArray<Point> getPoints(int thickness) {
        PointArray<Point> points = new PointArray<Point>();
        Point2D p1 = getP1();
        Point2D p2 = getP2();
        
        if (isVertical()) {
            for (int y = (int)p1.getY(); y <= p2.getY(); y++) {
                for (int i = ceil((float)p1.getX() - thickness / 2); i <= floor((float)p1.getX() + thickness / 2); i++) {
                    points.add(new Point(i,y));
                }
            }
            return points;
        }
        
        double m = gradient();
        double c = yIntercept();
        for (int x = (int)p1.getX(); x <= (int)p2.getX(); x++) {
            int y = (int)(m * x + c);
            for (int i = ceil(y - thickness / 2); i <= floor(y + thickness / 2); i++) {
                points.add(new Point(x,i));
            }
        }
        
        if (p1.getY() <= p2.getY()) {
            for (int y = (int)p1.getY(); y <= p2.getY(); y++) {
                int x = (int)((y - c) / m);
                for (int i = ceil(x - thickness / 2); i <= floor(x + thickness / 2); i++) {
                    points.add(new Point(i,y));
                }
            }
        }
        else {
            for (int y = (int)p1.getY(); y >= p2.getY(); y--) {
                int x = (int)((y - c) / m);
                for (int i = ceil(x - thickness / 2); i <= floor(x + thickness / 2); i++) {
                    points.add(new Point(i,y));
                }
            }
        }
        return points;
    }   
}

// Util class for updating image pixels locations
// predefined the image witdth and height
// if the point is out of the image, it will not be added to the array
// handling of NullPointerException is not required
class PointArray<E extends Point2D> extends ArrayList<E> {
    private final int MAX_WIDTH;
    private final int MAX_HEIGHT;
    
    public PointArray(int width, int height) {
        MAX_WIDTH = width;
        MAX_HEIGHT = height;
    }
    
    public PointArray() {
        this(320,240);
    }
    
    @Override
    public boolean add(E e) {
        if (e.getX() < 0 || e.getX() >= MAX_WIDTH || e.getY() < 0 || e.getY() >= MAX_HEIGHT) {
            return false;
        }
        return super.add(e);
    }
}

