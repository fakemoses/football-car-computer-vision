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