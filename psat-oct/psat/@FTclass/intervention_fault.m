function a = intervention_fault(a,t)

global DAE Bus Settings
persistent angles voltages

if ~a.n, return, end

% do not repeat computations if the simulation is stucking
if a.time ~= t
  a.time = t;
else
  return
end
  
for i = 1:a.n
  
  h = a.bus(i);
  
  if t == a.con(i,5) % fault occurrence
    
    fm_disp(['Applying fault(s) at bus <', ...
             Bus.names{h},'> for t = ',num2str(t),' s'])
    
    % enable fault
    a.u(i) = 1; 
    
    % store pre-fault bus angles
    angles = DAE.y(Bus.a);
    voltages = DAE.y([Bus.n+1:end]);
    
    % update algebraic variables
    %conv = fm_nrlf(40,1e-4,1,0);
    
  elseif t == a.con(i,6) % fault clearance
    
    fm_disp(['Clearing fault(s) at bus <', ...
             Bus.names{h},'> for t = ',num2str(t),' s'])
    
    % disable fault
    a.u(i) = 0; 
    
    % recover bus voltages
    %DAE.y(Bus.n+1:2*Bus.n) = ones(Bus.n,1);
    %DAE.y(getbus_pv(PV,'v')) = getvg_pv(PV,'all');
    %DAE.y(getbus_sw(SW,'v')) = getvg_sw(SW,'all');
    DAE.y([Bus.n+1:end]) = voltages;
    if Settings.resetangles
      DAE.y(Bus.a) = angles;
    end

    % update algebraic variables
    %conv = fm_nrlf(40,1e-4,1,1);
    
  end
  
end
