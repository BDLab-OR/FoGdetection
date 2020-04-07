function [Metrics] = getMetrics_MM(Data,Data_Rl, Data_Ll,Data_Rf,Data_Lf, iSamples,sampleRate,nHours,segmentL,fileName,Method)
dbstop if error

lpCF            = 3;                                        % Lowpass filter

% Applying Kernel filter to Lumbar Data
AccLp(:,1) = KernelFilter(Data(:,1),sampleRate,lpCF)/9.81; % Lumbar Vertical
AccLp(:,2) = KernelFilter(Data(:,2),sampleRate,lpCF)/9.81; % Lumbar Medio-Lateral
AccLp(:,3) = KernelFilter(Data(:,3),sampleRate,lpCF)/9.81; % Lumbar Anterior-Posterior

gyroLp(:,1) = KernelFilter(Data(:,4),sampleRate,lpCF);
gyroLp(:,2) = KernelFilter(Data(:,5),sampleRate,lpCF);
gyroLp(:,3) = KernelFilter(Data(:,6),sampleRate,lpCF);


%%% R and L leg NOT filtered if any
if ~isempty(Data_Rl)
    Rl_gyroLp(:,1) =Data_Rl(:,4);
    Rl_gyroLp(:,2) =Data_Rl(:,5);
    Rl_gyroLp(:,3) =Data_Rl(:,6);
    
    Ll_gyroLp(:,1) =Data_Ll(:,4);
    Ll_gyroLp(:,2) =Data_Ll(:,5);
    Ll_gyroLp(:,3) =Data_Ll(:,6);
    
    Rl_acc(:,1) =Data_Rl(:,1);
    Rl_acc(:,2) =Data_Rl(:,2);
    Rl_acc(:,3) =Data_Rl(:,3);
    
    Ll_acc(:,1) =Data_Ll(:,1);
    Ll_acc(:,2) =Data_Ll(:,2);
    Ll_acc(:,3) =Data_Ll(:,3);
    
else
    Rl_gyroLp=[];
    Ll_gyroLp=[];
    Rl_acc=[];
    Ll_acc=[];
end
%%% R and L feet NOT filtered
Rf_gyroLp(:,1) =Data_Rf(:,4);
Rf_gyroLp(:,2) =Data_Rf(:,5);
Rf_gyroLp(:,3) =Data_Rf(:,6);

Lf_gyroLp(:,1) =Data_Lf(:,4);
Lf_gyroLp(:,2) =Data_Lf(:,5);
Lf_gyroLp(:,3) =Data_Lf(:,6);

Rf_acc(:,1) =Data_Rf(:,1);
Rf_acc(:,2) =Data_Rf(:,2);
Rf_acc(:,3) =Data_Rf(:,3);

Lf_acc(:,1) =Data_Lf(:,1);
Lf_acc(:,2) =Data_Lf(:,2);
Lf_acc(:,3) =Data_Lf(:,3);



Metrics     = struct;

Turns.durations = [];
Turns.angles    = [];
Turns.meanVel   = [];
Turns.peakVel   = [];
Turns.jerk      = [];
Turns.MLJerk      = [];
Turns.MLRange      = [];
%===========================================================
% Analyze 30 min segment at a time
%===========================================================
for cSegment    = 1: nHours
    tic
    if cSegment  ==1
        iStart    = 1;
        iEnd      = segmentL;
    else
        iStart    = iStart+segmentL;
        iEnd      = iEnd + segmentL;
    end
    iSamples     = iStart:iEnd;
    % Checking if the length of the data is 30 min
    % (30min*60sec*128Hz=230400) or less and assigning to sensors
    % accordingly
    if length(gyroLp)<230400
        gLumbar      = gyroLp;
        aLumbar      = AccLp;
        gRleg        = Rl_gyroLp;
        gLleg        = Ll_gyroLp;
        aRleg        = Rl_acc;
        aLleg        = Ll_acc;
        gRfoot        = Rf_gyroLp;
        gLfoot        = Lf_gyroLp;
        aRfoot        = Rf_acc;
        aLfoot        = Lf_acc;
    else
        
        gLumbar      = gyroLp(iSamples,:);
        aLumbar      = AccLp(iSamples,:);
        if ~isempty(Rl_gyroLp)==1
            gRleg        = Rl_gyroLp(iSamples,:);
            gLleg        = Ll_gyroLp(iSamples,:);
            aRleg        = Rl_acc(iSamples,:);
            aLleg        = Ll_acc(iSamples,:);
        else
            gRleg=[];
            gLleg=[];
            aRleg=[];
            aLleg=[];
        end
        gRfoot        = Rf_gyroLp(iSamples,:);
        gLfoot        = Lf_gyroLp(iSamples,:);
        aRfoot        = Rf_acc(iSamples,:);
        aLfoot        = Lf_acc(iSamples,:);
        
    end
    %======================================================
    % Get Walking periods from 3D Lumbar Acceleration
    %======================================================
    close all
    Walks              = getACCBouts_FOG_MM (aLumbar,gLumbar,gRleg, gLleg,aRleg,aLleg,sampleRate,fileName)
    
    
    nWalks             = length(Walks.iWalks)
    
    %-------------------------------------------------------
    % No Turns or Steps if nWalks = 0
    %-------------------------------------------------------
    if nWalks ==0
        Walks.number    = 0;
        Walks.duration  = [];
        
        Turns.number    = 0;
        Turns.angles    = [];
        Turns.durations = [];
        Turns.meanVel   = [];
        Turns.peakVel   = [];
        Turns.jerk      = [];
        Turns.MLJerk    = [];
        Turns.MLRange   = [];
        IFOG_shank.FoGtime=[];
        IFOG_shank.Mcorr=[];
        IFOG_shank.SDcorr=[];
        IFOG_shank.Very_short_FOG=[];
        IFOG_shank.Short_FOG= [];
        IFOG_shank.Long_FOG=[];
        IFOG_shank.NN=[];
        IFOG_shank.MM=[];
        IFOG_feet.FoGtime=[];
        IFOG_feet.Mcorr=[];
        IFOG_feet.SDcorr=[];
        IFOG_feet.Very_short_FOG=[];
        IFOG_feet.Short_FOG= [];
        IFOG_feet.Long_FOG=[];
        IFOG_feet.NN=[];
        IFOG_feet.MM=[];
        
        Metrics(cSegment).Turns = Turns;
        Metrics(cSegment).Walks = Walks;
        Metrics(cSegment).IFOG1_shank = IFOG_shank;
        Metrics(cSegment).IFOG1_feet = IFOG_feet;
        
        continue
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% GAit bout info and time spent higher frequency
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Walks.number    = nWalks;
    Walks.boutduration  = Walks.duration/128;
    
    for cWalks=1:nWalks
        if ~isempty(aRleg)
            Rleg_acc       = aRleg(Walks.IndexStart(cWalks): Walks.IndexStart(cWalks)+Walks.duration(cWalks),3);
            Lleg_acc       = aLleg(Walks.IndexStart(cWalks): Walks.IndexStart(cWalks)+Walks.duration(cWalks),3);
            Rleg_gyr       = -gRleg(Walks.IndexStart(cWalks): Walks.IndexStart(cWalks)+Walks.duration(cWalks),2);
            Lleg_gyr       = -gLleg(Walks.IndexStart(cWalks): Walks.IndexStart(cWalks)+Walks.duration(cWalks),2);
            IFOG_shank=getFOGmarkers(Rleg_acc,Lleg_acc,Rleg_gyr,Lleg_gyr,sampleRate);
            IFOG1_shank.FoGtime(cWalks,1)=IFOG_shank.FoGtime;
            IFOG1_shank.NN(cWalks,1)=IFOG_shank.NN;
            IFOG1_shank.MM(cWalks,1)=IFOG_shank.MM;
            IFOG1_shank.Mcorr(cWalks,1)=IFOG_shank.Mcorr;
            IFOG1_shank.SDcorr(cWalks,1)=IFOG_shank.SDcorr;
            IFOG1_shank.Very_short_FOG(cWalks,1)=IFOG_shank.Very_short_FOG;
            IFOG1_shank.Short_FOG(cWalks,1)=IFOG_shank.Short_FOG;
            IFOG1_shank.Long_FOG(cWalks,1)=IFOG_shank.Long_FOG;
            IFOG1_shank.Very_Long_FOG(cWalks,1)=IFOG_shank.Very_Long_FOG;
            
        else
            
        end
        Rfoot_acc       = aRfoot(Walks.IndexStart(cWalks): Walks.IndexStart(cWalks)+Walks.duration(cWalks),1);
        Lfoot_acc       = aLfoot(Walks.IndexStart(cWalks): Walks.IndexStart(cWalks)+Walks.duration(cWalks),1);
        Rfoot_gyr       = -gRfoot(Walks.IndexStart(cWalks): Walks.IndexStart(cWalks)+Walks.duration(cWalks),2);
        Lfoot_gyr       = -gLfoot(Walks.IndexStart(cWalks): Walks.IndexStart(cWalks)+Walks.duration(cWalks),2);
        IFOG_feet=getFOGmarkers_feet(Rfoot_acc,Lfoot_acc,Rfoot_gyr,Lfoot_gyr,sampleRate);
        IFOG1_feet.FoGtime(cWalks,1)=IFOG_feet.FoGtime;
        IFOG1_feet.NN(cWalks,1)=IFOG_feet.NN;
        IFOG1_feet.MM(cWalks,1)=IFOG_feet.MM;
        IFOG1_feet.Mcorr(cWalks,1)=IFOG_feet.Mcorr;
        IFOG1_feet.SDcorr(cWalks,1)=IFOG_feet.SDcorr;
        IFOG1_feet.Very_short_FOG(cWalks,1)=IFOG_feet.Very_short_FOG;
        IFOG1_feet.Short_FOG(cWalks,1)=IFOG_feet.Short_FOG;
        IFOG1_feet.Long_FOG(cWalks,1)=IFOG_feet.Long_FOG;
        IFOG1_feet.Very_Long_FOG(cWalks,1)=IFOG_feet.Very_Long_FOG;
    end
    if exist('IFOG1_shank')==1
        IFOG1_shank.totalFOG=100*((sum(IFOG1_shank.NN,'omitnan')-sum(IFOG1_shank.Very_short_FOG,'omitnan'))/sum(IFOG1_shank.MM,'omitnan'));
    else
    end
    IFOG1_feet.totalFOG=100*((sum(IFOG1_feet.NN,'omitnan')-sum(IFOG1_feet.Very_short_FOG,'omitnan'))/sum(IFOG1_feet.MM,'omitnan'));
    
    
    %======================================================
    % Get Turns during bouts from Lumbar Rotation
    %======================================================
    
    for cWalks      = 1:nWalks
        gyroV       = gLumbar(Walks.iWalks(cWalks): Walks.iWalks(cWalks)+Walks.duration(cWalks),1);
        MLacc       = aLumbar(Walks.iWalks(cWalks): Walks.iWalks(cWalks)+Walks.duration(cWalks),2);
        APacc       = aLumbar(Walks.iWalks(cWalks): Walks.iWalks(cWalks)+Walks.duration(cWalks),3);
        Vacc        = aLumbar(Walks.iWalks(cWalks): Walks.iWalks(cWalks)+Walks.duration(cWalks),1);
        
        
        fileName
        WalkTurn    = getTurnMetrics_BB(gyroV,MLacc, APacc,sampleRate);
        length(WalkTurn.durations)
        
        if cWalks ==1
            Turn            = WalkTurn;
            Turn.number     = length(WalkTurn.durations);
        else
            Turn.number     =  Turn.number + length(WalkTurn.durations);
            Turn.durations  = [Turn.durations   ;WalkTurn.durations];
            Turn.angles     = [Turn.angles      ;WalkTurn.angles];
            Turn.meanVel    = [Turn.meanVel     ;WalkTurn.meanVel];
            Turn.peakVel    = [Turn.peakVel     ;WalkTurn.peakVel];
            Turn.jerk       = [Turn.jerk        ;WalkTurn.jerk];
            Turn.MLJerk     = [Turn.MLJerk        ;WalkTurn.MLJerk];
            Turn.MLRange    = [Turn.MLRange        ;WalkTurn.MLRange];
            
        end
        
    end
    
    
    Metrics(cSegment).Turns = Turn;
    Metrics(cSegment).Walks = Walks;
    if exist('IFOG1_shank')==1
        Metrics(cSegment).IFOG1_shank = IFOG1_shank;
    else
    end
    Metrics(cSegment).IFOG1_feet = IFOG1_feet;
    clear IFOG1_shank IFOG1_feet
end
