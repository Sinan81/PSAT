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
   case 'z'
    b = a.z;
   case 'kr'
    b = a.kr;
   case 'v1'
    b = a.v1;
   case 'v2'
    b = a.v2;
   case 'v3'
    b = a.v3;
   case 'Vs'
    b = a.Vs;
   case 'type'
    b = a.type;
   case 'idx'
    b = a.idx;
   case 'svc'
    b = a.svc;
   case 'statcom'
    b = a.statcom;
   case 'sssc'
    b = a.sssc;
   case 'tcsc'
    b = a.tcsc;
   case 'upfc'
    b = a.upfc;
   case 'dfig'
    b = a.dfig;
   case 'n'
    b = a.n;
   case 'ncol'
    b = a.ncol;
   case 'format'
    b = a.format;
  end
end
