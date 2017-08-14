function p = base(p)
%converts revice parameters to system power and voltage bases
global Syn Settings

if ~p.n, return, end
for i = 1:p.n
    if (p.con(i,2) == 1) || (p.con(i,2) == 2),
         p.con(i,4) = Settings.mva.*p.con(i,4)./getvar(Syn,p.syn(i),'mva');
         p.con(i,5) = p.con(i,5).*getvar(Syn,p.syn(i),'mva')/Settings.mva;
         p.con(i,6) = p.con(i,6).*getvar(Syn,p.syn(i),'mva')/Settings.mva;
    end 
    if (p.con(i,2) == 3),
         p.con(i,5) = p.con(i,5).*getvar(Syn,p.syn(i),'mva')/Settings.mva;
         p.con(i,6) = p.con(i,6).*getvar(Syn,p.syn(i),'mva')/Settings.mva;
         p.con(i,7) = p.con(i,7).*getvar(Syn,p.syn(i),'mva')/Settings.mva;
         p.con(i,8) = p.con(i,8).*getvar(Syn,p.syn(i),'mva')/Settings.mva;
         p.con(i,11) = p.con(i,11).*Settings.mva./getvar(Syn,p.syn(i),'mva');
    end
    if (p.con(i,2) == 4),
         p.con(i,5) = p.con(i,5).*getvar(Syn,p.syn(i),'mva')/Settings.mva;
         p.con(i,6) = p.con(i,6).*getvar(Syn,p.syn(i),'mva')/Settings.mva;
         p.con(i,7) = p.con(i,7).*getvar(Syn,p.syn(i),'mva')/Settings.mva;
         p.con(i,8) = p.con(i,8).*getvar(Syn,p.syn(i),'mva')/Settings.mva;
         p.con(i,11) = p.con(i,11).*Settings.mva./getvar(Syn,p.syn(i),'mva');
    end
    if (p.con(i,2) == 5),
         p.con(i,5) = p.con(i,5).*getvar(Syn,p.syn(i),'mva')/Settings.mva;
         p.con(i,6) = p.con(i,6).*getvar(Syn,p.syn(i),'mva')/Settings.mva;
         p.con(i,7) = p.con(i,7).*getvar(Syn,p.syn(i),'mva')/Settings.mva;
         p.con(i,8) = p.con(i,8).*getvar(Syn,p.syn(i),'mva')/Settings.mva;
         p.con(i,11) = p.con(i,11).*Settings.mva./getvar(Syn,p.syn(i),'mva');
    end
    if (p.con(i,2) == 6),
         p.con(i,16) = p.con(i,16).*Settings.mva./getvar(Syn,p.syn(i),'mva');
    end
end



    



