function odm(a,fid,tag,bus,space)

if ~a.n, return, end

idx = findbus(a,bus);

if isempty(idx), return, end

if a.gen(idx)
  type = 'gen';
  code = 'PQ';
else
  type = 'load';
  code = 'CONST_P';
end

count = fprintf(fid,'%s<%s:%sData>\n',space,tag,type);
count = fprintf(fid,'  %s<%s:code>%s</%s:code>\n',space,tag,code,tag);
count = fprintf(fid,'  %s<%s:%s>\n',space,tag,type);
count = fprintf(fid,'    %s<%s:p>%8.5f</%s:p>\n',space,tag,a.con(idx,4),tag);
count = fprintf(fid,'    %s<%s:q>%8.5f</%s:q>\n',space,tag,a.con(idx,5),tag);
count = fprintf(fid,'    %s<%s:unit>PU</%s:unit>\n',space,tag,tag);
count = fprintf(fid,'  %s</%s:%s>\n',space,tag,type);
count = fprintf(fid,'%s</%s:%sData>\n',space,tag,type);
