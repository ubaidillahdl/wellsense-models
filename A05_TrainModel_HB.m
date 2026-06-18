%% MAIN SCRIPT: Repeated CV untuk Model HB (NCA)
clc; clear; close all;

%% ========== 1. KONFIGURASI ==========
nRepeats = 5;          % jumlah pengulangan repeated CV
k = 5;                 % jumlah fold per repeat

% Lokasi file CSV hasil seleksi fitur (sudah berisi fitur terpilih + hb)
folderPath = fullfile("features");
dataFile = "nca_hb_features.csv";   % pastikan file ini ada

%% ========== 2. BACA DATA ==========
% Baca data
datasets = readtable(fullfile(folderPath, dataFile));

% Pisahkan fitur dan target
featureNames = datasets.Properties.VariableNames;
targetName = featureNames{end};  % target di kolom terakhir
featureNames = featureNames(1:end-1);
features = datasets{:, 1:end-1};
target = datasets{:, end};

nSamples = size(features, 1);

%% ========== 3. PREALOKASI ==========
% Prealokasi untuk metrik repeated CV
all_R     = zeros(nRepeats, 1);
all_RMSE  = zeros(nRepeats, 1);
all_MAE   = zeros(nRepeats, 1);
all_MAPE  = zeros(nRepeats, 1);

% Prealokasi untuk plot regresi (maksimal nRepeats * nSamples)
maxPredictions = nRepeats * nSamples;
all_actual = zeros(maxPredictions, 1);
all_pred   = zeros(maxPredictions, 1);
predictionIdx = 0;

%% ========== 4. REPEATED CROSS VALIDATION ==========
for rep = 1:nRepeats
    rng(rep * 10);   % seed berbeda setiap repeat
    cv = cvpartition(nSamples, 'KFold', k);
    
    R_folds = zeros(k,1); RMSE_folds = zeros(k,1); MAE_folds = zeros(k,1); MAPE_folds = zeros(k,1);
    
    for fold = 1:k
        trainIdx = cv.training(fold);
        testIdx  = cv.test(fold);
        
        X_train = features(trainIdx, :)';
        Y_train = target(trainIdx)';
        X_test  = features(testIdx, :)';
        Y_test  = target(testIdx)';
        
        % Normalisasi Min-Max ke [-1,1]
        minX = min(X_train, [], 2);
        maxX = max(X_train, [], 2);
        rangeX = maxX - minX;
        rangeX(rangeX == 0) = 1;
        X_train_norm = (X_train - minX) ./ rangeX * 2 - 1;
        X_test_norm  = (X_test - minX) ./ rangeX * 2 - 1;
        
        minY = min(Y_train);
        maxY = max(Y_train);
        rangeY = maxY - minY;
        if rangeY == 0; rangeY = 1; end
        Y_train_norm = (Y_train - minY) ./ rangeY * 2 - 1;
        
        % ANN dengan 2 hidden neuron, trainbr
        net = feedforwardnet(2, 'trainbr');
        net.layers{1}.transferFcn = 'tansig';
        net.layers{2}.transferFcn = 'purelin';
        net.divideParam.trainRatio = 0.7;
        net.divideParam.valRatio   = 0.15;
        net.divideParam.testRatio  = 0.15;
        net.trainParam.showWindow = false;
        
        [net, ~] = train(net, X_train_norm, Y_train_norm);
        
        pred_norm = net(X_test_norm);
        pred = (pred_norm + 1) / 2 * rangeY + minY;
        
        % Simpan untuk plot regresi
        nTest = length(Y_test);
        idxRange = predictionIdx + 1 : predictionIdx + nTest;
        all_actual(idxRange) = Y_test;
        all_pred(idxRange)   = pred;
        predictionIdx = predictionIdx + nTest;
        
        % Metrik
        RMSE_folds(fold) = sqrt(mean((pred - Y_test).^2));
        MAE_folds(fold)  = mean(abs(pred - Y_test));
        MAPE_folds(fold) = mean(abs((Y_test - pred) ./ Y_test)) * 100;
        R_temp = corrcoef(pred, Y_test);
        R_folds(fold) = R_temp(1,2);
    end
    
    mean_R = mean(R_folds);
    mean_RMSE = mean(RMSE_folds);
    mean_MAE = mean(MAE_folds);
    mean_MAPE = mean(MAPE_folds);
    
    % Simpan ke array yang sudah diprealokasi
    all_R(rep)     = mean_R;
    all_RMSE(rep)  = mean_RMSE;
    all_MAE(rep)   = mean_MAE;
    all_MAPE(rep)  = mean_MAPE;
    
    fprintf('Repeat %d:\tR=%.4f\n', rep, mean_R);
end

% Trim array prediksi (buang kelebihan yang tidak terisi)
all_actual = all_actual(1:predictionIdx);
all_pred   = all_pred(1:predictionIdx);

%% ========== 5. BASELINE (MEAN PREDICTOR) ==========
baseline_rmse = std(target);
baseline_mae = mean(abs(target - mean(target)));

%% ========== 6. HASIL AKHIR ==========
fprintf('\n---------------------------------------\n');
fprintf('HEMOGLOBIN (HB):\n');
fprintf('\t\t\t\tANN \t\t\tBASELINE\n');
fprintf('\t------------------------------------\n');
fprintf('\tR     : %.4f±%.4f\t| %25s\n', mean(all_R), std(all_R), '-');
fprintf('\tRMSE  : %.2f±%.4f\t| %.2f g/L | %.1f%%\n', mean(all_RMSE), std(all_RMSE), baseline_rmse, (1 - mean(all_RMSE)/baseline_rmse)*100);
fprintf('\tMAE   : %.2f±%.4f\t\t| %.2f g/L | %.1f%%\n', mean(all_MAE), std(all_MAE), baseline_mae, (1 - mean(all_MAE)/baseline_mae)*100);
fprintf('\tMAPE  : %.2f±%.4f\t\t| \n', mean(all_MAPE), std(all_MAPE));

%% ========== 7. PLOT REGRESI HB (REPEATED CV) ==========
figure();
h1 = scatter(all_actual, all_pred);
hold on;

% Garis fit linear
coef_hb = polyfit(all_actual, all_pred, 1);
x_fit = [min(all_actual), max(all_actual)];
y_fit = polyval(coef_hb, x_fit);
h2 = plot(x_fit, y_fit, 'r-', 'LineWidth', 1.5);

% Garis Y = T (ideal)
h3 = plot(x_fit, x_fit, 'k:', 'LineWidth', 1.5);

% Hitung R (korelasi)
R_hb_plot = corrcoef(all_actual, all_pred);
R_hb_plot = R_hb_plot(1,2);

% Judul, legend, label
title(sprintf('HEMOGLOBIN (HB): R = %.5f', R_hb_plot));
legend([h1, h2, h3], {'Data', 'Fit', 'Y = T'}, 'Location', 'northwest');
xlabel('Target HB (g/L)', 'FontWeight', 'bold');
ylabel(sprintf('Output~=%.3f*Target+%.3f', coef_hb(1), coef_hb(2)), 'FontWeight', 'bold');

% Batas sumbu
xlim([min(all_actual), max(all_actual)]);
ylim([min(all_pred), max(all_pred)]);
hold off;

%% ========== 8. TAMPILKAN R DARI PLOT ==========
fprintf('\n---------------------------------------\n');
fprintf('HB: R = %.4f (dari %d prediksi)\n', R_hb_plot, length(all_actual));