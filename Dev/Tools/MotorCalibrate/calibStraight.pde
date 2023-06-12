class CalibStraight extends CalibBase{

    private Antrieb antrieb;

    private float init;
    private int initCount = 3;
    private int count= 0;

    CalibStraight(Antrieb antrieb, float value, float init){
        super(value);
        this.antrieb = antrieb;
        this.init = init;
    }

    public String getCalibName(){
        return "CalibStraight";
    }

    public void execute(){
        if(count < initCount){
            antrieb.fahrt(init, init);
            count++;
            return;
        }
        
        antrieb.fahrt(value, value);
    }

    @Override
    public String[] getValues(){
        String[] values = new String[2];
        values[0] = "Init: " + String.valueOf(init);
        values[1] = "Value: " + String.valueOf(value);
        return values;
    }
}