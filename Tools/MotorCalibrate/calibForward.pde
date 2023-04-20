class CalibForward extends CalibBase{

    private Antrieb antrieb;

    private float init;
    private int initCount = 3;
    private int count= 0;

    CalibForward(Antrieb antrieb, float value, float init){
        super(value);
        this.antrieb = antrieb;
        this.init = init;
    }

    public String getCalibName(){
        return "CalibForward";
    }

    public void execute(){
        if(count < initCount){
            antrieb.fahrt(init, init);
            count++;
            return;
        }
        
        antrieb.fahrt(value, value);
    }
}