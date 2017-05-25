/*  
 This is an adaptation of sample code from libelium that is
 adapted to send data from temp, hum and lux sensors, as well as 
 battery level and internal temperature of the Plug & 
 Sense! module
 
 - Alex Ensminger
 */
 
#include <WaspXBee802.h>
#include <WaspFrame.h>
#include <WaspSensorAmbient.h>

uint8_t  panID[2] = {0x33,0x32}; 

// Define Freq Channel to be set: 
// Center Frequency = 2.405 + (CH - 11d) * 5 MHz
//   Range: 0x0B - 0x1A (XBee)
//   Range: 0x0C - 0x17 (XBee-PRO)
uint8_t  channel = 0x0C;

// Define the Encryption mode: 1 (enabled) or 0 (disabled)
uint8_t encryptionMode = 0;

// Define the AES 16-byte Encryption Key
char  encryptionKey[] = "WpspmotePonkKey2!"; 


// Destination MAC address
//////////////////////////////////////////
char RX_ADDRESS[] = "0013A20041022FDA";
//////////////////////////////////////////

// Define the Waspmote ID
char WASPMOTE_ID[] = "Ambient";


// define variable
char* sleepTime = "00:00:30:00"; 
uint8_t error;
float digitalTemperature;
float digitalHumidity;
float lux;
int sequence;


void setup()
{
  // init USB port
  USB.ON();
  USB.println(F("Sending ambient data example"));
  
  xbee802.setChannel( channel );
  xbee802.setPAN( panID );
  xbee802.setEncryptionMode( encryptionMode );
  xbee802.setLinkKey( encryptionKey );
  xbee802.writeValues();
  
  // store Waspmote identifier in EEPROM memory
  frame.setID( WASPMOTE_ID );
  
  // init XBee
  xbee802.ON();
  
}


void loop()
{
  
  //////////////////////////////////////////////
  // Read Sensor Data
  /////////////////////////////////////////////
 // Step 8. Turn on the Sensor Board

    //Turn on the RTC
    RTC.ON();
    //supply stabilization delay
    delay(100);

  // Step 9. Turn on the sensors
    SensorAmbient.setSensorMode(SENS_ON, SENS_AMBIENT_TEMPERATURE);
    SensorAmbient.setSensorMode(SENS_ON, SENS_AMBIENT_LUX);
     delay(10000);

  // Step 10. Read the sensors
    //Sensor temperature reading
    digitalTemperature = SensorAmbient.readValue(SENS_AMBIENT_TEMPERATURE);
  
    //Sensor humidty reading
    digitalHumidity = SensorAmbient.readValue(SENS_AMBIENT_HUMIDITY);

  
    //First dummy reading for analog-to-digital converter channel selection
    SensorAmbient.readValue(SENS_AMBIENT_LUX);
    //Sensor temperature reading
    //lux = SensorAmbient.readLUXdim();
    lux = SensorAmbient.readValue(SENS_AMBIENT_LUX);

  // Step 11. Turn off the sensors
    SensorAmbient.setSensorMode(SENS_OFF, SENS_AMBIENT_TEMPERATURE);
    SensorAmbient.setSensorMode(SENS_OFF, SENS_AMBIENT_LUX);
  
  
  ///////////////////////////////////////////
  // 1. Create ASCII frame
  ///////////////////////////////////////////  

  // create new frame
  frame.createFrame(ASCII);  
  
  // add frame fields
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
  frame.addSensor(SENSOR_IN_TEMP, RTC.getTemperature());
  //frame.addSensor(SENSOR_VAPI, xbee802.get);
  frame.addSensor(SENSOR_TCB, digitalTemperature);
  frame.addSensor(SENSOR_HUMB, digitalHumidity);
  frame.addSensor(SENSOR_LUX, lux);


  frame.showFrame();
  ///////////////////////////////////////////
  // 2. Send packet
  ///////////////////////////////////////////  

  xbee802.ON();
  // send XBee packet
  error = xbee802.send( RX_ADDRESS, frame.buffer, frame.length );   
  
  // check TX flag
  if( error == 0 )
  {
    USB.println(F("send ok"));
  }
  else 
  {
    USB.println(F("send error"));
  }
  
  xbee802.OFF();
  delay(100);
  
  
  //go into hibernate for some time specified at top
  PWR.deepSleep(sleepTime,RTC_OFFSET,RTC_ALM1_MODE1,ALL_OFF);
  // wait for five seconds
  //delay(5000);
}
