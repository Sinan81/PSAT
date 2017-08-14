function a = init(a)

a.con = [];   % DATA - para definir las matrices de datos que se definen en PSAT.
a.n = 0;      % NUMBER OF DEVICES.
a.gen = [];   % INDICE DE LOS GENERADORES NO CONVENCIONALES.
a.freq = [];
a.dat = [];   % Internal data. 
a.we = [];  %Indice de estado de la variable velocidad omega_e.
a.Df = [];  %Indice de estado de la variable velocidad delta_f.
a.Dfm = [];     %Indice de estado de la variable delta_fm.
a.x  =  [];     %Indice de estado de la variable x.
a.csi = [];     %Indice de estado de la variable csi.
a.pfw = [];     %Indice de estado de la variable p_fw.
a.pwa = [];     %Indice de estado de la variable p_w*.
a.pf1 = [];     %Indice de estado de la variable p'_f.
a.pout = [];    %Indice de estado de la variable p_out.
a.store = [];
a.u = [];
