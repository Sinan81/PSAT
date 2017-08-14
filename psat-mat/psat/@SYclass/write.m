function idx = write(a,fid,buslist)
% write synchronous machine data

global Bus Settings

idx = [];

if ~a.n, return, end

% filter machines using bus list
idx = [];
for i = 1:a.n
  jdx = find(buslist == a.bus(i)*a.u(i));
  if ~isempty(jdx), idx = [idx; i]; end
end

if isempty(idx), return, end

data = a.con(idx,:);

try
  Vb2old = data(:,3).*data(:,3);
  Vb2new = getkv(Bus,a.bus(idx),2);
  k = Settings.mva*Vb2old./data(:,2)./Vb2new;
  i = [6:10, 13:15];
  for h = 1:length(i)
    data(:,i(h))= data(:,i(h))./k;
  end
  data(:,18) = Settings.mva*data(:,18)./data(:,2);
  data(:,19) = Settings.mva*data(:,19)./data(:,2);
catch
  % nothing to do 
end

% write Syn data
fprintf(fid,'Syn.con = [ Syn.con; ...\n');
fprintf(fid,['   ',a.format,';\n'],data');
fprintf(fid,'   ];\n\n');
