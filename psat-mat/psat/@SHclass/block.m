function [enables,prompts] = block(a,object,values,enables,prompts)

value = str2num(values{2});
names = get_param(object,'MaskNames');

if strcmp(names{2},'p6q')
  type = value;
else
  return
end

if type == 0
  fm_choice('Shunt reactance should not be zero!',2)
  return
end

ground = ['[0 0],[-0.4 0.4],[0.075 0.075],[-0.25 0.25],[0.15' ...
          ' 0.15],[-0.1 0.1]'];

if type < 0 % inductor

  lx  = ['-[0 23 23 24 28 34 40 47 52 55 56 54 51 51 47 46 ', ...
         '48 51 57 64 70 75 79 79 77 74 74 70 69 71 75 80 87 ', ...
         '93 99 102 103 101 97 97 94 93 94 98 104 110 117 ', ...
         '122 125 126 126 150]/150'];
  ly  = ['[0 0 1 11 19 24 25 23 17 8 -2 -12 -18 -18 -9 1 11 ', ...
         '19 24 25 23 17 8 -2 -12 -18 -18 -9 1 11 19 24 25 ', ...
         '23 17 8 -2 -12 -18 -18 -9 1 11 19 24 25 23 17 8 0 0 0]/45'];
  display1 = ['plot(',lx,',',ly,',',ground,',0,-0.5)'];

elseif type > 0 % capacitor

  cx1 = '-[0 60 60 55 53 55 60 60 55 53]/150';
  cy1 = '[0 0 8 16 25 16 8 -8 -16 -25]/50';
  cx2 = '-[80 80 80 150]/150';
  cy2 = '[25 -25 0 0]/50';
  display1 = ['plot(',cx1,',',cy1,',',cx2,',',cy2,',',ground,')'];

end

set_param(object,'MaskDisplay',display1);

