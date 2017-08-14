function check = write(a,fid,buslist)
% write slack buses

check = 0;

if ~a.n, return, end

% filter slack buses using bus list
idx = [];
for i = 1:a.n
  jdx = find(buslist == a.bus(i)*a.u(i));
  if ~isempty(jdx), idx = [idx; i]; end
end

if isempty(idx), return, end

data = a.con(idx,:);
jdx = find(data(:,12));
if isempty(jdx), data(1,12) = 1; end

% write SW data
check = 1;
fprintf(fid,'SW.con = [ SW.con; ...\n');
fprintf(fid,['   ',a.format,';\n'],data');
fprintf(fid,'   ];\n\n');
