function a = intervention(a,t)

if ~a.n, return, end

% do not repeat computations if the simulation is stucking
if a.time ~= t
  a.time = t;
else
  return
end

global Line Bus

% Toggle Breaker Status

action = {'Opening','Closing'};
idx = [find(a.t1 == t); find(a.t2 == t)];

if ~isempty(idx)

  a.u(idx) = ~a.u(idx);
  for i = 1:length(idx)
    k = idx(i);
    fm_disp([action{a.u(k)+1},' breaker at bus <', ...
             Bus.names{a.bus(k)}, ...
             '> on line from <', ...
             Bus.names{Line.fr(a.line(k))}, ...
             '> to <', ...
             Bus.names{Line.to(a.line(k))}, ...
             '> for t = ',num2str(t),' s'])
    
    % update Line data and admittance matrix
    Line = setstatus(Line,a.line(k),a.u(k));
    
    % update algebraic variables
    %conv = fm_nrlf(40,1e-4,1,1);
  
    % checking network connectivity
    fm_flows('connectivity','verbose');

  end
end
