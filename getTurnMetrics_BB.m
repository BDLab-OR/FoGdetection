function [Turns] = getTurnMetrics_BB(gyroV,ML, AP,fs)


%5WalkTurn    = getTurnMetrics(gyroV,MLacc, APacc, Vacc,sampleRate,[fileName '' cWalks]);
%==========================================================
% User-Specified Parameters
%==========================================================
 minimumPeakVelocity = 25*pi/180; %deg in rad
 minimumTurnVelocity = 5*pi/180;
 
maxTurnDuration     = 7;                                    % max turn duration is 4 seconds
minTurnDuration     = .5;                                   % min turn duration is .5 seconds
yaw             = cumsum(gyroV)/fs*180/pi; % rad in d

lTurn           = abs(gyroV) > minimumPeakVelocity;         % Threshold angular velocity > 25 dps
iTurn           = find(lTurn);
Turns.iTurns    = [];
Turns.iTurnEnds = [];
Turns.durations = [];
Turns.angles    = [];
Turns.meanVel   = [];
Turns.peakVel   = [];
Turns.jerk      = [];   
Turns.MLJerk    = [];  
Turns.MLRange    = [];  
if isempty(iTurn)
    return
end
iTurnEnd    = [iTurn(find(diff(iTurn) > 1)); iTurn(end)];   %indices of the end of each turn
iTurnStart  = [iTurn(1); iTurn(find(diff(iTurn) > 1)+1)];

%==========================================================
% Get Turn Times
%==========================================================
for c1 = 1:length(iTurnEnd)
    iTmpMax = find(abs(gyroV(1:iTurnEnd(c1))) < minimumPeakVelocity, 1, 'last');
    iTmpMin = iTurnEnd(c1) + find(abs(gyroV(iTurnEnd(c1):end)) < minimumPeakVelocity, 1, 'first');
    if gyroV(iTurnEnd(c1)) > 0
        iTmp = find(gyroV(1:iTmpMax) < minimumTurnVelocity, 1, 'last');
        if isempty(iTmp)
            iTurnStart(c1) = 1;
        else
            iTurnStart(c1) = iTmp+1;
        end
        iTmp = find(gyroV(iTmpMin:end) < minimumTurnVelocity, 1, 'first');
        if isempty(iTmp)
            iTurnEnd(c1) = length(gyroV);
        else
            iTurnEnd(c1) = iTmpMin + iTmp - 1;
        end
    else
        iTmp = find(gyroV(1:iTmpMax) > -minimumTurnVelocity, 1, 'last') + 1;
        if isempty(iTmp)
            iTurnStart(c1) = 1;
        else
            iTurnStart(c1) = iTmp+1;
        end
        iTmp = find(gyroV(iTmpMin:end) > -minimumTurnVelocity, 1, 'first');
        if isempty(iTmp)
            iTurnEnd(c1) = length(gyroV);
        else
            iTurnEnd(c1) = iTmpMin + iTmp - 1;
        end
    end
end

iTurnEnd = unique(iTurnEnd);
iTurnStart = unique(iTurnStart);
if isempty(iTurnStart)
    return
end
a=length(iTurnStart);
b=length(iTurnEnd);
iTurnEnd=iTurnEnd(1:min(a,b));
iTurnStart=iTurnStart(1:min(a,b));
%==========================================================
% Merge turns with same direction and interval < 0.25 s
%==========================================================
turnDurations       = (iTurnEnd-iTurnStart)/fs;
intraturnDurations  = (iTurnStart(2:end)-iTurnEnd(1:end-1))/fs;
done = 0;
while ~done
    done = 1;
    for c1 = 1:length(intraturnDurations)
        if intraturnDurations(c1) <= 0 %same turn, remove
            turnDurations = turnDurations([1:c1-1 c1+1:end]);
            iTurnStart    = iTurnStart([1:c1 c1+2:end]);
            iTurnEnd      = iTurnEnd([1:c1-1 c1+1:end]);
            intraturnDurations = intraturnDurations([1:c1-1 c1+1:end]);
            done = 0;
            break;
        end
    end
end%!
done = 0;
while ~done
    done = 1;
    for c1 = 1:length(intraturnDurations)
        if intraturnDurations(c1) < 0.25  && (sign(yaw(iTurnEnd(c1))-yaw(iTurnStart(c1))) == sign(yaw(iTurnEnd(c1+1))-yaw(iTurnStart(c1+1)))) %same turn, merge
            turnDurations(c1) = turnDurations(c1) + turnDurations(c1+1);
            turnDurations = turnDurations([1:c1-1 c1+1:end]);
            iTurnStart = iTurnStart([1:c1 c1+2:end]);
            iTurnEnd = iTurnEnd([1:c1-1 c1+1:end]);
            intraturnDurations = intraturnDurations([1:c1-1 c1+1:end]);
            if turnDurations (c1) > maxTurnDuration
                done =0;
                break;
            end
            done = 0;
            break;
        end
    end
end

%==========================================================
%Get Turn metrics
%==========================================================
if isempty(turnDurations)
    return
end
turnAngles = zeros(length(turnDurations),1);
turnJerk   = zeros(length(turnDurations),1);
turnML_Jerk   = zeros(length(turnDurations),1);
turnMLrange   = zeros(length(turnDurations),1);

i1 = 0;
for c1  = 1:length(turnDurations)
    i1  = i1+1;
    ang = sum(gyroV(iTurnStart(c1):iTurnEnd(c1)))/fs*180/pi;
    if abs(ang) < 45 || turnDurations(c1) <minTurnDuration || turnDurations(c1) > maxTurnDuration
        i1 = i1 - 1;
    else
        iTurnStart(i1)    = iTurnStart(c1);
        iTurnEnd(i1)      = iTurnEnd(c1);
        turnDurations(i1) = turnDurations(c1);
        turnAngles(i1)    = ang;
        turnMLrange(i1)   = max(ML(iTurnStart(i1):iTurnEnd(i1)))-min(ML(iTurnStart(i1):iTurnEnd(i1)));
        MLjerk            = diff(ML(iTurnStart(i1):iTurnEnd(i1))).*fs;
        APjerk            = diff(AP(iTurnStart(i1):iTurnEnd(i1))).*fs;
        tJerk             = sqrt(sum(MLjerk.^2 + APjerk.^2));
        turnJerk(i1)      = round(tJerk*100)/100;
        turnML_Jerk(i1)    = 0.5*(trapz((MLjerk.^2)./fs));
    end
end
turnAngles      = turnAngles(1:i1);
iTurnStart      = iTurnStart(1:i1);
iTurnEnd        = iTurnEnd(1:i1);
turnDurations   = turnDurations(1:i1);
turnJerk        = turnJerk(1:i1);
turnML_Jerk         = turnML_Jerk(1:i1);
turnMLrange         = turnMLrange(1:i1);
% turnMLJerk        = turnMLJerk(1:i1);
% turnMLRange       = MLrange(1:i1);


pv = zeros(length(turnAngles),1);
mv = zeros(length(turnAngles),1);
for c1 = 1:length(turnAngles)
    pv(c1) = max(abs(gyroV(iTurnStart(c1):iTurnEnd(c1))));
    mv(c1) = abs(mean(gyroV(iTurnStart(c1):iTurnEnd(c1))));
end

Turns.iTurns    = iTurnStart;
Turns.iTurnEnds = iTurnEnd;
Turns.durations = turnDurations;
Turns.angles    = round(turnAngles);
Turns.meanVel   = mv*180/pi; %% added august 2016 Martina 
Turns.peakVel   = pv*180/pi; %% added august 2016 Martina 
Turns.jerk      = turnJerk ;
Turns.MLRange   = turnMLrange;
Turns.MLJerk    = turnML_Jerk;
