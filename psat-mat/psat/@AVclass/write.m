function idx = write(a,fid,synlist,offset)
% write AVR data
idx = [];

if ~a.n, return, end

% filter AVRs using synchronous machine list
idx = [];
sdx = [];
for i = 1:a.n
  jdx = find(synlist == a.syn(i)*a.u(i));
  if ~isempty(jdx), idx = [idx; i]; end
  sdx = [sdx; jdx];
end

if isempty(idx), return, end

data = a.con(idx,:);
data(:,1) = sdx + offset;

% write AVR data
fprintf(fid,'Exc.con = [ Exc.con; ...\n');
fprintf(fid,['   ',a.format,';\n'],data');
fprintf(fid,'   ];\n\n');
