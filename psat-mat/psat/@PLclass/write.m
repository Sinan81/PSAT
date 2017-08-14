function write(a,fid,buslist)
% write polynomial loads

if ~a.n, return, end

% filter loads using bus list
idx = [];
for i = 1:a.n
  jdx = find(buslist == a.bus(i)*a.u(i));
  if ~isempty(jdx), idx = [idx; i]; end
end

if isempty(idx), return, end

% write Pl data
fprintf(fid,'Pl.con = [ Pl.con; ...\n');
fprintf(fid,['   ',a.format,';\n'],a.con(idx,:)');
fprintf(fid,'   ];\n\n');
