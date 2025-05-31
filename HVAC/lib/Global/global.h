#ifndef global_h
#define global_h

#include <ThingsBoard.h>
#include <string.h>

extern float temperature;
extern float humidity;
extern float light_intensity;
extern float air_quality;

extern ThingsBoard tb;

extern bool led1_state;
extern bool led2_state;
extern int fan_state;

constexpr char LED1_STATE_ATTR[] = "LED1_STATE";
constexpr char LED2_STATE_ATTR[] = "LED2_STATE";
constexpr char FAN_STATE_ATTR[] = "FAN_STATE";
#endif // GLOBAL_HPP