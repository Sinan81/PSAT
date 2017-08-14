function vwplot(a)

global Settings

if ~Settings.init
  fm_choice('No data found. Solve Power Flow first.',2)
  return
end
if ~a.n
  fm_choice('No Wind data found!',2)
  return
end

% plot Wind speeds
colors = {'b','g','r','c','m','y','k'};
figure
hold on
for i = 1:a.n
  leg{i} = ['v_{w',num2str(i),'}'];
  plot(a.speed(i).time,a.speed(i).vw*a.con(i,2),colors{rem(i-1,7)+1})
end
hold off
legend(leg)
title('Wind Speeds')
xlabel('time [s]')
ylabel('v_w [m/s]')
box('on')
