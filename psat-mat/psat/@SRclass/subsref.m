function b = subsref(a,index)

switch index(1).type
 case '.'
  switch index(1).subs
   case 'con'
    if length(index) == 2
      b = a.con(index(2).subs{:});
    else
      b = a.con;
    end
   case 'u'
    if length(index) == 2
      b = a.u(index(2).subs{:});
    else
      b = a.u;
    end
   case 'bus'
    b = a.bus;
   case 'n'
    b = a.n;
   case 'Id'
    b = a.Id;    
   case 'Iq'
    b = a.Iq;    
   case 'If'
    b = a.If;    
   case 'Edc'
    b = a.Edc;    
   case 'Eqc'
    b = a.Eqc;    
   case 'Tm'
    b = a.Tm;    
   case 'Efd'
    b = a.Efd;    
   case 'delta_HP'
    b = a.delta_HP;    
   case 'omega_HP'
    b = a.omega_HP;    
   case 'delta_IP'
    b = a.delta_IP;    
   case 'omega_IP'
    b = a.omega_IP;    
   case 'delta_LP'
    b = a.delta_LP;    
   case 'omega_LP'
    b = a.omega_LP;    
   case 'delta_EX'
    b = a.delta_EX;    
   case 'omega_EX'
    b = a.omega_EX;    
   case 'delta'
    b = a.delta;    
   case 'omega'
    b = a.omega;    
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
  end
end
