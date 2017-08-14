function [enables,prompts] = block(a,object,values,enables,prompts)

type = values{4};
switch type
 case 'on'
  prompts{2} = 'Percentage of resistance, active current and active power [%, %, %]';
  prompts{3} = 'Percentage of reactance, reactive current and reactive power [%, %, %]';
 case 'off'
  prompts{2} = 'Resistance, active current and active power [p.u., p.u., p.u.]';
  prompts{3} = 'Reactance, reactive current and reactive power [p.u., p.u., p.u.]';
end
