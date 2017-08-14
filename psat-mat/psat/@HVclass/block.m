function [enables,prompts] = block(a,object,values,enables,prompts)

type = values{11};
switch type
 case 'Voltage_control'
  prompts{10} = ['Reference dc voltage limits (Vr_max, Vr_min, Vi_max, ' ...
                 'Vi_min) [p.u.]'];
 otherwise
  prompts{10} = ['Reference dc current limits (Ir_max, Ir_min, Ii_max, ' ...
                 'Ii_min) [p.u.]'];
end
