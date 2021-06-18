#include <Bela.h>
#include <libraries/Trill/Trill.h>

#define NUM_TOUCH 5 // Number of touches on Trill sensor

// Trill object declaration
Trill touchSensor;

// Location of touches on Trill Bar
float gTouchLocation[NUM_TOUCH] = {0.0, 0.0, 0.0, 0.0, 0.0};
// Size of touches on Trill Bar
float gTouchSize[NUM_TOUCH] = {0.0, 0.0, 0.0, 0.0, 0.0};
// Number of active touches
int gNumActiveTouches = 0;

// Sleep time for auxiliary task in microseconds
unsigned int gTaskSleepTime = 12000; // microseconds

// Provided by bela.nim
extern "C" {
void livecore_cc_write(int idx, float value);
bool livecore_setup(BelaContext *context, void *userData);
void livecore_render(BelaContext *context, void *userData);
void livecore_cleanup(BelaContext *context, void *userData);
}

/*
 * Function to be run on an auxiliary task that reads data from the Trill
 * sensor. Here, a loop is defined so that the task runs recurrently for as long
 * as the audio thread is running.
 */
void loop(void *) {
  while (!Bela_stopRequested()) {
    // Read locations from Trill sensor
    touchSensor.readI2C();
    gNumActiveTouches = touchSensor.getNumTouches();
    livecore_cc_write(0, gNumActiveTouches);
    for (unsigned int i = 0; i < gNumActiveTouches; i++) {
      gTouchLocation[i] = touchSensor.touchLocation(i);
      gTouchSize[i] = touchSensor.touchSize(i);
      livecore_cc_write(i + 1, gTouchLocation[i]);
      livecore_cc_write(NUM_TOUCH + i + 1, gTouchSize[i]);
    }
    // For all inactive touches, set location and size to 0
    for (unsigned int i = gNumActiveTouches; i < NUM_TOUCH; i++) {
      gTouchLocation[i] = 0.0;
      gTouchSize[i] = 0.0;
      livecore_cc_write(i + 1, gTouchLocation[i]);
      livecore_cc_write(NUM_TOUCH + i + 1, gTouchSize[i]);
    }
    usleep(gTaskSleepTime);
  }
}

// setup() is called once before the audio rendering starts.
// Use it to perform any initialisation and allocation which is dependent
// on the period size or sample rate.
//
// Return true on success; returning false halts the program.
bool setup(BelaContext *context, void *userData) {
  livecore_setup(context, userData);

  // Setup a Trill Bar sensor on i2c bus 1, using the default mode and address
  if (touchSensor.setup(1, Trill::BAR) != 0) {
    fprintf(stderr, "Unable to initialise Trill Bar\n");
    return false;
  }
  touchSensor.printDetails();

  // Set and schedule auxiliary task for reading sensor data from the I2C bus
  Bela_runAuxiliaryTask(loop);
  return true;
}

// render() is called regularly at the highest priority by the audio engine.
// Input and output are given from the audio hardware and the other
// ADCs and DACs (if available).
void render(BelaContext *context, void *userData) {
  livecore_render(context, userData);
}

// cleanup() is called once at the end, after the audio has stopped.
// Release any resources that were allocated in setup().
void cleanup(BelaContext *context, void *userData) {
  livecore_cleanup(context, userData);
}
