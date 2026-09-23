"Thurston's patent date routines.";

% The essential reference for all date algorithms is "Calendrical
% Calculations" by E. Reingold and N. Dershowitz, CUP, 2001. [R&D]

vardef base(expr Y, M, d) =
  save m, y;
  if M < 3: m = M + 9; y = Y - 1;
  else: m = M - 3; y = Y; fi
  365/1024 y + (floor(y/4) - floor(y/100) + floor(y/400)
    + floor((2+3m)/5) + 30m + d - 307) / 1024
enddef;
%
% The `base` macro takes three integer arguments representing year, month, and
% day; it returns a single <numeric> value representing that date in the
% Gregorian calendar.  This number is what R&D call a "fixed date" that
% represents the number of days since the 1 January in the year 1 CE.  So
% `base(1,1,1)` is 0 and base(2001,1,1) is 730486, except that in our case the
% result is divided by 1024 to make it work with MP's scaled number system.  So
% with these macros `base(1,1,1)` is still 0, but `base(2001,1,1)` is
% 730486/1024 = 713.36523.  This means that the macros will work with years
% from 4095 BCE to 4095 CE with plain MP using the scaled number system.
%
% To get the base number for today use `base` with the built-in date variables:
% `base(year, month, day)`.
%
% The macros do no range checking, by design; this is often helpful.  For example
%
% - `base(year, 3, 0)` will give you the last day of February in the current year,
% - `base(year, month, day + 42)` will give you the base number for the date in six weeks time.
%
% You can also calculate the difference between two dates, using
%
%     base(a,b,c) - base(d,e,f)
%
% except that the result will be in units of 1/1024, so you need
% to multiply by 1024 to get the difference as days. To avoid errors try to
% avoid dates more than 11 years apart (or use the `decimal` number system).

vardef gregorian_year(expr b) =
  save d, s, c, o, y; numeric d, s, c, o, y;
  save sd, cd, od, yd; numeric sd, cd, od, yd;
  sd = 142+689/1024;
  cd = 35+684/1024;
  od = 1+437/1024;
  yd = 365/1024;
  d = b;
  s = floor (d / sd); d := d - s * sd;
  c = floor (d / cd); d := d - c * cd;
  o = floor (d / od); d := d - o * od;
  y = floor (d / yd);
  400s + 100c + 4o + y + if (c = 4) or (y = 4): 0 else: 1 fi
enddef;
%
% The `gregorian_year` function takes a base date number and returns
% the corresponding year in the Gregorian calendar, as a <numeric> value.

vardef leap(expr y) =
  (y mod 400 = 0) or ((y mod 4 = 0) and (y mod 100 <> 0))
enddef;
%
% The `leap` macro takes a <numeric> value representing a year in the Gregorian
% calendar and returns a <boolean> result: true if the year is a leap year and false otherwise.

vardef date(expr b) =
  save y, m, d, prior_days, march, correction;
  numeric y, m, d, prior_days, march, correction;
  y = gregorian_year(b);
  prior_days = 1024(b - base(y, 1, 1));
  march = base(y, 3, 1);
  correction = if b < march: 0 elseif (b >= march) and leap(y): 1 else: 2 fi;
  m = floor(12/367 * (prior_days + correction) + 371/367);
  d = 1 + 1024 * (b - base(y, m, 1));
  (y, m, d)
enddef;
%
% The `date` macro is the opposite of the `base` macro.  It takes a base number
% and returns a triplet `(y, m, d)` representing the corresponding year, month,
% and day in the Gregorian calendar.
%
% This triple looks like a <color> to Metapost, so you can use `redpart` to get
% the year, `greenpart` to get the month, and `bluepart` to get the day.
% However usually it is much easier to assign the value to a triple of
% variables, like this:
%
%     (y, m, d) = date(b)
%

vardef dow(expr b) =
  save m, n; numeric m, n;
  n = floor(b);
  m = b - n;
  (2n + 1024m) mod 7
enddef;
%
% The `dow` macro takes a base date number and returns a value between
% 0 and 6 representing the day of the week, where 0 is Monday and 6 is Sunday.

vardef isoweekday(expr b) =
  1 + dow(b)
enddef;
%
% The `isoweekday` macro takes a base date number and returns a value between 1
% and 7 representing the day of the week according to ISO 8601, where 1 is Monday and 7 is Sunday.
%
% If you prefer the system where 0 is Sunday and 6 is Saturday, then you could
% use `isoweekday(b) mod 7`

vardef leading_zero(expr n) = if n < 10: "0" & fi decimal n enddef;

vardef isodate(expr b) =
  save y, m, d; numeric y, m, d;
  (y, m, d) = date(b);
  decimal y & "-" & leading_zero(m) & "-" & leading_zero(d)
enddef;
%
% The `isodate` macro takes base date number and returns a <string> showing the corresponding
% Gregorian date formatted according to ISO 8601 as "YYYY-MM-DD".

vardef stripdate(expr s) =
  if length(s) = 8:
    scantokens ("(" & substring (0,4) of s & "," & substring (4,6) of s & "," & substring (6,8) of s & ")")
  elseif length(s) = 10:
    scantokens ("(" & substring (0,4) of s & "," & substring (5,7) of s & "," & substring (9,10) of s & ")")
  else:
    (0,0,0)
  fi
enddef;
%
% `stripdate` converts a <string> representing a date as "YYYYMMDD" or "YYYY-MM-DD" and returns
% the corresponding triple of numeric values represeting `(y, m, d)`.

vardef easter(expr y) =
  save a, b, c, d, e, g;
  g = y mod 19;    % position in the 19 year cycle
  c = floor(y/100) + 1;  % century number
  a = floor(c*3/4) - 12; % non-leap days at century ends
  b = floor((c*8+5)/25); % extra day every 3rd/4th century
  e = (11*g + 2 - a + b) mod 30; % age of the moon on 5 April
  if (e = 0) or ((e = 1) and (g > 10)): e := e + 1; fi % avoid Passover
  e := e - 7 + (floor(y*5/4) - a + 5 - e) mod 7;  % shift to Sunday
  base(y, 4, 19 - e)
enddef;
%
% The `easter` macro returns the base date number of Easter Sunday in the given year.

vardef next_isoweekday(expr b, weekday) = 
  save c, d; 
  c = isoweekday(b);
  if c = weekday:
    d = 7;
  else:
    d = (weekday - c) mod 7;
  fi
  b + d / 1024
enddef;
