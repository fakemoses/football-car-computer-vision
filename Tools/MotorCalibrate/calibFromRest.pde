class CalibFromRest extends CalibBase{

    private Antrieb antrieb;

    CalibFromRest(Antrieb antrieb,float value){
        super(value);
        this.antrieb = antrieb;
    }

    public String getCalibName(){
        return "CalibFromRest";
    }

    public void execute(){
        antrieb.fahrt(value, value);
    }
}