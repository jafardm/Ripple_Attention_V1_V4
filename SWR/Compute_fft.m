function [PS,F,fft_N,phi] = Compute_fft(x,Fs,fft_N,Fres,Flim)

% calculates the fft power spectrum of a continuous signal
% [PS,F,fft_N] = fftspectrumc(x,Fs,fft_N,Fres,Flim)
%
% x ...... matrix
% Fs ..... sampling frequency
% fft_N ... points for fft, fastest for  2.^[9:n] = [512 1024 2048 4096 ...]
% Fres ... if fft_N is empty, this gives the desired frequency resolution
% Flim ... determines the limit of output
%

% [nRows,nCols] = size(x);
% if nRows==1 && nCols>1
%     x = x(:);
%     nCols = nRows;
% end  
% 
% check input
if nargin<2;Fs = 1;end
if nargin<3;fft_N = 1;end
if nargin<4;Fres = [];end
if nargin<5;Flim = [];end

% determine N points
if isempty(fft_N) && ~isempty(Fres)
	fft_N = Fs/Fres;
end

dnow  = hann(size(x,1)).*x;
% run fast fourier transform
y = fft(dnow,round(fft_N));

% convert y to power density
PS = y.* conj(y) / round(fft_N);
phi = angle(y);
% magnitude = abs(y);

PS = PS(1:round(fft_N/2)+1,:);
phi = phi(1:round(fft_N/2)+1,:);
F = Fs*(0:round(fft_N/2))/round(fft_N);
F = F';


% limit the output
if nargin>4 && ~isempty(Flim)
	Fi = (F>=Flim(1)&F<=Flim(2));
	PS(~Fi,:) = [];
    phi(~Fi,:) = [];	
    F(~Fi) = [];
end

% N = length(y);
% y(1) = [];
% power = abs(y(1:N/2)).^2;
% nyquist = 1/2;
% freq = (1:N/2)/(N/2)*nyquist;
