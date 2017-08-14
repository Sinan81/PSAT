function [enables,prompts] = block(a,object,values,enables,prompts)

type = str2num(values{2});
idx = [4, 7];

switch type
 case 1, enables(idx) = {'off'; 'off'};
 case 3, enables(idx) = {'on';  'off'};
 case 5, enables(idx) = {'on';  'on'};
end
