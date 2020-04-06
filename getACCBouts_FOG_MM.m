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
% gRlegUP=gRleg(upright,:);
% gLlegUP=gLleg(upright,:);
% aRlegUP=aRleg(upright,:);
% aLlegUP=aLleg(upright,:);
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

% %===========================================================
% % Get Moving Indices
% %===========================================================
% iWalk       = find(iWalking);
% iNoWalk     = find(~iWalking);
% iWalkEnd    = iWalk  (find(diff(iWalk) > 1));               % indices of the end of each Walk
% iWalkStart  = iNoWalk(find(diff(iNoWalk) > 1))+1;           % indices of the start of each Walk
% 
% if isempty(iWalk) || isempty(iWalkEnd)
%     return
% end
% if isempty(iWalkStart)
%     iWalkStart = iWalk(1);
% end
% 
% if (iWalkEnd(1) < iWalkStart(1))
%     iWalkEnd = iWalkEnd(2:end);
% end
% if (iWalkStart(end) > iWalkEnd(end))
%     iWalkStart = iWalkStart(1:end-1);
% end
% WalkDurations  = (iWalkEnd-iWalkStart);
% 
% %===========================================================
% % Keep only moving intervals >= .5 s
% %===========================================================
% iC     = 0;
% for c1 = 1:length(WalkDurations)
%     if WalkDurations(c1) > minStepInterval                 % Minimum moving interval aproximalty one step length
%         iC = iC+1;
%         iWalkEnd(iC)      = iWalkEnd(c1);
%         iWalkStart(iC)    = iWalkStart(c1);
%     end
% end
% iWalkStart          = iWalkStart(1:iC);
% iWalkEnd            = iWalkEnd(1:iC);
% intraWalkDurations  = (iWalkStart(2:end)-iWalkEnd(1:end-1));
%===========================================================
% Get Moving Indices
%===========================================================
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


% end

%%% Added by Vrutang on 25 Nov 2019%%%%%%%%%%%%%%%%
%%%%%%%%%%% With following it was somehow removing last bout
% if isempty(iWalk) || isempty(iWalkEnd_bt)
%     return
% end
% if isempty(iWalkStart_bt)
%     iWalkStart_bt = iWalk(1);
% end
% 
% if (iWalkEnd_bt(1) < iWalkStart_bt(1))
%     iWalkEnd_bt = iWalkEnd_bt(2:end);
% end
% if (iWalkStart_bt(end) > iWalkEnd_bt(end))
%     iWalkStart_bt = iWalkStart_bt(1:end-1);
% end

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
        
        % iWalkStart          = iWalkStart(1:iC);
        % iWalkEnd            = iWalkEnd(1:iC);
        
        
        
        %clear c1
        %%
        %===========================================================
        % Merge consecutive walks with stationary gap periods < 20 s
        %===========================================================
        iC          = 0;
        Flag        = 0;
        %%%%%%%%%%%%%% Changed by Vrutang%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % boutCount   = length(intraWalkDurations);
        % if boutCount == 0
        %     return
        % end
        % for c1 = 1:boutCount
        %     iC = iC+1;
        %     if intraWalkDurations(c1) < maxIntraWalk
        %         iWalkEnd(iC)      = iWalkEnd(c1+1);
        %         if Flag == 1
        %             iWalkStart(iC)    = iWalkStart(c1+1);
        %         end
        %         Flag = 0;
        %         iC = iC-1;
        %     else
        %         if Flag == 0
        %             iC = iC+1;
        %         end
        %         iWalkStart(iC)    = iWalkStart(c1+1);
        %         iWalkEnd(iC)      = iWalkEnd(c1+1);
        %         Flag = 1;
        %     end
        % end
        
        
        % boutCount   = length(WalkDurations)-1;
        % if boutCount >0
        %     for c1 = 1:boutCount
        %         iC = iC+1;
        %         if intraWalkDurations(c1) < maxIntraWalk
        %             iWalkEnd(iC)      = iWalkEnd(c1+1);
        %             if Flag == 1
        %                 iWalkStart(iC)    = iWalkStart(c1+1);
        %             end
        %             Flag = 0;
        %             iC = iC-1;
        %         else
        %             if Flag == 0
        %                 iC = iC+1;
        %             end
        %             iWalkStart(iC)    = iWalkStart(c1+1);
        %             iWalkEnd(iC)      = iWalkEnd(c1+1);
        %             Flag = 1;
        %         end
        %     end
        % else
        % end
        % if Flag ==0
        %     iWalkStart          = iWalkStart(1:iC+1);
        %     iWalkEnd            = iWalkEnd(1:iC+1);
        % else
        %     iWalkStart          = iWalkStart(1:iC);
        %     iWalkEnd            = iWalkEnd(1:iC);
        % end
        % WalkDurations       = (iWalkEnd-iWalkStart);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        % if boutCount >0 || isempty(find(intraWalkDurations_mit< maxIntraWalk))==0
        %     for c1 = 1:boutCount
        %         if intraWalkDurations_mit(c1) < maxIntraWalk
        %             iWalkStart(c1)=iWalkStart_mit(c1);
        %             iWalkEnd(c1)=iWalkEnd_mit(c1+1);
        %         end
        %     end
        % else
        %     iWalkStart=iWalkStart_mit;
        %     iWalkEnd = iWalkEnd_mit;
        %     WalkDurations=WalkDurations_mit;
        %     intraWalkDurations=intraWalkDurations_mit;
        % end
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
% for i=1:length(Walks.iWalks)
% figure(1)
% subplot(3,1,1)
% hold on
% plot([Walks.iWalks(i) Walks.iWalks(i)],[-2 1],'-k')
% plot([Walks.iWalks(i)+Walks.duration(i) Walks.iWalks(i)+Walks.duration(i)],[-2 1],':k')
% end
% figure(1)
% subplot(3,1,1)
% hold on
% plot(nACCc)
% plot(Lum_f,'m')
% plot(-0.5-gRlegUP(:,2)/100,'b')
% plot(-0.5-gLlegUP(:,2)/100,'r')
% plot(-0.5-(gLumbarUP(:,1)-mean(gLumbarUP(:,1)))/1000,'g')
% text(100,nanmean(nACCc),['Bouts #',num2str(length(Walks.iWalks)) ],'Backgroundcolor','c')
% title(fileName)

% HERE TO WORK WITH 
% figure(1)
% hold on
% subplot(3,1,2)
% [Stms,Ftms,Ttms,Ptms]=spectrogram(aRlegUP(:,1),128,(128)-1,128,128);
% % nPtms=Ptms/sum(sum(Ptms));
% %   maxPtmsap(1)=max(max(Ptms));
% imagesc(Ttms,Ftms(Ftms <= 10 & Ftms > 0 ),Ptms(Ftms <= 10 & Ftms > 0,:))
% axis xy
% %   caxis([0 max(maxPtmsap)])
% %      caxis([0 20])
% % set(gca,'fontsize',15)
% figtspan = get(gca,'xlim');
% colorbar
% title('R foot')
% hold on
% xlabel('time')
% ylabel('Frequency')
% 
% subplot(3,1,3)
% hold on
% [Stms,Ftms,Ttms,Ptms]=spectrogram(aLlegUP(:,1),128,(128)-1,128,128);
% % nPtms=Ptms/sum(sum(Ptms));
% %   maxPtmsap(1)=max(max(Ptms));
% imagesc(Ttms,Ftms(Ftms <= 10 & Ftms > 0 ),Ptms(Ftms <= 10 & Ftms > 0,:))
% axis xy
% %   caxis([0 max(maxPtmsap)])
% %      caxis([0 20])
% % set(gca,'fontsize',15)
% figtspan = get(gca,'xlim');
% colorbar
% title('L foot')
% 
% hold on
% xlabel('time')
% ylabel('Frequency')
% pause

