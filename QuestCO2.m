startdate = datenum('08-25-2015');
enddate = datenum('08-08-2017');
xdata = linspace(startdate,enddate,716);

figure(1)
Y = medfilt1(DI7_11(55:end),15);
plot(xdata,Y/max(DI7_11))
%plot(xdata,DI7_11(55:end)/max(DI7_11))
hold on
Y2 = medfilt1(F7_11(55:end),5);
plot(xdata,Y2/max(F7_11))
%plot(xdata,F7_11(55:end)/max(F7_11))
hold off
Y3 = medfilt1(T7_11(55:end),5);
yyaxis right

%plot(xdata,T7_11(55:end),'g')
plot(xdata,Y3,'g')
ylabel('Bottom Hole Temperature')
yyaxis left

title('7-11')
legend('Normalized Dynamic Injectivity','Normalized Flow','Bottom Hole Temperature (C)')
datetick('x','mmmyy')

figure(2)
Y = medfilt1(DI8_19(55:end),15);
plot(xdata,Y/max(DI8_19))
%plot(xdata,DI8_19(55:end)/max(DI8_19))
hold on
Y2 = medfilt1(F8_19(55:end),5);
plot(xdata,Y2/max(F8_19))
%plot(xdata,F8_19(55:end)/max(F8_19))
hold off

Y3 = medfilt1(T8_19(55:end),5);
yyaxis right

%plot(xdata,T8_19(55:end),'g')
plot(xdata,Y3,'g')
ylabel('Bottom Hole Temperature')
yyaxis left

title('8-19')
legend('Normalized Dynamic Injectivity','Normalized Flow','Bottom Hole Temperature (C)')
datetick('x','mmmyy')

figure(3)
plot(T7_11,DI7_11,'.')
figure(4)
plot(T8_19,DI8_19,'.')

%8-19
figure(3)
plot(T8_19(55:260),DI8_19(55:260),'.')
xlabel('Bottom Hole Temperature (Deg C)')
ylabel('Dynamic Injectivity (Kg/hr-kPa')
title('8-19 September 2015 - March 2016')

figure(4)
plot(T8_19(305:520),DI8_19(305:520),'.')
xlabel('Bottom Hole Temperature (Deg C)')
ylabel('Dynamic Injectivity (Kg/hr-kPa')
title('8-19 May 2016 - December 2016')

figure(5)
plot(T8_19(530:675),DI8_19(530:675),'.')
xlabel('Bottom Hole Temperature (Deg C)')
ylabel('Dynamic Injectivity (Kg/hr-kPa')
title('8-19 December 2016 - May 2017')

figure(6)
plot(T8_19(688:769),DI8_19(688:769),'.')
xlabel('Bottom Hole Temperature (Deg C)')
ylabel('Dynamic Injectivity (Kg/hr-kPa')
title('8-19 Final dates')

%7-11
figure(3)
plot(T7_11(55:260),DI7_11(55:260),'.')
xlabel('Bottom Hole Temperature (Deg C)')
ylabel('Dynamic Injectivity (Kg/hr-kPa')
title('7-11 December 2015 - March 2016')

figure(4)
plot(T7_11(305:520),DI7_11(305:520),'.')
xlabel('Bottom Hole Temperature (Deg C)')
ylabel('Dynamic Injectivity (Kg/hr-kPa')
title('7-11 May 2016 - September 2016')

figure(5)
plot(T7_11(530:675),DI7_11(530:675),'.')
xlabel('Bottom Hole Temperature (Deg C)')
ylabel('Dynamic Injectivity (Kg/hr-kPa')
title('7-11 October 2016 - April 2017')

figure(6)
plot(T7_11(688:769),DI7_11(688:769),'.')
xlabel('Bottom Hole Temperature (Deg C)')
ylabel('Dynamic Injectivity (Kg/hr-kPa')
title('8-19 Final dates')

%8-19
x=movstd(medfilt1(F7_11,5),15);
x1 = x(55:260);
x2 = x(305:520);
x3 = x(530:675);
x4 = x(688:769);
t18 = T8_19(55:260);
t28 = T8_19(305:520);
t38 = T8_19(530:675);
t48 = T8_19(688:769);
t17 = T7_11(55:260);
t27 = T7_11(305:520);
t37 = T7_11(530:675);
t47 = T7_11(688:769);
d18 = DI8_19(55:260);
d28 = DI8_19(305:520);
d38 = DI8_19(530:675);
d48 = DI8_19(688:769);
d17 = DI7_11(55:260);
d27 = DI7_11(305:520);
d37 = DI7_11(530:675);
d47 = DI7_11(688:769);
plot(T8_19(55:260),DI8_19(55:260),'ob')
hold on
plot(T8_19(305:520),DI8_19(305:520),'or')
plot(T8_19(530:675),DI8_19(530:675),'oc')
plot(T8_19(688:769),DI8_19(688:769),'om')
plot(T7_11(55:260),DI7_11(55:260),'xb')
plot(T7_11(305:520),DI7_11(305:520),'xr')
plot(T7_11(530:675),DI7_11(530:675),'xc')
plot(T7_11(688:769),DI7_11(688:769),'xm')
legend('8-19 Aug15 - Mar16','8-19 May16 - Nov16','8-19 Dec16 - Apr17','8-19 May17 - Aug17','7-11 Aug15 - Mar16','7-11 May16 - Nov16','7-11 Dec16 - Apr17','7-11 May17 - Aug 17')
xlabel('Bottom Hole Temperature (Deg C)')
ylabel('Dynamic Injectivity (Kg/hr-Kpa)')
title('Dynamic Injectivity versus Bottom Hole Temperature')
hold off

plot(t18(x1>20000),d18(x1>20000),'ob')
hold on
plot(t28(x2>20000),d28(x2>20000),'or')
plot(t38(x3>20000),d38(x3>20000),'oc')
plot(t48(x4>20000),d48(x4>20000),'om')
plot(t17(x1>20000),d17(x1>20000),'xb')
plot(t27(x2>20000),d27(x2>20000),'xr')
plot(t37(x3>20000),d37(x3>20000),'xc')
plot(t47(x4>20000),d47(x4>20000),'xm')
legend('8-19 Aug15 - Mar16','8-19 May16 - Nov16','8-19 Dec16 - Apr17','8-19 May17 - Aug17','7-11 Aug15 - Mar16','7-11 May16 - Nov16','7-11 Dec16 - Apr17','7-11 May17 - Aug 17')
xlabel('Bottom Hole Temperature (Deg C)')
ylabel('Dynamic Injectivity (Kg/hr-Kpa)')
title('Dynamic Injectivity versus Bottom Hole Temperature')
hold off

