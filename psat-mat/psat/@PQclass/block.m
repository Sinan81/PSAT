function [enables,prompts] = block(a,object,values,enables,prompts)

type = values{4};
switch type
 case 'on',  enables{3} = 'on';
 case 'off', enables{3} = 'off';
end

