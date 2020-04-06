function Data = getHDFdata (fileName)

sensors     = h5info(fileName, '/Sensors');
processed   = h5info(fileName, '/Processed');
nDevices    = length(sensors.Groups);

sensor(nDevices)   = struct('acc',[],'gyro',[],'mag',[],'orient',[],'monitorLabel',[]);

for i = 1:nDevices
    monitorLabel = h5readatt(fileName, [sensors.Groups(i).Name '/Configuration'], 'Label 0');    
    acc = h5read(fileName, [sensors.Groups(i).Name '/Accelerometer'])';
    gyro = h5read(fileName, [sensors.Groups(i).Name '/Gyroscope'])';
    mag = h5read(fileName, [sensors.Groups(i).Name '/Magnetometer'])';
    orient = h5read(fileName, [processed.Groups(i).Name '/Orientation'])';
    
    
    %Devices(i).x            = [a g m];
    Devices(i).acc.x           = acc(:,1)';
    Devices(i).acc.y           = acc(:,2)';
    Devices(i).acc.z           = acc(:,3)';
    Devices(i).gyro.x            = gyro(:,1)';
    Devices(i).gyro.y           = gyro(:,2)';
    Devices(i).gyro.z            = gyro(:,3)';
    Devices(i).mag.x = mag(:,1)';
    Devices(i).mag.y = mag(:,2)';
    Devices(i).mag.z = mag(:,3)';
    Devices(i).orient.q1=orient(:,1)';
    Devices(i).orient.q2=orient(:,2)';
    Devices(i).orient.q3=orient(:,3)';
    Devices(i).orient.q4=orient(:,4)';
   % Devices(i).q            = q;
    
    Devices(i).monitorLabel        = monitorLabel;
end
dn = h5read(fileName, [sensors.Groups(i).Name '/Time']).';
tOffset                 = -7*60; 
    Data.dateNumbers  = double(dn).'/(24*3600*1e6) + datenum(1970,1,1)+ tOffset/(24*60);
    Data.sampleRate=128;
Data.sensor = Devices;