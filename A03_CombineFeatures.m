clc;
clear;
close all;

% Pilih BP atau HB
dataSignal = "ppg_hb";
folderPath = fullfile("features", dataSignal);

% Dapatkan semua file CSV
files = dir(fullfile(folderPath, '*.csv'));

% Prealokasi cell array
datasetsCell = cell(1, length(files));

% Gabungkan semua file CSV ke cell array
for i = 1:length(files)
    filePath = fullfile(folderPath, files(i).name);
    datasetsCell{i} = readtable(filePath);
    
    fprintf('  [%d/%d] %s\n', i, length(files), files(i).name);
end

% Gabungkan semua tabel sekaligus
datasets = vertcat(datasetsCell{:});

% Tentukan header sesuai jenis data
if strcmp(dataSignal, 'ppg_bp')
    header = {'gender', 'age', 'cycleDuration', 'widthW1', 'widthW2', ...
              'w1W2Ratio', 'w1centerTime', 'relWidthW1', 'relWidthW2', ...
              'heartRate', 'sysTime', 'diasTime', 'sbp', 'dbp'};
elseif strcmp(dataSignal, 'ppg_hb')
    header = {'gender', 'age', 'cycleDuration', 'widthW1', 'widthW2', ...
              'w1W2Ratio', 'w1centerTime', 'relWidthW1', 'relWidthW2', ...
              'heartRate', 'sysTime', 'diasTime', 'hb'};
end

% Ganti nama variabel tabel
datasets.Properties.VariableNames = header;

% Pastikan folder tujuan ada
outputFolder = "features";
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Nama file output
featureFileName = fullfile(outputFolder, dataSignal + "_features.csv");

% Simpan tabel ke CSV
% writetable(datasets, featureFileName);

fprintf("Semua data berhasil digabung dan disimpan di %s\n", featureFileName);