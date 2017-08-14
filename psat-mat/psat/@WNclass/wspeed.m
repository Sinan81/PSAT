function Vw = wspeed(a)

global DAE Settings

Vw = zeros(a.n,1);
t = DAE.t;
if t < 0, t = Settings.t0; end

if t == Settings.t0
  Vw = a.vwa;
else
  for i = 1:a.n
    Vw(i) = interp1(a.speed(i).time,a.speed(i).vw,t);
  end
end
