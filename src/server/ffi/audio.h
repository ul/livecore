#include "miniaudio.h"

extern void audio_enum_devices(int dac_idx, int adc_idx);
extern void *audio_user_data(ma_device *device);
extern ma_device *audio_init(ma_uint32 channels, ma_uint32 sample_rate,
                             int dac_idx, int adc_idx, void *data_callback,
                             void *user_data);
extern int audio_start(ma_device *pDevice);
extern void audio_uninit(ma_device *pDevice);
