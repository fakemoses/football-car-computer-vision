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
        // println("Adding point: " + e);
        return super.add(e);
    }
}