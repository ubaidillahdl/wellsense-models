%% MAIN SCRIPT: Seleksi Fitur DBP dengan NCA
clc; 
clear; 
close all;

%% ========== 1. KONFIGURASI DAN BACA DATA ==========
folderPath = fullfile("features");
dataSignal = "ppg_bp";

% Baca data (kolom 1-12 = fitur, kolom 13 = target DBP)
datasets = readtable(fullfile(folderPath, dataSignal + "_features.csv"));
featureNames = datasets.Properties.VariableNames(1:12);
features = datasets{:, 1:12};    % 96 x 12
dbp = datasets{:, 14};            % Target DBP

nFeatures = size(features, 2);

%% ========== 2. NCA UNTUK DBP ==========
nca_dbp = fsrnca(features, dbp, 'Verbose', 0);
weights_dbp = nca_dbp.FeatureWeights;
weights_dbp_norm = weights_dbp / max(weights_dbp);

%% ========== 3. FITUR TERPILIH (Bobot > 0.05) ==========
selectedIdx = find(weights_dbp_norm > 0.05);

%% ========== 4. TAMPILKAN HASIL ==========
fprintf('\n======= HASIL NCA UNTUK DBP (12 FITUR) =======\n');
fprintf('+-----------------+------------+\n');
fprintf('| Fitur           | Bobot DBP   |\n');
fprintf('+-----------------+------------+\n');

for i = 1:nFeatures
    % Tambahkan bintang jika fitur terpilih
    if ismember(i, selectedIdx)
        displayName = ['*' featureNames{i}];
    else
        displayName = [' ' featureNames{i}];
    end
    
    fprintf('| %-15s | %+10f |\n', ...
        displayName, weights_dbp_norm(i));
end
fprintf('+-----------------+------------+\n');

%% ========== 5. VISUALISASI (PLOT) ==========
figure();
pos = get(gcf, 'Position'); 
set(gcf, 'Position', [pos(1), pos(2), pos(3), pos(4)/2]);
bar(weights_dbp_norm);
title('Bobot Kepentingan Fitur untuk DBP');
xticks(1:nFeatures);
xticklabels(featureNames);
xtickangle(45);
ylim([0 1.1]);
grid on;

%% ========== 6. SIMPAN FITUR TERPILIH KE CSV ==========
X_selected = features(:, selectedIdx);
selectedFeatureNames = featureNames(selectedIdx);

% Buat tabel dengan fitur terpilih + target
T_final = array2table(X_selected, 'VariableNames', selectedFeatureNames);
T_final.dbp = dbp;

% Simpan ke file
outputFile = fullfile(folderPath, "nca_dbp_features.csv");
% writetable(T_final, outputFile);

fprintf('\nFile\t: \t%s\n', outputFile);
fprintf('Dataset\t: \t%d sampel x %d fitur + 1 target\n', size(X_selected,1), size(X_selected,2));