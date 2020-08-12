function [] = findFOGs
dbstop if error

%{
USER SPECIFIED VARIABLES
Subject folder must contain CSV files. These can be in subdirectories.
Output directory can be anywhere
To set input accelerometer and gryoscope data (required to run this), 
please set the column names so they correspond to the correct data, as
described in comments below. If you have questions about this, please see the 
Readme at https://github.com/BDLab-OR/FoGdetection
%}
subjectFolder = '/Users/alexastefanko/lab/FoGdetection/Subjects';
yourOutputDirectory = '/Users/alexastefanko/lab/FoGdetection/';
sampleRate = 128;

R_acc_ap_col = "R_acc"; %Column name for right accelerometer anterior-posterior
L_acc_ap_col = "L_acc"; %Column name for left accelerometer anterior-posterior
R_gyr_ml_col = "R_gyr"; %Column name for right gyroscope mediolateral
L_gyr_ml_col = "L_gyr"; %Column name for left gyroscop mediolateral

%Check if directory exists, warn user if not
if ~isfolder(subjectFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', subjectFolder);
  uiwait(warndlg(errorMessage));
  return;
end

%Get all csv files from folder and its subfolders
fds = fileDatastore(subjectFolder, 'ReadFcn', @load, 'FileExtensions', '.csv');
fullFileNames = fds.Files;
numFiles = length(fullFileNames);

% Loop over all files and process them
for k = 1 : numFiles
    fileName = fullFileNames{k};
    fprintf('Now reading file %s\n', fileName);
    metricsTable = readtable(fileName);
    [~,name,~] = fileparts(fileName);

    R_acc_ap = metricsTable.(R_acc_ap_col); 
    L_acc_ap = metricsTable.(L_acc_ap_col);
    R_gyr_ml = metricsTable.(R_gyr_ml_col);
    L_gyr_ml = metricsTable.(L_gyr_ml_col);
    IFOG = getFOGInstances(name, R_acc_ap, L_acc_ap, R_gyr_ml, L_gyr_ml, sampleRate);
    FOGs(k) = IFOG;
end

%Return FOG info on a per-bout basis to an xls file. Each row is a bout.
mkdir(yourOutputDirectory, "Output");
outputDirectory = strcat(yourOutputDirectory, "Output/");
writetable(struct2table(FOGs), strcat(outputDirectory,'fogs.xls'));


