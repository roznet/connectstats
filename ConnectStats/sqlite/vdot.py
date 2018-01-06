#!/usr/bin/python

import math

#in minutes
Time = 47.
#in meters
Distance = 10000.

V02Max = 0.8 + 0.1894393 * math.exp(-0.012778 * Time) + 0.2989558 * math.exp(-0.1932605 * Time);
VDOT = (-4.6 + 0.182258 * (Distance / Time) + 0.000104 * pow(Distance / Time, 2)) / V02Max

print V02Max
print 'Vdot', VDOT

// http://www.runsmartproject.com/calculator/#modInt
// Easy: 59-74% of VO2max or 65-79% of your HRmax.
// Marathon: 75-84% of VO2max or 80-90% of your HRmax
// Threshold: 83-88% of VO2max or 88-92% of HRmax        To improve endurance.
// Interval: 95-100% of VO2max or 98-100% of HRmax

paces={
'Easy':1 / (29.54 + 5.000663 * (VDOT * (0.59 + 0.41 * (0.73 - 0.65) / 0.35)) - 0.007546 * pow(VDOT * (0.59 + 0.41 * (0.73 - 0.65) / 0.35), 2)) * 1609.344 * 60,
'M':Time * pow(26.21875 / (Distance / 1609.344), 1.06) / 26.21875 * 60
}
def sectostr(secs):
    mm = int(secs)/60
    ss = secs-mm*60
    return '%02d:%02d' %( mm,ss)

for k,v in paces.iteritems():
    print k , sectostr(v)
