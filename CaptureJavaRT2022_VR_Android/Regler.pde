

public class Regler
{
    private Antrieb antrieb;
    private float px,py,pz;
    private boolean start, stop;
    private boolean offS;
    SensorM sensorData;
    String direction ="";

    private float u_links, u_rechts;
   
   //reset to private later -> just to print some stuffs
    public float offSetX,offSetY,offSetZ;
    long startTime;

    public Regler(Antrieb antrieb, SensorM sensorData)
    {
        this.antrieb = antrieb;
        this.sensorData = sensorData;
        this.start = false; 
        this.stop = false;
        this.offS = false;
        startTime = System.currentTimeMillis();
    }
    
    public void fahren()
    {
      getLatestDatainNormal();
      //takes time to load app. 2s is fine
      if(!offS && System.currentTimeMillis() - startTime > 2000){
        this.offSetX = (sensorData.x) / 90.0f;
        this.offSetY = (sensorData.y) / 90.0f;
        this.offSetZ = (sensorData.z) / 180.0f;
        offS = true;
      }

      //TODO: Sensor seems to be inverted -> need to check if it's the case for all phones
      // start is when the phone is slanted to the left, stop when to the right -> pz is checked
      if((px > 0.35 || start) && !stop && (py > 0.1 || py < -0.1)){
         
         start = true;
         float s =  VORTRIEB * py * (-1.95f);
         if(pz > -0.1 && pz < 0.1){
           direction ="Straight";
            u_links = s;
            u_rechts = s;
         }
         else if(pz > 0.1)
         {
           direction ="Right";
            u_links = (s < pz) ? 0 : s - pz;
            u_rechts = s;
         }
         else if (pz < -0.1)
         {
           direction ="Left";
            u_links = s;
            u_rechts = (s > pz) ? 0 : s - pz;
         }

         if(px < -0.35){
            stop = true;
         }

      } else{
         u_links = 0.0;
         u_rechts = 0.0;
      }

      u_links*=ASYMMETRIE;
      u_rechts*=(2.0 - ASYMMETRIE);
      
      println("u_links: " + nf(u_links,0,2) + " u_rechts: " + nf(u_rechts,0,2) + " direction: " + direction  + " px: " + nf(px,0,2) + " py: " + nf(py,0,2) + " pz: " + nf(pz,0,2));
      antrieb.fahrt(u_links,u_rechts);
      
    }

    private void getLatestDatainNormal(){
         // convert data to normal and clamp between [-1,1] since it's in degree for all, for x and y / 90.0f and for z / 180.0f
         // Don't forget to consider the offset for z. Also consider the direction of the angle. since Z is in between [-180,180]
         px = ((sensorData.x) / 90.0f)-offSetX;
         py = ((sensorData.y ) / 90.0f)-offSetY;
         pz = ((sensorData.z ) / 180.0f)-offSetZ;
         
         px = Math.max(-1.0f, Math.min(px, 1.0f));
         py = Math.max(-1.0f, Math.min(py, 1.0f));
         pz = Math.max(-1.0f, Math.min(pz, 1.0f));

    }

    
}
