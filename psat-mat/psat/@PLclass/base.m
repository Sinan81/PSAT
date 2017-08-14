function a = base(a)

if ~a.n, return, end

global Settings

if ~isempty(a.init)
  k = a.init;
  a.con(k,5) = a.con(k,5).*a.con(k,2)/Settings.mva;
  a.con(k,6) = a.con(k,6).*a.con(k,2)/Settings.mva;
  a.con(k,7) = a.con(k,7).*a.con(k,2)/Settings.mva;
  a.con(k,8) = a.con(k,8).*a.con(k,2)/Settings.mva;
  a.con(k,9) = a.con(k,9).*a.con(k,2)/Settings.mva;
  a.con(k,10) = a.con(k,10).*a.con(k,2)/Settings.mva;
end
