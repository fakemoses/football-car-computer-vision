public enum HandlerPriority {
    PRIORITY_HIGH,
    PRIORITY_MEDIUM,
    PRIORITY_LOW,
    PRIORITY_LOWEST; // temporary priority for random handlers
    
    public boolean isHigherPriorityThan(HandlerPriority otherPriority) {
        return compareTo(otherPriority) < 0;
    }
    
    public boolean isLowerPriorityThan(HandlerPriority otherPriority) {
        return compareTo(otherPriority) > 0;
    }
    
    public boolean isSamePriorityAs(HandlerPriority otherPriority) {
        return compareTo(otherPriority) == 0;
    }
    
    public boolean isNotSamePriorityAs(HandlerPriority otherPriority) {
        return !isSamePriorityAs(otherPriority);
    }
    
    public boolean isHigherOrSamePriorityAs(HandlerPriority otherPriority) {
        return isSamePriorityAs(otherPriority) || isHigherPriorityThan(otherPriority);
    }
    
    public boolean isLowerOrSamePriorityAs(HandlerPriority otherPriority) {
        if (this == PRIORITY_LOWEST && otherPriority == PRIORITY_LOWEST) { // temporary priority for random handlers. avoid overriding
            return false;
        }
        return isSamePriorityAs(otherPriority) || isLowerPriorityThan(otherPriority);
    }
}

abstract class MotorHandler{
    private Antrieb antrieb;
    
    public MotorHandler(Antrieb antrieb) {
        this.antrieb = antrieb;
    }
    
    public abstract void execute();
    public abstract String getHandlerName();
}

class ReverseHandler extends MotorHandler {
    
    public ReverseHandler(Antrieb antrieb) {
        super(antrieb);
    }
    
    @Override
    public void execute() {
        antrieb.fahrt( -VORTRIEB, -VORTRIEB);
    }
    
    public String getHandlerName() {
        return "ReverseHandler";
    }
}

class StopHandler extends MotorHandler {
    
    public StopHandler(Antrieb antrieb) {
        super(antrieb);
    }
    
    @Override
    public void execute() {
        antrieb.fahrt(0, 0);
    }
    
    public String getHandlerName() {
        return "StopHandler";
    }
}

class ForwardHandler extends MotorHandler {
    
    float direction;
    float links;
    float rechts;
    float mult = 0.2f;
    float motorPower;
    
    ForwardHandler(Antrieb antrieb, float d, float motorPower) {
        super(antrieb);
        this.direction = d;
        this.motorPower = motorPower;
    }
    
    @Override
    public void execute() {
        if (direction > 0.2) {
            rechts = motorPower * (VORTRIEB + (mult * direction));
            links = motorPower * (VORTRIEB - (mult * direction));
        } else if (direction < - 0.2) {
            rechts = motorPower * (VORTRIEB - (mult * abs(direction)));
            links = motorPower * (VORTRIEB + (mult * abs(direction)));
        } else {
            rechts = VORTRIEB * 0.95f;
            links = VORTRIEB * 0.95f;
        }
        
        if (TAUSCHE_ANTRIEB_LINKS_RECHTS)
            println("direction: " + direction + "  links: " + rechts + " rechts: " + links + " Motor Power: " + motorPower);
        else
            println("direction: " + direction + "  links: " + links + " rechts: " + rechts + " Motor Power: " + motorPower);
        rechts *= (2.0 - ASYMMETRIE);
        links *= ASYMMETRIE;
        
        antrieb.fahrt(links, rechts);
    }
    
    public String getHandlerName() {
        return "ForwardHandler";
    }
}


class TurnHandler extends MotorHandler {
    
    boolean executed = false;
    
    TurnHandler(Antrieb antrieb) {
        super(antrieb);
    }
    
    @Override
    public void execute() {
        if (!executed) {
            antrieb.fahrt(0, VORTRIEB);
            executed = true;
        }  
        antrieb.fahrt(0, VORTRIEB * 0.92f);
    }
    
    public String getHandlerName() {
        return "TurnHandler";
    }
}

class StopForGoalHandler extends MotorHandler {
    
    StopForGoalHandler(Antrieb antrieb) {
        super(antrieb);
    }
    
    @Override
    public void execute() {
        antrieb.fahrt(0, 0);
    }
    
    public String getHandlerName() {
        return "StopForGoalHandler";
    }
}