function gui_star_octave
% GUI_STAR_OCTAVE Stack star trails with octave
%(c) Jussi Parviainen

% Initialize variables that are shared with subfunctions
global params;
params.folder = 'C:\Users\parvi\Pictures\vesaniemi27092019\v2';
params.file_list = [];
params.nFiles = 0;
params.path_list = [];
params.imres = [];
params.max_r =0;
params.max_g =0;
params.max_b =0;
params.im = [];
params.weight = 1;

global h;
% Make figure, axes and plot map
hfig = figure('Position',[100,50,1400,700]);
h.h_axes = axes('Parent', hfig,...
    'Units','Pixels',...
    'Position',[270,100,1000,550]);
set(h.h_axes, 'XTick', []);
set(h.h_axes, 'YTick', []);


h.h_load = uicontrol('Parent',hfig,...
    'Style','pushbutton',...
    'String', 'Load Images', ...
    'Value', 0, ...
    'Position', [50 550, 100, 50], ...
    'Callback', @(src,eventdata)load_callback(src,eventdata) );

h.h_listbox = uicontrol('Parent',hfig,...
    'Enable','off',...
    'Style','listbox',...
    'String', 'No images', ...
    ...'Value', '', ...
    'Position', [150 500, 100, 100]);


h.h_stack = uicontrol('Parent',hfig,...
    'Enable','off',...
    'Style','pushbutton',...
    'String', 'Stack', ...
    'Value', 0, ...
    'Position', [50 400, 100, 50], ...
    'Callback', @(src,eventdata)stack_callback(src,eventdata) );

h.h_save = uicontrol('Parent',hfig,...
    'Enable','off',...
    'Style','pushbutton',...
    'String', 'Save', ...
    'Value', 0, ...
    'Position', [50 300, 100, 50], ...
    'Callback', @(src,eventdata)save_callback(src,eventdata) );

weight_list = {'normal','fade in','fade out','fade in&out'};
% Plot dropdown menu for weight
h.h_weight = uicontrol(hfig,'Style','popupmenu', ...
    'Position', [150 400, 100, 50], ...
    'String',  weight_list, ...
    'Callback',  @weight_callback, ...
    'Enable', 'off')

% Normalize all units, objects resize automatically
set(h.h_load,'Units', 'normalized');
set(h.h_save,'Units', 'normalized');
set(h.h_stack,'Units', 'normalized');
set(h.h_weight,'Units', 'normalized');
set(h.h_axes,'Units', 'normalized');
set(h.h_listbox,'Units', 'normalized');
##set(hfig,'Units', 'normalized');


end

% Load images Callback
function load_callback(~,~)
  global h params
  [params.file_list, params.path_list] = ...
      uigetfile(fullfile(params.folder, '.jpg'), ...
      'JPG Files (*.jpg)','MultiSelect','on');
  if ~iscell(params.file_list)
      errordlg('Select at least 2 images');
      set(h.h_listbox,'string','No Images');
      set(h.h_save, 'Enable', 'off');
      set(h.h_stack, 'Enable', 'off');
      set(h.h_weight, 'Enable', 'off');
      set(h.h_listbox, 'Enable', 'off');
  end
  % Make sure that figures are sorted by name
  params.file_list = sort(params.file_list);
  params.im = imread(fullfile(params.path_list,params.file_list{1}));
  params.imres = size(params.im);
  r_im = params.im(:,:,1);
  g_im = params.im(:,:,2);
  b_im = params.im(:,:,3);
  params.max_r = r_im(:);
  params.max_g = g_im(:);
  params.max_b = b_im(:);
  params.weight = ones(size(params.max_b));
  imshow(params.im, 'Parent', h.h_axes)
  params.nFiles = numel(params.file_list);
  if params.nFiles > 1
      set(h.h_listbox,'string',params.file_list);
      set(h.h_save, 'Enable', 'on');
      set(h.h_stack, 'Enable', 'on');
      set(h.h_weight, 'Enable', 'on');
      set(h.h_listbox, 'Enable', 'on');
  end
end


% Load images Callback
function stack_callback(~,~)

  global params h

  % Hide buttons
  set(h.h_save, 'Enable', 'off');
  set(h.h_stack, 'Enable', 'off');
  set(h.h_weight, 'Enable', 'off');
  set(h.h_load, 'Enable', 'off');

  params.im = imread(fullfile(params.path_list,params.file_list{1}));

  % Reset max vectors to zero
  params.max_r = params.max_r*0;
  params.max_g = params.max_g*0;
  params.max_b = params.max_b*0;

  % Make progress bar with cancel button
  message = sprintf('Stacking %i/%i',0, params.nFiles);
  title(h.h_axes,  message)
  drawnow
  %h_wait = waitbar(0,message, ...
  %    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
  %setappdata(h_wait,'canceling',0);

  % Loop all the images and always select the pixel that has maximum
  % intesity
  for i = 1:params.nFiles
      params.im = imread(fullfile(params.path_list,params.file_list{i}));
      %
      message = sprintf('Stacking %i/%i',i,params.nFiles);
      title(h.h_axes,  message)
      drawnow
      % Check whether user closed the wait message
      %if ~isvalid(h_wait)
      %    message = sprintf('Stacking %i/%i',i,params.nFiles);
      %    h_wait = waitbar(0,message);
      %end
      % Break if cancel button was pressed
      %if getappdata(h_wait,'canceling')
      %    break
      %end
      % Update progress bar
      %h_wait = waitbar(i/params.nFiles,h_wait,message);
      % Shift progress bar always upmost figure
      %figure(h_wait);
      r_im = params.im(:,:,1);
      g_im = params.im(:,:,2);
      b_im = params.im(:,:,3);
      % Select the pixels with maximum weighted intensity
      params.max_r = max(r_im(:)*params.weight(i),params.max_r);
      params.max_g = max(g_im(:)*params.weight(i),params.max_g);
      params.max_b = max(b_im(:)*params.weight(i),params.max_b);
      params.im(:,:,1) = reshape(params.max_r,params.imres(1),params.imres(2));
      params.im(:,:,2) = reshape(params.max_g,params.imres(1),params.imres(2));
      params.im(:,:,3) = reshape(params.max_b,params.imres(1),params.imres(2));
      imshow(params.im, 'Parent', h.h_axes)
      
      %             if i == 1
      %                 imwrite(imind,im,filename,'gif', 'Loopcount',inf);
      %             else
      %                 imwrite(imind,cm,filename,'gif','WriteMode','append');
      %             end
  end
  %delete(h_wait)

  % Enable buttons after stacking is compete
  set(h.h_save, 'Enable', 'on');
  set(h.h_stack, 'Enable', 'on');
  set(h.h_weight, 'Enable', 'on');
  set(h.h_load, 'Enable', 'on');

end

function save_callback(~,~)
  global params
  [ffile, ffolder] =  uiputfile('*.jpg');
  full_file = fullfile(ffolder,ffile);
  imwrite(params.im,full_file,'jpg')
end

function weight_callback(src,~)
  global params
  switch get(src,'Value')
      case 1
          params.weight = ones(params.nFiles,1);
      case 2
          params.weight = linspace(0,1,params.nFiles);
      case 3
          params.weight = linspace(1,0,params.nFiles);
      case 4
          params.weight = hanning2(params.nFiles);
  end
end

function out = hanning2(N)
  i = 0:N-1;
  out = (0.5*(1-cos(2*pi*i/(N-1))));
end

