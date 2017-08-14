function val_out = fval(co,val_in,gtzero)
% FVAL sets parameters in graphical user interfaces
%
% OUT = FVAL(HDL,IN [,GTZERO])
%     HDL    object handle
%     IN     input value
%     GTZERO check if output value > 0
%            ( == 0 to disable,  default == 1)
%     OUT    output value
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Update:    22-Aug-2003
%Version:   1.1.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

if nargin == 2
  gtzero = 1;
end

stringa = get(co,'String');
callback = get(co,'Callback');
a = findstr(callback,' =');
if a,
  nome = ['"',callback(1:a(1)-1),'" '];
end

try
  val_out = str2num(stringa);
catch
  val_out = val_in;
  fm_disp(lasterr,2);
  return
end
[a0, b0] = size(val_out);
if isempty(val_out)
  fm_disp(['Input variable or function "',stringa,'" is empty.'], 2)
  val_out = val_in;
  set(co,'String',num2str(val_in))
elseif (a0 > 1 || b0 > 1)
  if a,
    fm_disp(['Parameter ', nome,'has to be scalar.'], 2),
  end
  val_out = val_in;
  set(co,'String',num2str(val_in))
else
  if gtzero == 1 && val_out < 0
    stringa = '0';
    fm_disp(['Parameter ',nome,'cannot be negative.']),
    set(co,'String','0')
    val_out = 0;
  elseif gtzero == 2 && val_out <= 0
    stringa = num2str(val_in);
    fm_disp(['Parameter ',nome,'cannot be negative.']),
    set(co,'String',stringa)
    val_out = val_in;
  end
  if a,
    fm_disp(['Parameter ',nome,'set to "', stringa,'".']),
  end
end