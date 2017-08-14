function [enables,prompts] = block(a,object,values,enables,prompts)

display1 = ['plot([1 2 2 1 1],[-1 -1 1 1 -1]),color(''red''),', ...
            'plot([1 2],[-1 1],[2 1],[-1 1])'];

display2 = ['plot([1 2 2 1 1],[-1 -1 1 1 -1])'];

type = values{2};

switch type
 case 'on',  set_param(object,'MaskDisplay',display1);
 case 'off', set_param(object,'MaskDisplay',display2);
end
