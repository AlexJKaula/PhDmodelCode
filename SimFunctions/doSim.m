function [scoreSheet, allocVals, resourceVals, annotatStr] = doSim(params)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

nSims = params.nSims; % N of particpants to simulate
simExp = params.simExp;
s_1_2 = params.s_1_2; % tweak this to find sigmoids we like
s_3   = params.s_3;
d_1   = params.d_1; % face task baseline difficulty
d_2   = params.d_2; % memory task difficulty
d_3   = params.d_3;
prime_lift = params.prime_lift;
load_weight = params.load_weight; 
% sampling method for each of the main parameters (1-3), randomly from
% normal dist (1), or uniform dist (2), or a fixed value
distribTypes = params.distribTypes;
R_s_sampling = params.R_s_sampling; % 
a_s_sampling = params.a_s_sampling; % lower vals of a_s result in less resources for Face Task, more for Memory Task
a_3s_sampling = params.a_3s_sampling; % lower vals of a_s3 result in less resources for Load Task, more for Face & Memory Tasks
x_ps_sampling = params.x_ps_sampling; % proportion of face task resource allocation given away under priming, - numbers approaching 1 probably not realistic
x_ls_sampling = params.x_ls_sampling; % proportion of mem task resource allocation given away to face task under load - numbers near 1 again prob not realistic
measErrMu = params.measErrMu; %measurement error. It's additive so mu = 0 and sigma = 0 for no error
measErrSigma = params.measErrSigma;
normAllocParams = params.normAllocParams;
fixedAllocs = params.fixedAllocs;

% scores: Priming (P then N) rotate fastest, Load (Lo then Hi) slow
scoreSheet  = NaN(nSims,4,3);
allocVals  = NaN(nSims,5); %keep a record of params used to generate each sim's performance
resourceVals = NaN(nSims,4,3);


%%
for simI = 1:nSims
    
    %% set up allocation vars
    
    if strcmp(R_s_sampling,'uniform')
       R_s = rand;
    elseif strcmp(R_s_sampling,'normal')
        R_s = normrnd(normAllocParams(1,1),normAllocParams(1,2));
    elseif strcmp(R_s_sampling,'fixed')
        R_s = fixedAllocs(1);
    end
    
    % create this sim's allocation: novel allocation, a, and freed (by priming)
    % reallocation parameter, x.
    
    if strcmp(a_s_sampling,'uniform')
       a_s = rand;
    elseif strcmp(a_s_sampling,'normal')
        a_s = normrnd(normAllocParams(2,1),normAllocParams(2,2));
    elseif strcmp(a_s_sampling,'fixed')
        a_s = fixedAllocs(2);
    end
    
    if strcmp(a_3s_sampling,'uniform')
       a_3s = rand;
    elseif strcmp(a_3s_sampling,'normal')
        a_3s = normrnd(normAllocParams(3,1),normAllocParams(3,2));
    elseif strcmp(a_3s_sampling,'fixed')
        a_3s = fixedAllocs(3);
    end
    
    if strcmp(x_ps_sampling,'uniform')
        x_ps = rand;
    elseif strcmp(x_ps_sampling,'normal')
        x_ps = normrnd(normAllocParams(4,1),normAllocParams(4,2));
    elseif strcmp(x_ps_sampling,'fixed')
        x_ps = fixedAllocs(4);
    end
    
    % then choose how much the load task will take up to an amount that
    % would keep performance in RT task constant
    
    if strcmp(x_ls_sampling,'uniform')
        x_ls = rand;
    elseif strcmp(x_ls_sampling,'normal')
        x_ls = normrnd(normAllocParams(5,1),normAllocParams(5,2));
    elseif strcmp(x_ls_sampling,'fixed')
        x_ls = fixedAllocs(5);
    end
    
   
    RTmeasErrs = normrnd(measErrMu,measErrSigma,1,4);
    SMmeasErrs = normrnd(measErrMu,measErrSigma,1,4);
    loadMeasErrs = normrnd(measErrMu,measErrSigma,1,2);
   
    %% Now build up scores:
    
    switch simExp
        
        case 'Exp. 2'
           
        r_1s    = a_s*R_s; % basic allocation
        theseRT_scores(1,2) = 1/(1+exp(-(r_1s-d_1)*s_1_2^-1)); %unprimed no load performance
        
        r_1ps  = a_s*R_s-x_ps*prime_lift; %primed allocation
        theseRT_scores(1,1) = 1/(1+exp(-(r_1ps-(d_1-prime_lift))*s_1_2^-1)); %primed no load
        
        % now Memory task, novel then primed:
        
        % resources
        r_2s  = R_s-r_1s;
        r_2ps  = R_s-r_1ps;
        
        theseSM_scores(1,2) = 1/(1+exp(-(r_2s-d_2)*s_1_2^-1));
        theseSM_scores(1,1) = 1/(1+exp(-(r_2ps-d_2)*s_1_2^-1));
        
        %% now we add perceptual load. This affects difficulty of face task by some fixed amount, load_weight
        % otherwise process above unchanged
        
        r_1ls = a_s * R_s + x_ls * load_weight; % original allocation plus proportion of mem resources
        r_1pls = a_s*R_s - x_ps*prime_lift + x_ls * load_weight; 
        
        theseRT_scores(1,4) = 1/(1+exp(-(r_1ls-(d_1+load_weight))*s_1_2^-1));
        theseRT_scores(1,3) =  1/(1+exp(-(r_1pls-((d_1-prime_lift)+load_weight))*s_1_2^-1));
        
        r_2ls = (1-a_s)*R_s - x_ls*load_weight;
        r_2pls = (1-a_s)*R_s+x_ps*prime_lift - x_ls * load_weight;
        
        theseSM_scores(1,4) =  1/(1+exp(-(r_2ls-(d_2))*s_1_2^-1));
        theseSM_scores(1,3) =  1/(1+exp(-(r_2pls-(d_2))*s_1_2^-1));
        
        scoreSheet(simI,:,1) = theseRT_scores + RTmeasErrs;
        scoreSheet(simI,:,2) = theseSM_scores + SMmeasErrs;
        
        % record r, a, xp, xh parameters in matrix
        
        allocVals(simI,1:5) = [R_s a_s NaN x_ps x_ls];
        resourceVals(simI,1:4,1) = [r_1ps r_1s r_1pls r_1ls];
        resourceVals(simI,1:4,2) = [r_2ps r_2s r_2pls r_2ls];
        
        case 'Exp. 3' %low WM-load task, no DV
        
        r_1s    = a_s*R_s; % basic allocation
        r_1ps  = a_s*R_s-x_ps*prime_lift; %primed allocation
        
        theseRT_scores(1,2) = 1/(1+exp(-(r_1s-d_1)*s_1_2^-1)); %unprimed no load performance
        theseRT_scores(1,1) = 1/(1+exp(-(r_1ps-(d_1-prime_lift))*s_1_2^-1)); %primed no load
        
        % now Memory task, novel then primed:
        
        % resources
        r_2s  = R_s-r_1s;
        r_2ps  = R_s-r_1ps;
        
        theseSM_scores(1,2) = 1/(1+exp(-(r_2s-d_2)*s_1_2^-1));
        theseSM_scores(1,1) = 1/(1+exp(-(r_2ps-d_2)*s_1_2^-1));
        
        
        %% now we add central load. In Exp 3 there was no effect on RTs of load, only on Subs Mem
        
        % L1 nov face score
        r_1ls = r_1s - (1-x_ls)*a_3s*R_s;
        r_1pls = r_1ps - (1-x_ls)*a_3s*R_s;
        
        theseRT_scores(1,4) = 1/(1+exp(-((r_1ls)-d_1)*s_1_2^-1));
        theseRT_scores(1,3) =  1/(1+exp(-(r_1pls-((d_1-prime_lift)))*s_1_2^-1));
        
        r_2ls = r_2s - x_ls*a_3s*R_s;
        r_2pls = r_2ps - x_ls*a_3s*R_s;
        
        theseSM_scores(1,4) =  1/(1+exp(-(r_2ls-(d_2))*s_1_2^-1));
        theseSM_scores(1,3) =  1/(1+exp(-(r_2pls-(d_2))*s_1_2^-1));
        
        r_3 = a_3s * R_s;
        
        theseLoad_scores(1,1) = 1/(1+exp(-(r_3-(d_3))*s_3^-1));
        
        scoreSheet(simI,:,1) = theseRT_scores + RTmeasErrs;
        scoreSheet(simI,:,2) = theseSM_scores + SMmeasErrs;
        scoreSheet(simI,1,3) = theseLoad_scores + loadMeasErrs(1);
        
        % record r, a, p, l parameters in matrix
        
        allocVals(simI,1:5) = [R_s a_s a_3s x_ps x_ls];
        
        resourceVals(simI,:,1) = [r_1ps r_1s r_1pls r_1ls];
        resourceVals(simI,:,2) = [r_2ps r_2s r_2pls r_2ls];
        resourceVals(simI,1,3) = r_3;
        
        case 'Exp. 4b'
        
        r_1s    = a_s*R_s; % basic allocation
        r_1ps  = a_s*R_s-x_ps*prime_lift; %primed allocation
        
        theseRT_scores(1,2) = 1/(1+exp(-(r_1s-d_1)*s_1_2^-1)); %unprimed no load performance
        theseRT_scores(1,1) = 1/(1+exp(-(r_1ps-(d_1-prime_lift))*s_1_2^-1)); %primed no load
        
        % now Memory task, novel then primed:
        
        % resources
        r_2s  = R_s-r_1s;
        r_2ps  = R_s-r_1ps;
        
        theseSM_scores(1,2) = 1/(1+exp(-(r_2s-d_2)*s_1_2^-1));
        theseSM_scores(1,1) = 1/(1+exp(-(r_2ps-d_2)*s_1_2^-1));
        
        
        %% now we add central load. In Exp 4b there was no effect on RTs of load, only on Subs Mem
        
        % L1 nov face score
        r_1ls = r_1s - (1-x_ls)*a_3s*R_s;
        r_1pls = r_1ps - (1-x_ls)*a_3s*R_s;
        
        theseRT_scores(1,4) = 1/(1+exp(-((r_1ls)-d_1)*s_1_2^-1));
        theseRT_scores(1,3) =  1/(1+exp(-(r_1pls-((d_1-prime_lift)))*s_1_2^-1));
        
        r_2ls = r_2s - x_ls*a_3s*R_s;
        r_2pls = r_2ps - x_ls*a_3s*R_s;
        
        theseSM_scores(1,4) =  1/(1+exp(-(r_2ls-(d_2))*s_1_2^-1));
        theseSM_scores(1,3) =  1/(1+exp(-(r_2pls-(d_2))*s_1_2^-1));
        
        r_3 = a_3s * R_s;
        
        theseLoad_scores(1,1) = 1/(1+exp(-(r_3-(d_3))*s_3^-1));
        theseLoad_scores(1,2) = 1/(1+exp(-(r_3-(d_3))*s_3^-1));
        
        scoreSheet(simI,:,1) = theseRT_scores + RTmeasErrs;
        scoreSheet(simI,:,2) = theseSM_scores + SMmeasErrs;
        scoreSheet(simI,1:2,3) = theseLoad_scores + loadMeasErrs;
        
        % record r, a, p, l parameters in matrix
        
        allocVals(simI,1:5) = [R_s a_s a_3s x_ps x_ls];
        
        resourceVals(simI,:,1) = [r_1ps r_1s r_1pls r_1ls];
        resourceVals(simI,:,2) = [r_2ps r_2s r_2pls r_2ls];
        resourceVals(simI,[1 2],3) = [r_3 r_3];
        
    end
end

%% make annotation

annotatStr = {
    sprintf('N = %d \n',nSims);
    sprintf('Sharpness:_ %.2f',s_1_2);
    sprintf('Face task:  d_1 = %.2f',d_1);
    sprintf('Mem task:   d_2 = %.2f',d_2);
    sprintf('Priming effect: d_1 - %.2f',prime_lift);
    sprintf('Load effect: d_1 + %.2f',load_weight);
    '';
    'Resource variables:';
    '';
    };

if strcmp(R_s_sampling,distribTypes(1))
    annotatStr{end+1} = sprintf('R_s, ~N(%.2f, %.2f)',normAllocParams(1,1), normAllocParams(1,2));
elseif strcmp(R_s_sampling,distribTypes(3))
    annotatStr{end+1} = sprintf('R =_ %.2f',fixedAllocs(1));
else
    annotatStr{end+1} = 'R_s, ~U(0,1)';
end

if strcmp(a_s_sampling,distribTypes(1))
    annotatStr{end+1} = sprintf('a_s, ~N(%.2f, %.2f)',normAllocParams(2,1), normAllocParams(2,2));
elseif strcmp(a_s_sampling,distribTypes(3))
    annotatStr{end+1} = sprintf('a = %.2f',fixedAllocs(2));
else
    annotatStr{end+1} = 'a_s, ~U(0,1)';
end

if ~strcmp(simExp,'Exp. 2')
if strcmp(a_3s_sampling,distribTypes(1))
    annotatStr{end+1} = sprintf('a_3s, ~N(%.2f, %.2f)',normAllocParams(3,1), normAllocParams(3,2));
elseif strcmp(a_3s_sampling,distribTypes(3))
    annotatStr{end+1} = sprintf('a_3 = %.2f',fixedAllocs(3));
else
    annotatStr{end+1} = 'a_3s, ~U(0,1)';
end
end

if strcmp(x_ps_sampling,distribTypes(1))
    annotatStr{end+1} = sprintf('x_ps, ~N(%.2f, %.2f)',normAllocParams(4,1), normAllocParams(4,2));
elseif strcmp(x_ps_sampling,distribTypes(3))
    annotatStr{end+1} = sprintf('x_p = %.2f',fixedAllocs(4));
else
    annotatStr{end+1} = 'x_ps, ~U(0,1)';
end

if strcmp(x_ls_sampling,distribTypes(1))
    annotatStr{end+1} = sprintf('x_ls, ~N(%.2f, %.2f)',normAllocParams(5,1), normAllocParams(5,2));
elseif strcmp(x_ps_sampling,distribTypes(3))
    annotatStr{end+1} = sprintf('x_l = %.2f',fixedAllocs(5));
else
    annotatStr{end+1} = 'x_ls, ~U(0,1)';
end

%% sort scoresheet, alloc and resourceVals:

[~, sortIndex] = sortrows(scoreSheet(:,:,1), 2); %sorts by unprimed (col2) performance
scoreSheet = scoreSheet(sortIndex,:,:);
allocVals = allocVals(sortIndex,:,:);
resourceVals = resourceVals(sortIndex,:,:);

end


