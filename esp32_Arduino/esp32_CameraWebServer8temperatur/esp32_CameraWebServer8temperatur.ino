#include "esp_camera.h"
#include "AsyncUDP.h"
#include "esp_wifi.h"

#include <WiFi.h>

//
// WARNING!!! PSRAM IC required for UXGA resolution and high JPEG quality
//            Ensure ESP32 Wrover Module or other board with PSRAM is selected
//            Partial images will be transmitted if image exceeds buffer size
//

// Select camera model
// #define CAMERA_MODEL_WROVER_KIT // Has PSRAM
//#define CAMERA_MODEL_ESP_EYE // Has PSRAM
//#define CAMERA_MODEL_M5STACK_PSRAM // Has PSRAM
//#define CAMERA_MODEL_M5STACK_V2_PSRAM // M5Camera version B Has PSRAM
//#define CAMERA_MODEL_M5STACK_WIDE // Has PSRAM
//#define CAMERA_MODEL_M5STACK_ESP32CAM // No PSRAM
#define CAMERA_MODEL_AI_THINKER // Has PSRAM
//#define CAMERA_MODEL_TTGO_T_JOURNAL // No PSRAM

#include "camera_pins.h"

const char* ssid = "PinnutNet 2.4 Ghz"; //Smartphone Pixel
const char* password = "ikanbilismasaklemakff12";

//const char* ssid = "carwifi"; //Smartphone Pixel
//const char* password = "wifipass";

unsigned long previousMillis = 0;
unsigned long interval = 1000; // every n second check

//const char* ssid = "TP-Link_3F12"; //Aaron's Laptop
//const char* password = "26643182";

AsyncUDP udp;

#define BLAU  13
#define LINKS 15
#define RECHTS 14
#define AUSGANG1 12
#define AUSGANG2 2
#define AUSGANG3 4

void startCameraServer();

/*
    https://circuits4you.com
    ESP32 Internal Temperature Sensor Example
*/

#ifdef __cplusplus
extern "C" {
#endif

uint8_t temprature_sens_read();

#ifdef __cplusplus
}
#endif

uint8_t temprature_sens_read();

void setup()
{
  //RGB LEDs:
  ledcAttachPin(BLAU, 1);   // 13 BLAU
  ledcAttachPin(LINKS, 2);  // 15 ROT == LINKS
  ledcAttachPin(RECHTS, 3); // 14 GRÜN == RECHTS

  ledcSetup(1, 12000, 8); // 12 kHz PWM, 8-bit resolution
  ledcSetup(2, 12000, 8);
  ledcSetup(3, 12000, 8);

  pinMode(AUSGANG1, OUTPUT);
  pinMode(AUSGANG2, OUTPUT);
  pinMode(AUSGANG3, OUTPUT);  //Kameralampe

  digitalWrite(AUSGANG1, LOW);
  digitalWrite(AUSGANG2, LOW);
  digitalWrite(AUSGANG3, LOW);


  Serial.begin(115200);
  Serial.setDebugOutput(true);
  Serial.println();

  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM;
  config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM;
  config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM;
  config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM;
  config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM;
  config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM;
  config.pin_href = HREF_GPIO_NUM;
  config.pin_sscb_sda = SIOD_GPIO_NUM;
  config.pin_sscb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM;
  config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 20000000;
  config.pixel_format = PIXFORMAT_JPEG;

  // if PSRAM IC present, init with UXGA resolution and higher JPEG quality
  //                      for larger pre-allocated frame buffer.
  if (psramFound()) {
    config.frame_size = FRAMESIZE_UXGA;
    config.jpeg_quality = 10;
    config.fb_count = 2;
  } else {
    config.frame_size = FRAMESIZE_SVGA;
    config.jpeg_quality = 12;
    config.fb_count = 1;
  }

#if defined(CAMERA_MODEL_ESP_EYE)
  pinMode(13, INPUT_PULLUP);
  pinMode(14, INPUT_PULLUP);
#endif

  // camera init
  esp_err_t err = esp_camera_init(&config);
  if (err != ESP_OK) {
    Serial.printf("Camera init failed with error 0x%x", err);
    return;
  }

  sensor_t * s = esp_camera_sensor_get();
  // initial sensors are flipped vertically and colors are a bit saturated
  if (s->id.PID == OV3660_PID) {
    s->set_vflip(s, 1); // flip it back
    s->set_brightness(s, 1); // up the brightness just a bit
    s->set_saturation(s, -2); // lower the saturation
  }
  // drop down frame size for higher initial frame rate
  s->set_framesize(s, FRAMESIZE_QVGA);

#if defined(CAMERA_MODEL_M5STACK_WIDE) || defined(CAMERA_MODEL_M5STACK_ESP32CAM)
  s->set_vflip(s, 1);
  s->set_hmirror(s, 1);
#endif
  //disable sleep for best performance
//  WiFi.mode(WIFI_STA);
//  esp_wifi_set_ps(WIFI_PS_NONE);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");

  startCameraServer();

  Serial.print("Camera Ready! Use 'http://");
  Serial.print(WiFi.localIP());
  Serial.println("' to connect");
}

void loop()
{

  //check for wifi connectivity
  unsigned long currentMillis = millis();
  // if WiFi is down, try reconnecting
  if ((WiFi.status() != WL_CONNECTED) && (currentMillis - previousMillis >= interval)) {
    WiFi.disconnect();
    WiFi.reconnect();
    previousMillis = currentMillis;
  }

  // put your main code here, to run repeatedly:
  //delay(10);
  if (udp.listen(6000))
  {

    //Serial.print("UDP Listening on IP: ");
    //Serial.println(WiFi.localIP());
    udp.onPacket([](AsyncUDPPacket packet)
    {
      /*
        Serial.print("UDP Packet Type: ");
        Serial.print(packet.isBroadcast()?"Broadcast":packet.isMulticast()?"Multicast":"Unicast");
        Serial.print(", From: ");
        Serial.print(packet.remoteIP());
        Serial.print(":");
        Serial.print(packet.remotePort());
        Serial.print(", To: ");
        Serial.print(packet.localIP());
        Serial.print(":");
        Serial.print(packet.localPort());
        Serial.print(", Length: ");
        Serial.print(packet.length());
        Serial.print(", Data: ");
      */
      Serial.write(packet.data(), packet.length());
      Serial.println();

      uint8_t *mat = packet.data();
      if (packet.length() >= 4 && mat[0] == 'L')
      {
        ledcWrite(2, (mat[1] - 48) * 100 + ((mat[2] - 48) * 10) + (mat[3] - 48));
      }
      else if (packet.length() >= 4 && mat[0] == 'R')
      {
        ledcWrite(3, (mat[1] - 48) * 100 + ((mat[2] - 48) * 10) + (mat[3] - 48));
      }
      else if (packet.length() >= 4 && mat[0] == 'A' && mat[1] == '1')
      {
        digitalWrite(AUSGANG1, HIGH);
      }
      else if (packet.length() >= 4 && mat[0] == 'B' && mat[1] == '1')
      {
        digitalWrite(AUSGANG2, HIGH);
      }
      else if (packet.length() >= 4 && mat[0] == 'C' && mat[1] == '1')
      {
        digitalWrite(AUSGANG3, HIGH);
      }
      else if (packet.length() >= 4 && mat[0] == 'A' && mat[1] == '0')
      {
        digitalWrite(AUSGANG1, LOW);
      }
      else if (packet.length() >= 4 && mat[0] == 'B' && mat[1] == '0')
      {
        digitalWrite(AUSGANG2, LOW);
      }
      else if (packet.length() >= 4 && mat[0] == 'C' && mat[1] == '0')
      {
        digitalWrite(AUSGANG3, LOW);
      }

      //reply to the client
      //packet.printf("Got %u bytes of data", packet.length());

      Serial.print("Temperature: ");

      // Convert raw temperature in F to Celsius degrees
      Serial.print((temprature_sens_read() - 32) / 1.8);
      Serial.println(" C");

      //Temperatur zurück geben:
      packet.printf("T%f", ((temprature_sens_read() - 32) / 1.8));
    });
  }

}
