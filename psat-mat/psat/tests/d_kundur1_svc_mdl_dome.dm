# DOME format version 1.0

Bus, Vn = 20.0, angle = 0.3229, idx = 1, name = "Bus 01", voltage = 1.03
Bus, Vn = 20.0, angle = 0.1536, idx = 2, name = "Bus 02", voltage = 1.01
Bus, Vn = 20.0, angle = -0.1187, area = 2.0, idx = 3, name = "Bus 03",
     voltage = 1.03
Bus, Vn = 20.0, angle = -0.295, area = 2.0, idx = 4, name = "Bus 04",
     voltage = 1.01
Bus, Vn = 230.0, angle = 0.2112, idx = 5, name = "Bus 05", voltage = 1.01
Bus, Vn = 230.0, angle = 0.03665, idx = 6, name = "Bus 06", voltage = 0.9876
Bus, Vn = 230.0, angle = -0.1065, idx = 7, name = "Bus 07"
Bus, Vn = 230.0, angle = -0.3368, area = 3.0, idx = 8, name = "Bus 08"
Bus, Vn = 230.0, angle = -0.555, area = 2.0, idx = 9, name = "Bus 09",
     voltage = 0.9899
Bus, Vn = 230.0, angle = -0.4119, area = 2.0, idx = 10, name = "Bus 10",
     voltage = 0.9938
Bus, Vn = 230.0, angle = -0.2339, area = 2.0, idx = 11, name = "Bus 11",
     voltage = 1.013

PQ, Vn = 230.0, bus = 9, idx = 9, name = "PQ 1", p = 17.67,
    q = -2.5, vmax = 1.05, vmin = 0.95, z = 0.0
PQ, Vn = 230.0, bus = 7, idx = 7, name = "PQ 2", p = 9.67,
    q = -1.0, vmax = 1.05, vmin = 0.95, z = 0.0

PVgen, Vn = 20.0, bus = 1, busr = 1, idx = 1, name = "PVgen 1",
       pg = 7.0, qmax = 5.0, qmin = -2.0, v0 = 1.03
PVgen, Vn = 20.0, bus = 2, busr = 2, idx = 2, name = "PVgen 2",
       pg = 7.0, qmax = 5.0, qmin = -2.0, v0 = 1.01
PVgen, Vn = 230.0, bus = 8, busr = 8, idx = 8, name = "PVgen 3",
       qmax = 5.0, qmin = -2.0, v0 = 1.03
PVgen, Vn = 20.0, bus = 4, busr = 4, idx = 4, name = "PVgen 4",
       pg = 7.0, qmax = 5.0, qmin = -2.0, v0 = 1.01

Slack, Vn = 20.0, bus = 3, busr = 3, idx = 3, name = "Slack 1",
       pg = 7.0, qmax = 99.0, qmin = -99.0, theta0 = -0.1186824, v0 = 1.03

Line, Vn = 230.0, Vn2 = 230.0, b = 0.04375, bus1 = 5, bus2 = 6,
      idx = 1, imax = 1.0, name = "Line 5-6", r = 0.0025, x = 0.025
Line, Vn = 230.0, Vn2 = 230.0, b = 0.0175, bus1 = 6, bus2 = 7,
      idx = 2, imax = 1.0, name = "Line 6-7", r = 0.001, x = 0.01
Line, Vn = 230.0, Vn2 = 230.0, b = 0.09625, bus1 = 9, bus2 = 8,
      idx = 3, imax = 1.0, name = "Line 9-8", r = 0.011, x = 0.11
Line, Vn = 230.0, Vn2 = 230.0, b = 0.09625, bus1 = 7, bus2 = 8,
      idx = 4, imax = 1.0, name = "Line 7-8", r = 0.011, x = 0.11
Line, Vn = 230.0, Vn2 = 230.0, b = 0.04375, bus1 = 11, bus2 = 10,
      idx = 5, imax = 1.0, name = "Line 11-10", r = 0.0025, x = 0.025
Line, Vn = 230.0, Vn2 = 230.0, b = 0.0175, bus1 = 10, bus2 = 9,
      idx = 6, imax = 1.0, name = "Line 10-9", r = 0.001, x = 0.01
Line, Vn = 230.0, Vn2 = 230.0, b = 0.09625, bus1 = 9, bus2 = 8,
      idx = 7, imax = 1.0, name = "Line 9-8", r = 0.011, x = 0.11
Line, Vn = 230.0, Vn2 = 230.0, b = 0.09625, bus1 = 7, bus2 = 8,
      idx = 8, imax = 1.0, name = "Line 7-8", r = 0.011, x = 0.11
Line, Sn = 900.0, Vn = 20.0, Vn2 = 230.0000046, bus1 = 1, bus2 = 5,
      idx = 9, imax = 1.0, name = "Traf 1-5", trasf = True, x = 0.15
Line, Sn = 900.0, Vn = 20.0, Vn2 = 230.0000046, bus1 = 2, bus2 = 6,
      idx = 10, imax = 1.0, name = "Traf 2-6", trasf = True, x = 0.15
Line, Sn = 900.0, Vn = 20.0, Vn2 = 230.0000046, bus1 = 4, bus2 = 10,
      idx = 11, imax = 1.0, name = "Traf 4-10", trasf = True, x = 0.15
Line, Sn = 900.0, Vn = 20.0, Vn2 = 230.0000046, bus1 = 3, bus2 = 11,
      idx = 12, imax = 1.0, name = "Traf 3-11", trasf = True, x = 0.15

Breaker, bus = 1, idx = "Breaker_1", line = 9, name = "Breaker 1", t1 = 1.1,
         t2 = 999999.0, u1 = 1, u2 = 1

Syn6b, M = 13.0, Sn = 900.0, Taa = 0.002, Td20 = 0.03, Tq10 = 0.4,
       Tq20 = 0.05, Vn = 20.0, bus = 1, corr = 1.0, gen = 1,
       idx = 1, name = "Syn6b 1", ra = 0.0025, xd = 1.8, xd1 = 0.3,
       xd2 = 0.25, xl = 0.2, xq1 = 0.55, xq2 = 0.25
Syn6b, M = 13.0, Sn = 900.0, Td20 = 0.03, Tq10 = 0.4, Tq20 = 0.05,
       Vn = 20.0, bus = 2, corr = 1.0, gen = 2, idx = 2,
       name = "Syn6b 2", ra = 0.0025, xd = 1.8, xd1 = 0.3, xd2 = 0.25,
       xl = 0.2, xq1 = 0.55, xq2 = 0.25
Syn6b, M = 12.35, Sn = 900.0, Td20 = 0.03, Tq10 = 0.4, Tq20 = 0.05,
       Vn = 20.0, bus = 3, corr = 1.0, gen = 3, idx = 3,
       name = "Syn6b 3", ra = 0.0025, xd = 1.8, xd1 = 0.3, xd2 = 0.25,
       xl = 0.2, xq1 = 0.55, xq2 = 0.25
Syn6b, M = 12.35, Sn = 900.0, Td20 = 0.03, Tq10 = 0.4, Tq20 = 0.05,
       Vn = 20.0, bus = 4, corr = 1.0, gen = 4, idx = 4,
       name = "Syn6b 4", ra = 0.0025, xd = 1.8, xd1 = 0.3, xd2 = 0.25,
       xl = 0.2, xq1 = 0.55, xq2 = 0.25

Avr1, Ae = 0.0056, Be = 1.075, Ka = 20.0, Kf = 0.125, Ta = 0.055,
      Te = 0.36, Tf = 1.8, Tr = 0.05, idx = 1, name = "Avr1 1",
      syn = 1
Avr1, Ae = 0.0056, Be = 1.075, Ka = 20.0, Kf = 0.125, Ta = 0.055,
      Te = 0.36, Tf = 1.8, Tr = 0.05, idx = 2, name = "Avr1 2",
      syn = 2
Avr1, Ae = 0.0056, Be = 1.075, Ka = 20.0, Kf = 0.125, Ta = 0.055,
      Te = 0.36, Tf = 1.8, Tr = 0.05, idx = 3, name = "Avr1 3",
      syn = 4
Avr1, Ae = 0.0056, Be = 1.075, Ka = 20.0, Kf = 0.125, Ta = 0.055,
      Te = 0.36, Tf = 1.8, Tr = 0.05, idx = 4, name = "Avr1 4",
      syn = 3

