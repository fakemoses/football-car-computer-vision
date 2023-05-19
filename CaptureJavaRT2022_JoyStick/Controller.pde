import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;

public class Controller{

    private String controllerName;
    private ControlIO control;
    private ControlDevice stick;

    public Controller(PApplet applet, String controllerName){
        this.controllerName = controllerName;
        control = ControlIO.getInstance(applet);
    }

    public boolean isDeviceAvailable(){
        stick = control.filter(GCP.STICK).getMatchedDevice(controllerName);
        if(stick == null){
            return false;
        }
        return true;
    }
  
    public UserInput getUserInput() {
        float px = map(stick.getSlider("direction").getValue(), -1, 1, 0, width);
        float py = map(stick.getSlider("throttle").getValue(), -1, 1, 0, height); 

        UserInput input = new UserInput(px, py);
        return input;
    }
}

public class UserInput {
    public float px;
    public float py;

    public UserInput(float px, float py) {
        this.px = px;
        this.py = py;

    }
}
