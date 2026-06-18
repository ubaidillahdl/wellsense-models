clc;
clear;
close all;

% Tambahkan folder 'functions' ke path
addpath(genpath('functions'));

% Deklarasi variabel global
global fileList selectedFile fileIndex;
global dataSignal folderPath;
global sbp dbp hb age gender ppgCycle fs;
global hAx1 hAx2 hPlot1 hPlot2 featureFileName;
global  cycleDuration widthW1 widthW2 w1W2Ratio w1centerTime relWidthW1 ...
        relWidthW2 heartRate sysTime diasTime dataset;

sbp     = [];
dbp     = [];
hb      = [];
age     = [];
fs      = [];
gender      = [];
ppgCycle    = [];

cycleDuration   = [];
widthW1         = [];
widthW2         = [];
w1W2Ratio       = [];
w1centerTime    = [];
relWidthW1      = [];
relWidthW2      = [];
heartRate       = [];
sysTime         = [];
diasTime        = [];
dataset         = [];

% Pilih BP atau HB
dataSignal = "ppg_hb";

folderPath = fullfile("datasets", "processed_data", dataSignal);

fileList = dir(fullfile(folderPath, '*.mat'));
sortName();
selectedFile = 2;
fileIndex = 1;

name = replace(fileList(fileIndex).name, '.mat', '');
featureFileName = fullfile("features", dataSignal, "feature_" + name + ".csv");

loadData();

% Atur ukuran dan posisi figure
screenSize = get(0, 'ScreenSize');
figWidth   = 600;
figHeight  = 400;
figX       = (screenSize(3) - figWidth) / 2;
figY       = (screenSize(4) - figHeight - 30) / 2;

% Buat figure utama
hFig = figure('Name', 'Feature Extraction OWSD', 'NumberTitle', 'off', 'Position', [figX, figY, figWidth, figHeight]);

% Buat subplot untuk sinyal PPG dan ABP
hAx1   = subplot(2, 1, 1);
hPlot1 = plot(nan, nan);

hAx2   = subplot(2, 1, 2);
hPlot2 = plot(nan, nan);
setPosition(hAx2, 0.5);

uicontrol('Style', 'pushbutton', 'String', 'Prev', 'Units', 'normalized', 'Position', [0.67, 0.26, 0.09, 0.07], 'Callback', @prevFile);
uicontrol('Style', 'pushbutton', 'String', 'Next', 'Units', 'normalized', 'Position', [0.78, 0.26, 0.09, 0.07], 'Callback', @nextFile);
uicontrol('Style', 'pushbutton', 'String', 'Save', 'Units', 'normalized', 'Position', [0.725, 0.18, 0.09, 0.07], 'BackgroundColor', [0.8 0.6 0], 'Enable', 'off', 'Callback', @saveFeature);

loadAll();
updateData();

% Uncomment ketika sudah selesai semua
% for i = 1 : length(fileList)
%     drawnow;
%     pause(1);
%     saveFeature();
%     pause(0.03);
%     nextFile();
% end

%% Fungsi untuk berpindah ke file sebelumnya
function prevFile(~, ~)
    % Gunakan variabel global
    global fileIndex;

    % Cek apakah masih ada file sebelumnya
    if fileIndex > 1
        % Pindah ke file sebelumnya
        fileIndex = fileIndex - 1;
        
        % Siapkan parameter untuk loadFile
        loadData();
        
        % Update plot pertama kali
        updateData();
    else
        % Tampilkan pesan jika sudah di file pertama
        disp('Already at the first file.');
    end
end

%% Fungsi untuk berpindah ke file berikutnya
function nextFile(~, ~)
    % Gunakan variabel global
    global  fileIndex fileList;
    
    % Cek apakah masih ada file berikutnya
    if fileIndex < length(fileList)
        
        % Pindah ke file berikutnya
        fileIndex = fileIndex + 1;
        
        % Siapkan parameter untuk loadFile
        loadData();
        
        % Update plot pertama kali
        updateData();
    else
        % Tampilkan pesan jika sudah di file terakhir
        disp('Already at the last file.'); 
    end
end

%%
function updateData(~, ~)
    global selectedFile fileList fileIndex fs ppgCycle featureFileName;
    global hPlot2 hAx1 hAx2 ppgAll dataSignal age gender;
    global  cycleDuration widthW1 widthW2 w1W2Ratio w1centerTime relWidthW1 ...
        relWidthW2 heartRate sysTime diasTime dataset sbp dbp hb;
    
    name = replace(fileList(fileIndex).name, '.mat', '');
    featureFileName = fullfile("features", dataSignal, "feature_" + name + ".csv");
    
    % Update plot pertama kali
    inUpdatePlot.selectedFile   = selectedFile;
    inUpdatePlot.fileIndex      = fileIndex;
    inUpdatePlot.fileList       = fileList;
    inUpdatePlot.plot.hPlot     = hPlot2;
    inUpdatePlot.plot.hAx       = [hAx1, hAx2];
    
    inUpdatePlot.ppgCycle       = ppgCycle;
    inUpdatePlot.ppgAll         = ppgAll;
    inUpdatePlot.fs             = fs;

    outUpdatePlot = updatePlot(inUpdatePlot);
    
    cycleDuration   =  outUpdatePlot.cycleDuration;
    widthW1         =  outUpdatePlot.widthW1;
    widthW2         =  outUpdatePlot.widthW2;
    w1W2Ratio       =  outUpdatePlot.w1W2Ratio;
    w1centerTime    =  outUpdatePlot.w1centerTime;
    relWidthW1      =  outUpdatePlot.relWidthW1;
    relWidthW2      =  outUpdatePlot.relWidthW2;
    heartRate       =  outUpdatePlot.heartRate;
    sysTime         =  outUpdatePlot.sysTime;
    diasTime        =  outUpdatePlot.diasTime;
    
    dataset = table(gender(:), age(:),cycleDuration(:), widthW1(:), widthW2(:), w1W2Ratio(:), ...
                w1centerTime(:), relWidthW1(:), relWidthW2(:), heartRate(:), ...
                sysTime(:), diasTime(:), ...           
                'VariableNames', {'gender', 'age', 'cycleDuration', 'widthW1', 'widthW2', ...
                'w1W2Ratio', 'w1centerTime', 'relWidthW1', 'relWidthW2', ...
                'heartRate', 'sysTime', 'diasTime'});
            
    if strcmp(dataSignal, 'ppg_bp')
        dataset.sbp = sbp(:);
        dataset.dbp = dbp(:);
    elseif strcmp(dataSignal, 'ppg_hb')
        dataset.hb = hb(:);
    end
end

%%
function loadData(~, ~)
    global selectedFile folderPath fileList fileIndex ppgCycle fs;
    global sbp dbp hb age gender dataSignal;
    
    % Siapkan parameter untuk loadFile
    inLoadFile.selectedFile = selectedFile;
    inLoadFile.folderPath = folderPath;
    inLoadFile.fileList = fileList;
    inLoadFile.fileIndex = fileIndex;

    % Load file baru
    outLoadFile = loadFile(inLoadFile);

    if strcmp(dataSignal, 'ppg_bp')
        sbp = outLoadFile.sbp;
        dbp = outLoadFile.dbp;
    elseif strcmp(dataSignal, 'ppg_hb')
        hb = outLoadFile.hb;
    end
    
    ppgCycle    = outLoadFile.ppgCycle;
    gender      = outLoadFile.gender;
    age         = outLoadFile.age;
    fs          = outLoadFile.fs;
end

%%
function loadAll(~, ~)
    global fileList fileIndex ppgAll ppgCycle;

    % Simpan fileIndex awal
    originalFileIndex = fileIndex;

    ppgAll = cell(1, length(fileList));

    for i = 1:length(fileList)
        fileIndex = i;  %#ok<NASGU>
        loadData();            % ini akan pakai fileIndex yang baru
        ppgAll{i} = ppgCycle(:)'; % simpan row vector
    end

    % Kembalikan fileIndex ke nilai awal
    fileIndex = originalFileIndex;
end

%% Fungsi untuk menyimpan siklus yang dipilih
function saveFeature(~, ~)
    global hPlot2 featureFileName dataset;
    
    % Pastikan folder tujuan ada
    featurePath = fileparts(featureFileName);
    if ~exist(featurePath, 'dir')
        mkdir(featurePath);
    end
    
    % Menyimpan tabel ke dalam file CSV
    writetable(dataset, featureFileName);
    
    defaultColor = get(hPlot2, 'Color');
    defaultLineWidth = get(hPlot2, 'LineWidth');
    
    % Ubah warna plot sebagai indikator penyimpanan
    set(hPlot2, 'Color', [0.8 0.6 0], 'LineWidth', 2);
    pause(1);
    set(hPlot2, 'Color', defaultColor, 'LineWidth', defaultLineWidth);
end

%% Sort nama file
function sortName(~, ~)
   global fileList;
    
    fileNums = zeros(length(fileList), 1);
    for i = 1:length(fileList)
        nameOnly = erase(fileList(i).name, '.mat'); % hapus ekstensi
        fileNums(i) = str2double(nameOnly);         % konversi ke angka
    end

    [~, idx] = sort(fileNums);
    fileList = fileList(idx);
end

%% Fungsi untuk mengatur posisi subplot
function setPosition(ax, width, xOffset)
    % Ambil posisi subplot saat ini
    pos = get(ax, 'Position');
    
    % Atur lebar subplot
    pos(3) = width;
    
    % Jika ada offset, atur posisi horizontalnya
    if nargin > 2
        pos(1) = xOffset;
    end
    
    % Terapkan perubahan posisi
    set(ax, 'Position', pos);
end
