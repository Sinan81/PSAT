function xfirst(a)

if ~a.n, return, end

global DAE Settings

I0 = a.con(:,26);
P0 = a.con(:,27);
V0 = a.con(:,28);
uI = a.u.*a.dat(:,9);
uP = a.u.*a.dat(:,10);
uV = a.u.*a.dat(:,11);

DAE.y(a.cosa) = 0.5*a.u.*(a.dat(:,3)+a.dat(:,4));
DAE.y(a.cosg) = a.u.*a.dat(:,5); % minimum gamma
DAE.y(a.Vrdc) = uI + uP + uV.*V0;
DAE.y(a.Vidc) = uI + uP + uV.*V0;
DAE.y(a.yr) = uI.*I0 + uP.*P0 + uV.*V0;
DAE.y(a.yi) = uI.*I0 + uP.*P0 + uV.*V0;
DAE.y(a.phir) = 0.5;
DAE.y(a.phii) = 0.5;

DAE.x(a.Idc) = uI.*I0 + uP.*P0;
DAE.x(a.xr) = DAE.y(a.cosa);
DAE.x(a.xi) = DAE.y(a.cosg);
