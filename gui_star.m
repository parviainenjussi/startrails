function gui_star
folder = 'C:\Users\Mörököllit\Pictures\2018-10-29 leikkimokki\';

% Make figure, axes and plot map
hfig = figure('Position',[100,50,1400,700]);
handleaxes = axes('Parent', hfig,...
    'Units','Pixels',...
    'Position',[350,100,1000,550]);

file_list = [];
path_list = [];
imres = [];
max_r =[];
max_g =[];
max_b =[];
h_load = uicontrol('Parent',hfig,...
    'Style','pushbutton',...
    'String', 'load images', ...
    'Value', 0, ...
    'Position', [50 500, 100, 100], ...
    'Callback', @(src,eventdata)load_callback(src,eventdata) );

h_stack = uicontrol('Parent',hfig,...
    'Style','pushbutton',...
    'String', 'stack', ...
    'Value', 0, ...
    'Position', [50 400, 100, 100], ...
    'Callback', @(src,eventdata)stack_callback(src,eventdata) );

    % Load images Callback
    function load_callback(src,event)
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
        imshow(im, 'Parent', handleaxes)
    end

    % Load images Callback
    function stack_callback(src,event)
        nFiles = numel(file_list);
        if nFiles < 2
            return;
        end
        h_wait = waitbar(0,'stacking');
        for i = 1:nFiles
            im = imread(fullfile(path_list,file_list{i}));
            h_wait = waitbar(i/nFiles,h_wait);
            r_im = im(:,:,1);
            g_im = im(:,:,2);
            b_im = im(:,:,3);
            max_r = max(r_im(:),max_r);
            max_g = max(g_im(:),max_g);
            max_b = max(b_im(:),max_b);
            im(:,:,1) = reshape(max_r,imres(1),imres(2));
            im(:,:,2) = reshape(max_g,imres(1),imres(2));
            im(:,:,3) = reshape(max_b,imres(1),imres(2));
            imshow(im, 'Parent', handleaxes)
        end
        delete(h_wait)
    end
end

