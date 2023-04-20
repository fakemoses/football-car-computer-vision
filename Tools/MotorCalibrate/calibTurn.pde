class CalibTurn extends CalibBase{
    
    private Antrieb antrieb;
    boolean swapping = false;
    
    CalibTurn(Antrieb antrieb, float value) {
        super(value);
        this.antrieb = antrieb;
    }
    
    public String getCalibName() {
        return "CalibTurn";
    }
    
    public void execute() {
        if (swapping) {
            antrieb.fahrt(0, value);
        } else {
            antrieb.fahrt(value, 0);
        }
    }
    
    @Override
    public void swap() {
        swapping = !swapping;
    }
}