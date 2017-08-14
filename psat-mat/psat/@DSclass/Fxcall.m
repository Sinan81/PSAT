function Fxcall(a)

global DAE Syn Settings

if ~a.n, return, end

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

DAE.Fy = DAE.Fy - sparse(a.omega,a.pm,iM,DAE.n,DAE.m);
DAE.Fy = DAE.Fy + sparse(a.omega_HP,a.pm,iMhp,DAE.n,DAE.m);

DAE.Fx = DAE.Fx + sparse(a.delta_HP,a.omega_HP,Wn,DAE.n,DAE.n); 
DAE.Fx = DAE.Fx - sparse(a.omega_HP,a.delta_HP,K12.*iMhp,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega_HP,a.omega_HP,(Dhp+D12).*iMhp,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_HP,a.delta_IP,K12.*iMhp,DAE.n,DAE.n);

DAE.Fx = DAE.Fx + sparse(a.delta_IP,a.omega_IP,Wn,DAE.n,DAE.n); 
DAE.Fx = DAE.Fx + sparse(a.omega_IP,a.delta_HP,K12.*iMip,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega_IP,a.delta_IP,(K12+K23).*iMip,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega_IP,a.omega_IP,(Dip+D12+D23).*iMip,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_IP,a.delta_LP,K23.*iMip,DAE.n,DAE.n);

DAE.Fx = DAE.Fx + sparse(a.delta_LP,a.omega_LP,Wn,DAE.n,DAE.n); 
DAE.Fx = DAE.Fx + sparse(a.omega_LP,a.delta_IP,K23.*iMlp,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega_LP,a.delta_LP,(K23+K34).*iMlp,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega_LP,a.omega_LP,(Dlp+D23+D34).*iMlp,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_LP,a.delta,K34.*iMlp,DAE.n,DAE.n);

DAE.Fx = DAE.Fx + sparse(a.omega,a.delta_LP,K34.*iM,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega,a.delta,(K34+K45).*iM,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega,a.omega,(D34+D45).*iM,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega,a.delta_EX,K45.*iM,DAE.n,DAE.n);

DAE.Fx = DAE.Fx + sparse(a.delta_EX,a.omega_EX,Wn,DAE.n,DAE.n); 
DAE.Fx = DAE.Fx + sparse(a.omega_EX,a.delta,K45.*iMex,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega_EX,a.delta_EX,K45.*iMex,DAE.n,DAE.n);
DAE.Fx = DAE.Fx - sparse(a.omega_EX,a.omega_EX,(Dex+D45).*iMex,DAE.n,DAE.n);

DAE.Fx = DAE.Fx + sparse(a.omega_HP,a.omega_IP,D12.*iMhp,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_IP,a.omega_HP,D12.*iMip,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_IP,a.omega_LP,D23.*iMip,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_LP,a.omega_IP,D23.*iMlp,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_LP,a.omega,D34.*iMlp,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega,a.omega_LP,D34.*iM,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega,a.omega_EX,D45.*iM,DAE.n,DAE.n);
DAE.Fx = DAE.Fx + sparse(a.omega_EX,a.omega,D45.*iMex,DAE.n,DAE.n);
