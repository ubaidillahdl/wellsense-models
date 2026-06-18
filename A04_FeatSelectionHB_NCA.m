%% MAIN SCRIPT: Seleksi Fitur HB dengan NCA
clc; 
clear; 
close all;

%% ========== 1. KONFIGURASI DAN BACA DATA ==========
folderPath = fullfile("features");
dataSignal = "ppg_hb";

% Baca data (kolom 1-12 = fitur, kolom 13 = target HB)
datasets = readtable(fullfile(folderPath, dataSignal + "_features.csv"));
featureNames = datasets.Properties.VariableNames(1:12);
features = datasets{:, 1:12};    % 96 x 12
hb = datasets{:, 13};            % Target Hemoglobin

nFeatures = size(features, 2);

%% ========== 2. NCA UNTUK HB ==========
nca_hb = fsrnca(features, hb, 'Verbose', 0);
weights_hb = nca_hb.FeatureWeights;
weights_hb_norm = weights_hb / max(weights_hb);

%% ========== 3. FITUR TERPILIH (Bobot > 0.05) ==========
selectedIdx = find(weights_hb_norm > 0.05);

%% ========== 4. TAMPILKAN HASIL ==========
fprintf('\n======= HASIL NCA UNTUK HB (12 FITUR) =======\n');
fprintf('+-----------------+------------+\n');
fprintf('| Fitur           | Bobot HB   |\n');
fprintf('+-----------------+------------+\n');

for i = 1:nFeatures
    % Tambahkan bintang jika fitur terpilih
    if ismember(i, selectedIdx)
        displayName = ['*' featureNames{i}];
    else
        displayName = [' ' featureNames{i}];
    end
    
    fprintf('| %-15s | %+10f |\n', ...
        displayName, weights_hb_norm(i));
end
fprintf('+-----------------+------------+\n');

%% ========== 5. VISUALISASI (PLOT) ==========
figure();
pos = get(gcf, 'Position'); 
set(gcf, 'Position', [pos(1), pos(2), pos(3), pos(4)/2]);
bar(weights_hb_norm);
title('Bobot Kepentingan Fitur untuk HB');
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
T_final.hb = hb;

% Simpan ke file
outputFile = fullfile(folderPath, "nca_hb_features.csv");
% writetable(T_final, outputFile);

fprintf('\nFile\t: \t%s\n', outputFile);
fprintf('Dataset\t: \t%d sampel x %d fitur + 1 target\n', size(X_selected,1), size(X_selected,2));