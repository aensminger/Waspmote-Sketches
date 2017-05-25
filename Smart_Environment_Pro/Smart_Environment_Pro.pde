/*  
 This is an adaptation of sample code from libelium that is
 adapted to send data from C0 and C02 sensors, as well as 
 battery level and internal temperature of the Plug & 
 Sense! module
 
 - Alex Ensminger
 */
 
#include <WaspXBee802.h>
#include <WaspFrame.h>
#include <WaspSensorGas_v20.h>

// Destination MAC address
//////////////////////////////////////////
char RX_ADDRESS[] = "0013A20041022FDA";
//////////////////////////////////////////

// Define the Waspmote ID
char WASPMOTE_ID[] = "Enviro";


// define variables
char* sleepTime = "00:00:05:00"; 
uint8_t error;
float CO;
float CO2;
int sequence;


void setup()
{
  // init USB port
  USB.ON();
  USB.println(F("Sending sensor data example"));
  
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
  SensorGasv20.setBoardMode(SENS_ON);
  RTC.ON();
  //supply stabilization delay
  delay(100);
   
  SensorGasv20.configureSensor(SENS_SOCKET3CO, 1, 100);
  delay(100);
  //First dummy reading to set analog-to-digital channel
  SensorGasv20.readValue(SENS_SOCKET3A);
  CO = SensorGasv20.readValue(SENS_SOCKET3CO);  
   
  
  SensorGasv20.configureSensor(SENS_CO2, 7);
  SensorGasv20.setSensorMode(SENS_ON, SENS_CO2);    
  delay(30000);
  //First dummy reading to set analog-to-digital channel
  SensorGasv20.readValue(SENS_CO2);
  CO2 = SensorGasv20.readValue(SENS_CO2);  
  SensorGasv20.setSensorMode(SENS_OFF, SENS_CO2); 
  
  
  ///////////////////////////////////////////
  // 1. Create ASCII frame
  ///////////////////////////////////////////  

  // create new frame
  frame.createFrame(ASCII);  
  
  // add frame fields
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
  frame.addSensor(SENSOR_IN_TEMP, RTC.getTemperature());
  //frame.addSensor(SENSOR_VAPI, xbee802.get);
  frame.addSensor(SENSOR_CO, CO);
  frame.addSensor(SENSOR_CO2, CO2);


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
