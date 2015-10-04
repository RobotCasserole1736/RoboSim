#include <Arduino.h>

// ENABLE_DISPLAY_ERRORS - define this macro to print OS errors to the OLED display
#define ENABLE_DISPLAY_ERRORS

#ifdef ENABLE_DISPLAY_ERRORS
    //Arduino compiles files separately, so the definition must be cloned here.
    //bad coding practice, I know :(
    extern void display_disp_msg(char *);
    #include <string.h>
#endif



extern "C" {
/**
 *  Print file and line when configASSERT is defied like this.
 *
 * #define configASSERT( x ) if( ( x ) == 0 ) {assertMsg(__FILE__,__LINE__);}
 */
void assertMsg(const char* file, int line) {
    interrupts();
    Serial.print(file);
    Serial.write('.');
    Serial.println(line);
    Serial.flush();
    #ifdef ENABLE_DISPLAY_ERRORS
    display_disp_msg((char *)file);
    #endif
}
}  // extern "C"