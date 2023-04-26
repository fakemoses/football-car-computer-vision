public class Regler
{
    private Antrieb antrieb;
    private Controller control;
    private float px,py;
    private boolean start, stop;
    private UserInput input;

    private float u_links, u_rechts;

    public Regler(Antrieb antrieb, Controller control)
    {
        this.antrieb = antrieb;
        this.control = control;
        this.start = false; 
        this.stop = false;
    }
    
    public void fahren()
    {
      updateInput();
      //println("px: " + px + " py: " + py + " start: " + start + " stop: " + stop);
      if(py > 0.0 && start && !stop){
         
         float s =  VORTRIEB * abs(py);
         if(px > -0.05 && px < 0.05){
            u_links = s;
            u_rechts = s;
         }
         else if(px > 0.05)
         {
            u_links = s;
            u_rechts = (s < px) ? 0 : s - px;
         }
         else if (px < -0.05)
         {
            u_links = (s > px) ? 0 : s - px;
            u_rechts = s;
         }
      } else{
         u_links = 0.0;
         u_rechts = 0.0;
      }

      u_links*=ASYMMETRIE;
      u_rechts*=(2.0 - ASYMMETRIE);
      
      println("u_links: " + u_links + " u_rechts: " + u_rechts);
      antrieb.fahrt(u_links,u_rechts);
      
    }

   // px,py are according to the size of the screen. In this case 320 x 240
   // normalised to -1.0 - 1.0
    private void updateInput(){
      input = control.getUserInput();
      px = (input.px - (width/2.0)) / (width/2.0);
      py = ((input.py - (height/2.0)) / (height/2.0)) * -1.0; ;
      start = input.start;
      stop = input.stop;
    }
    
}
