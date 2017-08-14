function check = write(a,fid,buslist,slack)
% write PV generator data

global DAE

check = slack;

if ~a.n, return, end

% filter PV buses using bus list
idx = [];
for i = 1:a.n
  jdx = find(buslist == a.bus(i)*a.u(i));
  if ~isempty(jdx), idx = [idx; i]; end
end

if isempty(idx), return, end

if ~slack
  check = 1;
  [pg,jdx] = max(a.con(idx,4));
  i = idx(jdx(1));
  data = [a.con(i,[1 2 3 5]),0,a.con(i,[6 7 8 9 4 10]),1,1];
  SWeq = SWclass;
  SWeq.con = data;
  SWeq.bus = data(1);
  SWeq.n = 1;
  SWeq.u = 1;
  slack = write(SWeq,fid,data(1));
  idx(jdx(1)) = [];
end

if isempty(idx), return, end

% write PV data
fprintf(fid,'PV.con = [ PV.con; ...\n');
fprintf(fid,['   ',a.format,';\n'],a.con(idx,:)');
fprintf(fid,'   ];\n\n');
