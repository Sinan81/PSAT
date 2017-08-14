function a = setx0(a)

global Syn Bus DAE PV

if ~a.n, return, end

V = DAE.y(a.vbus);
Kr = a.con(:,5);
Tr = a.con(:,6);
ist_max = a.u.*a.con(:,7);
ist_min = a.u.*a.con(:,8);

% eliminate PV components used for initializing STATCOM's
for i = 1:a.n
  idxg = findbus(Syn,a.bus(i));
  if ~isempty(idxg)
    warn(a,i,[' STATCOM cannot be connected at the same bus as ' ...
                     'synchronous machines.'])
    continue
  end
  if a.u(i)
    idx = findbus(PV,a.bus(i));
    PV = remove(PV,idx);
    if isempty(idx)
      warn(a,i,' no PV generator found at the bus.')
    end
  end
end
DAE.x(a.ist) = a.u.*Bus.Qg(a.bus)./V;
idx = find(DAE.x(a.ist) > ist_max);
if idx, warn(a,idx,' Ish is over its max limit.'), end
idx = find(DAE.x(a.ist) < ist_min);
if idx, warn(a,idx,' Ish is under its min limit.'), end
DAE.x(a.ist) = max(DAE.x(a.ist),ist_min);
DAE.x(a.ist) = min(DAE.x(a.ist),ist_max);

% reference voltages
a.Vref = DAE.x(a.ist)./Kr + V;
DAE.y(a.vref) = a.Vref;

fm_disp('Initialization of STATCOMs completed.')
