#define MINIAUDIO_IMPLEMENTATION
#include "miniaudio.h"
#include "audio.h"
#include <stddef.h>

void audio_enum_devices(int dac_idx, int adx_idx) {
  ma_context context;

  if (ma_context_init(NULL, 0, NULL, &context) != MA_SUCCESS) {
    return;
  }

  ma_device_info *playback_infos;
  ma_uint32 playback_count;
  ma_device_info *capture_infos;
  ma_uint32 capture_count;

  if (ma_context_get_devices(&context, &playback_infos, &playback_count,
                             &capture_infos, &capture_count) != MA_SUCCESS) {
    return;
  }

  printf("\nOutput devices (select with --dac:N):\n");
  for (ma_uint32 idx = 0; idx < playback_count; idx += 1) {
    printf("%d%s\t%s\n", idx, (dac_idx == -1 && playback_infos[idx].isDefault) || (dac_idx == (int)idx) ? " >>" : "", playback_infos[idx].name);
  }

  printf("\nInput devices (select with --adc:N):\n");
  for (ma_uint32 idx = 0; idx < capture_count; idx += 1) {
    printf("%d%s\t%s\n", idx, adx_idx == (int)idx ? " <<" : "", capture_infos[idx].name);
  }

  ma_context_uninit(&context);
}

void *audio_user_data(ma_device *device) { return device->pUserData; }

ma_device *audio_init(ma_uint32 channels, ma_uint32 sample_rate, int dac_idx,
                      int adx_idx, void *data_callback, void *user_data) {
  ma_context context;

  if (ma_context_init(NULL, 0, NULL, &context) != MA_SUCCESS) {
    return NULL;
  }

  ma_device_info *playback_infos;
  ma_uint32 playback_count;
  ma_device_info *capture_infos;
  ma_uint32 capture_count;

  if (ma_context_get_devices(&context, &playback_infos, &playback_count,
                             &capture_infos, &capture_count) != MA_SUCCESS) {
    return NULL;
  }

  int dac = dac_idx;
  if (dac < 0) {
      for (ma_uint32 idx = 0; idx < playback_count; idx += 1) {
        if (playback_infos[idx].isDefault) {
          dac = idx;
        }
      }
  }

  ma_device_config config = ma_device_config_init(adx_idx > -1 ? ma_device_type_duplex : ma_device_type_playback);
  config.playback.pDeviceID = &playback_infos[dac].id;
  config.playback.format = ma_format_f32;
  config.playback.channels = channels;
  if (adx_idx > -1) {
    config.capture.pDeviceID = &capture_infos[adx_idx].id;
    config.capture.format = ma_format_f32;
    config.capture.channels = channels;
  }
  config.sampleRate = sample_rate;
  config.dataCallback = data_callback;
  config.pUserData = user_data;

  ma_device *device = malloc(sizeof(ma_device));
  if (ma_device_init(NULL, &config, device) != MA_SUCCESS) {
    return NULL; // Failed to initialize the device.
  }
  return device;
}

int audio_start(ma_device *device) { return ma_device_start(device); }

void audio_uninit(ma_device *device) {
  ma_device_uninit(device);
  free(device);
}
