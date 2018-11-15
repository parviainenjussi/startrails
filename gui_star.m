function gui_star
folder = 'C:\Users\Mörököllit\Pictures\2018-10-29 leikkimokki\';

% Make figure, axes and plot map
hfig = figure('Position',[100,50,1400,700]);
handleaxes = axes('Parent', hfig,...
    'Units','Pixels',...
    'Position',[350,100,1000,550]);

file_list = [];
nFiles = 0;
path_list = [];
imres = [];
max_r =0;
max_g =0;
max_b =0;
im = [];
weight = 1;
h_load = uicontrol('Parent',hfig,...
    'Style','pushbutton',...
    'String', 'Load Images', ...
    'Value', 0, ...
    'Position', [50 500, 100, 100], ...
    'Callback', @(src,eventdata)load_callback(src,eventdata) );

h_stack = uicontrol('Parent',hfig,...
    'Style','pushbutton',...
    'String', 'Stack', ...
    'Value', 0, ...
    'Position', [50 400, 100, 100], ...
    'Callback', @(src,eventdata)stack_callback(src,eventdata) );

h_save = uicontrol('Parent',hfig,...
    'Style','pushbutton',...
    'String', 'Save', ...
    'Value', 0, ...
    'Position', [50 300, 100, 100], ...
    'Callback', @(src,eventdata)save_callback(src,eventdata) );

weight_list = {'normal','fade in','fade out','fade in&out'};

% Plot dropdown menu for weight
h_weight = uicontrol(hfig,'Style','popupmenu');
h_weight.Position = [150 400, 100, 100];
h_weight.String = weight_list;
h_weight.Callback = @weight_callback;


% Load images Callback
    function load_callback(~,~)
        [file_list, path_list] = uigetfile(fullfile(folder, '.jpg'), ...
            'All Files (*.*)','MultiSelect','on');
        im = imread(fullfile(path_list,file_list{1}));
        imres = size(im);
        r_im = im(:,:,1);
        g_im = im(:,:,2);
        b_im = im(:,:,3);
        max_r = r_im(:);
        max_g = g_im(:);
        max_b = b_im(:);
        weight = ones(size(max_b));
        imshow(im, 'Parent', handleaxes)
        nFiles = numel(file_list);
    end


% Load images Callback
    function stack_callback(~,~)
        if nFiles < 2
            errordlg('Load at least 2 images')
            return;
        end
        im = imread(fullfile(path_list,file_list{1}));
        max_r =max_r*0;
        max_g =max_g*0;
        max_b =max_b*0;
        h_wait = waitbar(0,'stacking');
        for i = 1:nFiles
            im = imread(fullfile(path_list,file_list{i}));
            h_wait = waitbar(i/nFiles,h_wait);
            r_im = im(:,:,1);
            g_im = im(:,:,2);
            b_im = im(:,:,3);
            max_r = max(r_im(:)*weight(i),max_r);
            max_g = max(g_im(:)*weight(i),max_g);
            max_b = max(b_im(:)*weight(i),max_b);
            im(:,:,1) = reshape(max_r,imres(1),imres(2));
            im(:,:,2) = reshape(max_g,imres(1),imres(2));
            im(:,:,3) = reshape(max_b,imres(1),imres(2));
            imshow(im, 'Parent', handleaxes)
        end
        delete(h_wait)
    end

    function save_callback(~,~)
        [ffile, ffolder] =  uiputfile('*.jpg');
        full_file = fullfile(ffolder,ffile);
        imwrite(im,full_file,'jpg')
    end

    function weight_callback(src,~)
        switch src.Value
            case 1
                weight = 1;                
            case 2
                weight = linspace(0,1,nFiles);
            case 3
                weight = linspace(1,0,nFiles);
            case 4
                weight = hanning(nFiles);                
        end
    end
end

