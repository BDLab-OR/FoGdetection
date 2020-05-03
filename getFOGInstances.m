function IFOG_limbs=getFOGInstances(R_acc_ap,L_acc_ap,R_gyr_ml,L_gyr_ml,sampleRate, fileName)

%% resample from 128 to 200
R_ml=resample(R_gyr_ml,200,sampleRate);
L_ml=resample(L_gyr_ml,200,sampleRate);


limbs(:,1)=R_ml;
limbs(:,2)=L_ml;

%% Low pass filter
[A,B]=butter(4,5/(200/2));
limbs_f=filtfilt(A,B,limbs);

se=length(R_ml);

%% Correlation Based Method 
%R and L angular velocities cross-correlation to find a delay between two
cross_1=xcov(limbs(1:se,1),limbs(1:se,2));
crosscov=cross_1;
for k=1:length(crosscov);
    if crosscov(k)==max(crosscov);
        shiftSIGN=k;
    end
end

startsync=shiftSIGN-((length(crosscov)/2));


% Synchronizing both R and L together after correction for the delay
t_limbs1=limbs_f(round(abs(startsync)):se,1);
t_limbs2=limbs_f(1:se-(round(abs(startsync))-1),2);

j=1:200:length(t_limbs1);
if length(t_limbs1)>200*5
    %Bouts need to have enough data
    for z=1:length(j)-2
        a=corrcoef(t_limbs1(j(z):j(z+1)),t_limbs2(j(z):j(z+1)));
        limbs_corr(z)=a(1,2);
    end
    
    ab_limbs_corr=abs(limbs_corr);
    % Threshold on abs correlation value
    ab_limbs_corr_log=ab_limbs_corr < 0.50;
    
    IFOG_limbs.Mcorr=mean(ab_limbs_corr);
    IFOG_limbs.SDcorr=std(ab_limbs_corr);
    
    
else
    errorMessage = sprintf('Error: There is not enough data to calculate FOG. Please ensure each bout is longer than 10 seconds or sample more often');
    uiwait(warndlg(errorMessage));
    IFOG_limbs.Mcorr=NaN;
    IFOG_limbs.SDcorr=NaN;
end
%% FFT Based Method


fc2=200;
xx=resample(R_acc_ap,fc2,sampleRate);
yy=resample(L_acc_ap,fc2,sampleRate);
x=xx(round(abs(startsync)):se,1);
y=yy(1:se-(round(abs(startsync))-1),1);
if length(x)>fc2*5%% Ideally there is no condition like this once we find bout duration greater than 10 sec

    i=1:(fc2):(length(x)-(fc2)-1);
    al=length(i);
    for k=1:al-1
        L=length(x(i(k):i(k+1)))-1;
        f=0:fc2/L:(fc2/L)*(L-1);
        LF=find(f==3); 
        HF=find(f==10); 
        LLF=find(f==0);
        Pxx = abs(fft(detrend(x(i(k):i(k+1)))))/(L/2);
        Pyy = abs(fft(detrend(y(i(k):i(k+1)))))/(L/2);
        Ratio_x(k)=sum(Pxx(LF:HF)).^2/sum(Pxx(LLF:LF)).^2;
        Ratio_y(k)=sum(Pyy(LF:HF)).^2/sum(Pyy(LLF:LF)).^2;


% 
    end
    for f=1:length(Ratio_x)
        % Threshold on Frequecnt Ratio based on FFT
        if Ratio_x(f)>10 || Ratio_y(f)>10  
            percF(f)=1;
        else
            percF(f)=0;
        end
    end
    A=find(percF==1);
    B=length(percF);
    IFOG_limbs.FoGtime=(100*length(A))/B;



    %% Condition of Finalizing FOG based both methods correctly identified FOG episodes

    for f=1:length(percF)
        if percF(f)==1 && ab_limbs_corr_log(f)==1
            percF_final(f)=1;
        else
            percF_final(f)=0;
        end
    end
    %%%%%%%% Without Merging FOG Episdoes%%%%%%%%%%%%%%%
    Merged_percF_final=percF_final;

    %%%%%% Merging FOG Episdoes with 1 sec apart
    Merged_percF_final=percF_final;
    FOG_episode=find(percF_final==1);
    FOG_episode_diff=diff(find(percF_final==1));
    indices_1=find(FOG_episode_diff==2);
    Merged_percF_final(FOG_episode(indices_1)+1)=1;
    % % 
    %%%%%%%% Merging FOG Episdoes with 2 sec apart
    indices_2=find(FOG_episode_diff==3);
    Merged_percF_final(FOG_episode(indices_2)+1)=1;
    Merged_percF_final(FOG_episode(indices_2)+2)=1;



    N=find(Merged_percF_final==1);
    M=length(Merged_percF_final);
    %%% Percentage time frozen
    IFOG_limbs.FoGtime=(100*length(N))/M;
    IFOG_limbs.NN=length(N);
    IFOG_limbs.MM=M;



    indices_for_distribution=find(Merged_percF_final)';
    O=length(indices_for_distribution);
    Very_short_FOG=0;
    Short_FOG=0;
    Long_FOG=0;
    Very_Long_FOG=0;
    Q = [true; diff(Merged_percF_final(:)) ~= 0];   % TRUE if values change
    B = Merged_percF_final(Q);                      % Elements without repetitions
    Z = find([Q', true]);          % Indices of 1
    V = diff(Z);    
    look_at=[B',V'];

    for TT=1:size(look_at,1)
        if look_at(TT,1)==1 && look_at(TT,2)==1
            Very_short_FOG=Very_short_FOG+1;
        elseif look_at(TT,1)==1 && (look_at(TT,2)>=2 && look_at(TT,2)<=5)
            Short_FOG=Short_FOG+1;
        elseif look_at(TT,1)==1 && (look_at(TT,2)>5 && look_at(TT,2)<=30)
            Long_FOG=Long_FOG+1;
        elseif look_at(TT,1)==1 && (look_at(TT,2)>30)
            Very_Long_FOG=Very_Long_FOG+1;
        end
    end

    IFOG_limbs.Very_short_FOG= Very_short_FOG;
    IFOG_limbs.Short_FOG= Short_FOG;
    IFOG_limbs.Long_FOG= Long_FOG;
    IFOG_limbs.Very_Long_FOG=Very_Long_FOG;
elseif length(x)<fc2*5
    errorMessage = sprintf('Error: There is not enough data to calculate FOG. Please ensure each bout is longer than 10 seconds or sample more often');
    uiwait(warndlg(errorMessage));
else
    IFOG_limbs.FoGtime=NaN;
    IFOG_limbs.Mcorr=NaN;
    IFOG_limbs.SDcorr=NaN;
    IFOG_limbs.Very_short_FOG=NaN;
    IFOG_limbs.Short_FOG= NaN;
    IFOG_limbs.Long_FOG=NaN;
    IFOG_limbs.Very_Long_FOG=NaN;
    IFOG_limbs.NN=NaN;
    IFOG_limbs.MM=NaN;
end
    IFOG_limbs.totalFOG=100*((sum(IFOG_limbs.NN,'omitnan')-sum(IFOG_limbs.Very_short_FOG,'omitnan'))/sum(IFOG_limbs.MM,'omitnan'));
    IFOG_limbs.fileName = fileName;


