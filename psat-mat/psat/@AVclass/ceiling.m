function output = ceiling(p,vf,A,B,flag)

%Se = A.*(exp(B.*abs(vf))-1);
Se = A.*exp(B.*abs(vf));

switch flag
 
 case 1, output = Se.*vf;
 case 2, output = Se + A.*B.*exp(B.*abs(vf)).*abs(vf);

end
