function odm(a,fid,tag,bus,space)

if ~a.n, return, end

idx = findbus(a,bus);

if isempty(idx), return, end

count = fprintf(fid,'%s<%s:voltage>\n',space,tag);
count = fprintf(fid,'  %s<%s:voltage>%8.5f</%s:voltage>\n',space,tag,a.con(idx,5),tag);
count = fprintf(fid,'  %s<%s:unit>PU</%s:unit>\n',space,tag,tag);
count = fprintf(fid,'%s</%s:voltage>\n',space,tag);
count = fprintf(fid,'%s<%s:genData>\n',space,tag);
count = fprintf(fid,'  %s<%s:code>PV</%s:code>\n',space,tag,tag);
count = fprintf(fid,'  %s<%s:gen>\n',space,tag);
count = fprintf(fid,'    %s<%s:p>%8.5f</%s:p>\n',space,tag,a.con(idx,4),tag);
count = fprintf(fid,'    %s<%s:q>0.0</%s:q>\n',space,tag,tag);
count = fprintf(fid,'    %s<%s:unit>PU</%s:unit>\n',space,tag,tag);
count = fprintf(fid,'  %s</%s:gen>\n',space,tag);
count = fprintf(fid,'%s</%s:genData>\n',space,tag);
