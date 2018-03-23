function H = doChapterSimFigs(params,scoreSheet,allocVals,annotatStr)
%just do sim plots and attotate with settings
%   Detailed explanation goes here

%% set up annotation string array

nSims  = params.nSims; % N of particpants to simulate
simExp = params.simExp;
s_1_2  = params.s_1_2; % tweak this to find sigmoids we like
s_3    = params.s_3;
d_1    = params.d_1; % face task baseline difficulty
d_2    = params.d_2; % memory task difficulty
d_3    = params.d_3;
prime_lift    = params.prime_lift;
load_weight   = params.load_weight;
distribTypes  = params.distribTypes;
R_s_sampling  = params.R_s_sampling;
a_s_sampling  = params.a_s_sampling; % lower vals of a_s result in less resources for Face Task, more for Memory Task
x_ps_sampling = params.x_ps_sampling; % proportion of face task resource allocation given away under priming, - numbers approaching 1 probably not realistic
x_ls_sampling = params.x_ls_sampling; % proportion of mem task resource allocation given away to face task under load - numbers near 1 again prob not realistic
measErrMu     = params.measErrMu; %measurement error. It's additive so mu = 0 and sigma = 0 for no error
measErrSigma  = params.measErrSigma;
normAllocParams = params.normAllocParams;
fixedAllocs = params.fixedAllocs;

s = [s_1_2 s_1_2 s_3];

if strcmp(simExp,'Exp. 3')|| strcmp(simExp,'Exp. 4b')
    nTasks = 3;
else nTasks = 2;
end

%% figure setup
figRect = [.2 .1 .78 .6]; % [bottom left width height]
figCol = [.75 .75 .75];

col1PlotLPos = .1; col2PlotLPos = .2;
col1PlotWidth = .1; col2PlotWidth = .2;

row1PlotBase = .55;
row2PlotBase = .1;
plotHeights = .32;

annotatPos = [.6 .4 .35 .4];
varPlotPos = [.76 .25 .2 .6];

subPlotTitleFontSize = 10;
subPlotAxFontSize = 8;
barCols   = {[0 0 255]*.00392;[0 0 255]*.00392;[255 0 0]*.00392;[255 0 0]*.00392};

simPlots = [1 4];
demoPlots = [2 5];

condLabels = {...
    'P'
    'N'
    'PL'
    'NL'
    };

taskNames = {...
    'Face';
    'Memory';
    'Load';
    };

dvs = {...
    '1/RTs'
    '3AFC acc'
    ''
    };

dvConds = {...
    [1 2]
    [1 2]
    [1 2]
    };

plotAxFontSize = 8;
plotLines{:,1} = {...
    'b--'
    'b-'
    'r--'
    'r-'
    };
plotLines{:,2} = {...
    'b-'
    };

if strcmp(simExp,'Exp. 2')
    dCurves =  {...
        %[d_1;(d_1-prime_lift);d_1+load_weight;d_1-prime_lift+load_weight];
        [(d_1-prime_lift);d_1];
        d_2;
        d_3;
        };
    curveToPlotOn = {...
        [1 2 3 4]
        [1 1 1 1]};
else
    dCurves =  {...
        [d_1;(d_1-prime_lift)];
        d_2;
        d_3;
        };
    curveToPlotOn = {...
        [2 1 2 1]
        [1 1 1 1]
        [1 1]};
end

primedLineCol = 'c'; %these for individual subject lines
negPrimedLineCol = [.65 .65 .65];
medianLineWidth = 1.25; %these for subject plots mean mark lines
medianLineColour = {'b';'b';'r';'r'};
medianLineStyle = {'--';'-';'--';'-'};

x = .01:.001:1;
lineBlank = zeros(1,length(x));

simVarTitle = {...
    'Individual simulation'
    'variable vals'
    };
simVarPlotBoxCol = [.3 .3 .3];
simVarPlotBoxLineWidth = 1.5;
scatterCols = {...
    'b'
    'r'
    'b'
    'c'
    'g'
    };
simVarPlotXticks = {...
    'R_s'
    'a_s'
    'a_3s'
    'xp_s'
    'xl_s'
    };

subPlotGrid = reshape(1:nTasks*3,[3,nTasks])';

%% make fig. 1, hypothetical resource-performance function

fig1 = figure;
set(gcf,'Units','normalized')
set(gcf,'color',[.75 .75 .75]);
set(gcf, 'Name', ['Sampled ' simExp]);

demoVert = repmat(lineBlank,[2 1])';
demoLine = repmat(lineBlank,[2 1]);
hold on
for demoCurveI = [1 2]
    demoCurve(:,demoCurveI) = 1./(1+exp(-(x-dCurves{1}(demoCurveI))/s(1)));
    plot(x,demoCurve(:,demoCurveI),plotLines{1}{demoCurveI});
end
for demoLineI = dvConds{1}
    demoLine(demoLineI,1:find(demoCurve(:,curveToPlotOn{1}(demoLineI))>median(scoreSheet(:,demoLineI,1)))) = median(scoreSheet(:,demoLineI,1));
    demoVert(find(demoLine(demoLineI,:),1,'last'),demoLineI) = median(scoreSheet(:,demoLineI,1));
    plot(x(1:find(demoLine(demoLineI,:),1,'last')),demoLine(demoLineI,1:find(demoLine(demoLineI,:),1,'last')),plotLines{1}{demoLineI},'LineWidth',medianLineWidth);
    bar(x,demoVert(:,demoLineI),'BarWidth',.05);
end
set(gca,'XLim',[0 1]);
set(gca,'YLim',[0 1]);
set(gca,'Box','on');
set(gca,'XTick',[0 .5 1]);
set(gca,'YTick',[0 .5 1]);
legend('d = .15','d = .35','Location','SouthEast');
legend('boxon');

xlabel('Resources');
clear demoCurve demoVert demoLine

%% do interaction concept illustration figure:
conceptFig = figure;
set(gcf,'Units','normalized');

col1PlotLPos = .1; col2PlotLPos = .35;
col1PlotWidth = .25; col2PlotWidth = .5;

row1PlotBase = .55;
row2PlotBase = .1;
plotHeights = .6;

annotatPos = [.6 .4 .35 .4];


for plotI = 1:2
   
    conceptPlot(plotI) = subplot(1,2,plotI);
    if plotI == 1
        hold on
        line([.7 6],[median(scoreSheet(:,1,1)) median(scoreSheet(:,1,1))],'Color',medianLineColour{1},'LineStyle',medianLineStyle{1},'LineWidth',medianLineWidth);
        line([1.7 6],[median(scoreSheet(:,2,1)) median(scoreSheet(:,2,1))],'Color',medianLineColour{2},'LineStyle',medianLineStyle{2},'LineWidth',medianLineWidth)
        line([3.7 6],[median(scoreSheet(:,3,1)) median(scoreSheet(:,3,1))],'Color',medianLineColour{3},'LineStyle',medianLineStyle{3},'LineWidth',medianLineWidth);
        line([4.7 6],[median(scoreSheet(:,4,1)) median(scoreSheet(:,4,1))],'Color',medianLineColour{4},'LineStyle',medianLineStyle{4},'LineWidth',medianLineWidth)
        
        xpos = [1,2,4,5];
        barFaceCols = [...
            0 0 .7;
            0 0 .5;
            .7 0 0;
            .5 0 0];
        
        for n = 1:4
        bar(xpos(n),median(scoreSheet(:,n,1)),1,'facecolor',barFaceCols(n,:),'edgecolor',[1 1 1]);
        hold on
        end
        xlim([0 6]);
        set(gca,'xtick',xpos);
        set(gca,'XTickLabel',{'P','N','PL','NL'})
        set(gca,'Box','on');
        ylim([0 1]);
        hold off
    else
        
        demoVert = repmat(lineBlank,[1 1])';
        demoLine = repmat(lineBlank,[1 1]);
        hold on
        demoCurve(:,1) = 1./(1+exp(-(x-dCurves{1}(2))/s(1)));
        plot(x,demoCurve(:,1),plotLines{1}{2});
        
        for demoLineI = 1:4
            demoLine(demoLineI,1:find(demoCurve(:,1)>median(scoreSheet(:,demoLineI,1)))) = median(scoreSheet(:,demoLineI,1));
            demoVert(find(demoLine(demoLineI,:),1,'last'),demoLineI) = median(scoreSheet(:,demoLineI,1));
            plot(x(1:find(demoLine(demoLineI,:),1,'last')),demoLine(demoLineI,1:find(demoLine(demoLineI,:),1,'last')),plotLines{1}{demoLineI},'LineWidth',medianLineWidth);
            bar(x,demoVert(:,demoLineI),'BarWidth',.05);
        end
        set(gca,'XLim',[0 1]);
        set(gca,'YLim',[0 1]);
        set(gca,'YTickLabel','');
        set(gca,'Box','on');
        xlabel('Resources');
        hold off
    end
    
end

set(conceptPlot(1),'Position',[col1PlotLPos row2PlotBase col1PlotWidth plotHeights]);
set(conceptPlot(2),'Position',[col2PlotLPos row2PlotBase col2PlotWidth plotHeights]);

%%
% 
% figure;
% set(gcf,'Units','normalized')
% set(gcf,'color',[.75 .75 .75]);
% set(gcf, 'Name', ['Sampled ' simExp]);
% 
% for plotRowI = 1:nTasks
%     for plotColI = 1:3
%         
%         plotNum = subPlotGrid(plotRowI,plotColI);
%         if ismember(plotNum,simPlots)
%             H(plotNum) = subplot(nTasks,3,plotNum);
%             hold on
%             title({[taskNames{plotRowI} ' Task'];'Simulation'},'FontSize',subPlotTitleFontSize);
%             d = scoreSheet(:,[1 2],plotRowI);
%             d(:,isnan(sum(d))) = [];
%             xs = zeros(size(d));
%             for xsi = 1:size(d,2)
%                 xs(:,xsi) = xsi;
%             end
%             boxplot(d,condLabels(1:size(d,2)),'Colors','bbrr','Notch','on');
%             set(findobj(gca,'Tag','Median'),'Color',[0 0 0],'LineWidth',2);
%             xTxt = findobj(gca,'Type','text');
%             set(xTxt,'FontSize',subPlotAxFontSize);
%             
%             for plotI = 1:size(d,2)
%                 plot(xs(:,plotI),d(:,plotI),'Color',barCols{plotI},'Marker','.','LineStyle','none')
%             end
%             
%             for lineI = 1:nSims
%                 if scoreSheet(lineI,1,plotRowI) > scoreSheet(lineI,2,plotRowI)
%                     line([1 2],scoreSheet(lineI,[1 2],plotRowI),'Color',primedLineCol)
%                 else
%                     line([1 2],scoreSheet(lineI,[1 2],plotRowI),'Color',negPrimedLineCol)
%                 end
%             end
%             
%             line([.7 5],[median(scoreSheet(:,1,plotRowI)) median(scoreSheet(:,1,plotRowI))],'Color',medianLineColour{1},'LineStyle',medianLineStyle{1},'LineWidth',medianLineWidth);
%             line([1.7 5],[median(scoreSheet(:,2,plotRowI)) median(scoreSheet(:,2,plotRowI))],'Color',medianLineColour{2},'LineStyle',medianLineStyle{2},'LineWidth',medianLineWidth)
%             
%             ylim([0 1]);
%             taskSimYlim = get(gca,'YLim');
%             set(gca,'FontSize',subPlotAxFontSize);
%             
%         elseif ismember(plotNum,demoPlots) && ~(strcmp(simExp,'Exp. 3')&& plotRowI==3)
%             
%             H(plotNum) = subplot(nTasks,3,plotNum);
%             demoVert = repmat(lineBlank,[length(dvConds{plotRowI}) 1])';
%             demoLine = repmat(lineBlank,[length(dvConds{plotRowI}) 1]);
%             hold on
%             for demoCurveI = 1:length(dCurves{plotRowI})
%                 demoCurve(:,demoCurveI) = 1./(1+exp(-(x-dCurves{plotRowI}(demoCurveI))/s(plotRowI)));
%                 plot(x,demoCurve(:,demoCurveI),plotLines{plotRowI}{demoCurveI});
%             end
%             for demoLineI = dvConds{plotRowI}
%                 demoLine(demoLineI,1:find(demoCurve(:,curveToPlotOn{plotRowI}(demoLineI))>median(scoreSheet(:,demoLineI,plotRowI)))) = median(scoreSheet(:,demoLineI,plotRowI));
%                 demoVert(find(demoLine(demoLineI,:),1,'last'),demoLineI) = median(scoreSheet(:,demoLineI,plotRowI));
%                 plot(x(1:find(demoLine(demoLineI,:),1,'last')),demoLine(demoLineI,1:find(demoLine(demoLineI,:),1,'last')),plotLines{1}{demoLineI},'LineWidth',medianLineWidth);
%                 bar(x,demoVert(:,demoLineI),'BarWidth',.05);
%             end
%             set(gca,'XLim',[0 1]);
%             set(gca,'YLim',taskSimYlim);
%             set(gca,'YTickLabel','');
%             set(gca,'Box','on');
%             xlabel('Resources');
%             clear demoCurve demoVert demoLine
%         end
%     end
% end
% 
% H(3) = annotation('textbox',...
%                     annotatPos,...
%                     'String',annotatStr,...
%                     'FontSize',10,...
%                     'FontName','Arial',...
%                     'LineStyle','--',...
%                     'EdgeColor','none',...
%                     'LineWidth',2,...
%                     'BackgroundColor','none',...
%                     'Color','k');
% 
% %% put plots in their allotted positions
% 
% set(gcf, 'Position',figRect);
% 
% set(H(1),'Position',[col1PlotLPos row1PlotBase col1PlotWidth plotHeights]);
% set(H(2),'Position',[col2PlotLPos row1PlotBase col2PlotWidth plotHeights]);
% set(H(3),'Position',annotatPos);
% set(H(4),'Position',[col1PlotLPos row2PlotBase col1PlotWidth plotHeights]);
% set(H(5),'Position',[col2PlotLPos row2PlotBase col2PlotWidth plotHeights]);
% 
% %                 if ~strcmp(simExp,'Exp. 2')
% %                     set(H(7),'Position',[col1PlotLPos row3PlotBase col1PlotWidth plotHeights]);
% %                     set(H(8),'Position',[col2PlotLPos row3PlotBase col2PlotWidth plotHeights]);
% %                     if strcmp(simExp,'Exp. 4b')
% %                         set(H(15),'Position',[col3PlotLPos row3PlotBase col3PlotWidth plotHeights]);
% %                     end
% %                 end
%                 
% 
H = conceptFig;

end

