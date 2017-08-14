function write(a,fid,buslist)
% write bus data

fprintf(fid,'Bus.con = [ Bus.con; ...\n');
fprintf(fid,['   ',a.format,';\n'],a.con(buslist,:)');
fprintf(fid,'   ];\n\n');

fprintf(fid,'Bus.names = [ Bus.names; { ...\n');
for i = 1:length(buslist)
  fprintf(fid,'    ''%s'';\n',a.names{buslist(i)});
end
fprintf(fid,'   }];\n\n');
