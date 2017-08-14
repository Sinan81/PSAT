function [enables,prompts] = block_sssc(a,object,values,enables,prompts)

type = values{2};
switch type
 case 'constant_power'
  enables([3 7]) = {'on'; 'on'};
 otherwise
  enables([3 7]) = {'off'; 'off'};
end

