function [enables,prompts] = block(a,object,values,enables,prompts)

display = 'plot(xc,yc), color(''blue''), text(-0.5,0.1,';

num = str2num(values{2});
type = get_param(object,'MaskType');

blocks = find_system(gcs,'MaskType',type);
idx = strmatch(object,blocks,'exact');
blocks(idx) = [];

id = zeros(1,length(blocks));
for i = 1:length(blocks)
 values = get_param(blocks{i},'MaskValues');
 id(i) = str2num(values{2});
end

uid = unique(id);
if length(uid) < length(id)
  fm_disp(['There are multiple defined ',type(1:end-1),' Id Numbers'],2)
end

idx = find(uid == num);
if isempty(idx)
  num = num2str(num);
else
  fm_disp(['The ', type(1:end-1),' Id ',num2str(num),' is already taken.'])
  nid = 1:length(uid);
  idx = find(nid < uid);
  if isempty(idx)
    num = num2str(length(uid)+1);
  else
    num = num2str(nid(idx(1)));
  end
  fm_disp(['PSAT will use ',num,' as ',type(1:end-1),' Id.'])
  values = get_param(object,'MaskValues');
  values{2} = num;
  set_param(object,'MaskValues',values);
end

switch type
 case 'Areas',  set_param(object,'MaskDisplay',[display,'''Area ',num,''')']);
 case 'Regions', set_param(object,'MaskDisplay',[display,'''Region ',num,''')']);
end

switch values{1}
 case '0', enables{3} = 'on';
 case '1', enables{3} = 'off';
end
