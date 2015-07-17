#define ROTATION_RAD_TO_TX_CHAR_CONV 254.0/2.0/PI
#define POSITION_FT_TO_TX_CHAR_CONV 254.0/50.0

double robot_x_pos = 0;
double robot_y_pos = 0;
double robot_rotation = 0;


void setup() {
  Serial.begin(115200);

}

void loop() {


  robot_x_pos = (int)(robot_x_pos + 1) % 40;
  robot_y_pos = (int)(robot_y_pos + 3 + robot_x_pos) % 40;
  robot_rotation = atan(robot_x_pos/robot_y_pos);

  Serial.write('~');
  Serial.write((char)(robot_x_pos*POSITION_FT_TO_TX_CHAR_CONV));
  Serial.write((char)(robot_y_pos*POSITION_FT_TO_TX_CHAR_CONV));
  Serial.write((char)(robot_rotation*ROTATION_RAD_TO_TX_CHAR_CONV));

  delay(10);

}
