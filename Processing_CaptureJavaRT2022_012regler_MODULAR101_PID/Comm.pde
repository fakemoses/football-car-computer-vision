import oscP5.*;
import netP5.*;

class Comm{
    OscP5 oscP5;
    NetAddress myRemoteLocation;
    int haveBall = 0;
    String uniqueName;
    int opponentHasBall = 0;
    
    public Comm(OscP5 oscP5, NetAddress myRemoteLocation, String uniqueName) {
        this.oscP5 = oscP5;
        this.myRemoteLocation = myRemoteLocation;
        this.uniqueName = uniqueName;
    }
    
    public void sendMessage(int msg) {
        OscMessage myMessage = new OscMessage(this.uniqueName);
        myMessage.add(msg);
        oscP5.send(myMessage, this.myRemoteLocation);
    }

    public getOpponentHasBall() {
        return this.opponentHasBall;
    }


    //any recieved messages are handled here
    public void onEventRun(OscMessage theOscMessage){
        if(theOscMessage.checkAddrPattern(this.uniqueName)==true) {
        /* check if the typetag is the right one. */
            if (theOscMessage.checkTypetag("i")) {
            /* parse theOscMessage and extract the values from the osc message arguments. */
            /* For messages with multiple add, use the get(i) where i is the index of the item*/
                int messageContent = theOscMessage.get(0).intValue();
                //println("### received an osc message with content "+messageContent);
                //car thing do here
                if (messageContent == 1) {
                    opponentHasBall = 1;
                } else {
                    opponentHasBall = 0;
                }
                return;
            }  
        } 
    }
}