function [y,h,s] = KernelFilter(x,fs,fc,foa,pfa);
%function [y,h,s] = KernelFilter(x,fs,fc,foa,rpa,lba,mda,pfa);
%KernelFilter: Non-negative FIR filter based on kernels.
%
%   [y,h,s] = KernelFilter(x,fs,fc,fo,pf)
%
%   x    Input signal       
%   fs   Signal sample rate (Hz).   
%   fc   Cutoff frequency (Hz).
%   fo   Filter order (samples). Must be even. Default = 200.
%   pf   Plot flag: 0=none (default), 1=screen
%
%   y    Filtered Signal.
%   h    Filter impulse response.
%   s    Structure of filter statistics.
%
%   Creates an optimal FIR filter with non-negative impulse response
%   that is as close as possible to an ideal lowpass filter. The 
%   current implementation uses an Epanechnikov kernel.

%====================================================================
% Process function arguments
%====================================================================
if nargin<1 | nargin>8,
    help KernelFilter;
    return;
    end;

fo = 200;                                                  % Default filter order (samples)
if exist('foa') & ~isempty(foa),
    fo = ceil(foa/2)*2;
    end;
  
pf = 0;                                % Default - no plotting
if nargout==0,                         % Plot if no output arguments
    pf = 1;
    end;  
if exist('pfa') & ~isempty(pfa),
    pf = pfa;
    end;

%====================================================================
% Process Inputs
%====================================================================
x  = x(:);
nx = length(x);

%====================================================================
% Author-Specified Parameters
%====================================================================
sd = linspace(0.35,0.50,100)*(fs/fc);

%====================================================================
% Preprocessing
%====================================================================
ih = -fo/2:fo/2;                                           % Filter impulse response indices
nh = length(ih);
p2 = max(14,nextpow2(nh)+1);                               % Power of 2 to use for the FFT
nf = 2^(p2-1)+1;                                           % Number of useful frequencies from FFT
k  = (1:nf)';                                              % Indices of useful range of FFTs
f  = fs*(k-1)/2^p2;                                        % Frequencies
Hi = f<fc;                                                 % Ideal lowpass filter impulse response

hr = sinc(ih*2*fc/fs);                                     % The raw sinc function (natural scale)
hr = hr/sum(hr);

%====================================================================
% Optimize the Filter Width (Scale)
%====================================================================
ns = length(sd);
er = zeros(ns,1);
cf = 0;                                                    % Convergence flag

while ~cf,
    for c1=1:length(sd),
        %h  = exp(-ih.^2/(2*sd(c1).^2));                        % Gaussian impulse response
        h = (1-(ih/sd(c1)).^2).*(abs(ih)<sd(c1));
        h = h/sum(h);
        if h(1)~=0 || h(end)~=0,
            error('Filter order is insufficient.');
            end;
        H = fft(h(fo/2+1:end),2^p2);    
        H = real(H + conj(H))' - h(fo/2+1);
        H = H(k);
        er(c1) = mean(abs(Hi-H).^2);
        end;
    [ero,imin] = min(er);
    sdo = sd(imin);
    cf = 1;
    end;
    
%====================================================================
% Calculate the Filter's Impulse Response
%====================================================================    
h  = (1-(ih/sdo).^2).*(abs(ih)<sdo);
ho = h/sum(h);
        
%====================================================================
%Apply the Filter
%====================================================================
mx = mean(x);
y = filter(ho,1,[x-mx;zeros(nh,1)])+mx;                      
y = y(fo/2+(1:nx));

%====================================================================
% Calculate the Frequency Response and Stats
%====================================================================
if pf>=1 || nargout>2,
    fmn = 0;
    fmx = fs/2;

    p2 = max(14,nextpow2(nh)+1);                           % Power of 2 to use for the FFT
    nf = 2^(p2-1)+1;                                       % Number of useful frequencies from FFT
    k = (1:nf)';                                           % Indices of useful range of FFTs
    f = fs*(k-1)/2^p2;                                     % Frequencies

    H  = fft(ho(fo/2+1:end),2^p2);
    H  = H + conj(H) - h(1);
    H  = real(H);
    H  = H(k);
    H  = H(:);
    Hi = f<fc;                                             % The ideal frequency response 
    
    s = struct('DC',nan,'MSE',nan,'MSEPB',nan,'MSESB',nan,'MXEPB',nan,'MXESB',nan);
        
    pb0 = min(find(H<0.75)-1);                             % Magnitude-defined passband edge    
    sb0 = min(nf,max(find(H>0.25))+1);                     % Magnitude-defined stopband edge
    
    if isempty(pb0),
        pb0 = 1;
        end;
    
    ipb = 1:pb0;                                           % Passband indices
    isb = sb0:nf;                                          % Stopband indices
    itb = (ipb(end)+1):(isb(1)-1);                         % Transition band indices
    
    s.DC    = 2*sum(h)-h(1);                               % DC gain
    
    s.MSE   = mean((Hi-H).^2);                             % Total    mean squared error
    s.MSEPB = mean((1-H(ipb)).^2);                         % Passband mean squared error
    s.MSESB = mean((0-H(isb)).^2);                         % Stopband mean squared error
    
    s.MXEPB = max(abs(1-H(ipb)));                          % Passband maximum error
    s.MXESB = max(abs(0-H(isb)));                          % Stopband maximum error
    end;
end    
