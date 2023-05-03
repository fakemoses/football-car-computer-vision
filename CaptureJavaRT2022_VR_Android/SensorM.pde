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

  private RotVecListener listenerRotVec;
  
  public SensorM(PApplet parent){
    this.parent = parent;
    this.context = parent.getActivity();
    this.manager = (SensorManager)context.getSystemService(Context.SENSOR_SERVICE);

    this.sensorVector = manager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);
    this.listenerRotVec = new RotVecListener(this);
    this.manager.registerListener(listenerRotVec, sensorVector, SensorManager.SENSOR_DELAY_NORMAL);
  }
  
}

class RotVecListener implements SensorEventListener {
  private SensorM sensorM;
  float[] rotationMatrix = new float[9];
  float[] orientation = new float[3];

  public RotVecListener(SensorM sensorM){
    this.sensorM = sensorM;
  }

  public void onSensorChanged(SensorEvent event) {
      /// Get rotation vector from sensor data
        float[] rotationVector = new float[4];
        System.arraycopy(event.values, 0, rotationVector, 0, 4);

        // Convert rotation vector to rotation matrix
        SensorManager.getRotationMatrixFromVector(rotationMatrix, rotationVector);

        // Calculate device orientation
        SensorManager.getOrientation(rotationMatrix, orientation);

        float x = (float) Math.toDegrees(orientation[1]);
        float y = (float) Math.toDegrees(orientation[2]);
        float z = (float) Math.toDegrees(orientation[0]);

        sensorM.x = x;
        sensorM.y = y;
        sensorM.z = z;
  }

  public void onAccuracyChanged(Sensor sensor, int accuracy) {
  }
}
