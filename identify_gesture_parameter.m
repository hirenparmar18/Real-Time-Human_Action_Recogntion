function [ampl, Nzc] = identify_gesture_parameter(Rp,ii,nf1)

% Take previous values
Vs = Rp(ii-nf1:ii);
Vs = Vs(1:end-1)-Vs(2:end);

% Find out zero crossing
i=1:length(Vs)-1;
Zcross=((Vs(i)>0 & Vs(i+1)<0) | (Vs(i)<0 & Vs(i+1)>0));

% Calculate amplitude
ampl = sum(abs(Vs));
% Calculate No of zero cross
Nzc = sum(Zcross);
