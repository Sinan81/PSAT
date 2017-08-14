function [enables,prompts] = block_bus(a,object,values,enables,prompts)

colors = {'black','blue','green','red','yellow', ...
          'cyan','orange','darkgreen','lightblue','gray'};
numc = rem(round(str2num(values{5}))-1,10)+1;
set_param(object,'BackgroundColor',colors{numc});
