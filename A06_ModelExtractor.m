%% SCRIPT EKSPOR MODEL ANN KE JSON (3 MODEL TERPISAH: SBP, DBP, HB)
clc;
clear;
close all;
rng(42);

%% 1. KONFIGURASI
folderPath = fullfile("features");
modelFolder = "model";

% Buat folder model jika belum ada
if ~exist(modelFolder, 'dir')
    mkdir(modelFolder);
end

%% ============================================================
% 2. EKSPOR MODEL SBP
% ============================================================
fprintf('\n========== EXPORT MODEL SBP ==========\n');

% Load data SBP
dataFileSBP = fullfile(folderPath, "nca_sbp_features.csv");
dataSBP = readtable(dataFileSBP);

% Ekstrak fitur dan target
featureNamesSBP = dataSBP.Properties.VariableNames;
featureNamesSBP = featureNamesSBP(1:end-1);
featuresSBP = dataSBP{:, 1:end-1};
targetSBP = dataSBP{:, end};

% Manual Min-Max normalization
minX_SBP = min(featuresSBP, [], 1);
maxX_SBP = max(featuresSBP, [], 1);
rangeX_SBP = maxX_SBP - minX_SBP;
rangeX_SBP(rangeX_SBP == 0) = 1;
X_norm_SBP = (featuresSBP - minX_SBP) ./ rangeX_SBP * 2 - 1;

minY_SBP = min(targetSBP);
maxY_SBP = max(targetSBP);
rangeY_SBP = maxY_SBP - minY_SBP;
if rangeY_SBP == 0; rangeY_SBP = 1; end
Y_norm_SBP = (targetSBP - minY_SBP) ./ rangeY_SBP * 2 - 1;

% Training final dengan seluruh data
netSBP = feedforwardnet(2, 'trainbr');
netSBP.layers{1}.transferFcn = 'tansig';
netSBP.layers{2}.transferFcn = 'purelin';
netSBP.divideParam.trainRatio = 1.0;
netSBP.divideParam.valRatio = 0;
netSBP.divideParam.testRatio = 0;
netSBP.trainParam.showWindow = true;

[netSBP, ~] = train(netSBP, X_norm_SBP', Y_norm_SBP');

% Ekstrak bobot dan bias
W1_SBP = netSBP.IW{1,1};
b1_SBP = netSBP.b{1};
W2_SBP = netSBP.LW{2,1};
b2_SBP = netSBP.b{2};

% Bangun struktur JSON
modelSBP = struct();
modelSBP.model = "ANN_Backpropagation";
modelSBP.target = "SBP";
modelSBP.features = featureNamesSBP;
modelSBP.normalization_type = "minmax_manual";
modelSBP.normalization_range = [-1, 1];
modelSBP.normalization_minX = minX_SBP;
modelSBP.normalization_maxX = maxX_SBP;
modelSBP.normalization_minY = minY_SBP;
modelSBP.normalization_maxY = maxY_SBP;
modelSBP.architecture_input = size(W1_SBP,2);
modelSBP.architecture_hidden = size(W1_SBP,1);
modelSBP.architecture_output = size(W2_SBP,1);
modelSBP.weights_W1 = W1_SBP;
modelSBP.weights_b1 = b1_SBP;
modelSBP.weights_W2 = W2_SBP;
modelSBP.weights_b2 = b2_SBP;
modelSBP.activation_hidden = "tansig";
modelSBP.activation_output = "purelin";

% Simpan JSON
jsonSBP = jsonencode(modelSBP);
fidSBP = fopen(fullfile(modelFolder, 'model_sbp.json'), 'w');
fprintf(fidSBP, '%s', jsonSBP);
fclose(fidSBP);
fprintf('? model_sbp.json (SBP, %d fitur)\n', length(featureNamesSBP));

%% ============================================================
% 3. EKSPOR MODEL DBP
% ============================================================
fprintf('\n========== EXPORT MODEL DBP ==========\n');

% Load data DBP
dataFileDBP = fullfile(folderPath, "nca_dbp_features.csv");
dataDBP = readtable(dataFileDBP);

% Ekstrak fitur dan target
featureNamesDBP = dataDBP.Properties.VariableNames;
featureNamesDBP = featureNamesDBP(1:end-1);
featuresDBP = dataDBP{:, 1:end-1};
targetDBP = dataDBP{:, end};

% Manual Min-Max normalization
minX_DBP = min(featuresDBP, [], 1);
maxX_DBP = max(featuresDBP, [], 1);
rangeX_DBP = maxX_DBP - minX_DBP;
rangeX_DBP(rangeX_DBP == 0) = 1;
X_norm_DBP = (featuresDBP - minX_DBP) ./ rangeX_DBP * 2 - 1;

minY_DBP = min(targetDBP);
maxY_DBP = max(targetDBP);
rangeY_DBP = maxY_DBP - minY_DBP;
if rangeY_DBP == 0; rangeY_DBP = 1; end
Y_norm_DBP = (targetDBP - minY_DBP) ./ rangeY_DBP * 2 - 1;

% Training final
netDBP = feedforwardnet(2, 'trainbr');
netDBP.layers{1}.transferFcn = 'tansig';
netDBP.layers{2}.transferFcn = 'purelin';
netDBP.divideParam.trainRatio = 1.0;
netDBP.divideParam.valRatio = 0;
netDBP.divideParam.testRatio = 0;
netDBP.trainParam.showWindow = true;

[netDBP, ~] = train(netDBP, X_norm_DBP', Y_norm_DBP');

% Ekstrak bobot dan bias
W1_DBP = netDBP.IW{1,1};
b1_DBP = netDBP.b{1};
W2_DBP = netDBP.LW{2,1};
b2_DBP = netDBP.b{2};

% Bangun struktur JSON
modelDBP = struct();
modelDBP.model = "ANN_Backpropagation";
modelDBP.target = "DBP";
modelDBP.features = featureNamesDBP;
modelDBP.normalization_type = "minmax_manual";
modelDBP.normalization_range = [-1, 1];
modelDBP.normalization_minX = minX_DBP;
modelDBP.normalization_maxX = maxX_DBP;
modelDBP.normalization_minY = minY_DBP;
modelDBP.normalization_maxY = maxY_DBP;
modelDBP.architecture_input = size(W1_DBP,2);
modelDBP.architecture_hidden = size(W1_DBP,1);
modelDBP.architecture_output = size(W2_DBP,1);
modelDBP.weights_W1 = W1_DBP;
modelDBP.weights_b1 = b1_DBP;
modelDBP.weights_W2 = W2_DBP;
modelDBP.weights_b2 = b2_DBP;
modelDBP.activation_hidden = "tansig";
modelDBP.activation_output = "purelin";

% Simpan JSON
jsonDBP = jsonencode(modelDBP);
fidDBP = fopen(fullfile(modelFolder, 'model_dbp.json'), 'w');
fprintf(fidDBP, '%s', jsonDBP);
fclose(fidDBP);
fprintf('? model_dbp.json (DBP, %d fitur)\n', length(featureNamesDBP));

%% ============================================================
% 4. EKSPOR MODEL HB
% ============================================================
fprintf('\n========== EXPORT MODEL HB ==========\n');

% Load data HB
dataFileHB = fullfile(folderPath, "nca_hb_features.csv");
dataHB = readtable(dataFileHB);

% Ekstrak fitur dan target
featureNamesHB = dataHB.Properties.VariableNames;
featureNamesHB = featureNamesHB(1:end-1);
featuresHB = dataHB{:, 1:end-1};
targetHB = dataHB{:, end};

% Manual Min-Max normalization
minX_HB = min(featuresHB, [], 1);
maxX_HB = max(featuresHB, [], 1);
rangeX_HB = maxX_HB - minX_HB;
rangeX_HB(rangeX_HB == 0) = 1;
X_norm_HB = (featuresHB - minX_HB) ./ rangeX_HB * 2 - 1;

minY_HB = min(targetHB);
maxY_HB = max(targetHB);
rangeY_HB = maxY_HB - minY_HB;
if rangeY_HB == 0; rangeY_HB = 1; end
Y_norm_HB = (targetHB - minY_HB) ./ rangeY_HB * 2 - 1;

% Training final
netHB = feedforwardnet(2, 'trainbr');
netHB.layers{1}.transferFcn = 'tansig';
netHB.layers{2}.transferFcn = 'purelin';
netHB.divideParam.trainRatio = 1.0;
netHB.divideParam.valRatio = 0;
netHB.divideParam.testRatio = 0;
netHB.trainParam.showWindow = true;

[netHB, ~] = train(netHB, X_norm_HB', Y_norm_HB');

% Ekstrak bobot dan bias
W1_HB = netHB.IW{1,1};
b1_HB = netHB.b{1};
W2_HB = netHB.LW{2,1};
b2_HB = netHB.b{2};

% Bangun struktur JSON
modelHB = struct();
modelHB.model = "ANN_Backpropagation";
modelHB.target = "HB";
modelHB.features = featureNamesHB;
modelHB.normalization_type = "minmax_manual";
modelHB.normalization_range = [-1, 1];
modelHB.normalization_minX = minX_HB;
modelHB.normalization_maxX = maxX_HB;
modelHB.normalization_minY = minY_HB;
modelHB.normalization_maxY = maxY_HB;
modelHB.architecture_input = size(W1_HB,2);
modelHB.architecture_hidden = size(W1_HB,1);
modelHB.architecture_output = size(W2_HB,1);
modelHB.weights_W1 = W1_HB;
modelHB.weights_b1 = b1_HB;
modelHB.weights_W2 = W2_HB;
modelHB.weights_b2 = b2_HB;
modelHB.activation_hidden = "tansig";
modelHB.activation_output = "purelin";

% Simpan JSON
jsonHB = jsonencode(modelHB);
fidHB = fopen(fullfile(modelFolder, 'model_hb.json'), 'w');
fprintf(fidHB, '%s', jsonHB);
fclose(fidHB);
fprintf('? model_hb.json (HB, %d fitur)\n', length(featureNamesHB));

%% ============================================================
% 5. VERIFIKASI
% ============================================================
fprintf('\n========== VERIFIKASI ==========\n');
fprintf('\nModel SBP:\n');
fprintf('  - Fitur: %s\n', strjoin(featureNamesSBP, ', '));
fprintf('  - Input count : %d\n', modelSBP.architecture_input);
fprintf('  - Output count: %d\n', modelSBP.architecture_output);
fprintf('  - File: model_sbp.json\n');

fprintf('\nModel DBP:\n');
fprintf('  - Fitur: %s\n', strjoin(featureNamesDBP, ', '));
fprintf('  - Input count : %d\n', modelDBP.architecture_input);
fprintf('  - Output count: %d\n', modelDBP.architecture_output);
fprintf('  - File: model_dbp.json\n');

fprintf('\nModel HB:\n');
fprintf('  - Fitur: %s\n', strjoin(featureNamesHB, ', '));
fprintf('  - Input count : %d\n', modelHB.architecture_input);
fprintf('  - Output count: %d\n', modelHB.architecture_output);
fprintf('  - File: model_hb.json\n');

fprintf('\n========== SELESAI ==========\n');
fprintf('3 model JSON siap digunakan di server:\n');
fprintf('  - model_sbp.json (SBP)\n');
fprintf('  - model_dbp.json (DBP)\n');
fprintf('  - model_hb.json (HB)\n');