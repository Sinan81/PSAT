function out = isdelta(a,idx)

global Settings

out = 0;

if ~a.n, return, end

if Settings.hostver > 7
  out1 = ~isempty(find(a.delta_HP == idx,1));
  out2 = ~isempty(find(a.delta_IP == idx,1));
  out3 = ~isempty(find(a.delta_LP == idx,1));
  out4 = ~isempty(find(a.delta_EX == idx,1));
  out5 = ~isempty(find(a.delta == idx,1));
else
  out1 = ~isempty(find(a.delta_HP == idx));
  out2 = ~isempty(find(a.delta_IP == idx));
  out3 = ~isempty(find(a.delta_LP == idx));
  out4 = ~isempty(find(a.delta_EX == idx));
  out5 = ~isempty(find(a.delta == idx));
end

out = out1 || out2 || out3 || out4 || out5;
