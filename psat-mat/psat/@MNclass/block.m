function [enables,prompts] = block(a,object,values,enables,prompts)

type = values{4};
switch type
 case 'on',  prompts{2} = 'Percentage of active && reactive powers [%, %]';
 case 'off', prompts{2} = 'Active && reactive powers [p.u., p.u.]';
end
