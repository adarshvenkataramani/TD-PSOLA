%% Read from Microphone and Write to Audio File
% Record ten seconds of speech with a microphone and send the output to a
% |.wav| file.

%%
% Create an |audioDeviceReader| System object(TM) with default settings.
% Call |setup| to reduce the computational load of initialization in an audio
% stream loop.
deviceReader = audioDeviceReader;
setup(deviceReader);

%%
% Create a |dsp.AudioFileWriter| System object. Specify the file name
% and type to write.
fileWriter = dsp.AudioFileWriter(...
    'mySpeech.wav',...
    'FileFormat','WAV');

%%
% Record 10 seconds of speech. In an audio stream loop, read an audio
% signal frame from the device, and write the audio signal frame to a
% specified file. The file saves to your current folder.
disp('Speak into microphone now.');
tic;
while toc < 10
    acquiredAudio = deviceReader();
    fileWriter(acquiredAudio);
end
disp('Recording complete.');

%%
% Release the audio device and close the output file.
release(deviceReader);
release(fileWriter);