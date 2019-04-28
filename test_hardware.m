try
    fclose(s)
end
clc;
clear;
close all;
%%

s = serial('COM3');
fopen(s);
pause(3)

fwrite(s,'3','char');

pause(2)
fwrite(s,'7','char');

fclose(s)