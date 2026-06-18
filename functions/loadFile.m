function outLoadFile = loadFile(inLoadFile)
    selectedFile = inLoadFile.selectedFile;

    switch selectedFile
        case 1
            outLoadFile = loadFile1(inLoadFile);
        case 2
            outLoadFile = loadFile2(inLoadFile);
        case 3
            outLoadFile = loadFile2(inLoadFile);
        otherwise
            error('Invalid selectedFile value. Use 1 or 2.');
    end
end

%% loadFile1
function outLoadFile = loadFile1(inLoadFile)
    % Ekstrak sinyal PPG, ABP, dan frekuensi sampling

    targetPath = inLoadFile.targetPath;
    folderPath = inLoadFile.folderPath;
    fileList = inLoadFile.fileList;
    fileIndex = inLoadFile.fileIndex;

    % Bangun path lengkap ke file berdasarkan indeks
    filePath = fullfile(folderPath, fileList(fileIndex).name);
    
    % Muat data dari file
    dataLoad = load(filePath);

    % Ambil nama variabel utama di file .mat
    mainFields = fieldnames(dataLoad);
    mainVar    = mainFields{1};
    
    % Case-insensitive comparison
    if strcmpi(mainVar, 'PPGdata')
        outLoadFile.ppg = dataLoad.PPGdata.data(:, 1);
    elseif strcmpi(mainVar, 'data')
        outLoadFile.ppg = dataLoad.data.channel_1;
    else
        disp('struktur tidak dikenali');
    end
    
    % Baca file Excel target
    warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
    targetTable = readtable(targetPath);
    
    [~, baseName, ~] = fileparts(fileList(fileIndex).name);
    idList = strtrim(string(targetTable.ID)); % pastikan string array & trim

    matchIdx = find(strcmpi(idList, strtrim(baseName)), 1);
    
    % Deteksi jenis folder
    if contains(folderPath, 'ppg_bp', 'IgnoreCase', true)
        folderType = 'ppg_bp';
    elseif contains(folderPath, 'ppg_hb', 'IgnoreCase', true)
        folderType = 'ppg_hb';
    else
        folderType = 'unknown';
    end
    
    % Ambil target sesuai jenis folder
    if strcmp(folderType, 'ppg_bp')
        outLoadFile.sbp = targetTable.SBP_mmHg_(matchIdx);
        outLoadFile.dbp = targetTable.DBP_mmHg_(matchIdx);
        
        outLoadFile.age = targetTable.Age(matchIdx);
        outLoadFile.gender = targetTable.Gender(matchIdx);
    elseif strcmp(folderType, 'ppg_hb')
        outLoadFile.hb = targetTable.Hemoglobin_g_L_(matchIdx);
        
        outLoadFile.age = targetTable.Age_year_(matchIdx);
        outLoadFile.gender = targetTable.Gender(matchIdx);
    end
    
    % Tampilkan informasi file yang berhasil dimuat
    fprintf("Loaded file: %s\n", filePath);
end

%% loadFile2
function outLoadFile = loadFile2(inLoadFile)
    % Ekstrak sinyal PPG, ABP, dan frekuensi sampling

    folderPath = inLoadFile.folderPath;
    fileList = inLoadFile.fileList;
    fileIndex = inLoadFile.fileIndex;

    % Bangun path lengkap ke file berdasarkan indeks
    filePath = fullfile(folderPath, fileList(fileIndex).name);
    
    % Muat data dari file
    dataLoad = load(filePath);

    % Deteksi jenis folder
    if contains(folderPath, 'ppg_bp', 'IgnoreCase', true)
        folderType = 'ppg_bp';
    elseif contains(folderPath, 'ppg_hb', 'IgnoreCase', true)
        folderType = 'ppg_hb';
    else
        folderType = 'unknown';
    end
    
    % Ambil target sesuai jenis folder
    if strcmp(folderType, 'ppg_bp')
        outLoadFile.sbp = dataLoad.sbp;
        outLoadFile.dbp = dataLoad.dbp;
    elseif strcmp(folderType, 'ppg_hb')
        outLoadFile.hb = dataLoad.hb;
    end
    
    outLoadFile.ppgCycle = dataLoad.ppgCycle;
    outLoadFile.gender = double(strcmpi(string(dataLoad.gender), 'male')); % male = 1, female = 0
    outLoadFile.age = dataLoad.age;
    outLoadFile.fs = dataLoad.fs;
    
    % Tampilkan informasi file yang berhasil dimuat
    fprintf("Loaded file: %s\n", filePath);
end