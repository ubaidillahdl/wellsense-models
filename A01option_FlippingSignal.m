% Folder yang berisi file .mat PPG terbalik
flipFolder = fullfile("datasets", "ppg_hb", "signal");
fileList = dir(fullfile(flipFolder, '*.mat'));

for k = 1:length(fileList)
    filePath = fullfile(flipFolder, fileList(k).name);
    dataLoad = load(filePath);

    % Cari nama variabel utama
    mainFields = fieldnames(dataLoad);
    mainVar = mainFields{1};

    % Ambil PPG
    if strcmpi(mainVar, 'PPGdata')
        ppg = dataLoad.PPGdata.data(:, 1);
        ppg = flipud(ppg); % Balik sinyal
        dataLoad.PPGdata.data(:, 1) = ppg; % Simpan kembali
    elseif strcmpi(mainVar, 'data')
        ppg = dataLoad.data.channel_1;
        ppg = flipud(ppg); % Balik sinyal
        dataLoad.data.channel_1 = ppg; % Simpan kembali
    else
        fprintf('Struktur tidak dikenali: %s\n', fileList(k).name);
        continue;
    end

    % Simpan ulang ke file yang sama
    save(filePath, '-struct', 'dataLoad');
    fprintf('Flipped & saved: %s\n', fileList(k).name);
end

disp('Semua file PPG berhasil dibalik.');
