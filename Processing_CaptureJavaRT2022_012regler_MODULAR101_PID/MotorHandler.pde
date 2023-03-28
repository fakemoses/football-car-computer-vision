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
    
    private final HandlerPriority priority;
    private Antrieb antrieb;
    
    public MotorHandler(Antrieb antrieb, HandlerPriority priority) {
        this.antrieb = antrieb;
        this.priority = priority;
    }
    
    public HandlerPriority getPriority() {
        return priority;
    }
    
    public abstract void execute();
    public abstract String getHandlerName();
}

class ReverseHandler extends MotorHandler {
    
    public ReverseHandler(Antrieb antrieb) {
        super(antrieb, HandlerPriority.PRIORITY_MEDIUM);
    }
    
    @Override
    public void execute() {
        antrieb.fahrt( -0.8, -0.8);
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
        super(antrieb, HandlerPriority.PRIORITY_MEDIUM);
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


class TurnHandler extends MotorHandler {
    
    TurnHandler(Antrieb antrieb) {
        super(antrieb, HandlerPriority.PRIORITY_LOW);
    }
    
    @Override
    public void execute() {
        antrieb.fahrt(0, 0.8);
    }
    
    public String getHandlerName() {
        return "TurnHandler";
    }
}

class StopForGoalHandler extends MotorHandler {
    
    StopForGoalHandler(Antrieb antrieb) {
        super(antrieb, HandlerPriority.PRIORITY_MEDIUM);
    }
    
    @Override
    public void execute() {
        antrieb.fahrt(0, 0);
    }
    
    public String getHandlerName() {
        return "StopForGoalHandler";
    }
}