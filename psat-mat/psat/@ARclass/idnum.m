function idnum(a,object,sys)

type = get_param(object,'MaskType');
nameblock = type(1:end-1);
blocks = find_system(sys,'MaskType',type);
maskvalues = get_param(object,'MaskValues');                                                      
if isempty(blocks), return, end
if length(blocks) == 1
  maskvalues{1} = '1';
  set_param(object,'MaskValues',maskvalues)
  return
end
idx = strmatch(object,blocks,'exact');
blocks(idx) = [];

id = zeros(1,length(blocks));
for i = 1:length(blocks)
 values = get_param(blocks{i},'MaskValues');
 id(i) = str2num(values{2});
end

uid = unique(id);
if length(uid) < length(id)
  fm_disp(['There are multiple defined ', nameblock,' Id Numbers'],2)
end
nid = 1:length(uid);
idx = find(nid < uid);
if isempty(idx)
  num = num2str(length(uid)+1);
else
  num = num2str(nid(idx(1)));
end

nameblock = [nameblock,' ',num];
maskvalues{2} = num;

set_param(object,'MaskDisplay',['plot(xc,yc), color(''blue''), text(-0.5,0.1,''',nameblock,''')'])
set_param(object,'MaskValues',maskvalues);                                                        
