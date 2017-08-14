function a = setx0(a)

global DAE Line

if ~a.n, return, end

ty3 = a.con(:,2) == 3;
typwr = a.con(:,10) == 1;
tyang = a.con(:,10) == 2;

kp = a.Cp./(1-a.Cp);

DAE.x(a.vcs) = a.u.*kp.*ssscden(a);
idx3 = find(ty3);
if ~isempty(idx3)
  DAE.x(a.vpi(idx3)) = a.u(idx3).*DAE.x(a.vcs(idx3));
end

% reset transmission line reactance and admittance matrix
Line = addxl(Line,a.line,a.u.*a.xcs);
if sum(a.u), Line = build_y(Line); end

[Ps,Qs,Pr,Qr] = flows(Line,'pq',a.line);
[Ps,Qs,Pr,Qr] = flows(a,Ps,Qs,Pr,Qr,'sssc');

a.Pref = Ps + ty3.*tyang.*Pr;

vcs_max = a.u.*a.con(:,8);
vcs_min = a.u.*a.con(:,9);

idx = find(DAE.x(a.vcs) > vcs_max);
if idx, warn(a,idx,' Vs is over its max limit.'), end
idx = find(DAE.x(a.vcs) < vcs_min);
if idx, warn(a,idx,' Vs is under its min limit.'), end
DAE.x(a.vcs) = max(DAE.x(a.vcs),vcs_min);
DAE.x(a.vcs) = min(DAE.x(a.vcs),vcs_max);

% reference voltage signal
a.V0 = DAE.x(a.vcs);

DAE.y(a.v0) = a.V0;
DAE.y(a.pref) = a.Pref;

fm_disp('Initialization of SSSC completed.')
