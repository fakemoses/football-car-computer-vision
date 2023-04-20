abstract class CalibBase{
    protected float value;
    
    protected final float MIN_VALUE = 0.0;
    protected final float MAX_VALUE = 1.0;
    
    public CalibBase(float value) {
        this.value = value;
    }
    
    public double getValue() {
        return value;
    }
    
    public void smallIncrement() {
        if (this.value >= MAX_VALUE) {
            this.value = MAX_VALUE;
            return;
        }
        
        this.value += 0.01;
    }
    
    public void largeIncrement() {
        if (this.value >= MAX_VALUE) {
            this.value = MAX_VALUE;
            return;
        }
        this.value += 0.05;
    }
    
    public void smallDecrement() {
        if (this.value <= MIN_VALUE) {
            this.value = MIN_VALUE;
            return;
        }
        
        this.value -= 0.01;
    }
    
    public void largeDecrement() {
        if (this.value <= MIN_VALUE) {
            this.value = MIN_VALUE;
            return;
        }
        this.value -= 0.05;
    }
    
    public void swap() {
        println("Nothing to swap");
    }
    
    public String[] getValues() {
        String[] values = new String[1];
        values[0] = String.valueOf(value);
        return values;
    }
    
    abstract public String getCalibName();
    
    public abstract void execute();
}