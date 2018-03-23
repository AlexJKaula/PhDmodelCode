function modelFig = doOAFig(params,scoreSheet,allocVals,annotatStr)
%doOAFig creates a figure showing essential features and qualitative score
%pattern of simulation

%   Shows underlying functions relating performance to resources in 2 (Exp.
%   2) or 3 (Exps 3&4) tasks, detailing individual simulations, parameter
%   settings, and actual values sampled

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

if strcmp(simExp,'Exp. 4b')
    nTasks = 3;
else nTasks = 2;
end

%% figure setup
figRect = [.2 .1 .78 .6]; % [bottom left width height]
figCol = [.75 .75 .75];

plotH = .22;

col1L = .1;
col1W = .14;

plotWPad = .05;
plotHPad = .1;

col2L = col1L + col1W;
col2W = col1W/2;

col3L = col2L + col2W + plotWPad;

row3B = .1;
row2B = row3B + plotH + plotHPad;
row1B = row2B + plotH + plotHPad;

corrSpacer = .05;
corrW      = .12;
corrH      = plotH;
corr1L = col2L+col1W/2+corrSpacer;
corr2L = col2L+col1W/2+corrSpacer+corrW;

posns = {
    [col1L row1B col1W plotH]
    [col2L row1B col1W/2 plotH]
    [col3L row1B col1W plotH]
    [corr2L+corrW+.02 row1B col3L+col1W+plotWPad plotH]
    [col1L row2B col1W plotH]
    [col2L row2B col1W/2 plotH]
    [corr1L row2B corrW plotH]
    [corr2L row2B corrW plotH]
    [col1L+col1W/2 row3B col1W/2 plotH]
    [col2L row3B col1W/2 plotH]
    };

subPlotTitleFontSize = 10;
subPlotAxFontSize = 8;
barCols   = {[0 0 255]*.00392;[0 0 150]*.00392;[255 0 0]*.00392;[150 0 0]*.00392};

simPlots = [1 7 13];
demoPlots = [2 8 14];
transRTplot = 3;
corrPlots = [9 10];
annotPlot = 4;

condLabels = {...
    'P'
    'U'
    'PL'
    'UL'
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
    [1 2 3 4]
    [1 2 3 4]
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
plotLines{:,3} = {...
    'b-'
    };

if strcmp(simExp,'Exp. 2')
    dCurves =  {...
        [d_1-prime_lift;d_1;d_1-prime_lift+load_weight;d_1+load_weight];
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
        [1 1 2 2]
        [1 1 1 1]
        [1 1]};
end

primedLineCol = 'c'; %these for individual subject lines
negPrimedLineCol = [.7 .7 .7]';
medianLineWidth = 1.25; %these for subject plots mean mark lines
medianLineColour = {'b';'b';'r';'r'};
x = .01:.01:1;
lineBlank = zeros(1,length(x));

simVarTitle = {...
    'Individual simulation'
    'variable vals'
    };
simVarPlotBoxCol = [.3 .3 .3];
simVarPlotBoxLineWidth = 1.5;
scatterCols = {...
    'b'
    'b'
    'r'
    'r'
    };

simVarPlotXticks = {...
    'R_s'
    'a_s'
    'a_3s'
    'xp_s'
    'xl_s'
    };

subPlotGrid = reshape(1:nTasks*6,[6,nTasks])';

%% make figure

modelFig = figure;
set(gcf,'Units','normalized')
set(gcf,'color',[.75 .75 .75]);
set(gcf, 'Name', ['Sampled ' simExp]);

for plotRowI = 1:nTasks
    for plotColI = 1:6
        
        plotNum = subPlotGrid(plotRowI,plotColI);
        
        if ismember(plotNum,simPlots)
            H(plotNum) = subplot(nTasks,6,plotNum);
            hold on
            title({[taskNames{plotRowI} ' Task'];'Simulation'},'FontSize',subPlotTitleFontSize);
            d = scoreSheet(:,:,plotRowI);
            d(:,isnan(sum(d))) = [];
            xs = zeros(size(d));
            for xsi = 1:size(d,2)
                xs(:,xsi) = xsi;
            end
            boxplot(d,condLabels(1:size(d,2)),'Colors','bbrr','Notch','on');
            set(findobj(gca,'Tag','Median'),'Color',[0 0 0],'LineWidth',2);
            xTxt = findobj(gca,'Type','text');
            set(xTxt,'FontSize',subPlotAxFontSize);
            
            for plotI = 1:size(d,2)
                plot(xs(:,plotI),d(:,plotI),'Color',barCols{plotI},'Marker','.','LineStyle','none')
            end
            
            for lineI = 1:nSims
                if scoreSheet(lineI,1,plotRowI) > scoreSheet(lineI,2,plotRowI)
                    line([1 2],scoreSheet(lineI,[1 2],plotRowI),'Color',primedLineCol)
                else
                    line([1 2],scoreSheet(lineI,[1 2],plotRowI),'Color',negPrimedLineCol)
                end
                
                if scoreSheet(lineI,3,plotRowI) > scoreSheet(lineI,4,plotRowI)
                    line([3 4],scoreSheet(lineI,[3 4],plotRowI),'Color',primedLineCol)
                else
                    line([3 4],scoreSheet(lineI,[3 4],plotRowI),'Color',negPrimedLineCol)
                end
            end
            
            line([.7 5],[median(scoreSheet(:,1,plotRowI)) median(scoreSheet(:,1,plotRowI))],'Color',medianLineColour{1},'LineStyle','--','LineWidth',medianLineWidth);
            line([1.7 5],[median(scoreSheet(:,2,plotRowI)) median(scoreSheet(:,2,plotRowI))],'Color',medianLineColour{2},'LineStyle','-','LineWidth',medianLineWidth)
            line([2.7 5],[median(scoreSheet(:,3,plotRowI)) median(scoreSheet(:,3,plotRowI))],'Color',medianLineColour{3},'LineStyle','--','LineWidth',medianLineWidth)
            line([3.7 5],[median(scoreSheet(:,4,plotRowI)) median(scoreSheet(:,4,plotRowI))],'Color',medianLineColour{4},'LineStyle','-','LineWidth',medianLineWidth)
            
            ylim([0 1]);
            taskSimYlim = get(gca,'YLim');
            set(gca,'FontSize',subPlotAxFontSize);
            set(gca,'Xtick',[1 2 3 4]);
            
        elseif ismember(plotNum,demoPlots) && ~(strcmp(simExp,'Exp. 3')&& plotRowI==3)
            
            H(plotNum) = subplot(nTasks,6,plotNum);
            demoVert = repmat(lineBlank,[length(dvConds{plotRowI}) 1])';
            demoLine = repmat(lineBlank,[length(dvConds{plotRowI}) 1]);
            hold on
            for demoCurveI = 1:length(dCurves{plotRowI})
                demoCurve(:,demoCurveI) = 1./(1+exp(-(x-dCurves{plotRowI}(demoCurveI))/s(plotRowI)));
                plot(x,demoCurve(:,demoCurveI),plotLines{plotRowI}{demoCurveI});
            end
            for demoLineI = dvConds{plotRowI}
                demoLine(demoLineI,1:find(demoCurve(:,curveToPlotOn{plotRowI}(demoLineI))>median(scoreSheet(:,demoLineI,plotRowI)))) = median(scoreSheet(:,demoLineI,plotRowI));
                demoVert(find(demoLine(demoLineI,:),1,'last'),demoLineI) = median(scoreSheet(:,demoLineI,plotRowI));
                plot(x(1:find(demoLine(demoLineI,:),1,'last')),demoLine(demoLineI,1:find(demoLine(demoLineI,:),1,'last')),plotLines{1}{demoLineI},'LineWidth',medianLineWidth);
                bar(x,demoVert(:,demoLineI),'BarWidth',.05);
            end
            set(gca,'XLim',[0 1]);
            set(gca,'YLim',taskSimYlim);
            set(gca,'YTickLabel','')
            set(gca,'Box','on');
            xlabel('Resources','FontSize',subPlotAxFontSize);
            
            clear demoCurve demoVert demoLine
            
        elseif plotNum == transRTplot
            
            H(plotNum) = subplot(nTasks,6,plotNum);
            hold on
            title({[taskNames{plotRowI} ' Task'];'Simulation'},'FontSize',subPlotTitleFontSize);
            d = scoreSheet(:,:,plotRowI);
            d(:,isnan(sum(d))) = [];
            d = (1-d)*1000 +300;
            xs = zeros(size(d));
            for xsi = 1:size(d,2)
                xs(:,xsi) = xsi;
            end
            boxplot(d,condLabels(1:size(d,2)),'Colors','bbrr','Notch','on');
            set(findobj(gca,'Tag','Median'),'Color',[0 0 0],'LineWidth',2);
            xTxt = findobj(gca,'Type','text');
            set(xTxt,'FontSize',subPlotAxFontSize);
            
            for plotI = 1:size(d,2)
                plot(xs(:,plotI),d(:,plotI),'Color',barCols{plotI},'Marker','.','LineStyle','none')
            end
            
            for lineI = 1:nSims
                if d(lineI,1) < d(lineI,2)
                    line([1 2],d(lineI,[1 2]),'Color',primedLineCol)
                else
                    line([1 2],d(lineI,[1 2]),'Color',negPrimedLineCol)
                end
                
                if d(lineI,3) < d(lineI,4)
                    line([3 4],d(lineI,[3 4]),'Color',primedLineCol)
                else
                    line([3 4],d(lineI,[3 4]),'Color',negPrimedLineCol)
                end
            end
            
            taskSimYlim = get(gca,'YLim');
            set(gca,'FontSize',subPlotAxFontSize);
            set(gca,'Xtick',[1 2 3 4]);
            ylabel('1/RT');
            
            for plotI = 1:size(d,2)
                plot(xs(:,plotI),d(:,plotI),'Color',scatterCols{plotI},'Marker','.','LineStyle','none')
            end
            
            
        elseif ismember(plotNum,corrPlots)
            
            H(plotNum) = subplot(nTasks,6,plotNum);
            
            if plotNum == corrPlots(1)
                PRT = scoreSheet(:,[1 2],1)*[1 -1]';
                PSM = scoreSheet(:,[1 2],2)*[1 -1]';
                noLylims = [min(PSM)*.95 max(PSM)*1.05];
                noLxlims = [min(PRT)*.95 max(PRT)*1.05];
                mCol = 'b.';
                title('Low Load');
                xlabel('PRT');
                ylabel('PSM');
                texPos = [corr1L+corrW*.02 row2B+corrH*.3 corrW*.96 corrH*.6];
            else
                PRT = scoreSheet(:,[3 4],1)*[1 -1]';
                PSM = scoreSheet(:,[3 4],2)*[1 -1]';
                Lylims = [min(PSM)*.95 max(PSM)*1.05];
                Lxlims = [min(PRT)*.95 max(PRT)*1.05];
                mCol = 'r.';
                title('High Load');
                xlabel('PRT');
                texPos = [corr2L+corrW*.02 row2B+corrH*.3 corrW*.96 corrH*.6];
            end
            
            d = [PRT PSM];
            
            hold on
            plot(d(:,1),d(:,2),mCol);
            grid('on');
            box('on');
            lsline;
            
            if plotNum == corrPlots(2)
                H(corrPlots(1)).YLim = ([min(noLylims(1),Lylims(1)) max(noLylims(2),Lylims(2))]);
                H(corrPlots(2)).YLim = ([min(noLylims(1),Lylims(1)) max(noLylims(2),Lylims(2))]);
                H(corrPlots(1)).XLim = ([noLxlims(1) noLxlims(2)]);
                H(corrPlots(2)).XLim = ([Lxlims(1) Lxlims(2)]);
                H(corrPlots(2)).YTickLabel = {};
            end
            
            
            [r, p] = corr(PRT(:,1),PSM(:,1));
            
            annotation('textbox',...
                texPos,...% [left bottom width height]
                'String',{sprintf('r = %.3f',r(1));sprintf('p = %.3f',p(1))},...
                'FontSize',10,...
                'FontName','Arial',...
                'LineStyle','--',...
                'EdgeColor','none',...
                'LineWidth',2,...
                'BackgroundColor','none',...
                'Color','k');
            
        end
    end
    set(gca,'FontSize',plotAxFontSize)
end

H(4) = annotation('textbox',...
    posns{4},...
    'String',annotatStr,...
    'FontSize',10,...
    'FontName','Arial',...
    'LineStyle','--',...
    'EdgeColor','none',...
    'LineWidth',2,...
    'BackgroundColor','none',...
    'Color','k');

%% put plots in their allotted positions

set(gcf, 'Position',figRect);
counter = 0;
for plotNum = 1:max(subPlotGrid(:))
    if ismember(plotNum,[simPlots demoPlots transRTplot corrPlots annotPlot])
        counter = counter+1;
        H(plotNum).Position = posns{counter};
    end
end

%%

end

