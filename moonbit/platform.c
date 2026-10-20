#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/* Keep OS time-zone and process APIs outside the calendar calculations. */
int32_t cal_local_date(int64_t seconds) {
    time_t timestamp = (time_t)seconds;
    struct tm local;
#ifdef _WIN32
    _tzset();
    if (localtime_s(&local, &timestamp) != 0) {
#else
    tzset();
    if (localtime_r(&timestamp, &local) == NULL) {
#endif
        fputs("cal: cannot read local date\n", stderr);
        exit(1);
    }
    return (local.tm_year + 1900) * 10000 + (local.tm_mon + 1) * 100 + local.tm_mday;
}

void cal_usage(void) {
    fputs("Usage: cal [month] year  OR  cal year  OR  cal\n", stderr);
    exit(2);
}
