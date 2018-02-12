function Y = PSOLA(X,Psc,Tsc,fs,N)
% Psc - Pitch Scale Parameter
% Tsc - Time Scale Parameter
% fs  - Sampling Frequency
% X - Input Signal
% N - Window Length
% Tm - Time mark Scale
%% Parameter Setup
[X,fs] = audioread('mySpeech.wav');
Tm = 100; % Time marks of the analysis speech
P = 50; % Period of the windows
L = length(X); % Length of the signal
X = X(1:floor(L/P)*Tm);
W = hann(2*P);
%% Frame Splitting Using Hanning

for i = 1+P:P:length(X)
    if (i-P/2 > 0 && i+P/2 < length(X))
        S(:,floor(i/P)) = X(i-P:i+P).*W;
    end
end
%% Overlap - Add
Tn = 50; % Time marks of synthesis speech
Y = [S(:,1)'];
for i = 1:size(S,2)-1
    OA = S(:,i+1)';
    AS  = Y(length(Y) - Tn:length(Y)-1) + OA(1:Tn);
    Y = [Y(1:length(Y) - Tn) AS OA(Tn+1:length(OA))];
end
end