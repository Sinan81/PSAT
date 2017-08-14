function odm(a,fid,tag,idx,space)

if ~a.n, return, end
if idx > a.n, return, end

count = fprintf(fid,'%s<%s:name>%s</%s:name>\n',space,tag,a.names{idx},tag);
count = fprintf(fid,'%s<%s:id>%d</%s:id>\n',space,tag,a.con(idx,1),tag);
count = fprintf(fid,'%s<%s:baseVoltage>%7.2f</%s:baseVoltage>\n',space,tag,a.con(idx,2),tag);
count = fprintf(fid,'%s<%s:baseVoltageUnit>KV</%s:baseVoltageUnit>\n',space,tag,tag);

