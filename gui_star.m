function gui_star
%GUI_STAR Make Start
folder = 'C:\Users\Mörököllit\Pictures\2018-10-29 leikkimokki\';

% Initialize variables that are shared with subfunctions
file_list = [];
nFiles = 0;
path_list = [];
imres = [];
max_r =0;
max_g =0;
max_b =0;
im = [];
weight = 1;

% Make figure, axes and plot map
hfig = figure('Position',[100,50,1400,700]);
h_axes = axes('Parent', hfig,...
    'Units','Pixels',...
    'Position',[270,100,1000,550]);
h_axes.XTick = [];
h_axes.YTick = [];


h_load = uicontrol('Parent',hfig,...
    'Style','pushbutton',...
    'String', 'Load Images', ...
    'Value', 0, ...
    'Position', [50 500, 100, 100], ...
    'Callback', @(src,eventdata)load_callback(src,eventdata) );

h_stack = uicontrol('Parent',hfig,...
    'Enable','off',...
    'Style','pushbutton',...
    'String', 'Stack', ...
    'Value', 0, ...
    'Position', [50 400, 100, 100], ...
    'Callback', @(src,eventdata)stack_callback(src,eventdata) );

h_save = uicontrol('Parent',hfig,...
    'Enable','off',...
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

% Normalize all units, objects resize automatically
h_load.Units = 'normalized';
h_save.Units = 'normalized';
h_stack.Units = 'normalized';
h_weight.Units = 'normalized';
h_axes.Units = 'normalized';
hfig.Units = 'normalized';



% Load images Callback
    function load_callback(~,~)
        [file_list, path_list] = uigetfile(fullfile(folder, '.jpg'), ...
            'JPG Files (*.jpg)','MultiSelect','on');
        im = imread(fullfile(path_list,file_list{1}));
        imres = size(im);
        r_im = im(:,:,1);
        g_im = im(:,:,2);
        b_im = im(:,:,3);
        max_r = r_im(:);
        max_g = g_im(:);
        max_b = b_im(:);
        weight = ones(size(max_b));
        imshow(im, 'Parent', h_axes)
        nFiles = numel(file_list);
        if nFiles > 1
            h_save.Enable = 'on';
            h_stack.Enable = 'on';
            h_weight.Enable = 'on';
        end
    end


% Load images Callback
    function stack_callback(~,~)

        im = imread(fullfile(path_list,file_list{1}));
        max_r =max_r*0;
        max_g =max_g*0;
        max_b =max_b*0;
        
        message = sprintf('Stacking %i/%i',0,nFiles);
        h_wait = waitbar(0,message, ...
            'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
        setappdata(h_wait,'canceling',0);
        for i = 1:nFiles
            im = imread(fullfile(path_list,file_list{i}));
            message = sprintf('Stacking %i/%i',i,nFiles);
            % Check whether user closed the wait message
            if ~isvalid(h_wait)
                message = sprintf('Stacking %i/%i',i,nFiles);
                h_wait = waitbar(0,message);
            end
            if getappdata(h_wait,'canceling')
                break
            end
            h_wait = waitbar(i/nFiles,h_wait,message);
            r_im = im(:,:,1);
            g_im = im(:,:,2);
            b_im = im(:,:,3);
            max_r = max(r_im(:)*weight(i),max_r);
            max_g = max(g_im(:)*weight(i),max_g);
            max_b = max(b_im(:)*weight(i),max_b);
            im(:,:,1) = reshape(max_r,imres(1),imres(2));
            im(:,:,2) = reshape(max_g,imres(1),imres(2));
            im(:,:,3) = reshape(max_b,imres(1),imres(2));
            imshow(im, 'Parent', h_axes)
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

