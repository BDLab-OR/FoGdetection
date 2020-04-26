function Opal = readOpalData(filename)
% readOpalData - reads data from .h5 file and returns a structure with
%   accelerometer and gyro data
%
% filename = name of the file to process
%
% Opal = structure returned with the data
%   .sampleRate = data collection rate
%   .time = time vector to use with data at this sampleRate
%   .sensor = array of structures with data from each sensor
%       .caseID = number on the monitor case
%       .monitorLabel = label for the body position of monitor
%       .acc = accelerometer data with x,y,z fields
%       .gyro = gyroscope data with x,y,z fields
%    
%

try
    vers = hdf5read(filename, '/FileFormatVersion');
catch
    try
        vers = hdf5read(filename, '/File_Format_Version');
    catch
        error('Couldn''t determine file format');
    end
end
if vers < 2
    error('This example only works with version 2 of the data file')
end

useMonitorLabels = {};
monitorLabels = {};
monitorCaseIDs = {};



monitorCaseIDList = hdf5read(filename, '/CaseIdList');
monitorLabelList = hdf5read(filename, '/MonitorLabelList');

for monitorIdx = 1:length(monitorCaseIDList)
    
    caseID = monitorCaseIDList(monitorIdx).data;
    monitorLabel = monitorLabelList(monitorIdx).data;
    
    if ~isempty(useMonitorLabels) && isempty(strmatch(monitorLabel, useMonitorLabels, 'exact'))
        continue;
    end
    
    accPath = [caseID '/Calibrated/Accelerometers'];
    gyroPath = [caseID '/Calibrated/Gyroscopes'];
    magPath = [caseID '/Calibrated/Magnetometers'];
    
    includeAcc = hdf5read(filename, [caseID '/AccelerometersEnabled']);
    includeGyro = hdf5read(filename, [caseID '/GyroscopesEnabled']);
    includeMag = hdf5read(filename, [caseID '/MagnetometersEnabled']);
    
    sampleRate = hdf5read(filename, [caseID '/SampleRate']);
    sampleRate = double(sampleRate);
    
    %buttonStatus = hdf5read(filename, [caseID '/ButtonStatus']);
    
    if includeAcc
        data = hdf5read(filename, accPath);
        acc.x = data(1,:);
        acc.y = data(2,:);
        acc.z = data(3,:);
        acc.units = 'm/s^2';
    end
    if includeGyro
        data = hdf5read(filename, gyroPath);
        gyro.x = data(1,:);
        gyro.y = data(2,:);
        gyro.z = data(3,:);
        gyro.units = 'rad/s';
    end
    
    if includeMag
         data = hdf5read(filename, magPath);
         mag.x = data(1,:);
         mag.y = data(2,:);
         mag.z = data(3,:);
         mag.units = 'a.u.';
     end


    Opal.sensor(monitorIdx).caseID = caseID;
    Opal.sensor(monitorIdx).monitorLabel = monitorLabel;
    Opal.sensor(monitorIdx).acc = acc;
    Opal.sensor(monitorIdx).gyro = gyro;
    Opal.sensor(monitorIdx).mag = mag;
%     Opal.sensor(monitorIdx).buttonStatus = buttonStatus;
end

Opal.sampleRate = sampleRate;
Opal.time = [0:length(data)-1]*(1/sampleRate);

warning off