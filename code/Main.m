clear;
params.topic='complex';
params.relativePath='..\\featurematrix\\';
params.queryfile='test';
params.vectortypes={'.feature.vector.txt'};

% disp('PSLBLASTing...');
% perl_cmd = sprintf('!perl PSIBlastlargedatadetail.pl %s',params.queryfile);
% eval(perl_cmd); 
% 
% disp ('GenerateFeatureMatrix.pl, searching GOA files and large prediction data will take a long time (recommend to run outside matlab if no running message prompt), please wait...');
% strcmd = sprintf('perl GenerateFeatureMatrix.pl %s',params.queryfile);
% eval(strcmd);     
% 
% disp ('FormatFeatureMatrix.pl...');
% strcmd = sprintf('perl FormatFeatureMatrix.pl %s',params.queryfile);
% eval(strcmd);

disp ('predicting protein co-complex relationships...');
PredictMain(params);

% disp ('identifying protein complexes...');
% perl_cmd = sprintf('!perl GetDenseSubgraphs.pl.pl %s',params.queryfile);
% eval(perl_cmd); 

disp('finished!');
