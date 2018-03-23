%% Simulate 3 different behavioural experiments from PhD project to date

% 3 experiments all show priming effects on RTs (PRT) and on subsequent associative memory (PSM)
% we model the 3 experiments where performance depends on resources via a sigmoidal
% function, the shape and position of which is determined by sharpness
% parameter s, and difficulty parameter d.

%% Exp. 2,3,4 model summary

%  priming effects on subsequent memory are the result of resources freed
%  from face task by change in d from du to dp (d unprimed to primed),
%  which translates resource-performance function in x.

% The form of such a sigmoid could be:
% perf = 1/(1+e^-(r-d)/s)

% initial, pre-priming performance is set by allocation of resources
% between tasks 1 (pleasantness face) and 2 (memorisation of
% association), according to value of variable a_s (where s is for
% subject), such that participant's resources R_s ~N(1,sigma) will be
% distributed as (subject task 1 resources) r_s1 = a_s*R_s and r_s2 =
% (1-a_s)*R_s

% Priming is then modelled as changing the difficulty variable, d_1, of
% task 1 by some amount, meaning less resources required for same
% performance (i.e. these could be 'freed'), and/or performance improves.
% Simulation assumes limit of resources give-away is change in d_1, as more
% than this would produce performance decline, which is not observed.

% Given that performance in the face task does improve, we assume that
% resources 'freed' in this way are not *all* given over to performance
% of the memorisation task. We assume that some proportion of the resources
% allocated to the face task will be reallocated to the memory
% task, task 2. This proportion is the variable 0<x<1.

% The opposite assumption is made in the case of perceptual load: difficulty
% variable d for the face task is increased, and some proportion (0<y<1) of
% the memory task's allocation is given to the face task.

%% implementation

% There is a sharpness variable, which we can't measure. We fix a value
% and apply it to both tasks.

% we choose some arbitrary values for the difficulty of the face
% task and for memory task, and also how
% much the effect of load and priming will be on face task
clear

%%

addpath('U:\PhD\AK_Shared\Model_and_Fig_Code\Simulation\SimFunctions')
addpath('U:\PhD\AK_Shared\Model_and_Fig_Code\Simulation\SimFunctions\figFuncs')
addpath('/Users/Alex/ownCloud/AK_SharedCloud/Simulation/SimFunctions')
addpath('/Users/Alex/ownCloud/AK_SharedCloud/Simulation/SimFunctions/figFuncs')

%%

figDir = '/Users/Alex/ownCloud/AK_SharedCloud/Simulation/figOutputs';

%%

% addpath('/Users/Alex/ownCloud/AK_SharedCloud/Simulation/SimFunctions')
% addpath('/Users/Alex/ownCloud/AK_SharedCloud/Simulation/SimFunctions/figFuncs')

%%


params.nSims = 32; % N of particpants to simulate

simExps = {'Exp. 2';'Exp. 3';'Exp. 4b'};
params.simExp = simExps{1}; % set your exp to model

params.s_1_2 = .15; % tweak this to find sigmoids (see figures in Chapter 4 for settings)
params.s_3   = .05; % secondary task sigmoid sharpness
params.d_1   = .35; % face task baseline difficulty
params.d_2   = .35; % memory task difficulty
params.d_3   = .25;

params.prime_lift = .1; % how much does priming affect task 1 difficulty?

% how load_weight functions depends on which experiment we're modelling...
% is either a rightward shift of face task curve (Exp. 2), or an amount of resources
% taken from those allocated to face and mem tasks (Exps 3 & 4).
params.load_weight = .2;

params.distribTypes = {'normal';'uniform';'fixed'}; %possible allocation schemes, sample from normal or uniform dist, or choose a fixed value
params.R_s_sampling = params.distribTypes(1);
params.a_s_sampling = params.distribTypes(1); % lower vals of a_s result in less resources for Face Task, more for Memory Task
params.a_3s_sampling = params.distribTypes(3); %
params.x_ps_sampling = params.distribTypes(3); % proportion of face task resource allocation given away under priming, - numbers approaching 1 probably not realistic
params.x_ls_sampling = params.distribTypes(3); % proportion of mem task resource allocation given away to face task under load - numbers near 1 again prob not realistic
params.x_p2s_sampling = params.distribTypes(3); % proportion of mem task resource allocation given away to face task under load - numbers near 1 again prob not realistic

params.measErrMu = 0; %measurement error. It's additive so mu = 0 and sigma = 0 for no error
params.measErrSigma = 0;

params.normAllocParams = [% mu, sigma if using norm distribution of relevant variable
    .75 .1; % R_s
    .6 .4; % a_s
    .3 .1; % a_3s
    .5 .25; % xp_s
    .5 .25;% xl_s
    .5 .25];% xp2_s

params.fixedAllocs = [
    1;  % R_s
    .35; % a_s, proportion of R_s given to face task
    .35;% a_3s, proportion of R_s given to load task, taken in some proportions...
    .5; % x_ps, proportion of available Face Task resources to give away to mem in primed trials
    .65;% x_ls, proportion of load demand to get from Memory Task
    1]; % x_p2s, proportion of available Face Task resources to give away to mem in primed trials

% fig colormap
params.cmap = colormap(jet(params.nSims));

%% run simulation with params above

[scoreSheet, allocVals, resourceVals, annotatStr] = doSim(params);

%% Main figure

   mainFig = doOAFig(params,scoreSheet,allocVals,annotatStr); % mainFig is figure handle

%% Chapter sim figs...
% whichFig vals to try: 'corr demo', 'res perf function', 'interaction concept', 'priming example'
whichFig = 'priming example';
conceptFig = doChap3ConceptFigs(params,scoreSheet,allocVals,annotatStr,whichFig);

%% Do correlation fig(s)

[corrFig, corrPlot] = doCorrPlot(params,scoreSheet,allocVals,annotatStr);
