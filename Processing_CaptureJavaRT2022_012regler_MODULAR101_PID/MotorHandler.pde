class ReverseHandler implements MotorHandler {
    private Antrieb antrieb;
    
    public ReverseHandler(Antrieb antrieb) {
        this.antrieb = antrieb;
    }
    
    @Override
    public void execute() {
        antrieb.fahrt( -0.8, -0.8);
    }
    
    public String getHandlerName() {
        return "ReverseHandler";
    }
}

class ForwardHandler implements MotorHandler {
    private Antrieb antrieb;
    
    float direction;
    float links;
    float rechts;
    float mult = 0.20;
    
    
    ForwardHandler(Antrieb antrieb, float d) {
        this.antrieb = antrieb;
        this.direction = d;
    }
    @Override
    public void execute() {
        // rechts = 0.2f * direction + 0.8f;
        // links = -0.2f * direction + 0.8f;
        if (direction > 0.2) {
            rechts = VORTRIEB + (mult * direction);
            links = VORTRIEB - (mult * direction);
            // rechts = 0.8f;
            // links = 0.6f;
        } else if (direction < - 0.2) {
            rechts = VORTRIEB - (mult * abs(direction));
            links = VORTRIEB + (mult * abs(direction));
            // rechts = 0.5f;
            // links = 0.8f;
        } else {
            rechts = VORTRIEB;
            links = VORTRIEB;
        }
        
        println("direction: " + direction + "  links: " + links + " rechts: " + rechts);
        rechts *= (2.0 - ASYMMETRIE);
        links *= ASYMMETRIE;
        
        antrieb.fahrt(links, rechts);
    }
    
    public String getHandlerName() {
        return "ForwardHandler";
    }
}


class TurnHandler implements MotorHandler {
    private Antrieb antrieb;
    
    TurnHandler(Antrieb antrieb) {
        this.antrieb = antrieb;
    }
    
    @Override
    public void execute() {
        antrieb.fahrt(0, 0.8);
    }
    
    public String getHandlerName() {
        return "TurnHandler";
    }
}

class StopForGoalHandler implements MotorHandler {
    private Antrieb antrieb;
    
    StopForGoalHandler(Antrieb antrieb) {
        this.antrieb = antrieb;
    }
    
    @Override
    public void execute() {
        antrieb.fahrt(0, 0);
    }
    
    public String getHandlerName() {
        return "StopForGoalHandler";
    }
}