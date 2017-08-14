function [enables,prompts] = block(a,object,values,enables,prompts)

type = values{2};
switch type
 case 'on',  enables([3, 4]) = {'off','off'};
 case 'off', enables([3, 4]) = {'on' ,'on'};
end
