# metapost-basedate

A set of macros for date calculations.

Toby Thurston -- 22 Sep 2026

The essential reference for all date algorithms is "Calendrical
Calculations" by E. Reingold and N. Dershowitz, CUP, 2001. [R&D]

## `base(y, m, d)`

The `base` macro takes three integer arguments representing year, month, and
day; it returns a single <numeric> value representing that date in the
Gregorian calendar.  This number is what R&D call a "fixed date" that
represents the number of days since the 1 January in the year 1 CE.  So
`base(1,1,1)` is 0 and base(2001,1,1) is 730486, except that in our case the
result is divided by 1024 to make it work with MP's scaled number system.  So
with these macros `base(1,1,1)` is still 0, but `base(2001,1,1)` is
730486/1024 = 713.36523.  This means that the macros will work with years
from 4095 BCE to 4095 CE with plain MP using the scaled number system.

To get the base number for today use `base` with the built-in date variables:
`base(year, month, day)`.

The macros do no range checking, by design.  So `base(year, 3, 0)` will give
you the last day of February in the current year, and `base(year, month, day
+ 42)` will give you the base number for the date in six weeks time.

You can also calculate the difference between two dates, using `base(a,b,c) -
base(d,e,f)` except that the result will be in units of 1/1024, so you need
to multiply by 1024 to get the difference as days. To avoid errors try to
avoid dates more than 11 years apart (or use the `decimal` number system).

## `gregorian_year(b)`

The `gregorian_year` function takes a base date number and returns
the corresponding year in the Gregorian calendar, as a <numeric> value.

## `leap(y)`

The `leap` macro takes a <numeric> value representing a year in the Gregorian
calendar and returns a <boolean> result: true if the year is a leap year and false otherwise.

## `date(b)`

The `date` macro is the opposite of the `base` macro.  It takes a base number
and returns a triplet `(y, m, d)` representing the corresponding year, month,
and day in the Gregorian calendar.

This triple looks like a <color> to Metapost, so you can use `redpart` to get
the year, `greenpart` to get the month, and `bluepart` to get the day.
However usually it is much easier to assign the value to a triple of
variables, like this:

    (y, m, d) = date(b)


## `dow(b)`

The `dow` macro takes a base date number and returns a value between
0 and 6 representing the day of the week, where 0 is Monday and 6 is Sunday.

## `isoweekday(b)`

The `isoweekday` macro takes a base date number and returns a value between 1
and 7 representing the day of the week according to ISO 8601, where 1 is Monday and 7 is Sunday.

If you prefer the system where 0 is Sunday and 6 is Saturday, then you could
use `isoweekday(b) mod 7`

## `isodate(b)`

The `isodate` macro takes base date number and returns a <string> showing the corresponding
Gregorian date formatted according to ISO 8601 as "YYYY-MM-DD".

## `stripdate(s)`

`stripdate` converts a <string> representing a date as "YYYYMMDD" or "YYYY-MM-DD" and returns
the corresponding triple of numeric values represeting `(y, m, d)`.
