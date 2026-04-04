#ifndef SPORTCORE_H
#define SPORTCORE_H
#include <stddef.h>
#include <stdint.h>
typedef struct ScBuffer { const uint8_t* ptr; size_t len; } ScBuffer;
int sc_version_major(void);
int sc_version_minor(void);
int sc_validate_session_bundle(const uint8_t* ptr, size_t len);
void sc_free_buffer(ScBuffer buf);
#endif
