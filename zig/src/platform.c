#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/* A small C ABI boundary avoids depending on struct tm and FILE layouts. */
void cal_write(const unsigned char *data, size_t length) {
    fwrite(data, 1, length, stdout);
}

void cal_usage(void) {
    fputs("Usage: cal [month] year  OR  cal year  OR  cal\n", stderr);
    exit(2);
}

int32_t cal_local_date(void) {
    time_t timestamp = time(NULL);
    struct tm local;
#ifdef _WIN32
    if (localtime_s(&local, &timestamp) != 0) {
#else
    if (localtime_r(&timestamp, &local) == NULL) {
#endif
        fputs("cal: cannot read local date\n", stderr);
        exit(1);
    }
    return (local.tm_year + 1900) * 10000 + (local.tm_mon + 1) * 100 + local.tm_mday;
}
