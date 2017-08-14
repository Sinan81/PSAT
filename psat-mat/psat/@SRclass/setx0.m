function a = setx0(a)

global Bus DAE

if ~a.n, return, end

V = DAE.y(a.vbus);
theta = DAE.y(a.bus);

xd  = a.con(:,5);
xq  = a.con(:,6);
ra  = a.con(:,7);
xad = a.con(:,8);
r   = a.con(:,9);
xl  = a.con(:,10);
xc  = a.con(:,11);
rf  = a.con(:,12);
xf  = a.con(:,13);
k12 = a.con(:,24);
k23 = a.con(:,25);
k34 = a.con(:,26);
k45 = a.con(:,27);

VV =  V.*exp(i*theta);
S = Bus.Pg(a.bus) - i*Bus.Qg(a.bus);
Ig = S./conj(VV);
delta = angle(VV + (ra+r + i*(xq+xl-xc)).*Ig);
cdt = cos(delta-theta);
sdt = sin(delta-theta);
Idq = Ig.*exp(-i*(delta-pi/2));
Id = real(Idq);
Iq = imag(Idq);
If = (xl.*Id+(ra+r).*Iq+xd.*Id-xc.*Id+V.*cdt)./xad;
Te = (xq-xd).*Id.*Iq+xad.*If.*Iq;
delta_LP = Te./k34+delta;
delta_IP = ((k23+k34).*delta_LP-k34.*delta)./k23;
delta_HP = ((k12+k23).*delta_IP-k23.*delta_LP)./k12;
B = (ra+r).*Id-xl.*Iq-xq.*Iq+xc.*Iq+V.*sdt;

a.Tm = k12.*delta_HP-k12.*delta_IP;
a.Efd = xf.*B./rf + xad.*If;

DAE.x(a.Id) = a.u.*Id;
DAE.x(a.Iq) = a.u.*Iq;
DAE.x(a.If) = a.u.*If;

DAE.x(a.omega_HP) = a.u;
DAE.x(a.omega_IP) = a.u;
DAE.x(a.omega_LP) = a.u;
DAE.x(a.omega) = a.u;
DAE.x(a.omega_EX) = a.u;

DAE.x(a.Eqc) = -a.u.*xc.*Id;
DAE.x(a.Edc) =  a.u.*xc.*Iq;

DAE.x(a.delta) = a.u.*delta;
DAE.x(a.delta_EX) = a.u.*delta;
DAE.x(a.delta_HP) = a.u.*delta_HP;
DAE.x(a.delta_IP) = a.u.*delta_IP;
DAE.x(a.delta_LP) = a.u.*delta_LP;

% find & delete static generators
check = 1;
for j = 1:a.n
  if ~fm_rmgen(a.u(j)*a.bus(j)), check = 0; end
end

if ~check
  fm_disp('SSR models cannot be properly initialized.')
else
  fm_disp('Initialization of SSR models completed.')
end
