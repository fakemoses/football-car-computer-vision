public class Regler
{
  private Antrieb antrieb;
  private float px, py, pz;
  public boolean start, stop;
  private boolean offS;
  SensorM sensorData;
  String direction ="";

  private float u_links, u_rechts;
  public float offSetX, offSetY, offSetZ;
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
    //load latest data from sensor
    getLatestDatainNormal();

    //2 seconds after start, set the offset
    if (!offS && System.currentTimeMillis() - startTime > 2000) {
      this.offSetX = (sensorData.x) / 90.0f;
      this.offSetY = (sensorData.y) / 90.0f;
      this.offSetZ = (sensorData.z) / 180.0f;
      offS = true;
    }

    // start moving if the tilt is below the threshold and the robot is not moving
    if ((px < tilt_thres || start) && !stop && (py > 0.05 || py < -0.05)) {

      start = true;
      float s =  VORTRIEB;
      float rf=0, rl=0, rr=0;

      //define the speed of the wheels depending on the direction
      if (py < -0.05)
        s *= -1;
      if (pz > -0.2 && pz < 0.2) {
        direction ="Straight";
        rf = (s*0.9f);
      }

      if (pz > 0.2)
      {
        direction ="Right";
        rl = -(0.6f);
        rr = (pz*.5f);
        rf = (s*0.9f);
      } else if (pz < -0.2)
      {
        direction ="Left";
        rr = -(0.6f);
        rl = (pz*.5f);
        rf = (s*0.9f);
      }
      
      //compute the speed of the wheels using vector addition
      float val = 0.6;
      if (rf < 0) {
        println("pos " + rf + "   " + s);
        if ( pz >-0.2 && pz < 0.2) {
          u_links = sqrt(pow(rf, 2)+pow(rl, 2));
          u_rechts = sqrt(pow(rf, 2)+pow(rr, 2));
        } else
        {
          u_links = sqrt(pow(rf*val, 2)+pow(rl, 2));
          u_rechts = sqrt(pow(rf*val, 2)+pow(rr, 2));
        }
      } else {
        println("neg " + rf + "   " + s);
        if ( pz >-0.2 && pz < 0.2) {
          u_links = -sqrt(pow(rf, 2)+pow(rl, 2));
          u_rechts = -sqrt(pow(rf, 2)+pow(rr, 2));
        } else
        {
          u_links = -sqrt(pow(rf*val, 2)+pow(rl, 2));
          u_rechts = -sqrt(pow(rf*val, 2)+pow(rr, 2));
        }
      }
      if (px > 0.8) {
        stop = true;
      }
    } else {
      u_links = 0.0;
      u_rechts = 0.0;
    }

    u_links*=ASYMMETRIE;
    u_rechts*=(2.0 - ASYMMETRIE);

    println("u_links: " + nf(u_links, 0, 2) + " u_rechts: " + nf(u_rechts, 0, 2) + " direction: " + direction  + " px: " + nf(px, 0, 2) + " py: " + nf(py, 0, 2) + " pz: " + nf(pz, 0, 2)+ " start: "+ start+ " offsetZ: "+ this.offSetZ + " sensorZ: "+ ((sensorData.z ) / 180.0f));


    antrieb.fahrt(u_links, u_rechts);
  }

  private void getLatestDatainNormal() {
    //convert the sensor data to a range of -1 to 1
    px = ((sensorData.x) / 90.0f) - offSetX;
    py = ((sensorData.y ) / 90.0f) - offSetY;
    pz = ((sensorData.z ) / 180.0f) - offSetZ;

    // Limit the values to the range of -1 to 1
    if (px < -1)
      px = -1;
    else if (px > 1)
      px = 1;

    if (py < -1)
      py = -1;
    else if (py > 1)
      py = 1;

    // Handle wrapping behavior if pz exceeds the range of -1 to 1
    if (pz < -1) {
      float range = 1 - (-1); // Calculate the range between -1 and 1
      pz = pz + range; // Wrap around by adding the range
    } else if (pz > 1) {
      float range = 1 - (-1); // Calculate the range between -1 and 1
      pz = pz - range; // Wrap around by subtracting the range
    }
  }
}
