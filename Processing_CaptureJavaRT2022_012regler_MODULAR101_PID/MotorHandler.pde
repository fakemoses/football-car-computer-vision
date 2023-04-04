public enum HandlerPriority {
    PRIORITY_HIGH,
    PRIORITY_MEDIUM,
    PRIORITY_LOW;
    
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

class ForwardHandler extends MotorHandler {
    
    float direction;
    float links;
    float rechts;
    float mult = 0.20;
    
    ForwardHandler(Antrieb antrieb, float d) {
        super(antrieb);
        this.direction = d;
    }
    
    @Override
    public void execute() {
        if (direction > 0.2) {
            rechts = VORTRIEB - (mult * direction);
            links = VORTRIEB + (mult * direction);
        } else if (direction < - 0.2) {
            rechts = VORTRIEB + (mult * abs(direction));
            links = VORTRIEB - (mult * abs(direction));
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
        antrieb.fahrt(0, VORTRIEB * 0.91f);
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