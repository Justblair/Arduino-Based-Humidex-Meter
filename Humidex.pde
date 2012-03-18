// The Humidex Meter 
// Written by Blair Thompson (AKA Justblair)
// Based on the sketch by ladyada
// Example testing sketch for various DHT humidity/temperature sensors
// Written by ladyada, public domain

// The circuit:

// SD card attached to SPI bus as follows:
// MOSI - pin 11
// MISO - pin 12
// CLK - pin 13
// CS - pin 10

// LCD Connnected to digital pins as follows:
// 
// By Blair Thompson

// First lets add some libraries

#include <SD.h>						// Stock
#include <Wire.h>					// Stock 
#include <DHT.h>					// https://github.com/adafruit/DHT-sensor-library
#include <LiquidCrystal.h>			// Stock

// lets define some pins

#define DHTPIN 2					// what pin we're connected to
#define LCD_BACKLIGHT 9				// To conserve energy the lcd will light up om request
#define BRIGHTNESS 50				// We donw need full brightness for the LCD
#define BUTTON 14					// Swtch on
#define CHIP_SELECT 10				// CS pin for the SD card

const int DS1307_I2C_ADDRESS = 0x68;

// Some variables 

unsigned long last_reading = 0;		// We will use and If instead of a delay
unsigned long lcd_time = 10000;		// Record the time that the LCD was switched on
float old_t;						// To hold the temperature
float old_h;						// To hold the 
float t = 0;						// The temperature will be held in this var
float h = 0;						// The humidity will be held in this var
float Humidex = 0;					// For Humidex


byte second, minute, hour, day_of_week, day_of_month, month, year, sqwe, bst_flag;
byte serial_debug     = 0; // if "1" it switches on the debug messages to the serial port
byte serial_show_time = 1; // If "1" it switches on time updates to the serial port
// Uncomment whatever type you're using!

#define DHTTYPE DHT11				// DHT 11 
// #define DHTTYPE DHT22			// DHT 22  (AM2302)
// #define DHTTYPE DHT21			// DHT 21 (AM2301)

DHT dht(DHTPIN, DHTTYPE);
LiquidCrystal lcd(8, 7, 6, 5, 4, 3);

// Setup loop (Runs once)

void setup() {
	  Wire.begin();

	setDateDs1307(0, 50, 22, 5, 15, 3, 0, 1);

	lcd.begin(16,2);
	Serial.begin(9600);				// For Serial Communication to PC
	analogWrite (LCD_BACKLIGHT , BRIGHTNESS);
	Serial.println("Humidex Logger Live!");		// Welcome message
	Serial.print("Initializing SD card...");
	lcd.print("Humidex Logger");
	lcd.setCursor(0,1);
	lcd.print("Activated");
	dht.begin(); 
	pinMode (CHIP_SELECT, OUTPUT);
	pinMode (BUTTON , INPUT);
	pinMode (LCD_BACKLIGHT, OUTPUT);
	delay(3000);
	// see if the card is present and can be initialized:
	if (!SD.begin(CHIP_SELECT)) {
		Serial.println("Card failed, or not present");
		lcd.clear();
		lcd.setCursor (0,0);
		lcd.print ("Card failed");
		lcd.setCursor (0,1);
		lcd.print ("or not present");
	} else {
		Serial.println("card initialized.");
				lcd.clear();
		lcd.setCursor (0,0);
		lcd.print ("Card initialised");
	}
	set_time();
	compile_time = __TIME__;
	compile_date = __DATE__;
}

// Main Loop (loops and loops and loops)

void loop() {

	get_date_DS1307(&second, &minute, &hour, &day_of_week, &day_of_month, &month, &year, &sqwe, &bst_flag);


	// Reading temperature or humidity takes about 250 milliseconds!
	// Sensor readings may also be up to 2 seconds 'old' (its a very slow sensor)

	if (millis() > last_reading + 2000){	// Wait 2 seconds between readings
		last_reading = millis();
		h = dht.readHumidity();
		t = dht.readTemperature();
		Humidex = t + (5 * ((6.112 * pow( 10, 7.5 * t/(237.7 + t))*h/100) - 10))/9;

	}

	if (digitalRead(BUTTON) == LOW || Humidex >= 30){
		analogWrite (LCD_BACKLIGHT, BRIGHTNESS);
		lcd_time = millis();
	} else if (lcd_time + 2000 < millis()) {
		digitalWrite (LCD_BACKLIGHT, LOW);
	}

	if (isnan(t) || isnan(h)) {				// Error checking bit
		Serial.println("Failed to read from DHT");
		lcd.setCursor(0,0);
		lcd.println("Reading Failed");
		lcd.print("Check Hardware");
	} 
	else if (t != old_t || h != old_h) {	// Only act if there has been a change in readings.
		if (abs(t - old_t) + abs(h - old_h) > 1){
			analogWrite(LCD_BACKLIGHT, BRIGHTNESS);
			lcd_time = millis();
		}
		old_t = t;
		old_h = h;
		Serial.print(hour, DEC);
		Serial.print(":");
		Serial.print(minute, DEC);
		Serial.print(":");
		Serial.print(second, DEC);
		Serial.print(" H: "); 
		Serial.print(h);
		Serial.print("%, ");
		Serial.print(" T: "); 
		Serial.print(t);
		Serial.print("*C, ");
		Serial.print("H-DEX: ");
		Serial.print(Humidex);
		Serial.println("*C.");

		lcd.setCursor(0,0);
		lcd.print("H: "); 
		lcd.print(h, 0);
		lcd.print("%   ");
		lcd.print("T: "); 
		lcd.print(t, 0);
		lcd.print("C ");
		lcd.setCursor(0,1);
		lcd.print("Humidex: ");
		lcd.print(Humidex);
		lcd.print("C ");

		
		write_to_SD(t, h, Humidex);

		if (Humidex < 30) {
			Serial.println("No Discomfort");
		}
		else if (Humidex < 40) {
			Serial.println ("Some Discomfort");
		}
		else if (Humidex <45) {
			Serial.println ("Great Discomfort");
		}
		else {
			Serial.print ("Danger Level");
			if (Humidex > 54){
				Serial.println (" - Heat Stroke");
			}
		}
	}
}

// There are functions here.

void write_to_SD(int _t ,int _h, int _humidex){
		String dataString = "";
		dataString += String(millis()/1000);
		dataString += ",";
		dataString += String(_t);
		dataString += ","; 
		dataString += String(_h);
		dataString += ","; 
		dataString += String(_humidex);

		// open the file. note that only one file can be open at a time,
		// so you have to close this one before opening another.
		File dataFile = SD.open("datalog.txt", FILE_WRITE);

		// if the file is available, write to it:
		if (dataFile) {
			dataFile.println(dataString);
			dataFile.close();
			// print to the serial port too:
			Serial.println(dataString);
		}  
}

// *****************************************************************
// *             These functions talk to the DS1307                *
// *  Based on code from  tronixstuff.com/tutorials in turn based  *
// *          based on code by Maurice Ribble 17-4-2008 -          *
// *         http://www.glacialwanderer.com/hobbyrobotics          *
// *****************************************************************

// Convert normal decimal numbers to binary coded decimal
// The DS1307 stores most of the units it uses in this format
byte dec_to_bcd(byte val){
  return ( (val/10*16) + (val%10) );
}

// Convert binary coded decimal to normal decimal numbers
byte bcd_to_dec(byte val){
  return ( (val/16*10) + (val%16) );
}

// Gets the date and time from the ds1307
void get_date_DS1307(
byte *second,
byte *minute,
byte *hour,
byte *day_of_week,
byte *day_of_month,
byte *month,
byte *year,
byte *sqwe,
byte *bst_flag)
{
  // Reset the register pointer, this tells the DS1307 where we want to 
  // start reading from (ie, where the time is stored on the chip)
  Wire.beginTransmission(DS1307_I2C_ADDRESS);
  Wire.send(0);
  Wire.endTransmission();

  Wire.requestFrom(DS1307_I2C_ADDRESS, 9);          // Ask for 9 bytes from the DS1307

  // A few of these need masks because certain bits are control bits
  *second      = bcd_to_dec(Wire.receive() & 0x7f);
  *minute      = bcd_to_dec(Wire.receive());
  *hour        = bcd_to_dec(Wire.receive() & 0x3f);  // Need to change this if 12 hour am/pm
  *day_of_week = bcd_to_dec(Wire.receive());
  *day_of_month= bcd_to_dec(Wire.receive());
  *month       = bcd_to_dec(Wire.receive());
  *year        = bcd_to_dec(Wire.receive());
  *sqwe        = Wire.receive();                   
  // I was lazy here, I'm reading the Square Wave control so I dont have to address the Ram 
  // in a seperate read cycle
  *bst_flag    = Wire.receive();                  
  // This is a flag to tell the arduino if we are in Summer-time or Standard-time
  if (serial_debug == 1){                      // Send a message to make sure!
    Serial.println ("Time Read");
  }
  // Nothing left to do, all requested bytes are read and understood
}

//Sends the date and time to the DS1307
void setDateDs1307(
byte second,          // 0-59
byte minute,          // 0-59
byte hour,            // 1-23
byte day_of_week,     // 1-7
byte day_of_month,    // 1-28/29/30/31
byte month,           // 1-12
byte year,            // 0-99
byte bst_flag)        // 0-1
{
  Wire.beginTransmission(DS1307_I2C_ADDRESS);
  Wire.send(0);                   // Reset the register pointer like before
  Wire.send(dec_to_bcd(second));  // 0 to bit 7 starts the clock (ie if there are seconds stored 
  Wire.send(dec_to_bcd(minute));  // in the DS1307 then we are telling the time
  Wire.send(dec_to_bcd(hour));     
  Wire.send(dec_to_bcd(day_of_week));
  Wire.send(dec_to_bcd(day_of_month));
  Wire.send(dec_to_bcd(month));
  Wire.send(dec_to_bcd(year));
  Wire.send(0x10);                 
  // sends 0x10 (hex) 00010000 (binary) to control register - turns on 1hz square wave
  Wire.send(bst_flag);             // 0 == standard-time  1 == summer-time 
  Wire.endTransmission();          // Time sent to DS1307, this functions work is done
  if (serial_debug == 1){          // Send a message to make sure!
    Serial.println ("Time Sent");
  }
}
void set_time(){
	String compile_time = __TIME__;
	String compile_date = __DATE__;
	int hour = compile_time[0]
}