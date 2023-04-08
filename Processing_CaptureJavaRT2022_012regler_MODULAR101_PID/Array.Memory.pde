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
}