function a = setx0(a)

global DAE Syn

if ~a.n, return, end

xd = a.con(:,4);
xq = a.con(:,5);

idx = find(a.con(:,3));

if ~isempty(idx)
  xd(idx) = Syn.con(a.syn(idx),8);
  xq(idx) = Syn.con(a.syn(idx),13);
  a.con(idx,4) = xd(idx);
  a.con(idx,5) = xq(idx);
end

% initialization
DAE.x(a.v) = zeros(a.n,1);
DAE.y(a.If) = ifield(a,1);

idx = find(DAE.y(a.If) > a.con(:,6));
if ~isempty(idx)
  warn(a,idx,' Field current is over its thermal limit. Reset to 1.2 I_f')
  a.con(idx,6) = 1.2*DAE.y(a.If(idx));
end

idx = find(a.con(:,2) <= 0);
if ~isempty(idx)
  warn(a,idx,' Integrator time constant is <= 0.  Reset to 10 s.')
  a.con(idx,2) = 10;
end

fm_disp('Initialization of Over Excitation Limiters completed.')
