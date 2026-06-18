clc;
clear;
close all;

% Tambahkan folder 'functions' ke path
addpath(genpath('functions'));

% Deklarasi variabel global
global folderPath fileList selectedFile fileIndex fs;
global hPlot1 hPlot2 hPlot3 hAx1 hAx2 hAx3;
global goodFolder poorFolder merah hijau kuning;
global sbp dbp hb age gender dataSignal ppg;
global targetPath ppgCycle savePath;

ppg     = [];
sbp     = [];
dbp     = [];
hb      = [];
age     = [];
gender      = [];
ppgCycle    = [];

% Pilih BP atau HB
dataSignal = "ppg_bp"; % untuk hb tinggal ubah ke "ppg_hb"

% Tentukan folder dataset dan ambil list file
% folderPath = fullfile("datasets", dataSignal, "signal");
% folderPath = fullfile("datasets", "signal_classify", dataSignal, "poor");
folderPath = fullfile("datasets", "signal_classify", dataSignal, "good");

% Folder pindahan
poorFolder = fullfile("datasets", "signal_classify", dataSignal, "poor");
goodFolder = fullfile("datasets", "signal_classify", dataSignal, "good");
targetPath = fullfile("datasets", dataSignal, "subjects_information.xlsx");
savePath   = fullfile("datasets", "processed_data", dataSignal);

fileList = dir(fullfile(folderPath, '*.mat'));
sortName();
selectedFile = 1;
fileIndex = 1;

merah = [0.8 0 0];
hijau = [0 0.6 0];
kuning = [0.8 0.6 0];

loadData();

fs = 200;

% Atur ukuran dan posisi figure
screenSize = get(0, 'ScreenSize');
figWidth   = 600;
figHeight  = 400;
figX       = (screenSize(3) - figWidth) / 2;
figY       = (screenSize(4) - figHeight - 30) / 2;

% Buat figure utama
hFig = figure('Name', 'Signal Quality Selection', 'NumberTitle', 'off', 'Position', [figX, figY, figWidth, figHeight]);

% Buat subplot untuk sinyal PPG dan ABP
hAx1   = subplot(3, 1, 1);
hPlot1 = plot(nan, nan);

hAx2   = subplot(3, 1, 2);
hPlot2 = plot(nan, nan);
% setPosition(hAx2, 0.5);

hAx3   = subplot(3, 1, 3);
hPlot3 = plot(nan, nan);
setPosition(hAx3, 0.5);

uicontrol('Style', 'pushbutton', 'String', 'Prev', 'Units', 'normalized', 'Position', [0.67, 0.26, 0.09, 0.07], 'Callback', @prevFile);
uicontrol('Style', 'pushbutton', 'String', 'Next', 'Units', 'normalized', 'Position', [0.78, 0.26, 0.09, 0.07], 'Callback', @nextFile);
uicontrol('Style', 'pushbutton', 'String', 'Poor', 'Units', 'normalized', 'Position', [0.67, 0.18, 0.09, 0.07], 'BackgroundColor', merah, 'Enable', 'off', 'Callback', @poorFile);
uicontrol('Style', 'pushbutton', 'String', 'Good', 'Units', 'normalized', 'Position', [0.78, 0.18, 0.09, 0.07], 'BackgroundColor', hijau, 'Enable', 'off', 'Callback', @goodFile);
uicontrol('Style', 'pushbutton', 'String', 'Save', 'Units', 'normalized', 'Position', [0.725, 0.1, 0.09, 0.07], 'BackgroundColor', kuning, 'Enable', 'off', 'Callback', @saveData);

% Update plot pertama kali
updateData();

% Uncomment ketika sudah selesai semua
% for i = 1 : length(fileList)
%     drawnow;
%     pause(1);
%     saveData();
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

%% Function to move the current file to bad_signals folder
function poorFile(~, ~)
    global  fileIndex fileList folderPath poorFolder hPlot1 hPlot2 hPlot3 merah;
    
    if ~exist(poorFolder, 'dir')
        mkdir(poorFolder);
    end
    
    oldPath = fullfile(folderPath, fileList(fileIndex).name);
    newPath = fullfile(poorFolder, fileList(fileIndex).name);
    
    movefile(oldPath, newPath);
    disp(['Moved file to: ', newPath]);
    
    % Simpan posisi index sebelum file dihapus
    currentIdx = fileIndex;
    
    fileList(fileIndex) = [];
    
    if fileIndex > length(fileList)
        fileIndex = max(1, length(fileList));
    end
    
    % Ubah warna plot sebagai indikator penyimpanan
    defaultColor = get(hPlot1, 'Color');
    defaultLineWidth = get(hPlot1, 'LineWidth');
    
    set(hPlot1, 'Color', merah, 'LineWidth', 2);
    set(hPlot2, 'Color', merah, 'LineWidth', 2);
    set(hPlot3, 'Color', merah, 'LineWidth', 2);
    pause(1);
    set(hPlot1, 'Color', defaultColor, 'LineWidth', defaultLineWidth);
    set(hPlot2, 'Color', defaultColor, 'LineWidth', defaultLineWidth);
    set(hPlot3, 'Color', defaultColor, 'LineWidth', defaultLineWidth);
    
    % Navigasi sesuai index awal
    if currentIdx ~= 1
        fileIndex = fileIndex+1;
        prevFile();
    else
        loadData();
        updateData();
    end
end

%% Function to move the current file to bad_signals folder
function goodFile(~, ~)
    global  fileIndex fileList folderPath goodFolder hPlot1 hPlot2 hPlot3 hijau;
    
    if ~exist(goodFolder, 'dir')
        mkdir(goodFolder);
    end
    
    oldPath = fullfile(folderPath, fileList(fileIndex).name);
    newPath = fullfile(goodFolder, fileList(fileIndex).name);
    
    movefile(oldPath, newPath);
    fprintf('Moved file to: %s\n', newPath);
    
    % Simpan posisi index sebelum file dihapus
    currentIdx = fileIndex;
    
    fileList(fileIndex) = [];
    
    if fileIndex > length(fileList)
        fileIndex = max(1, length(fileList));
    end
    
    % Ubah warna plot sebagai indikator penyimpanan
    defaultColor = get(hPlot1, 'Color');
    defaultLineWidth = get(hPlot1, 'LineWidth');
    
    set(hPlot1, 'Color', hijau, 'LineWidth', 2);
    set(hPlot2, 'Color', hijau, 'LineWidth', 2);
    set(hPlot3, 'Color', hijau, 'LineWidth', 2);
    pause(1);
    set(hPlot1, 'Color', defaultColor, 'LineWidth', defaultLineWidth);
    set(hPlot2, 'Color', defaultColor, 'LineWidth', defaultLineWidth);
    set(hPlot3, 'Color', defaultColor, 'LineWidth', defaultLineWidth);
    
    % Navigasi sesuai index awal
    if currentIdx ~= 1
        fileIndex = fileIndex+1;
        prevFile();
    else
        loadData();
        updateData();
    end
end

%%
function updateData(~, ~)
    global selectedFile fileList fileIndex ppg fs;
    global hPlot1 hPlot2 hPlot3 hAx1 hAx2 hAx3 ppgCycle tPpgCycle
    
    % Update plot pertama kali
    inUpdatePlot.selectedFile   = selectedFile;
    inUpdatePlot.ppg            = ppg;
    inUpdatePlot.fs             = fs;
    inUpdatePlot.fileIndex      = fileIndex;
    inUpdatePlot.fileList       = fileList;
    inUpdatePlot.plot.hPlot     = [hPlot1, hPlot2, hPlot3];
    inUpdatePlot.plot.hAx       = [hAx1, hAx2, hAx3];

    outUpdatePlot = updatePlot(inUpdatePlot);

    ppgCycle = outUpdatePlot.ppgCycle;
    tPpgCycle = outUpdatePlot.tPpgCycle;
end

%%
function loadData(~, ~)
    global selectedFile folderPath fileList fileIndex ppg targetPath;
    global sbp dbp hb age gender dataSignal;
    
    % Siapkan parameter untuk loadFile
    inLoadFile.selectedFile = selectedFile;
    inLoadFile.folderPath = folderPath;
    inLoadFile.targetPath = targetPath;
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
    
    ppg    = outLoadFile.ppg;
    age    = outLoadFile.age;
    gender = string(outLoadFile.gender);
end

%%
function saveData(~, ~)
    global hPlot1 hPlot2 hPlot3;
    global savePath fileList fileIndex dataSignal kuning;
    global sbp dbp hb age gender ;
    global ppgCycle fs;
    
    if ~exist(savePath, 'dir')
        mkdir(savePath);
    end
    
    if strcmp(dataSignal, 'ppg_bp')
        save(fullfile(savePath, fileList(fileIndex).name), ...
            'ppgCycle', 'fs', 'age', 'gender', 'sbp', 'dbp');
    elseif strcmp(dataSignal, 'ppg_hb')
        save(fullfile(savePath, fileList(fileIndex).name), ...
            'ppgCycle', 'fs', 'age', 'gender', 'hb');
    end
    
    % Ubah warna plot sebagai indikator penyimpanan
    defaultColor = get(hPlot1, 'Color');
    defaultLineWidth = get(hPlot1, 'LineWidth');
    
    set(hPlot1, 'Color', kuning, 'LineWidth', 2);
    set(hPlot2, 'Color', kuning, 'LineWidth', 2);
    set(hPlot3, 'Color', kuning, 'LineWidth', 2);
    pause(1);
    set(hPlot1, 'Color', defaultColor, 'LineWidth', defaultLineWidth);
    set(hPlot2, 'Color', defaultColor, 'LineWidth', defaultLineWidth);
    set(hPlot3, 'Color', defaultColor, 'LineWidth', defaultLineWidth);
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