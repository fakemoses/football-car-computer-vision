class PointArray<E> extends ArrayList<E> {
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
        if (e instanceof Point) {
            Point p = (Point) e;
            if (p.x < 0 || p.x >= MAX_WIDTH || p.y < 0 || p.y >= MAX_HEIGHT) {
                // println("Point out of bounds: " + p.toString());
                return false;
            }
        }
        return super.add(e);
    }
}