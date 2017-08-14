function write(a,fid,buslist)
% write shunt admitance data
   
if ~a.n, return, end

% filter shunts using bus list
idx = [];
for i = 1:a.n
  jdx = find(buslist == a.bus(i)*a.u(i));
  if ~isempty(jdx), idx = [idx; i]; end
end

if isempty(idx), return, end

% write shunt data
fprintf(fid,'Shunt.con = [ Shunt.con; ...\n');
fprintf(fid,['   ',a.format,';\n'],a.con(idx,:)');
fprintf(fid,'   ];\n\n');
