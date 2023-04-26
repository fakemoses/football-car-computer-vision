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
        float px = map(stick.getSlider("X").getValue(), -1, 1, 0, width);
        float py = map(stick.getSlider("Y").getValue(), -1, 1, 0, height);
        boolean start = stick.getButton("Start").pressed();
        boolean stop = stick.getButton("Stop").pressed();

        UserInput input = new UserInput(px, py, start, stop);
        return input;
    }
}

public class UserInput {
    public float px;
    public float py;
    public boolean start;
    public boolean stop;

    public UserInput(float px, float py, boolean start, boolean stop) {
        this.px = px;
        this.py = py;
        this.start = start;
        this.stop = stop;
    }
}
