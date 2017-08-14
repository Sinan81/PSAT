function a = setx0(a)

global Bus DAE PV Syn Line jay

if ~a.n, return, end

% reset transmission line reactance and admittance matrix
Line = addxl(Line,a.line,a.u.*a.xcs);
if sum(a.u), Line = build_y(Line); end

V1 = DAE.y(a.v1);
V2 = DAE.y(a.v2);
a1 = DAE.y(a.bus1);
a2 = DAE.y(a.bus2);

vp_max = a.con(:,9);
vp_min = a.con(:,10);
vq_max = a.con(:,11);
vq_min = a.con(:,12);
iq_max = a.con(:,13);
iq_min = a.con(:,14);

kp = a.Cp./(1-a.Cp);
V = V1.*exp(jay.*a1)-V2.*exp(jay.*a2);
theta = angle(V)-pi/2;

% if vp = 0, gamma is as follows:
a.gamma = pi/2+theta-a1;

DAE.x(a.vp) = 0;
DAE.x(a.vq) = a.u.*kp.*V1.*sin(a1-a2)./sin(a1-a2+a.gamma);
DAE.x(a.iq) = a.u.*Bus.Qg(a.bus1)./V1;

idx = find(DAE.x(a.vp) > vp_max);
if idx, warn(a,idx,' Vp is over its max limit.'), end
idx = find(DAE.x(a.vp) < vp_min);
if idx, warn(a,idx,' Vp is under its min limit.'), end

idx = find(DAE.x(a.vq) > vq_max);
if idx, warn(a,idx,' Vq is over its max limit.'), end
idx = find(DAE.x(a.vq) < vq_min);
if idx, warn(a,idx,' Vq is under its min limit.'), end

idx = find(DAE.x(a.iq) > iq_max);
if idx, warn(a,idx,' Ish is over its max limit.'), end
idx = find(DAE.x(a.iq) < iq_min);
if idx, warn(a,idx,' Ish is under its min limit.'), end

DAE.x(a.vp) = max(DAE.x(a.vp),vp_min);
DAE.x(a.vp) = min(DAE.x(a.vp),vp_max);

DAE.x(a.vq) = max(DAE.x(a.vq),vq_min);
DAE.x(a.vq) = min(DAE.x(a.vq),vq_max);

DAE.x(a.iq) = max(DAE.x(a.iq),iq_min);
DAE.x(a.iq) = min(DAE.x(a.iq),iq_max);

% reference voltages
a.Vp0 = DAE.x(a.vp);
a.Vq0 = DAE.x(a.vq);
a.Vref = DAE.x(a.iq)./a.con(:,7) + V1;   
DAE.y(a.vp0) = a.Vp0;
DAE.y(a.vq0) = a.Vq0;
DAE.y(a.vref) = a.Vref;

% checking for synchronous machines and PV generators
for i = 1:a.n
  idxg = findbus(Syn,a.bus1(i));
  if ~isempty(idxg)
    warn(a,i,[' UPFC cannot be connected at the same bus as ' ...
                'synchronous machines.'])
    continue
  end
  if a.u(i)
    idx = findbus(PV,a.bus1(i));
    PV = remove(PV,idx);
    if isempty(idx)
      warn(a,i,' no PV generator found at the bus.')
    end
  end
end

fm_disp('Initialization of UPFCs completed.')  
