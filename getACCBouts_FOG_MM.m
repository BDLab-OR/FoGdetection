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
iWalking= Lum_f>0.015;
Walks.iWalks            = [];
Walks.duration          = [];
Walks.IndexStart          = [];
Walks.IndexEnd          = [];

%% Changed by Vrutang

iWalk       = find(iWalking);
iNoWalk    = find(~iWalking);
iWalkEnd_bt    = iWalk  (find(diff(iWalk) > 1));        %%bt means before threshold       % indices of the end of each Walk
if isempty(iWalkEnd_bt)==1
    if ~isempty(iWalk)==1
        iWalkEnd_bt=iWalk(end);
    else
    end
end
iWalkStart_bt  = iNoWalk(find(diff(iNoWalk) > 1))+1;           % indices of the start of each Walk


%%%%%%%% Corrected bouts so that includes the last bout
if (~isempty(iWalkEnd_bt)==1 && (length(iWalkEnd_bt)>1 || length(iWalkStart_bt)>1)) || (~isempty(iWalkEnd_bt)==1 && length(iWalkEnd_bt)==1 && length(iWalkStart_bt)==1 && (iWalkEnd_bt(1) < iWalkStart_bt(1)))
    iWalkEnd_bt=[iWalkEnd_bt;iWalk(end)];
    
    if length(iWalkStart_bt)~=length(iWalkEnd_bt)
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
    % Keep only moving intervals >= 0.5 s
    %===========================================================
    iC     = 0;
    for c1 = 1:length(WalkDurations_bt)
        if WalkDurations_bt(c1) > minStepInterval                 % Minimum moving interval aproximalty one step length
            iC = iC+1;
            iWalkEnd(iC)      = iWalkEnd_bt(c1); %% mit stands for moving interval threshold
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
        %%%%%%%%%%%%%% Changed by Vrutang%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
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


