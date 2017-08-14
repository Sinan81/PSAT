function [enables,prompts] = block(a,object,values,enables,prompts)

type = str2num(values{1});
switch type
 case 1, enables([2 5 6 7 8 9 10]) = {'off','on', 'off','off','off','off','off'};
 case 2, enables([2 5 6 7 8 9 10]) = {'on' ,'off','on', 'off','off','off','off'};
 case 3, enables([2 5 6 7 8 9 10]) = {'on' ,'off','on', 'off','off','off','off'};
 case 4, enables([2 5 6 7 8 9 10]) = {'on' ,'off','on', 'on', 'on', 'on' ,'on'};
 case 5, enables([2 5 6 7 8 9 10]) = {'on' ,'off','on', 'on', 'on', 'on' ,'on'};
end

