folder = 'C:\Users\M�r�k�llit\Pictures\2018-10-29 leikkimokki\';
im = 'C:\Users\M�r�k�llit\Pictures\2018-10-29 leikkimokki\DSC_1019.jpg';

a= dir([folder '\*.jpg']);

for k = 1:20
    im = imread(fullfile(folder,a(k).name));
    
end