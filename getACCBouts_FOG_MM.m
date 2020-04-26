function [Walks] = getACCBouts_FOG_MM (aLumbar,gLumbar,gRleg, gLleg,aRleg,aLleg,sampleRate,fileName)

%% aLumbar is the 3D lumbar acceleration

%%%% Specified treshold
upright=find(aLumbar(:,1)<0.6);                   %%% gravity on vertical axis to get the standing period negative now on Oapl data
iBuffer                 = sampleRate;                       % 1 second buffer before and after walk periods
minStepInterval         = (sampleRate)/2;    % was 0.5 sec                 % Minimum moving interval aproximalty one step length
maxIntraWalk            = sampleRate * 20;  % was 30  initially                 % Maximum intervals between Walks used to merge consecutive walks
minBoutInterval         = sampleRate * 10;    % was 10  initially            % Minimum Bout duration 10seconds

%%% ACC treshold walking based on the sqrt
gLumbarUP=gLumbar(upright,:);

ACCc=sum(aLumbar(upright,:).^2,2).^(1/2);
nACCc=ACCc-mean(ACCc);
nACCc=abs(nACCc);
[A,B]=butter(4,1/(sampleRate/2));
%%%%%%%%% Because of error running filtfilt which reuqire the sameple
%%%%%%%%% greater than 12.
if length(nACCc)<=12 %%%%%%%%%%%%
    nACCc=double.empty(0,1);
end
%%%%%%%%%%%%
Lum_f=filtfilt(A,B,nACCc);
%% Walking indices based on threshold
iWalking= Lum_f>0.015;
Walks.iWalks            = [];
Walks.duration          = [];
Walks.IndexStart          = [];
Walks.IndexEnd          = [];

%% finding Walking and Non-walking indices

iWalk       = find(iWalking);
iNoWalk    = find(~iWalking);
% Finding the indices of the end of the walking boouts
iWalkEnd_bt    = iWalk  (find(diff(iWalk) > 1)); 

% If there is no walking bout end (i.e. only one bout detected) then
% assign the end of that one Wlaking bout as end of the walking bout 
if isempty(iWalkEnd_bt)==1
    if ~isempty(iWalk)==1
        iWalkEnd_bt=iWalk(end);
    else
    end
end
% Finding the indices of the start of the walking boouts
iWalkStart_bt  = iNoWalk(find(diff(iNoWalk) > 1))+1;           

%% Added on 4 July 2020
if (~isempty(iWalkEnd_bt)==1) && (~isempty(iWalkStart_bt)==1) && (iWalkStart_bt(end)~=(iNoWalk(end)-1)) && ((iNoWalk(end)+1)<length(Lum_f))
    iWalkStart_bt=[iWalkStart_bt;iNoWalk(end)+1];
else
end
%%
%%%%%%%% % In Case of Mutliple Start and End bouts

% 1. When End bout is nonempty and (the leanght of either the end bout and
% the start bout>1) OR When End bout is nonempty and (the leanght of the end bout and
% the start bout=1 but end out indice is smaller than start bout indice)
if (~isempty(iWalkEnd_bt)==1 && (length(iWalkEnd_bt)>1 || length(iWalkStart_bt)>1)) || (~isempty(iWalkEnd_bt)==1 && length(iWalkEnd_bt)==1 && length(iWalkStart_bt)==1 && (iWalkEnd_bt(1) < iWalkStart_bt(1)))
    %When total length of the End bout < Start Bout
    iWalkEnd_bt=[iWalkEnd_bt;iWalk(end)];
    %If the total length of the End bout is still mismatch with the length of the Start Bout
    if length(iWalkStart_bt)~=length(iWalkEnd_bt)
        % Check if End bout < Start bout
        if iWalkEnd_bt(1) < iWalkStart_bt(1)
            iWalkStart_bt=[1;iWalkStart_bt];
        else 
            iWalkEnd_bt=iWalkEnd_bt(1:end-1);
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if length(iWalkStart_bt)~=length(iWalkEnd_bt)
        iWalkEnd_bt(end)=[];
        WalkDurations_bt  = (iWalkEnd_bt-iWalkStart_bt);
    else
        WalkDurations_bt  = (iWalkEnd_bt-iWalkStart_bt);
    end
    %===========================================================
    % Keep only Walking intervals >= 0.5 s
    %===========================================================
    iC     = 0;
    for c1 = 1:length(WalkDurations_bt)
        if WalkDurations_bt(c1) > minStepInterval                 % Minimum moving interval aproximalty one step length
            iC = iC+1;
            iWalkEnd(iC)      = iWalkEnd_bt(c1); 
            iWalkStart(iC)    = iWalkStart_bt(c1);
        else
            
        end
    end
    if max(WalkDurations_bt)<= minStepInterval
        iWalkEnd =[]; %% If walkduration is smaller than minStepinterval
        iWalkstart =[];
        intraWalkDurations=[];
        WalkDurations=[];
    else
        intraWalkDurations  = (iWalkStart(2:end)-iWalkEnd(1:end-1));
        WalkDurations  = (iWalkEnd-iWalkStart);
        
        
        %===========================================================
        % Merge consecutive walks with stationary gap periods < 20 s
        %===========================================================
        iC          = 0;
        Flag        = 0;
        
        boutCount   = length(WalkDurations)-1;
        indx=find(intraWalkDurations>maxIntraWalk);
        if ~isempty(indx)==1
            for iii=1:length(indx)+1
                if iii==1
                    iWalkStart_new(1)=iWalkStart(1);
                    iWalkEnd_new(1)=iWalkEnd(indx(iii));
                else
                    iWalkStart_new(iii)=iWalkStart(indx(iii-1)+1);
                    if length(indx)>=iii
                        iWalkEnd_new(iii)=iWalkEnd(indx(iii));
                    else
                        iWalkEnd_new(iii)=iWalkEnd(end);
                    end
                end
            end
        else
            iWalkStart_new(1)=iWalkStart(1);
            iWalkEnd_new(1)=iWalkEnd(end);
        end
        WalkDurations=iWalkEnd_new- iWalkStart_new;
        
        %===========================================================
        %Keep only Walks with interval > 20 s
        %===========================================================
        iWalkEnd_new_2    = [];
        iWalkStart_new_2    = [];
        iC       = 0;
        nWalks   = length(WalkDurations);
        for c1 = 1:nWalks
            if WalkDurations(c1) > minBoutInterval
                iC = iC+1;
                iWalkEnd_new_2(iC)      = iWalkEnd_new(c1);
                iWalkStart_new_2(iC)    = iWalkStart_new(c1);
            end
        end
        Walks.iWalks               = max(1,iWalkStart_new_2);
        Walks.duration             = iWalkEnd_new_2- iWalkStart_new_2;
        Walks.IndexStart           =iWalkStart_new_2;
        Walks.IndexEnd           =iWalkEnd_new_2;
    end
    
    % No Start Bout and End bout has 1 indix
elseif ~isempty(iWalkEnd_bt)==1 && length(iWalkEnd_bt)==1 && isempty(iWalkStart_bt)==1
    Walks.iWalks            = 1;
    iWalkStart_bt=1;
    Walks.duration          = iWalkEnd_bt-iWalkStart_bt;
    Walks.IndexStart          = iWalkStart_bt;
    Walks.IndexEnd          = iWalkEnd_bt;
    if Walks.duration < minBoutInterval
        Walks.iWalks   =[];
        Walks.duration          = [];
        Walks.IndexStart          = [];
        Walks.IndexEnd          = [];
    else
    end
    % No End Bout and Start bout has 1 indix
elseif ~isempty(iWalkStart_bt)==1 && length(iWalkStart_bt)==1 && isempty(iWalkEnd_bt)==1
    Walks.iWalks            = max(1,iWalkStart_bt);
    iWalkEnd_bt=iWalk(end);
    Walks.duration          = iWalkEnd_bt-iWalkStart_bt;
    Walks.IndexStart          = iWalkStart_bt;
    Walks.IndexEnd          = iWalkEnd_bt;
    if Walks.duration < minBoutInterval
        Walks.iWalks   =[];
        Walks.duration          = [];
        Walks.IndexStart          = [];
        Walks.IndexEnd          = [];
    else
    end
    % Only 1 end bout index and is > stat bout index
elseif ~isempty(iWalkEnd_bt)==1 && length(iWalkEnd_bt)==1 && (iWalkEnd_bt > iWalkStart_bt)
    Walks.iWalks            = max(1,iWalkStart_bt);
    Walks.duration          = iWalkEnd_bt-iWalkStart_bt;
    Walks.IndexStart          = iWalkStart_bt;
    Walks.IndexEnd          = iWalkEnd_bt;
    if Walks.duration < minBoutInterval
        Walks.iWalks   =[];
        Walks.duration          = [];
        Walks.IndexStart          = [];
        Walks.IndexEnd          = [];
    else
    end
else
    
end


