const int analogInPinA0 = A0;
const int analogInPinA1 = A1;
const int analogInPinA2 = A2;

int mode = -1;
unsigned int sensorValue = 0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  Serial.println('a');
  char a = 'b';
  while(a != 'a')
  {
    a = Serial.read();
  }
}

void loop() {
  // put your main code here, to run repeatedly:
  if(Serial.available() > 0)
  {
    mode = Serial.read();
    if(mode == 'R')
    {
      sensorValue = analogRead(analogInPinA0);
      Serial.println(sensorValue);
      sensorValue = analogRead(analogInPinA1);
      Serial.println(sensorValue);
      sensorValue = analogRead(analogInPinA2);
      Serial.println(sensorValue);
    }
    delay(20);
  }
}
