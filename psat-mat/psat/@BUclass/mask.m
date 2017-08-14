function [x,y,s] = mask(a,idx,orient,vals)

x = cell(1,1);
y = cell(1,1);
s = cell(1,1);

x{1} = [0 1 1 0 0];
y{1} = [0 0 1 1 0];
s{1} = 'k';
