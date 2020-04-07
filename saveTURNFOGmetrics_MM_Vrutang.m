  function [] = saveTURNFOGmetrics_MM
dbstop if error

%===========================================================
% User-Specified Parameters
%===========================================================
studyDirectory = 'C:\Users\shahvr\Documents\GitHub\Freezing-Proxy\';
folderList     = dir(studyDirectory);
isub           = [folderList(:).isdir];                     % Returns logical vector
nameFolds      = {folderList(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];             % Keep only folders with data
nSubjects      = size(nameFolds,1);                         % Number of subFolders



for cSubjects =1:nSubjects %9,11,13
   subjectCode         = nameFolds{cSubjects};
   subjectDirectory    =[studyDirectory '/' subjectCode '/'] ;
   fileList            = dir([subjectDirectory '*.h5']);
   nFiles              = length(fileList);
   if nFiles ==0
      continue
   end
   %===========================================================
   % Main Loop
   %===========================================================
   nHours         = zeros(nFiles,1);
   for cFiles     = 1:nFiles  %11 for VG_303; 25, 26 for VG_310; 23 for VG_309
       %setdiff(1:nFiles, 85)%for vibro data old agorithm 
       %setdiff(1:nFiles,[40 42 44 46 57 103 130 131 132 134 137 140 143 146 148 149 160 166 175 176 177 178 179 180 200 201 202])%203:nFiles % 130 131 132 134 137 error2 160(eror3) 166(error4)  200(error3) % for HOME
       %cFiles     = setdiff(1:nFiles, 85)%for vibro data old agorithm 
       
       %for only PD02 folder use setdiff(1:nFiles,[8 13 14 15 16])
       display(cFiles)
      fileName    = [subjectDirectory fileList(cFiles).name]
      clear Opal OpalsL
      Opal        = getHDFdata(fileName); %% V1 hardware Data from 001to 006
      
       %OpalsL={Opal.sensor(1).monitorLabel; Opal.sensor(2).monitorLabel; Opal.sensor(3).monitorLabel;Opal.sensor(4).monitorLabel};
%         OpalsL={Opal.sensor(1).monitorLabel; Opal.sensor(2).monitorLabel; Opal.sensor(3).monitorLabel};

for ii=1:length(Opal.sensor)
    OpalsL{ii}=Opal.sensor(ii).monitorLabel;
end
OpalsL=OpalsL';
%OpalsL={Opal.sensor(1).monitorLabel; Opal.sensor(2).monitorLabel; Opal.sensor(3).monitorLabel;Opal.sensor(4).monitorLabel;Opal.sensor(5).monitorLabel;Opal.sensor(6).monitorLabel;Opal.sensor(7).monitorLabel;Opal.sensor(8).monitorLabel}; 
        Lumb=strmatch(['Lumbar'],OpalsL); 
%         Rleg=strmatch(['Right Foot'],OpalsL);
%         Lleg=strmatch(['Left Foot'],OpalsL);
%      


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

%      

   

      Data=Opal.sensor(Lumb).acc.x';
      Data(:,2)=Opal.sensor(Lumb).acc.y';
      Data(:,3)=Opal.sensor(Lumb).acc.z';
      Data(:,4)=Opal.sensor(Lumb).gyro.x';
      Data(:,5)=Opal.sensor(Lumb).gyro.y';
      Data(:,6)=Opal.sensor(Lumb).gyro.z';
      
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
      

    
      
      sampleRate= 128;
      nSamples= length(Data(:,1));                             % whatever length is in the loaded file
      segmentL= sampleRate*1800;                           % 30 min segment per plot 3600s in a hour, 1800 in 30 min 
      nSamples= nSamples - rem(nSamples,segmentL);         % multiple hours

      iSamples    = 1 : nSamples;
      nHours = nSamples/(segmentL);

      if nHours==0
          iSamples    = 1 ;
          nHours =1;
      else
      end
      %------------------------------------------------
      % Get Metrics for each hour and save 
      %------------------------------------------------
%       Data=Data.a;
      Metrics    = getMetrics_MM(Data,Data_Rl, Data_Ll, Data_Rf,Data_Lf,iSamples, sampleRate,nHours,segmentL,fileName);
   
      
      for cHours = 1:size(Metrics,2)
%          s(cFiles,cHours).iHour        = nHours;
         s(cFiles,cHours).Turns        = Metrics(cHours).Turns;
         s(cFiles,cHours).Walks        = Metrics(cHours).Walks;
         if isfield('Metrics.IFOG1_shank',Metrics)==1 && ~isempty(Metrics(cHours).IFOG1_shank)==1
         s(cFiles,cHours).IFOG1_shank         = Metrics(cHours).IFOG1_shank;
         else
             s(cFiles,cHours).IFOG1_shank =[];
         end
         s(cFiles,cHours).IFOG1_feet         = Metrics(cHours).IFOG1_feet;
%          s(cFiles,cHours).Steps        = Metrics(cHours).Steps;
%          s(cFiles,cHours).Bouts        = Metrics(cHours).Bouts;

%          s(cFiles,cHours).Time         = datestr(Data.Devices(1).dateNumbers(iHour));
      end
        clear nHours segmentL
   end
   %saveDirectory='E:\Vrutang OHSU Research\FOG daily life\FOG daily life\Matlab_V3_22August_2019\';
   saveDirectory = [pwd '/'] ;
   saveName = [saveDirectory subjectCode '.mat'];
   save(saveName,'s');
   clear s 
end