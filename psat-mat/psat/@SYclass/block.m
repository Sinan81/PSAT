function [enables,prompts] = block(a,object,values,enables,prompts)

type = str2num(values{2});
idx = 11;

switch type
 case 2,   enables(idx) = {'off'};
 case 3,   enables(idx) = {'off'};
 case 4,   enables(idx) = {'off'};
 case 5.1, enables(idx) = {'off'};
 case 5.2, enables(idx) = { 'on'};
 case 5.3, enables(idx) = {'off'};
 case 6,   enables(idx) = { 'on'};
 case 8,   enables(idx) = { 'on'};
end
