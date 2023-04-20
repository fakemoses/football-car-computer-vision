class CalibSymmetrie extends CalibBase{
    
    private Antrieb antrieb;
    
    private float init;
    
    CalibSymmetrie(Antrieb antrieb, float value, float init) {
        super(value);
        this.antrieb = antrieb;
        this.init = init;
    }
    
    public String getCalibName() {
        return "CalibSymmetrie";
    }
    
    public void execute() {
        antrieb.fahrt(init, init);
    }
    
    @Override
    public String[] getValues() {
        String[] values = new String[2];
        values[0] = "Init: " + String.valueOf(init);
        values[1] = "Value: " + String.valueOf(value);
        return values;
    }
}