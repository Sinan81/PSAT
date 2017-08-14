function write(a,fid,buslist)
% write transmission line and transformer data

% filter lines using bus list
idx = [];
for i = 1:a.n
  idxfr = find(buslist == a.fr(i)*a.u(i));
  idxto = find(buslist == a.to(i)*a.u(i));
  if ~isempty(idxfr) && ~isempty(idxto), idx = [idx; i]; end
end

if isempty(idx), return, end

% write line data
fprintf(fid,'Line.con = [ Line.con; ...\n');
fprintf(fid,['   ',a.format,';\n'],a.con(idx,:)');
fprintf(fid,'   ];\n\n');

