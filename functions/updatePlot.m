function outUpdatePlot = updatePlot(inUpdatePlot)
    % Memilih fungsi update plot berdasarkan nilai selectedFile
    switch inUpdatePlot.selectedFile
        case 1
            outUpdatePlot = updatePlot1(inUpdatePlot);
        case 2
            outUpdatePlot = updatePlot2(inUpdatePlot);
        otherwise
            error('Invalid selectedFile value. Use 1 or 2.');
    end
end

%% updatePlot1
function outUpdatePlot = updatePlot1(inUpdatePlot)
    % Ambil data dan parameter utama dari input struktur
    ppg = inUpdatePlot.ppg;
    fs = inUpdatePlot.fs;
    fileIndex = inUpdatePlot.fileIndex;
    fileList = inUpdatePlot.fileList;
    
    % Ambil handle plot dan axes untuk update grafik
    hPlot1 = inUpdatePlot.plot.hPlot(1);
    hPlot2 = inUpdatePlot.plot.hPlot(2);
    hPlot3 = inUpdatePlot.plot.hPlot(3);
    hAx1 = inUpdatePlot.plot.hAx(1);
    hAx2 = inUpdatePlot.plot.hAx(2);
    hAx3 = inUpdatePlot.plot.hAx(3);
    
    %% Warna hijau, nama file, normalisasi sinyal, dan waktu sinyal
    green = [0 0.6 0];
    currentFileName = fileList(fileIndex).name;
    ppg = (ppg - min(ppg)) / (max(ppg) - min(ppg));
    tPPG = (0:length(ppg) - 1) / fs;

    % Filter bandpass Chebyshev II 0.5–8 Hz, orde 4, attenuasi 40 dB
    Rs = 40; 
    [b, a] = cheby2(4, Rs, [0.5 8] / (fs / 2), 'bandpass');
    ppg = filtfilt(b, a, ppg);

    %% Cari segmen baik dari sinyal PPG
    segmentDuration = 4;
    [segments, tSegments, nSegments] = ppgSegment(ppg, fs, tPPG, segmentDuration);
    
    % Tentukan indeks segmen terbaik berdasarkan kualitas siklus
    bestSegmentIdx = findBestSegment(segments, nSegments, fs);
    
    % Jika tidak ada segmen terbaik, hapus plot dan tampilkan garis lurus kosong
    if bestSegmentIdx == 0
        delete(findobj([hAx1, hAx2], 'Tag', 'PeakPlot'));
        
        xDummy = [0, max(tPPG)];  
        yDummy = [0, 0];   
        
        set(hPlot2, 'XData', xDummy, 'YData', yDummy);
        set(hPlot3, 'XData', xDummy, 'YData', yDummy);
        
        outUpdatePlot.ppgCycle  = NaN;
        outUpdatePlot.tPpgCycle = NaN;
        return;
    end
    
    % Ambil sinyal dan waktu segmen terbaik
    bestSegment = segments{bestSegmentIdx};
    tBestSegment = tSegments{bestSegmentIdx};

    % Deteksi puncak dan lembah pada segmen terbaik
    minProm = 0.9 * max(bestSegment);
    minDist = round(0.4 * fs);
    
    [~, idxPeaks]   = findpeaks(bestSegment,  'MinPeakProminence', minProm, 'MinPeakDistance', minDist);
    [~, idxValleys] = findpeaks(-bestSegment, 'MinPeakProminence', minProm, 'MinPeakDistance', minDist);

    % Filter puncak dan lembah yang valid
    [idxValidPeaks, idxValleysBefore, idxValleysAfter] = validPeaks(idxPeaks, idxValleys);
    
    % Potong siklus dan cari siklus G1 terbaik serta siklus template terbaik
    [cycles, tCycles, g1Idx, ~, bCycle] = cutCycle(bestSegment, idxValleysBefore, idxValleysAfter, fs);

    % Bersihkan plot puncak sebelumnya agar tidak bertumpuk
    delete(findobj(hAx1, 'Tag', 'PeakPlot'));
    delete(findobj(hAx2, 'Tag', 'PeakPlot'));
    
    %% Perbarui plot sinyal PPG keseluruhan
    set(hPlot1, 'XData', tPPG, 'YData', ppg);
    title(hAx1, sprintf('Long PPG Signal ( %d/%d - %s )', fileIndex, length(fileList), currentFileName));

    %% Perbarui plot segmen terbaik dan tandai puncak & lembah
    set(hPlot2, 'XData', tBestSegment, 'YData', bestSegment);
    hold(hAx2, 'on');

    % Plot semua puncak & lembah dari siklus G1 (valid) dengan marker hitam
    plot(hAx2, tBestSegment(idxValidPeaks(g1Idx)), bestSegment(idxValidPeaks(g1Idx)), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 4, 'Tag', 'PeakPlot');
    plot(hAx2, tBestSegment(idxValleysBefore(g1Idx)), bestSegment(idxValleysBefore(g1Idx)), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 4 ,'Tag', 'PeakPlot');
    plot(hAx2, tBestSegment(idxValleysAfter(g1Idx)), bestSegment(idxValleysAfter(g1Idx)), 'ko',  'MarkerFaceColor', 'k', 'MarkerSize', 4, 'Tag', 'PeakPlot');

    % Tandai siklus terbaik (bCycle) dengan marker hijau
    plot(hAx2, tBestSegment(idxValidPeaks(bCycle)), bestSegment(idxValidPeaks(bCycle)), 'o', 'MarkerEdgeColor', green, 'MarkerFaceColor', green,  'Tag', 'PeakPlot');
    plot(hAx2, tBestSegment(idxValleysBefore(bCycle)), bestSegment(idxValleysBefore(bCycle)), 'o', 'MarkerEdgeColor', green, 'MarkerFaceColor', green, 'Tag', 'PeakPlot');
    plot(hAx2, tBestSegment(idxValleysAfter(bCycle)), bestSegment(idxValleysAfter(bCycle)), 'o', 'MarkerEdgeColor', green, 'MarkerFaceColor', green, 'Tag', 'PeakPlot');

    hold(hAx2, 'off')
    title(hAx2, sprintf('Best Segment PPG'));

    %% Perbarui plot siklus terbaik
    set(hPlot3, 'XData', tCycles{bCycle}, 'YData', cycles{bCycle});
    title(hAx3, sprintf('Best Cycle PPG'));
    
    %% Output
    outUpdatePlot.ppgCycle  = cycles{bCycle};
    outUpdatePlot.tPpgCycle = tCycles{bCycle};
end

function bestSegmentIdx = findBestSegment(segments, nSegments, fs)
    bestSegmentIdx = 0;
    bestAvgCorr = -inf;  % Simpan skor kualitas tertinggi (avgCorr)

    for segIdx = 1:nSegments
        % Ambil sinyal segmen ini
        segPPG = segments{segIdx};
        
        % Deteksi puncak dan lembah pada sinyal PPG 
        minProm = 0.9 * max(segPPG);
        minDist = round(0.4 * fs); 

        [~, idxPeaks]   = findpeaks(segPPG,  'MinPeakProminence', minProm, 'MinPeakDistance', minDist);
        [~, idxValleys] = findpeaks(-segPPG, 'MinPeakProminence', minProm, 'MinPeakDistance', minDist);

        [idxValidPeaks, idxValleysBefore, idxValleysAfter] = validPeaks(idxPeaks, idxValleys);

        nCycle = length(idxValidPeaks);

        % Skip kalau nggak ada siklus sama sekali
        if nCycle <= 0
            continue;
        end
        
        % Potong siklus & hitung SQI
        [~, ~, g1Idx, avgCorr, ~] = cutCycle(segPPG, idxValleysBefore, idxValleysAfter, fs);
        
        if isempty(g1Idx) || isnan(avgCorr)
            continue;
        end
        
        % Pilih segmen dengan rata-rata korelasi tertinggi
        if avgCorr > bestAvgCorr
            bestAvgCorr = avgCorr;
            bestSegmentIdx = segIdx;
        end
    end
end

function [cycles, tCycles, g1Idx, avgCorr, bestCycle] = cutCycle(segPPG, idxValleysBefore, idxValleysAfter, fs)
    % Jumlah siklus
    nCycle = length(idxValleysBefore);

    % Inisialisasi sel array untuk menyimpan sinyal dan waktu per siklus
    cycles   = cell(nCycle, 1);
    tCycles  = cell(nCycle, 1);

    % Potong sinyal untuk setiap siklus
    for i = 1:nCycle
        cycles{i}  = segPPG(idxValleysBefore(i):idxValleysAfter(i));
        tCycles{i} = (0:length(cycles{i}) - 1) / fs;
    end

    [bestCycle, g1Idx, avgCorr] = findBestPPGCycle(cycles);
end

function [bestCycle, g1Idx, avgCorr] = findBestPPGCycle(cycles)
    % Hitung SQI: skewness & kurtosis
    sqiResult = cell(length(cycles), 3);
    for i = 1:length(cycles)
        yPPG = cycles{i};
        sqiResult{i,1} = i;
        sqiResult{i,2} = skewness(yPPG);
        sqiResult{i,3} = kurtosis(yPPG);
    end

    % Filter siklus dengan kriteria G1 (skewness dan kurtosis)
    skewnessVals = cell2mat(sqiResult(:,2));
    kurtosisVals = cell2mat(sqiResult(:,3));

    g1Idx = find( ...
        skewnessVals >= -1 & skewnessVals <= 1.5 & ...
        kurtosisVals >= 2 & kurtosisVals <= 5);

    if isempty(g1Idx)
        bestCycle = NaN;
        avgCorr = NaN; 
        return;
    end

    % Cari panjang minimal dari siklus yang lolos filter
    minLen = min(cellfun(@length, cycles(g1Idx)));

    % Potong semua siklus ke panjang minimal dan simpan di matrix
    alignedCycles = zeros(minLen, length(g1Idx));
    for k = 1:length(g1Idx)
        idx = g1Idx(k);
        alignedCycles(:, k) = cycles{idx}(1:minLen);
    end

    % Buat template PPG dari rata-rata semua siklus yang sudah align
    templatePPG = mean(alignedCycles, 2);

    % Inisialisasi nilai terbaik
    bestScore = -inf;
    bestCycle = NaN;
    corrScores = zeros(1, length(g1Idx));
    for k = 1:length(g1Idx)
        currentCycle = alignedCycles(:,k);
        corrVal = corrcoef(currentCycle, templatePPG);
        score = corrVal(1,2);
        corrScores(k) = score;

        if score > bestScore
            bestScore = score;
            bestCycle = g1Idx(k);
        end
    end

    avgCorr = mean(corrScores);
end

function [segments, tSegments, nSegments] = ppgSegment(ppg, fs, tPPG, segmentDuration)
    % Hitung jumlah segmen dulu
    segmentSamples  = round(segmentDuration * fs);
    nSegments = ceil(length(ppg) / segmentSamples);

    % Preallocate
    segments   = cell(nSegments, 1);
    tSegments  = cell(nSegments, 1);

    startIdx = 1;
    for i = 1:nSegments
        endIdx = min(startIdx + segmentSamples - 1, length(ppg));
        segments{i}  = ppg(startIdx:endIdx);
        tSegments{i} = tPPG(startIdx:endIdx);
        startIdx = endIdx + 1;
    end
end

%% updatePlot2
function outUpdatePlot = updatePlot2(inUpdatePlot)
    % Ambil data dan parameter utama dari input struktur
    ppgCycle = inUpdatePlot.ppgCycle;
    ppgAll = inUpdatePlot.ppgAll;
    fs = inUpdatePlot.fs;
    fileIndex = inUpdatePlot.fileIndex;
    fileList = inUpdatePlot.fileList;
    
    % Ambil handle plot dan axes untuk update grafik
    hPlot2 = inUpdatePlot.plot.hPlot;
    hAx1 = inUpdatePlot.plot.hAx(1);
    hAx2 = inUpdatePlot.plot.hAx(2);
    
    %% Warna hijau, nama file, normalisasi sinyal, dan waktu sinyal
    currentFileName = fileList(fileIndex).name;
    tPpgCycle = (0:length(ppgCycle) - 1) / fs;
    
    [~, idxPeaks]   = findpeaks(ppgCycle);
 
    outExtractW1W2 = extractW1W2(ppgCycle, 1, tPpgCycle, fs);
      
    idxLeftW1    = outExtractW1W2.idxLeftW1;
    idxLeftW2    = outExtractW1W2.idxLeftW2;
    idxRightW1   = outExtractW1W2.idxRightW1;
    idxRightW2   = outExtractW1W2.idxRightW2;
    valW1        = outExtractW1W2.valW1;
    valW2        = outExtractW1W2.valW2;

    cycleDuration    = outExtractW1W2.cycleDuration;
    widthW1          = outExtractW1W2.widthW1;
    widthW2          = outExtractW1W2.widthW2;
    w1W2Ratio        = outExtractW1W2.w1W2Ratio;
    w1centerTime     = outExtractW1W2.w1centerTime;
    relWidthW1       = outExtractW1W2.relWidthW1;
    relWidthW2       = outExtractW1W2.relWidthW2;
    heartRate        = outExtractW1W2.heartRate;
    sysTime          = outExtractW1W2.sysTime;
    diasTime         = outExtractW1W2.diasTime;
    
    % Bersihkan plot puncak sebelumnya agar tidak bertumpuk
    delete(findobj(hAx1, 'Tag', 'PeakPlot'));
    delete(findobj(hAx2, 'Tag', 'PeakPlot'));

    %% Perbarui plot PPG keseluruhan
    hold(hAx1, 'on');
    
    for i = 1:length(ppgAll)
        plot(hAx1, ppgAll{i});
    end
    
    hold(hAx1, 'off');
    title(hAx1, sprintf('All PPG Cycle'));

    %% Perbarui plot PPG
    set(hPlot2, 'XData', tPpgCycle, 'YData', ppgCycle);
    hold(hAx2, 'on');
    
    plot(hAx2, tPpgCycle(idxPeaks(1)), ppgCycle(idxPeaks(1)), 'ro', 'MarkerFaceColor', 'r', 'Tag', 'PeakPlot');
    plot(hAx2, tPpgCycle(1), ppgCycle(1), 'kv', 'MarkerFaceColor', 'k', 'Tag', 'PeakPlot');
    plot(hAx2, tPpgCycle(end), ppgCycle(end), 'kv', 'MarkerFaceColor', 'k', 'Tag', 'PeakPlot');
    
    plot(hAx2, [tPpgCycle(idxLeftW1), tPpgCycle(idxRightW1)], [valW1, valW1], 'k-.', 'Tag', 'PeakPlot');
    plot(hAx2, [tPpgCycle(idxLeftW2), tPpgCycle(idxRightW2)], [valW2, valW2], 'k-.', 'Tag', 'PeakPlot');

    plot(hAx2, tPpgCycle(idxLeftW1), valW1, 'kd', 'MarkerFaceColor', 'k','Tag', 'PeakPlot');
    plot(hAx2, tPpgCycle(idxRightW1), valW1, 'kd', 'MarkerFaceColor', 'k','Tag', 'PeakPlot');
    plot(hAx2, tPpgCycle(idxLeftW2), valW2, 'ks', 'MarkerFaceColor', 'k','Tag', 'PeakPlot');
    plot(hAx2, tPpgCycle(idxRightW2), valW2, 'ks', 'MarkerFaceColor', 'k','Tag', 'PeakPlot');
    
    hold(hAx2, 'off')
    title(hAx2, sprintf('PPG Cycle ( %d/%d - %s )', fileIndex, length(fileList), currentFileName));

    %% Out
    outUpdatePlot.cycleDuration     = cycleDuration;
    outUpdatePlot.widthW1           = widthW1;
    outUpdatePlot.widthW2           = widthW2;
    outUpdatePlot.w1W2Ratio         = w1W2Ratio;
    outUpdatePlot.w1centerTime      = w1centerTime;
    outUpdatePlot.relWidthW1        = relWidthW1;
    outUpdatePlot.relWidthW2        = relWidthW2;
    outUpdatePlot.heartRate         = heartRate;
    outUpdatePlot.sysTime           = sysTime;
    outUpdatePlot.diasTime          = diasTime;
end