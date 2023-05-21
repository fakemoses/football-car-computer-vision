public class Regler
{
  private Antrieb antrieb;
  private float px, py, pz;
  public boolean start, stop;
  private boolean offS;
  SensorM sensorData;
  String direction ="";

  private float u_links, u_rechts;

  //reset to private later -> just to print some stuffs
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
    getLatestDatainNormal();
    //takes time to load app. 2s is fine
    if (!offS && System.currentTimeMillis() - startTime > 2000) {
      this.offSetX = (sensorData.x) / 90.0f;
      this.offSetY = (sensorData.y) / 90.0f;
      this.offSetZ = (sensorData.z) / 180.0f;
      offS = true;
    }

    //TODO: Sensor seems to be inverted -> need to check if it's the case for all phones
    // start is when the phone is slanted to the left, stop when to the right -> pz is checked
    if ((px < tilt_thres || start) && !stop && (py > 0.05 || py < -0.05)) {

      start = true;
      float s =  VORTRIEB * py * 2.5f;
      if (pz > -0.1 && pz < 0.1) {
        direction ="Straight";  // added (-) to make car forward when head moves down, but car reverse when head moves up
        u_links = s * -0.8f;
        u_rechts = s * -0.8f;
      } else if (pz > 0.1)
      {
        direction ="Right";
        u_links = s * 0.5f;
        u_rechts = (s*0.6f) + pz;
      } else if (pz < -0.1)
      {
        direction ="Left";   // for MT1 car, i make left turning little stronger than right to make it balanced 
        u_links = (s*0.7f) + abs(pz);  // HAVE TO RECHECK VALUES WITH OTHER CAR
        u_rechts = s * 0.6f;
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
    // convert data to normal and clamp between [-1,1] since it's in degree for all, for x and y / 90.0f and for z / 180.0f
    // Don't forget to consider the offset for z. Also consider the direction of the angle. since Z is in between [-180,180]
    // Z Offset is too big due to the phone rotation, hence when eg: OffsetZ = 0.6, when we move the phone to right, it will increase from 0.6
    // gradually to a certain value. Hence when adding this value with the offset

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
