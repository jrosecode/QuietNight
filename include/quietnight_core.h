#pragma once
#include <stdint.h>
#include <stddef.h>
typedef struct { float rms,peak,confidence; uint8_t severity; float periodicity; } QnResult;
QnResult qn_analyze(const float *samples, size_t len, float baseline);
uint32_t qn_version(void);
