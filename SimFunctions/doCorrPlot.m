function [figHandle, plotHandles] = doCorrPlot(params,scoreSheet,allocVals,annotatStr)
%do PSM vs PRT plot
%   plot PSM and PRT with correlation coefficient and p-value in chart,
%   paramters in annotation

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
a_3s_sampling  = params.a_3s_sampling; % lower vals of a_s result in less resources for Face Task, more for Memory Task
x_ps_sampling = params.x_ps_sampling; % proportion of face task resource allocation given away under priming, - numbers approaching 1 probably not realistic
x_ls_sampling = params.x_ls_sampling; % proportion of mem task resource allocation given away to face task under load - numbers near 1 again prob not realistic
measErrMu     = params.measErrMu; %measurement error. It's additive so mu = 0 and sigma = 0 for no error
measErrSigma  = params.measErrSigma;
normAllocParams = params.normAllocParams;
fixedAllocs = params.fixedAllocs;
cmap        = params.cmap;

s = [s_1_2 s_1_2 s_3];

if strcmp(simExp,'Exp. 3')|| strcmp(simExp,'Exp. 4b')
    nTasks = 3;
else nTasks = 2;
end

%% adjust position

figH = figure;
set(gcf,'Units','normalized')
set(gcf, 'Name', ['Sampled ' simExp]);

PRT = scoreSheet(:,[1 2],1)*[1 -1]';
PSM = scoreSheet(:,[1 2],2)*[1 -1]';

d = [PRT PSM];

plotH(1) = subplot(121);

hold on
scatter(d(:,1),d(:,2),60,cmap,'filled');
plot(d(:,1),d(:,2),'ok','markersize',12);
grid('on');
box('on');
lsline;

title('PSM vs PRT');
xlabel('PRT');
ylabel('PSM');
xlim([min(d(:,1))-.05*max(d(:,1)) max(d(:,1))+.05*max(d(:,1))]);
ylim([min(d(:,2))-.05*max(d(:,2)) max(d(:,2))+.05*max(d(:,2))]);

[r p] = corr(PRT(:,1),PSM(:,1));

plotH(3) = annotation('textbox',...
        [.7 .7 .15 .15],...% [left bottom width height]
        'String',{sprintf('r = %.3f',r(1));sprintf('p = %.3f',p(1))},...
        'FontSize',10,...
        'FontName','Arial',...
        'LineStyle','--',...
        'EdgeColor','none',...
        'LineWidth',2,...
        'BackgroundColor','none',...
        'Color','k');
    
plotH(4) = annotation('textbox',...
        [.7 .06 .25 .3],...% [left bottom width height]
        'String',annotatStr,...
        'FontSize',10,...
        'FontName','Arial',...
        'LineStyle','--',...
        'EdgeColor','none',...
        'LineWidth',2,...
        'BackgroundColor','none',...
        'Color','k');
    
    set(figH,'position',[.05 .1 .3 .25])
    
    set(plotH(1),'position',[.1 .15 .6 .65])
    set(plotH(3),'position',[.55 .7 .1 .05])
    set(plotH(4),'position',[.75 .2 .25 .6])
    
figHandle = figH;
plotHandles = plotH;

end

