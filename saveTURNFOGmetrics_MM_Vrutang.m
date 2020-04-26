function [] = saveTURNFOGmetrics_MM
dbstop if error

%===========================================================
% User-Specified Parameters
%===========================================================
studyDirectory = 'C:\Users\shahvr\Documents\GitHub\FoGdetection';
folderList     = dir(studyDirectory);
isub           = [folderList(:).isdir];                     % Returns logical vector
nameFolds      = {folderList(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];             % Keep only folders with data
nSubjects      = size(nameFolds,1);                         % Number of subFolders


%% Loop over the number Of Subjects inside the fodler
for cSubjects =1:nSubjects
    subjectCode         = nameFolds{cSubjects};
    subjectDirectory    =[studyDirectory '/' subjectCode '/'] ;
    fileList            = dir([subjectDirectory '*.h5']);
    nFiles              = length(fileList);
    if nFiles ==0
        continue
    end
    nHours         = zeros(nFiles,1);
    %%% Loop over the number of files inside a subject folder
    for cFiles     = 1:nFiles
        % Displaying a filename being analysize
        display(cFiles)
        fileName    = [subjectDirectory fileList(cFiles).name]
        clear Opal OpalsL
        % Reading Opals Data
        try
            Opal        = getHDFdata(fileName);
        catch
            Opal        = readOpalData(fileName);
        end
        for ii=1:length(Opal.sensor)
            OpalsL{ii}=Opal.sensor(ii).monitorLabel;
        end
        OpalsL=OpalsL';
        
        % Finding Indices to match location of the sensors
        Lumb=strmatch(['Lumbar'],OpalsL);
        
        
        Rfoot=strmatch(['Right Foot'],OpalsL);
        Lfoot=strmatch(['Left Foot'],OpalsL);
        
        if isempty(Lfoot)
            Lfoot=strmatch(['L Foot'],OpalsL);
        end
        
        if isempty(Rfoot)
            Rfoot=strmatch(['R Foot'],OpalsL);
        end
        
        Lleg=strmatch(['Left Leg'],OpalsL);
        Rleg=strmatch(['Right Leg'],OpalsL);
        
        
        if isempty(Lleg)
            Lleg=strmatch(['Left Lower Leg'],OpalsL);
            if isempty(Lleg)
                Lleg=strmatch(['L Leg'],OpalsL);
                if isempty(Lleg)
                    Lleg=strmatch(['Left Ankle'],OpalsL);
                end
            end
        end
        
        if isempty(Rleg)
            Rleg=strmatch(['Right Lower Leg'],OpalsL);
            if isempty(Rleg)
                Rleg=strmatch(['R Leg'],OpalsL);
                if isempty(Rleg)
                    Rleg=strmatch(['Right Ankle'],OpalsL);
                end
            end
        end
        % Assigning Lumbar data
        Data=Opal.sensor(Lumb).acc.x';
        Data(:,2)=Opal.sensor(Lumb).acc.y';
        Data(:,3)=Opal.sensor(Lumb).acc.z';
        Data(:,4)=Opal.sensor(Lumb).gyro.x';
        Data(:,5)=Opal.sensor(Lumb).gyro.y';
        Data(:,6)=Opal.sensor(Lumb).gyro.z';
        
        % Assigning Left and Right Leg data if any
        if ~isempty(Rleg)
            Data_Rl=Opal.sensor(Rleg).acc.x';
            Data_Rl(:,2)=Opal.sensor(Rleg).acc.y';
            Data_Rl(:,3)=Opal.sensor(Rleg).acc.z';
            Data_Rl(:,4)=Opal.sensor(Rleg).gyro.x';
            Data_Rl(:,5)=Opal.sensor(Rleg).gyro.y';
            Data_Rl(:,6)=Opal.sensor(Rleg).gyro.z';
            
            Data_Ll=Opal.sensor(Lleg).acc.x';
            Data_Ll(:,2)=Opal.sensor(Lleg).acc.y';
            Data_Ll(:,3)=Opal.sensor(Lleg).acc.z';
            Data_Ll(:,4)=Opal.sensor(Lleg).gyro.x';
            Data_Ll(:,5)=Opal.sensor(Lleg).gyro.y';
            Data_Ll(:,6)=Opal.sensor(Lleg).gyro.z';
            
        else
            Data_Rl=[];
            Data_Ll=[];
        end
        
        % Assigning Left and Right Feet data
        Data_Rf=Opal.sensor(Rfoot).acc.x';
        Data_Rf(:,2)=Opal.sensor(Rfoot).acc.y';
        Data_Rf(:,3)=Opal.sensor(Rfoot).acc.z';
        Data_Rf(:,4)=Opal.sensor(Rfoot).gyro.x';
        Data_Rf(:,5)=Opal.sensor(Rfoot).gyro.y';
        Data_Rf(:,6)=Opal.sensor(Rfoot).gyro.z';
        
        Data_Lf=Opal.sensor(Lfoot).acc.x';
        Data_Lf(:,2)=Opal.sensor(Lfoot).acc.y';
        Data_Lf(:,3)=Opal.sensor(Lfoot).acc.z';
        Data_Lf(:,4)=Opal.sensor(Lfoot).gyro.x';
        Data_Lf(:,5)=Opal.sensor(Lfoot).gyro.y';
        Data_Lf(:,6)=Opal.sensor(Lfoot).gyro.z';
        
        
        
        % Deviding total data into bacth of 30 mins 
        sampleRate= 128;
        nSamples= length(Data(:,1));                             
        segmentL= sampleRate*1800;                           
        nSamples= nSamples - rem(nSamples,segmentL);         
        
        iSamples    = 1 : nSamples;
        nHours = nSamples/(segmentL);
        
        if nHours==0
            iSamples    = 1 ;
            nHours =1;
        else
        end
        %------------------------------------------------
        % Get Metrics for each 30 min data
        %------------------------------------------------
        
        Metrics    = getMetrics_MM(Data,Data_Rl, Data_Ll, Data_Rf,Data_Lf,iSamples, sampleRate,nHours,segmentL,fileName);
        
        % Saving all metrics for each 30 min data in a signle file within a
        % subject folder
        for cHours = 1:size(Metrics,2)
            s(cFiles,cHours).Turns        = Metrics(cHours).Turns;
            s(cFiles,cHours).Walks        = Metrics(cHours).Walks;
            if isfield('Metrics.IFOG1_shank',Metrics)==1 && ~isempty(Metrics(cHours).IFOG1_shank)==1
                s(cFiles,cHours).IFOG1_shank         = Metrics(cHours).IFOG1_shank;
            else
                s(cFiles,cHours).IFOG1_shank =[];
            end
            s(cFiles,cHours).IFOG1_feet         = Metrics(cHours).IFOG1_feet;
            
        end
        clear nHours segmentL
    end
    % Saving all metrics in "s" strucutre format
    saveDirectory = [pwd '/'] ;
    saveName = [saveDirectory subjectCode '.mat'];
    save(saveName,'s');
    clear s
end
