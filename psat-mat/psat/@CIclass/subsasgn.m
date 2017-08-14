function a = subsasgn(a,index,val)

switch index(1).type
 case '.'
  switch index(1).subs
   case 'syn'
    a.syn = val;
   case 'gen'
    a.gen = val;
   case 'delta'
    a.delta = val;
   case 'omega'
    a.omega = val;
   case 'n'
    a.n = val;
  end
end
