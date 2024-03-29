classdef mesoscopeParams
    
    properties (Constant)
        
        % paths
        savepath_mac          = '/Users/lucas/Documents/Princeton/data/mesoscope/'; 
        serverpath_mac        = '/Volumes/braininit/RigData/mesoscope/imaging/';
        serverpath_spock      = '/jukebox/braininit/RigData/mesoscope/imaging/'; 
        serverpathbehav_mac   = '/Volumes/braininit/RigData/mesoscope/behavior/lucas/blocksReboot/data/'; 
        serverpathbehav_spock = '/jukebox/braininit/RigData/mesoscope/behavior/lucas/blocksReboot/data/';
        serverpath_pc         = '\\bucket.pni.princeton.edu\braininit\RigData\mesoscope\imaging\';
        serverpathbehav_pc    = '\\bucket.pni.princeton.edu\braininit\RigData\mesoscope\behavior\lucas\blocksReboot\data\';
        extHDpath_mac         = '/Volumes/LPData/mesoscope/';

        % list of all mice
        mice                  = {'sp1';'sp2';'sp4';'sp6';'sp7'}; 
        
        % scale
        xySizeFactor          = 1.05; % images are this much larger than nominal size
        zFactor               = 1.45; % actual displacement in z vs command
        
        % acquisition parameters
       
        % plotting
        colormap        = 'red2blue'
        myblue          = [57 133 255]./255;
        myblueSh        = [151 193 252]./255;
        myred           = [255 0 0]./255;
        myredSh         = [255 179 179]./255;
        mypurple        = [207  79 223]./255;
        darkgray        = [.3 .3 .3];
        lightgray       = [.7 .7 .7];
        mediumgray      = [.5 .5 .5];
        darkgreen       = [0 .5 0];
        mediumgreen     = [0.2353    0.7020    0.4431];
        orange          = [245 145 32]./255;
        lightpurple     = [220 150 255]./255;
        darkpurple      = [188 19  254]./255;
        lightyellow     = [255 220 150]./255;
        darkyellow      = [252 194 0]./255;
        mymagenta       = [192 71 196]/255;
        visGuideCl      = [1 1 1]./2;
        accMazeCl       = [0 0 0];
        
        % analysis
        vascMaxIter     = 2;
        vasMinNSigmas   = 1.5;
        winSizeModeSec  = 45;
        f_offset        = 1550;
        perfTh          = 0.6;
        
        colors          = @colorcube;
        
        areaCl          = [[0 129 59]./255;   ...
                           [0 224 59]./255;   ...
                           [0 224 205]./255;  ...
                           [0 116 225]./255;  ...
                           [231 118 22]./255; ...
                           [231 179 42]./255; ...
                           [172 51 59]./255;  ...
                           [207  79 223]./255 ...
                          ];
%         colors          = [ mesoscopeParams.myblue      ;   ...
%                             mesoscopeParams.orange      ;   ...
%                             mesoscopeParams.mediumgreen ;   ...
%                             mesoscopeParams.mypurple    ;   ...
%                             mesoscopeParams.darkyellow  ;   ...
%                             mesoscopeParams.darkgreen   ;   ...
%                             mesoscopeParams.lightpurple ;   ...
%                             mesoscopeParams.myred       ;   ...
%                             mesoscopeParams.mymagenta   ;   ...
%                             mesoscopeParams.darkpurple  ;   ...
%                             [.2        .2        .2    ];   ...
%                             [.4        .4        .4    ];   ...
%                             [.6        .6        .6    ];   ...
%                             [.8        .8        .8    ];   ...
%                             [0.2       0.6470    0.7410];   ...
%                             [0.8500    0.4250    0.4980];   ...
%                             [0.9290    0.8940    0.3250];   ...
%                             [0.5940    0.4840    0.5560];   ...
%                             [0.6660    0.6740    0.3880];   ...
%                             [0.5010    0.7450    0.9330];   ...
%                             [0.6350    0.2780    0.3840];   ...
%                             [1         .2        .2    ];   ...
%                             [.2        1         1     ];   ...
%                             [.2        1         .2    ];   ...
%                             [1         1          1    ];   ...
%                             [1         .5        .5    ];   ...
%                             [.5        1         .5    ];   ...
%                             [.5        .5        1     ];   ...
%                             [1         1         1     ];   ...
%                             ];
        
        epochCl          = {[.5        .5        .5    ];   ...
                            [0         0         1     ];   ...
                            [0         0.4470    0.7410];   ...
                            [0.9290    0.6940    0.1250];   ...
                            [0.8500    0.3250    0.0980];   ...
                            [0.4940    0.1840    0.5560];   ...
                            };
    end
    
    properties
        
        filters
        
    end
    
    methods
      
      function applyAxisDefaults(obj,axisHandle,cl,fs)
        if nargin < 3; cl = 'w'; end
        if nargin < 4; fs = 12; end
        set(axisHandle,'ycolor',cl,'xcolor',cl,'zcolor',cl,'fontsize',fs,'box','off')
      end
      
      function applyAxisLbls(obj,axisHandle,xlbl,ylbl,titlestr,zlbl)
        if nargin < 5; titlestr = []; end
        if nargin < 6; zlbl     = []; end
        axes(axisHandle)
        xlabel(xlbl,'fontsize',14)
        ylabel(ylbl,'fontsize',14)
        if ~isempty(zlbl)     
          zlabel(zlbl,'fontsize',14);                                    
        end
        if ~isempty(titlestr) 
          title(titlestr,'fontsize',15,'fontweight','bold','color',get(axisHandle,'ycolor')); 
        end
      end
      
      function applyFigDefaults(obj,figHandle,panels,cl)
        if nargin < 4; cl = 'k'; end
        set(figHandle,'color',cl,'position',[10 10 min([1200 800; panels.*250])])
      end
      
      function rootdir = getRootDir(obj,spockFlag)
        if ischar(spockFlag)
          tempchar = spockFlag;
          if strcmpi(tempchar,'scotty') || strcmpi(tempchar,'spock')
            spockFlag = true;
          else
            spockFlag = false;
          end
        end
        if spockFlag
          rootdir   = mesoscopeParams.serverpath_spock;
        else
          if ispc
            rootdir = mesoscopeParams.serverpath_pc;
          else
            rootdir = mesoscopeParams.serverpath_mac;
          end
        end
        rootdir = formatFilePath(rootdir);
      end
      
      function rootdir = getRootDirBehav(obj,spockFlag)
        if ischar(spockFlag)
          tempchar = spockFlag;
          if strcmpi(tempchar,'scotty') || strcmpi(tempchar,'spock')
            spockFlag = true;
          else
            spockFlag = false;
          end
        end
        if spockFlag
          rootdir   = mesoscopeParams.serverpathbehav_spock;
        else
          if ispc
            rootdir = mesoscopeParams.serverpathbehav_pc;
          else
            rootdir = mesoscopeParams.serverpathbehav_mac;
          end
        end
        rootdir = formatFilePath(rootdir);
      end
      
      function recls = getMouseRecs(obj,mouse,type,localFlag)
        if nargin < 3; type      = 'task'; end
        if nargin < 4; localFlag = false;  end
        
        rootdir = obj.getRootDir(isThisSpock,localFlag);
        recls   = mesoscope_recLs.recs;
        idx     = cellfun(@(x)(contains(x,mouse)),recls);
        recls   = recls(idx);
        recls   = cellfun(@(x)([rootdir x]),recls,'Uniformoutput',false);
%         switch type
%           case 'task'
%             recls = widefield_recLs.BVrecs_gcamp;
%             idx   = cellfun(@(x)(contains(x,mouse)),recls);
%             recls = recls(idx);
%             recls = cellfun(@(x)([rootdir x]),recls,'Uniformoutput',false);
%             
%           case 'spont'
%             recls = widefield_recLs.BVrecs_spont;
%             idx   = cellfun(@(x)(contains(x,mouse)),recls);
%             recls = [rootdir recls{idx}];
%         end
        
        
      end
      
    end
    
end