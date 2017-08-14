function fcall(a)

global DAE Settings

if ~a.n, return, end

dHP = DAE.x(a.delta_HP);
oHP = DAE.x(a.omega_HP);
dIP = DAE.x(a.delta_IP);
oIP = DAE.x(a.omega_IP);
dLP = DAE.x(a.delta_LP);
oLP = DAE.x(a.omega_LP);
dEX = DAE.x(a.delta_EX);
oEX = DAE.x(a.omega_EX);
oEX = DAE.x(a.omega_EX);
dSY = DAE.x(a.delta);
oSY = DAE.x(a.omega);
Tm = DAE.y(a.pm);

iMhp = a.u.*a.con(:,2);
iMip = a.u.*a.con(:,3);
iMlp = a.u.*a.con(:,4);
iMex = a.u.*a.con(:,5);
iM = a.u.*a.con(:,18);

Dhp = a.con(:,6);
Dip = a.con(:,7);
Dlp = a.con(:,8);
Dex = a.con(:,9);

D12 = a.con(:,10);
D23 = a.con(:,11);
D34 = a.con(:,12);
D45 = a.con(:,13);

K12 = a.con(:,14);
K23 = a.con(:,15);
K34 = a.con(:,16);
K45 = a.con(:,17);

Wn = 2*pi*Settings.freq*a.u;

DAE.f(a.delta_HP) = Wn.*(oHP-1);
DAE.f(a.omega_HP) = (Tm-Dhp.*(oHP-1)-D12.*(oHP-oIP)-K12.*dHP+K12.*dIP).*iMhp;
DAE.f(a.delta_IP) = Wn.*(oIP-1);
DAE.f(a.omega_IP) = (-Dip.*(oIP-1)-D12.*(oIP-oHP)-D23.*(oIP-oLP)+K12.*dHP-(K12+K23).*dIP+K23.*dLP).*iMip;
DAE.f(a.delta_LP) = Wn.*(oLP-1);
DAE.f(a.omega_LP) = (-Dlp.*(oLP-1)-D23.*(oLP-oIP)-D34.*(oLP-oSY)+K23.*dIP-(K23+K34).*dLP+K34.*dSY).*iMlp;
DAE.f(a.omega) = DAE.f(a.omega) + (-D34.*(oSY-oLP)-D45.*(oSY-oEX)+K34.*dLP -(K34+K45).*dSY+K45.*dEX-Tm).*iM;
DAE.f(a.delta_EX) = Wn.*(oEX-1);
DAE.f(a.omega_EX) = (-Dex.*(oEX-1)-D45.*(oEX-oSY)+K45.*dSY-K45.*dEX).*iMex;
