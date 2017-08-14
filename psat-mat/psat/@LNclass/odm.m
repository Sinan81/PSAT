function odm(a,fid,tag,space)

if ~a.n, return, end

for idx = 1:a.n
  
  if a.con(idx,12)
    type = 'phaseShiftXfrData';
    code = 'PhaseShiftXformer';
  elseif a.con(idx,7)
    type = 'xformerData';
    code = 'Transformer';
  else
    type = 'lineData';
    code = 'Line';
  end

  count = fprintf(fid,'%s<%s:branch>\n',space,tag);
  count = fprintf(fid,'  %s<%s:id>%d</%s:id>\n',space,tag,idx,tag);
  count = fprintf(fid,'  %s<%s:fromBus>\n',space,tag);
  count = fprintf(fid,'    %s<%s:idRef>%d</%s:idRef>\n',space,tag,round(a.con(idx,1)),tag);
  count = fprintf(fid,'  %s</%s:fromBus>\n',space,tag);
  count = fprintf(fid,'  %s<%s:toBus>\n',space,tag);
  count = fprintf(fid,'    %s<%s:idRef>%d</%s:idRef>\n',space,tag,round(a.con(idx,2)),tag);
  count = fprintf(fid,'  %s</%s:toBus>\n',space,tag);
  count = fprintf(fid,'  %s<%s:circuitId>1</%s:circuitId>\n',space,tag,tag);
  count = fprintf(fid,'  %s<%s:loadflowBranchData>\n',space,tag);
  count = fprintf(fid,'    %s<%s:code>%s</%s:code>\n',space,tag,code,tag);
  count = fprintf(fid,'    %s<%s:z>\n',space,tag);
  count = fprintf(fid,'      %s<%s:r>%8.5f</%s:r>\n',space,tag,a.con(idx,8),tag);
  count = fprintf(fid,'      %s<%s:x>%8.5f</%s:x>\n',space,tag,a.con(idx,9),tag);
  count = fprintf(fid,'      %s<%s:unit>PU</%s:unit>\n',space,tag,tag);
  count = fprintf(fid,'    %s</%s:z>\n',space,tag);
  count = fprintf(fid,'    %s<%s:totalShuntY>\n',space,tag);
  count = fprintf(fid,'      %s<%s:b>%8.5f</%s:b>\n',space,tag,a.con(idx,10),tag);
  count = fprintf(fid,'      %s<%s:unit>PU</%s:unit>\n',space,tag,tag);
  count = fprintf(fid,'    %s</%s:totalShuntY>\n',space,tag);

  % Rating
  count = fprintf(fid,'    %s<%s:ratingData>\n',space,tag);
  count = fprintf(fid,'      %s<%s:ratedPower>\n',space,tag);
  count = fprintf(fid,'        %s<%s:p>%8.2f</%s:p>\n',space,tag,a.con(idx,3),tag);
  count = fprintf(fid,'        %s<%s:unit>MVA</%s:unit>\n',space,tag,tag);
  count = fprintf(fid,'      %s</%s:ratedPower>\n',space,tag);
  if a.con(idx,7)
    count = fprintf(fid,'      %s<%s:fromRatedVoltage>\n',space,tag);
    count = fprintf(fid,'        %s<%s:voltage>%8.2f</%s:voltage>\n',space,tag,a.con(idx,4),tag);
    count = fprintf(fid,'        %s<%s:unit>KV</%s:unit>\n',space,tag,tag);
    count = fprintf(fid,'      %s</%s:fromRatedVoltage>\n',space,tag);
    count = fprintf(fid,'      %s<%s:toRatedVoltage>\n',space,tag);
    count = fprintf(fid,'        %s<%s:voltage>%8.2f</%s:voltage>\n',space,tag,a.con(idx,4)/a.con(idx,7),tag);
    count = fprintf(fid,'        %s<%s:unit>KV</%s:unit>\n',space,tag,tag);
    count = fprintf(fid,'      %s</%s:toRatedVoltage>\n',space,tag);
  else
    count = fprintf(fid,'      %s<%s:RatedVoltage>\n',space,tag);
    count = fprintf(fid,'        %s<%s:voltage>%8.2f</%s:voltage>\n',space,tag,a.con(idx,4),tag);
    count = fprintf(fid,'        %s<%s:unit>KV</%s:unit>\n',space,tag,tag);
    count = fprintf(fid,'      %s</%s:RatedVoltage>\n',space,tag);
  end
  count = fprintf(fid,'    %s</%s:ratingData>\n',space,tag);
  
  % Tap Ratio
  if a.con(idx,11)
    count = fprintf(fid,'    %s<%s:fromTurnRatio>%8.5f</%s:fromTurnRatio>\n',space,tag,a.con(idx,11),tag);
  end

  % Phase Shifter
  if a.con(idx,12)
    count = fprintf(fid,'    %s<%s:toAngle>\n',space,tag);
    count = fprintf(fid,'      %s<%s:angle>%8.5f</%s:angle>\n',space,tag,180*a.con(idx,12)/pi,tag);
    count = fprintf(fid,'      %s<%s:unit>DEG</%s:unit>\n',space,tag,tag);
    count = fprintf(fid,'    %s</%s:toAngle>\n',space,tag);
  end
  
  % Rating Limits
  if a.con(idx,13)
    count = fprintf(fid,'    %s<%s:ratingLimit>\n',space,tag);
    count = fprintf(fid,'      %s<%s:currentRating>%8.5f</%s:currentRating>\n',space,tag,a.con(idx,13),tag);
    count = fprintf(fid,'      %s<%s:currentRatingUnit>PU</%s:currentRatingUnit>\n',space,tag,tag);
    count = fprintf(fid,'    %s</%s:ratingLimit>\n',space,tag);
  end
  
  count = fprintf(fid,'  %s</%s:loadflowBranchData>\n',space,tag);
  count = fprintf(fid,'%s</%s:branch>\n',space,tag);
end
