function Fxcall(a)

global DAE Settings

if ~a.n, return, end

id = DAE.x(a.Id);
iq = DAE.x(a.Iq);
If = DAE.x(a.If);
ed = DAE.x(a.Edc);
eq = DAE.x(a.Eqc);
w = DAE.x(a.omega);
d = DAE.x(a.delta);

xd  = a.con(:,5);
xq  = a.con(:,6);
xad = a.con(:,8);
xf  = a.con(:,13);

xl  = a.con(:,10);
xc  = a.con(:,11);
xeq = xad.*xad-xf.*(xd+xl);

rf  = a.con(:,12);
ra  = a.con(:,7);
r   = a.con(:,9);

D1 = a.u.*a.con(:,19);
D2 = a.u.*a.con(:,20);
D3 = a.u.*a.con(:,21);
D4 = a.u.*a.con(:,22);
D5 = a.u.*a.con(:,23);

M1 = a.con(:,14);
M2 = a.con(:,15);
M3 = a.con(:,16);
M4 = a.con(:,17);
M5 = a.con(:,18);

k12 = a.u.*a.con(:,24);
k23 = a.u.*a.con(:,25);
k34 = a.u.*a.con(:,26);
k45 = a.u.*a.con(:,27);

Tm  = a.Tm;
Efd = a.Efd;
Wb = 2*pi*Settings.freq;
Wbu = Wb*a.u;
notu = ~a.u;

V = a.u.*DAE.y(a.vbus);
t = DAE.y(a.bus);
cdt = cos(d-t);
sdt = sin(d-t);

DAE.Fx = DAE.Fx - sparse(a.delta_HP,a.delta_HP,notu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.delta_IP,a.delta_IP,notu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.delta_LP,a.delta_LP,notu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.delta_EX,a.delta_EX,notu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.delta,a.delta,notu,DAE.n,DAE.n);

DAE.Fx = DAE.Fx - sparse(a.omega_HP,a.omega_HP,D1./M1+notu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega_IP,a.omega_IP,D2./M2+notu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega_LP,a.omega_LP,D3./M3+notu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega_EX,a.omega_EX,D5./M5+notu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega,a.omega,D4./M4+notu,DAE.n,DAE.n);

DAE.Fx = DAE.Fx + sparse(a.Id,a.Id,Wbu.*xf.*(ra+r)./xeq-notu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.Iq,a.Iq,Wbu.*(ra+r)./(xq+xl)+notu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.If,a.If,Wbu.*(xd+xl).*rf./xeq-notu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.Edc,a.Edc,notu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.Eqc,a.Eqc,notu,DAE.n,DAE.n);

DAE.Fx = DAE.Fx + sparse(a.delta_HP,a.omega_HP,Wbu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.delta_IP,a.omega_IP,Wbu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.delta_LP,a.omega_LP,Wbu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.delta,a.omega,Wbu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.delta_EX,a.omega_EX,Wbu,DAE.n,DAE.n);

DAE.Fx = DAE.Fx - sparse(a.omega_HP,a.delta_HP,k12./M1,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_HP,a.delta_IP,k12./M1,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_IP,a.delta_HP,k12./M2,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega_IP,a.delta_IP,(k12+k23)./M2,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_IP,a.delta_LP,k23./M2,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_LP,a.delta_IP,k23./M3,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega_LP,a.delta_LP,(k23+k34)./M3,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_LP,a.delta,k34./M3,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_EX,a.delta,k45./M5,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega_EX,a.delta_EX,k45./M5,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega,a.delta_LP,k34./M4,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega,a.delta,(k34+k45)./M4,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega,a.delta_EX,k45./M4,DAE.n,DAE.n);

DAE.Fx = DAE.Fx - sparse(a.omega,a.Id,a.u.*(xq-xd).*iq./M4,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega,a.Iq,a.u.*((xq-xd).*id+xad.*If)./M4,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega,a.If,a.u.*xad.*iq./M4,DAE.n,DAE.n);

DAE.Fx = DAE.Fx + sparse(a.Edc,a.Id,Wbu.*xc,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.Edc,a.Eqc,Wbu,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.Eqc,a.Iq,Wbu.*xc,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.Eqc,a.Edc,Wbu,DAE.n,DAE.n);

DAE.Fx = DAE.Fx - sparse(a.Id,a.Iq,Wbu.*xf.*(xl+w.*xq)./xeq,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.Id,a.If,Wbu.*xad.*rf./xeq,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.Id,a.Edc,Wbu.*xf./xeq,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.Id,a.omega,Wbu.*xf.*iq.*xq./xeq,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.Id,a.delta,Wbu.*V.*xf.*cdt./xeq,DAE.n,DAE.n);

DAE.Fx = DAE.Fx + sparse(a.If,a.Id,Wbu.*xad.*(ra+r)./xeq,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.If,a.Iq,Wbu.*xad.*(xl+w.*xq)./xeq,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.If,a.Edc,Wbu.*xad./xeq,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.If,a.omega,Wbu.*xad.*iq.*xq./xeq,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.If,a.delta,Wbu.*xad.*V.*cdt./xeq,DAE.n,DAE.n);

DAE.Fx = DAE.Fx - sparse(a.Iq,a.Id,Wbu.*(xl+w.*xd)./(xq+xl),DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.Iq,a.If,Wbu.*(w.*xad)./(xq+xl),DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.Iq,a.Eqc,Wbu./(xq+xl),DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.Iq,a.omega,Wbu.*(If.*xad-xd.*id)./(xq+xl),DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.Iq,a.delta,Wbu.*V.*sdt./(xq+xl),DAE.n,DAE.n);

DAE.Fy = DAE.Fy - sparse(a.Id,a.bus,Wbu.*V.*cdt.*xf./xeq,DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.Id,a.vbus,Wbu.*sdt.*xf./xeq,DAE.n,DAE.m);
DAE.Fy = DAE.Fy - sparse(a.If,a.bus,Wbu.*V.*cdt.*xad./xeq,DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.If,a.vbus,Wbu.*sdt.*xad./xeq,DAE.n,DAE.m);
DAE.Fy = DAE.Fy - sparse(a.Iq,a.bus,Wbu.*V.*sdt./(xq+xl),DAE.n,DAE.m);
DAE.Fy = DAE.Fy - sparse(a.Iq,a.vbus,Wbu.*cdt./(xq+xl),DAE.n,DAE.m);

DAE.Gx = DAE.Gx - sparse(a.bus,a.Id,V.*sdt,DAE.m,DAE.n);
DAE.Gx = DAE.Gx - sparse(a.vbus,a.Id,V.*cdt,DAE.m,DAE.n);
DAE.Gx = DAE.Gx - sparse(a.bus,a.Iq,V.*cdt,DAE.m,DAE.n);
DAE.Gx = DAE.Gx + sparse(a.vbus,a.Iq,V.*sdt,DAE.m,DAE.n);
DAE.Gx = DAE.Gx + sparse(a.bus,a.delta,-V.*cdt.*id+V.*sdt.*iq,DAE.m,DAE.n);
DAE.Gx = DAE.Gx + sparse(a.vbus,a.delta,V.*sdt.*id+V.*cdt.*iq,DAE.m,DAE.n);
