public class UDPcomfort
{
    String TEMPERATUR = "";
    
    UDP udp;
    int PORT;
    String IP;
    public UDPcomfort(String IP, int PORT)
        {
        this.IP = IP;
        this.PORT = PORT;
        udp = new UDP(this, 6000);
        udp.listen(true);
    }
    
    public void send(int nr, int onoffpwm)
        {
        String message  = "C000"; 
        if (nr ==  0)
            {
            message = "L";
            if (onoffpwm < 100) message += "0";
            if (onoffpwm < 10) message += "0";
            message += onoffpwm;
        }
        else if (nr ==  1)
            {
            message = "R";
            if (onoffpwm < 100) message += "0";
            if (onoffpwm < 10) message += "0";
            message += onoffpwm;
        }
        else if (nr ==  2)
            {
            message = "A";
            message += onoffpwm;
            if (onoffpwm < 100) message += "0";
            if (onoffpwm < 10) message += "0";
        }
        else if (nr ==  3)
            {
            message = "B";
            message += onoffpwm;
            if (onoffpwm < 100) message += "0";
            if (onoffpwm < 10) message += "0";
        }
        else if (nr ==  4)
            {
            message = "C";
            message += onoffpwm;
            if (onoffpwm < 100) message += "0";
            if (onoffpwm < 10) message += "0";
        }
        udp.send(message, IP, PORT);
    }
    
    public String getTemperatur()
        {
        return TEMPERATUR;
    }
    
    void receive(byte[] data, String ip, int port) 
        {  // <-- extended handler
        
        
        // getthe "real" message =
        // forget the";\n" at the end <-- !!! only for a communication with Pd !!!
        data = subset(data, 0, data.length - 2);
        String message = new String(data);
        
        // print the result
        //   println("receive: \""+message+"\" from " + ip + " on port " + port);
        TEMPERATUR = "receive: \""+message+"\" " + ip + " " + port;
    }     
}
