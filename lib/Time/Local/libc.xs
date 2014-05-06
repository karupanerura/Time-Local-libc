#ifdef __cplusplus
extern "C" {
#endif

#define PERL_NO_GET_CONTEXT /* we want efficiency */
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#ifdef __cplusplus
} /* extern "C" */
#endif

#define NEED_newSVpvn_flags
#include "ppport.h"

#include <time.h>

time_t timegm_nocheck(
  unsigned int sec,
  unsigned int min,
  unsigned int hour,
  unsigned int mday,
  unsigned int month,
  unsigned int year
) {
  struct tm t;
  memset(&t, 0, sizeof(struct tm));
  t.tm_sec   = sec;
  t.tm_min   = min;
  t.tm_hour  = hour;
  t.tm_mday  = mday;
  t.tm_mon   = month;
  t.tm_year  = year;
  t.tm_isdst = -1;
  return timegm(&t);
}

time_t timelocal_nocheck(
  unsigned int sec,
  unsigned int min,
  unsigned int hour,
  unsigned int mday,
  unsigned int month,
  unsigned int year
) {
  struct tm t;
  memset(&t, 0, sizeof(struct tm));
  t.tm_sec   = sec;
  t.tm_min   = min;
  t.tm_hour  = hour;
  t.tm_mday  = mday;
  t.tm_mon   = month;
  t.tm_year  = year;
  t.tm_isdst = -1;
  return mktime(&t);
}

MODULE = Time::Local::libc    PACKAGE = Time::Local::libc PREFIX = xs_

PROTOTYPES: DISABLE

#define _CHECK(sec, min, hour, mday, month, year) \
  {\
    static unsigned int MONTH_DAYS[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}; \
    if (month > 11) {\
      croak("Month \"%d\" out of range 0..11", month);\
    }\
    if (mday < 1 || mday > MONTH_DAYS[month]) {\
      croak("Day \"%d\" out of range 1..%d", mday, MONTH_DAYS[month]);\
    }\
    if (hour > 23) {\
      croak("Hour \"%d\" out of range 0..23", hour);\
    }\
    if (min > 59) {\
      croak("Minute \"%d\" out of range 0..59", min);\
    }\
    if (sec > 59) {\
      croak("Second \"%d\" out of range 0..59", sec);\
    }\
  }

time_t
xs_timegm(sec, min, hour, mday, month, year)
  unsigned int sec;
  unsigned int min;
  unsigned int hour;
  unsigned int mday;
  unsigned int month;
  unsigned int year;
CODE:
{
  _CHECK(sec, min, hour, mday, month, year);
  RETVAL = timegm_nocheck(sec, min, hour, mday, month, year);
}
OUTPUT:
  RETVAL

time_t
xs_timegm_nocheck(sec, min, hour, mday, month, year)
  unsigned int sec;
  unsigned int min;
  unsigned int hour;
  unsigned int mday;
  unsigned int month;
  unsigned int year;
CODE:
{
  RETVAL = timegm_nocheck(sec, min, hour, mday, month, year);
}
OUTPUT:
  RETVAL

time_t
xs_timelocal(sec, min, hour, mday, month, year)
  unsigned int sec;
  unsigned int min;
  unsigned int hour;
  unsigned int mday;
  unsigned int month;
  unsigned int year;
CODE:
{
  _CHECK(sec, min, hour, mday, month, year);
  RETVAL = timelocal_nocheck(sec, min, hour, mday, month, year);
}
OUTPUT:
  RETVAL

time_t
xs_timelocal_nocheck(sec, min, hour, mday, month, year)
  unsigned int sec;
  unsigned int min;
  unsigned int hour;
  unsigned int mday;
  unsigned int month;
  unsigned int year;
CODE:
{
  RETVAL = timelocal_nocheck(sec, min, hour, mday, month, year);
}
OUTPUT:
  RETVAL
