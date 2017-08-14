function a = setup(a)

if isempty(a.con)
  a.store = [];
  return
end

a.n = 1;

lypdp = length(a.con);

if lypdp > 206, a.con = a.con([1:206]); end

if lypdp < 206
  fm_disp(['* * * Custom Power Demand Profile.'])
  a.d = 1;
  a.w = 1;
  a.y = 1;
  a.day = a.con';
  a.week = 100;
  a.year = 100;
  a.len = length(a.day);
else
  fm_disp(['* * * Daily Power Demand Profile.'])
  a.day = zeros(24,6);
  a.day(:,1) = a.con([1:24]);
  a.day(:,2) = a.con([25:48]);
  a.day(:,3) = a.con([49:72]);
  a.day(:,4) = a.con([73:96]);
  a.day(:,5) = a.con([97:120]);
  a.day(:,6) = a.con([121:144]);
  a.week = a.con([145:151]);
  a.year = a.con([152:203]);
  a.d = min(6,max(1,round(a.con(204))));
  a.w = min(7,max(1,round(a.con(205))));
  a.y = min(52,max(1,round(a.con(206))));
  a.len = 24;
end

a.store = a.con;
