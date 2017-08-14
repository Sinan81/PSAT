function b = subsref(a,index)

switch index(1).type
 case '.'
  switch index(1).subs
   case 'n'
    b = a.n;
   case 'syn'
    if length(index) == 2
      switch index(2).type
       case '{}'
        b = a.syn{index(2).subs{:}};
       case '()'
        b = a.syn(index(2).subs{:});
      end
    else
      b = a.syn;
    end
   case 'con'
    b = [];
   case 'M'
    b = a.M;
   case 'Mtot'
    b = a.Mtot;
   case 'delta'
    b = a.delta;
   case 'omega'
    b = a.omega;
   case 'gen'
    b = a.gen;
   case 'dgen'
    b = a.dgen;
   case 'wgen'
    b = a.wgen;
  end
end
