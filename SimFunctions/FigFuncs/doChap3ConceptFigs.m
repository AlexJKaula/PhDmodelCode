function [conceptFig] = doChap3ConceptFigs(params,scoreSheet,allocVals,annotatStr,whichFig)
%just do sim plots and attotate with settings

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
cmap = params.cmap;

s = [s_1_2 s_1_2 s_3];

switch simExp
    case {'Exp. 3';'Exp. 4b'}
        nTasks = 3;
    case 'Exp. 2'
        nTasks = 2;
end


%% general figures setup
figCount = 0;
subPlotTitleFontSize = 10;
subPlotAxFontSize = 8;
barCols   = {[0 0 255]*.00392;[0 0 255]*.00392;[255 0 0]*.00392;[255 0 0]*.00392};

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

dvConds = {...
    [1 2]
    [1 2]
    [1 2]
    };

plotLines{:,1} = {...
    'b--'
    'b-'
    'r--'
    'r-'
    };
plotLines{:,2} = {...
    'b-'
    };

dCurves =  {...
    %[d_1;(d_1-prime_lift);d_1+load_weight;d_1-prime_lift+load_weight];
    [(d_1-prime_lift);d_1];
    d_2;
    d_3;
    };
curveToPlotOn = {...
    [1 2 3 4]
    [1 1 1 1]};


primedLineCol = 'c'; %these for individual subject lines
negPrimedLineCol = [.65 .65 .65];
medianLineWidth = 1.25; %these for subject plots mean mark lines
medianLineColour = {'b';'b';'r';'r'};
medianLineStyle = {'--';'-';'--';'-'};

x = .01:.001:1;
lineBlank = zeros(1,length(x));

switch whichFig
    
    case 'res perf function'
        %% make fig. 1, hypothetical resource-performance function
        
        figCount = figCount + 1;
        conceptFigs(figCount) = figure;
        set(gcf,'Units','normalized')
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
        legend(['d = ' num2str(d_1)],['d = ' num2str(d_1-prime_lift)],'Location','SouthEast');
        legend('boxon');
        ylabel('Performance');
        xlabel('Resources');
        clear demoCurve demoVert demoLine
        
    case 'interaction concept'
        %% do interaction concept illustration figure:
        
        figCount = figCount + 1;
        conceptFigs(figCount) = figure;
        figRect = [.1 .1 .7 .6];
        set(gcf,'Units','normalized');
        set(gcf, 'Position',figRect);
        
        col1PlotLPos = .1; col2PlotLPos = .225;
        col1PlotWidth = .125; col2PlotWidth = .25;
        
        row1PlotBase = .4;
        plotHeights = .4;
        
        annotatPos = [.55 .3 .35 .6];
        
        for plotI = 1:2
            
            conceptPlot(plotI) = subplot(2,2,plotI);
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
                set(gca,'ytick',[0 .5 1])
                ylabel('Performance');
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
                    bar(x,demoVert(:,demoLineI),'BarWidth',.025);
                end
                set(gca,'XLim',[0 1]);
                set(gca,'YLim',[0 1]);
                set(gca,'YTickLabel','');
                set(gca,'Box','on');
                xlabel('Resources');
                hold off
            end
            
        end
        
        annotation('textbox',...
            annotatPos,...
            'String',annotatStr,...
            'FontSize',10,...
            'FontName','Arial',...
            'LineStyle','--',...
            'EdgeColor','none',...
            'LineWidth',2,...
            'BackgroundColor','none',...
            'Color','k');
        
        set(conceptPlot(1),'Position',[col1PlotLPos row1PlotBase col1PlotWidth plotHeights]);
        set(conceptPlot(2),'Position',[col2PlotLPos row1PlotBase col2PlotWidth plotHeights]);
        
    case {'priming example';'corr demo'}
        
        switch whichFig
            case 'priming example'
                %% do priming example fig
                
                figCount = figCount + 1;
                conceptFig(figCount) = figure;
                set(gcf,'Units','normalized')
                set(gcf,'color',[.75 .75 .75]);
                set(gcf, 'Name', ['Sampled ' simExp]);
                
                col1PlotLPos = .1; col2PlotLPos = .2;
                col1PlotWidth = .1; col2PlotWidth = .2;
                
                row1PlotBase = .6;
                row2PlotBase = .15;
                plotHeights = .3;
                
                annotatPos = [.6 .3 .35 .4];
                
                subPlotGrid = [1 2 3; 4 5 6];
                simPlots = [1 4];
                demoPlots = [2 5];
                
                for plotRowI = 1:2
                    for plotColI = 1:3
                        
                        plotNum = subPlotGrid(plotRowI,plotColI);
                        if ismember(plotNum,simPlots)
                            conceptPlots(plotNum) = subplot(nTasks,3,plotNum);
                            hold on
                            title({[taskNames{plotRowI} ' Task'];'Simulation'},'FontSize',subPlotTitleFontSize);
                            d = scoreSheet(:,[1 2],plotRowI);
                            d(:,isnan(sum(d))) = [];
                            xs = zeros(size(d));
                            for xsi = 1:size(d,2)
                                xs(:,xsi) = xsi;
                            end
                            
                            for plotI = 1:size(d,2)
                                scatter(xs(:,plotI),d(:,plotI),6,cmap,'filled');
                                plot(xs(:,plotI),d(:,plotI),'ok','markersize',8);
                            end
                            
                            
                            for lineI = 1:nSims
                                if scoreSheet(lineI,1,plotRowI) > scoreSheet(lineI,2,plotRowI)
                                    line([1 2],scoreSheet(lineI,[1 2],plotRowI),'Color',cmap(lineI,:))
                                else
                                    line([1 2],scoreSheet(lineI,[1 2],plotRowI),'Color',cmap(lineI,:))
                                end
                            end
                            
                            line([.7 5],[median(scoreSheet(:,1,plotRowI)) median(scoreSheet(:,1,plotRowI))],'Color',medianLineColour{1},'LineStyle',medianLineStyle{1},'LineWidth',medianLineWidth);
                            line([1.7 5],[median(scoreSheet(:,2,plotRowI)) median(scoreSheet(:,2,plotRowI))],'Color',medianLineColour{2},'LineStyle',medianLineStyle{2},'LineWidth',medianLineWidth)
                            
                            boxplot(d,condLabels(1:size(d,2)),'Colors','bbrr','Notch','on');
                            set(findobj(gca,'Tag','Median'),'Color',[0 0 0],'LineWidth',2);
                            xTxt = findobj(gca,'Type','text');
                            set(xTxt,'FontSize',subPlotAxFontSize);
                            
                            
                            ylim([0 1]);
                            taskSimYlim = get(gca,'YLim');
                            set(gca,'XTick',[1 2]);
                            set(gca,'FontSize',subPlotAxFontSize);
                            ylabel('Performance');
                            
                        elseif ismember(plotNum,demoPlots)
                            
                            conceptPlots(plotNum) = subplot(nTasks,3,plotNum);
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
                            set(gca,'YTickLabel','');
                            set(gca,'Box','on');
                            xlabel('Resources');
                            %             if plotNum ==2
                            %             legend('Primed','Unprimed','Location','SouthEast');
                            %             end
                            title({'Resources vs'; 'performance'});
                            clear demoCurve demoVert demoLine
                        end
                    end
                end
                
                conceptPlots(3) = annotation('textbox',...
                    annotatPos,...
                    'String',annotatStr,...
                    'FontSize',10,...
                    'FontName','Arial',...
                    'LineStyle','--',...
                    'EdgeColor','none',...
                    'LineWidth',2,...
                    'BackgroundColor','none',...
                    'Color','k');
                
                %% put plots in their allotted positions
                
                figRect = [.4 .1 .48 .5]; % [bottom left width height]
                
                
                col1PlotLPos = .1; col2PlotLPos = .25; col3PlotLPos = .4;
                col1PlotWidth = .15; col2PlotWidth = .15; col3PlotWidth = .1;
                
                row1PlotBase = .6;
                row2PlotBase = .1;
                plotHeights = .28;
                set(gcf, 'Position',figRect);
                
                set(conceptPlots(1),'Position',[col1PlotLPos row1PlotBase col1PlotWidth plotHeights]);
                set(conceptPlots(2),'Position',[col2PlotLPos row1PlotBase col2PlotWidth plotHeights]);
                set(conceptPlots(3),'Position',annotatPos);
                set(conceptPlots(4),'Position',[col1PlotLPos row2PlotBase col1PlotWidth plotHeights]);
                set(conceptPlots(5),'Position',[col2PlotLPos row2PlotBase col2PlotWidth plotHeights]);
                
                %                 if ~strcmp(simExp,'Exp. 2')
                %                     set(H(7),'Position',[col1PlotLPos row3PlotBase col1PlotWidth plotHeights]);
                %                     set(H(8),'Position',[col2PlotLPos row3PlotBase col2PlotWidth plotHeights]);
                %                     if strcmp(simExp,'Exp. 4b')
                %                         set(H(15),'Position',[col3PlotLPos row3PlotBase col3PlotWidth plotHeights]);
                %                     end
                %                 end
            case 'corr demo'
                %%
                figCount = figCount + 1;
                conceptFig(figCount) = figure;
                set(gcf,'Units','normalized')
                set(gcf,'color',[.75 .75 .75]);
                set(gcf, 'Name', ['Sampled ' simExp]);
                
                figRect = [.05 .1 .7 .3]; % [bottom left width height]
                colPad = .005;
                corrPad = .062;
                rowBase = .25;
                rowBase2 = .285;
                simW    = .1;
                funcsW  = .1;
                corrW = .18;
                annotW = .15;
                plotH = .5;
                corrPlotH = plotH - (rowBase2-rowBase);
                
                col1L = .1;
                col2L = col1L + simW;
                col3L = col2L + funcsW +colPad;
                col4L = col3L + simW;
                col5L = col4L + funcsW + corrPad;
                annotL = col5L + corrW + .05;
                simPlots = [1 3];
                demoPlots = [2 4];
                corrPlot = 5;
                
                for plotI = 1:5
                    
                    if sum(plotI == [1 2])
                        taskI = 1;
                    else
                        taskI = 2;
                    end
                    
                    if ismember(plotI,simPlots)
                        conceptPlots(plotI) = subplot(nTasks,6,plotI);
                        hold on
                        
                        d = scoreSheet(:,[1 2],taskI);
                        
                        d(:,isnan(sum(d))) = [];
                        xs = zeros(size(d));
                        for xsi = 1:size(d,2)
                            xs(:,xsi) = xsi;
                        end
                        
                        for condI = 1:size(d,2)
                            scatter(xs(:,condI),d(:,condI),6,cmap,'filled');
                            plot(xs(:,condI),d(:,condI),'ok','markersize',8);
                        end
                        
                        for lineI = 1:nSims
                            if d(lineI,1) > d(lineI,2)
                                line([1 2],d(lineI,[1 2]),'Color',cmap(lineI,:))
                            else
                                line([1 2],d(lineI,[1 2]),'Color',cmap(lineI,:))
                            end
                        end
                        
                        line([.7 5],[median(d(:,1)) median(d(:,1))],'Color',medianLineColour{1},'LineStyle',medianLineStyle{1},'LineWidth',medianLineWidth);
                        line([1.7 5],[median(d(:,2)) median(d(:,2))],'Color',medianLineColour{2},'LineStyle',medianLineStyle{2},'LineWidth',medianLineWidth)
                        
                        boxplot(d,condLabels(1:size(d,2)),'Colors','bbrr','Notch','on');
                        set(findobj(gca,'Tag','Median'),'Color',[0 0 0],'LineWidth',2);
                        xTxt = findobj(gca,'Type','text');
                        set(xTxt,'FontSize',subPlotAxFontSize);
                        
                        ylim([0 1]);
                        taskSimYlim = get(gca,'YLim');
                        set(gca,'XTick',[1 2]);
                        set(gca,'xticklabel','');
                        set(gca,'FontSize',subPlotAxFontSize);
                        if taskI ==1
                        ylabel('Performance');
                        else
                            set(gca,'yticklabel','');
                        end
                    elseif ismember(plotI,demoPlots)
                        
                        conceptPlots(plotI) = subplot(1,6,plotI);
                        demoVert = repmat(lineBlank,[length(dvConds{taskI}) 1])';
                        demoLine = repmat(lineBlank,[length(dvConds{taskI}) 1]);
                        hold on
                        for demoCurveI = 1:length(dCurves{taskI})
                            demoCurve(:,demoCurveI) = 1./(1+exp(-(x-dCurves{taskI}(demoCurveI))/s(taskI)));
                            plot(x,demoCurve(:,demoCurveI),plotLines{taskI}{demoCurveI});
                        end
                        for demoLineI = dvConds{taskI}
                            demoLine(demoLineI,1:find(demoCurve(:,curveToPlotOn{taskI}(demoLineI))>median(scoreSheet(:,demoLineI,taskI)))) = median(scoreSheet(:,demoLineI,taskI));
                            demoVert(find(demoLine(demoLineI,:),1,'last'),demoLineI) = median(scoreSheet(:,demoLineI,taskI));
                            plot(x(1:find(demoLine(demoLineI,:),1,'last')),demoLine(demoLineI,1:find(demoLine(demoLineI,:),1,'last')),plotLines{1}{demoLineI},'LineWidth',medianLineWidth);
                            bar(x,demoVert(:,demoLineI),'BarWidth',.05);
                        end
                        set(gca,'XLim',[0 1]);
                        set(gca,'YLim',taskSimYlim);
                        set(gca,'YTickLabel','');
                        set(gca,'xticklabel','');
                        set(gca,'Box','on');
                        set(gca,'FontSize',subPlotAxFontSize);
                        clear demoCurve demoVert demoLine
                        
                    elseif ismember(plotI,corrPlot)
                        conceptPlots(plotI) = subplot(1,6,plotI);
                        
                        PRT = scoreSheet(:,[1 2],1)*[1 -1]';
                        PSM = scoreSheet(:,[1 2],2)*[1 -1]';
                        
                        d = [PRT PSM];
                        hold on
                        scatter(d(:,1),d(:,2),60,cmap,'filled');
                        plot(d(:,1),d(:,2),'ok','markersize',12);
                        grid('on');
                        box('on');
                        lsline;
                        
                        set(gca,'FontSize',subPlotAxFontSize);
                        ylabel('PSM');
                        xlim([min(d(:,1))-.05*max(d(:,1)) max(d(:,1))+.05*max(d(:,1))]);
                        ylim([min(d(:,2))-.05*max(d(:,2)) max(d(:,2))+.05*max(d(:,2))]);
                        
                        [r, p] = corr(PRT(:,1),PSM(:,1));
                        
                        annotation('textbox',...
                            [col5L+.05*corrW rowBase+.7*plotH corrW*.9 plotH*.25],...% [left bottom width height]
                            'String',{sprintf('r = %.3f',r);sprintf('p = %.3f',p)},...
                            'FontSize',10,...
                            'FontName','Arial',...
                            'LineStyle','--',...
                            'EdgeColor','none',...
                            'LineWidth',2,...
                            'BackgroundColor','none',...
                            'Color','k');
                        
                    end
                end
                
                conceptPlots(6) = annotation('textbox',...
                    'String',annotatStr,...
                    'FontSize',8,...
                    'FontName','Arial',...
                    'LineStyle','--',...
                    'EdgeColor','none',...
                    'LineWidth',2,...
                    'BackgroundColor','none',...
                    'Color','k');
                
                set(gcf, 'Position',figRect);
                
                set(conceptPlots(1),'Position',[col1L rowBase simW plotH]);
                set(conceptPlots(2),'Position',[col2L rowBase funcsW plotH]);
                set(conceptPlots(4),'Position',[col4L rowBase funcsW plotH]);
                set(conceptPlots(5),'Position',[col5L rowBase2 corrW corrPlotH]);
                set(conceptPlots(6),'Position',[annotL .35 annotW plotH]);
                set(conceptPlots(3),'Position',[col3L rowBase simW plotH]);
                
                
        end
end

end

