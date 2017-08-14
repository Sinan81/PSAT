function a = setup(a)

if isempty(a.con)
  a.store = [];
  return
end

a.n = length(a.con(:,1));
for i = 1:a.n
  a.speed(i).time = [];
end
a.store = a.con;
