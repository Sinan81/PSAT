function a = base(a)

if ~a.n, return, end

global Settings

if ~isempty(a.init)
  k = a.init;
  a.con(k,4) = a.con(k,4).*a.con(k,2)/Settings.mva;
  a.con(k,5) = a.con(k,5).*a.con(k,2)/Settings.mva;
end
