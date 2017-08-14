function write(a,fid,buslist,type)
% write PQ loads/generators

if ~a.n, return, end

% filter loads using bus list
idx = [];
for i = 1:a.n
  jdx = find(buslist == a.bus(i)*a.u(i));
  if ~isempty(jdx), idx = [idx; i]; end
end

if isempty(idx), return, end

% write PQ data
fprintf(fid,[type,'.con = [ ',type,'.con; ...\n']);
fprintf(fid,['   ',a.format,';\n'],a.con(idx,:)');
fprintf(fid,'   ];\n\n');
