function a = islands(a,traceY)

if ~a.n, return, end

% defining critical islanded buses
a.island = find(traceY < 1e-4);
if ~isempty(a.island)
  n = length(a.island);
  if n > 10
    fm_disp(['* * ',num2str(n),' buses are islanded!'])
    fm_disp(['* * Type ''Bus.island'' to get islanded bus numbers.'])
  else
    fm_disp(fm_strjoin(' * * Bus #', num2str(a.island),' is islanded.'))
  end
end