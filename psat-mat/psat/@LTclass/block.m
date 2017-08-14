function [enables,prompts] = block(a,object,values,enables,prompts)

display1 = ['plot(x,y,x+1.4,y,[2.4 2.8],[0 0],[3.1 3.5],[0 0],[-1 -2],[0 0],0,2), color(''green''), plot([2.95 2.95],', ...
            '[-0.15 -2],[2.95 -0.8],[-2 -2],[-0.8 -0.8],[-2 -1.2], [-0.8 0.7],[-1.2 1.2],', ...
            '[0.5 0.7],[1.1 1.2],[0.7 0.7], [1.0 1.2],[2.8 3.1 3.1 2.8 2.8],[-0.15 -0.15 0.15 0.15 -0.15]);'];

display2 = ['plot(x,y,x+1.4,y,[2.4 3.5],[0 0],[-1 -2],[0 0],0,2-4*rot), color(''green''), plot([0.8 0.8],3*rot-[1.3 1.7],', ...
            '[0.65 0.95 0.95 0.65 0.65],[3.4*rot-1.7 3.4*rot-1.7 4*rot-2 4*rot-2 3.4*rot-1.7],', ...
            '[0.8 -0.8],[2.4*rot-1.2 1.3-2.6*rot],[-0.6 -0.8],[1.1-2.2*rot 1.2-2.4*rot],[-0.8 -0.8], [1-2*rot 1.2-2.4*rot]);'];

inputs = get_param(object,'Ports');
inputs = inputs(3);
type = str2num(values{3});

switch type
 case 1
  prompts{7} = 'Reference Voltage Vref [p.u.]';
  set_param(object,'MaskDisplay',display1);
  if inputs, delete_block([object,'/in_2']); end
 case 2
  prompts{7} = 'Reference Reactive Power Qref [p.u.]';
  set_param(object,'MaskDisplay',display1);
  if inputs, delete_block([object,'/in_2']); end
 case 3
  prompts{7} = 'Remote Reference Voltage Vref [p.u.]';
  set_param(object,'MaskDisplay',display2);
  if ~inputs
    add_block('built-in/EnablePort',[object,'/in_2'])
    set_param([object,'/in_2'],'position',[65, 155, 85, 175])
  end
end


