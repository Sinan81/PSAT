function cdata = fm_mat(filename)
% FM_MAT filter images for fitting GUI appearance
%
% CDATA = FM_MAT(FILENAME)
%     FILENAME bitmap file name without extension (string)
%     CDATA MxNx3 array containing the bitmap
%
%Author:    Federico Milano
%Date:      11-Nov-2002
%Version:   1.0.0
%
%E-mail:    federico.milano@ucd.ie
%Web-site:  faraday1.ucd.ie/psat.html
%
% Copyright (C) 2002-2016 Federico Milano

global Theme Path Settings

is_bmp = (exist([Path.images,filename,'.bmp']) == 2);
is_jpg = (exist([Path.images,filename,'.jpg']) == 2);

if is_bmp

  cdata = imread([Path.images,filename,'.bmp'],'bmp');
  [xs,ys,zs] = size(cdata);
  cdata = double(cdata);
  [xa ya] = find(cdata(:,:,1) == 192 & cdata(:,:,2) == 192 & cdata(:,:,3) == 192);
  [xb yb] = find(cdata(:,:,1) == 128 & cdata(:,:,2) == 128 & cdata(:,:,3) == 128);

  if ~isempty(xa)
    switch Settings.platform
     case 'MAC'
      c = round(0.9529*255)-192;
      cdata(:,:,1) = cdata(:,:,1) + sparse(xa,ya,c,xs,ys);
      cdata(:,:,2) = cdata(:,:,2) + sparse(xa,ya,c,xs,ys);
      cdata(:,:,3) = cdata(:,:,3) + sparse(xa,ya,c,xs,ys);
     otherwise
      cdata(:,:,1) = cdata(:,:,1) + sparse(xa,ya,round(Theme.color02(1)*255)-192,xs,ys);
      cdata(:,:,2) = cdata(:,:,2) + sparse(xa,ya,round(Theme.color02(2)*255)-192,xs,ys);
      cdata(:,:,3) = cdata(:,:,3) + sparse(xa,ya,round(Theme.color02(3)*255)-192,xs,ys);
    end
  end

  if ~isempty(xb)
    switch Settings.platform
     case 'MAC'
      c = round(0.9529*255)-128;
      cdata(:,:,1) = cdata(:,:,1) + sparse(xb,yb,c,xs,ys);
      cdata(:,:,2) = cdata(:,:,2) + sparse(xb,yb,c,xs,ys);
      cdata(:,:,3) = cdata(:,:,3) + sparse(xb,yb,c,xs,ys);
     otherwise
      cdata(:,:,1) = cdata(:,:,1) + sparse(xb,yb,round(Theme.color03(1)*255)-128,xs,ys);
      cdata(:,:,2) = cdata(:,:,2) + sparse(xb,yb,round(Theme.color03(2)*255)-128,xs,ys);
      cdata(:,:,3) = cdata(:,:,3) + sparse(xb,yb,round(Theme.color03(3)*255)-128,xs,ys);
    end
  end

  cdata = uint8(cdata);

elseif is_jpg

  if Settings.hostver < 8.04
    cdata = imread([Path.images,filename,'.jpg'],'jpg');
  else
    cdata = flipud(fliplr(imread([Path.images,filename,'.jpg'],'jpg')));
  end
else

  fm_disp(['* FM_MAT Warning: "',filename,'" is not an image file.'])
  cdata = '';

end