import processing.core.PApplet;
import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;

public class SensorM{

  private Sensor sensorVector;
  private SensorManager manager;

  PApplet parent;
  Context context;

  public float x,y,z;

  //listener for rotation vector sensor
  private RotVecListener listenerRotVec;
  
  public SensorM(PApplet parent){
    // passing parent to get access to activity and context
    this.parent = parent;
    this.context = parent.getActivity();

    //initialize sensor manager and sensor for rotation vector
    this.manager = (SensorManager)context.getSystemService(Context.SENSOR_SERVICE);
    this.sensorVector = manager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);

    //initialize and register listener for rotation vector sensor
    this.listenerRotVec = new RotVecListener(this);
    this.manager.registerListener(listenerRotVec, sensorVector, SensorManager.SENSOR_DELAY_NORMAL);
  }
  
}

// listener for rotation vector sensor
class RotVecListener implements SensorEventListener {
  private SensorM sensorM;
  float[] rotationMatrix = new float[9];
  float[] orientation = new float[3];

  public RotVecListener(SensorM sensorM){
    this.sensorM = sensorM;
  }

  // listen to sensor and update rotation matrix and orientation whenever new sensor data is available
  public void onSensorChanged(SensorEvent event) {
        // Get rotation vector from sensor data
        float[] rotationVector = new float[4];
        System.arraycopy(event.values, 0, rotationVector, 0, 4);

        // Convert rotation vector to rotation matrix
        SensorManager.getRotationMatrixFromVector(rotationMatrix, rotationVector);

        // Calculate device orientation
        SensorManager.getOrientation(rotationMatrix, orientation);

        float x = -(float) Math.toDegrees(orientation[1]);
        float y = -(float) Math.toDegrees(orientation[2]);
        float z = (float) Math.toDegrees(orientation[0]);

        sensorM.x = x;
        sensorM.y = y;
        sensorM.z = z;
  }

  //do nothing. Just required to be override as part of SensorEventListener
  public void onAccuracyChanged(Sensor sensor, int accuracy) {
  }
}
