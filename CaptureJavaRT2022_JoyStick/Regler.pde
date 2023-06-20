public class Regler
{
    private Antrieb antrieb;
    private Controller control;
    private float px,py;
    private UserInput input;

    private float u_links, u_rechts;

    public Regler(Antrieb antrieb, Controller control)
    {
        this.antrieb = antrieb;
        this.control = control;
    }
    
    // Motor Controller
    public void fahren()
    {
      String direction = "";

      //get latest input value
      updateInput();

      //only drive if throttle is pressed with minimum threshold for both directions 
      if((py > 0.05 || py < -0.05)){

         float s =  VORTRIEB * py;
         if(px > -0.05 && px < 0.05){
            direction = "straight";
            u_links = s;
            u_rechts = s;
         }
         if(s > 0.0){
            if(px > 0.05)
            {
               direction = "right";
               u_links = s;
               u_rechts = (s-px < 0) ? 0 : s - px;;
            }
            else if (px < -0.05)
            {
               direction = "left";
               u_links = (s - abs(px) < 0) ? 0 : s - abs(px);
               u_rechts = s;
            }
         }else{
            if(px > 0.05)
            {
               direction = "right";
               u_links = s;
               u_rechts = (s+px > 0) ? 0 : s + px;;
            }
            else if (px < -0.05)
            {
               direction = "left";
               u_links = (s - px > 0) ? 0 : s - px;
               u_rechts = s;
            }
         }
      } else{
         u_links = 0.0;
         u_rechts = 0.0;
      }

      u_links*=ASYMMETRIE;
      u_rechts*=(2.0 - ASYMMETRIE);
      
      //println("u_links: " + u_links + " u_rechts: " + u_rechts + " Direction: " + direction + " px: " + px + " throttle: " + py);
      antrieb.fahrt(u_links,u_rechts);
      
    }

   // px,py are according to the size of the screen. In this case 320 x 240
   // normalised to -1.0 - 1.0
    private void updateInput(){
      input = control.getUserInput();
      px = (input.px - (width/2.0)) / (width/2.0) * 0.8f;
      py = -((input.py - (height/2.0)) / (height/2.0)) * 0.9f;
    }
    
}
