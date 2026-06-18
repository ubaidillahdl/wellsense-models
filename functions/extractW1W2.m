function outExtractW1W2 = extractW1W2(cyclesPPG, idxValleysBeforePPG, tPPG, fs)
    % Hitung tinggi amplitudo
    [maxVal, maxIdx] = max(cyclesPPG);
    [minVal, ~] = min(cyclesPPG);
    amplitude = maxVal - minVal;

    valW1 = minVal + 0.5 * amplitude;
    valW2 = minVal + 0.66 * amplitude;

    % Titik W1
    idxLeftW1 = find(cyclesPPG(1:maxIdx) >= valW1, 1, 'first');
    idxRightW1 = maxIdx - 1 + find(cyclesPPG(maxIdx:end) <= valW1, 1, 'first');

    % Titik W2
    idxLeftW2 = find(cyclesPPG(1:maxIdx) >= valW2, 1, 'first');
    idxRightW2 = maxIdx - 1 + find(cyclesPPG(maxIdx:end) <= valW2, 1, 'first');

    tLeftW1 = tPPG(idxValleysBeforePPG + idxLeftW1 - 1);
    tRightW1 = tPPG(idxValleysBeforePPG + idxRightW1 - 1);

    tLeftW2 = tPPG(idxValleysBeforePPG + idxLeftW2 - 1);
    tRightW2 = tPPG(idxValleysBeforePPG + idxRightW2 - 1);
    
    tCyclePPG = (0:length(cyclesPPG)-1) / fs;
    
    cycleDuration    = tCyclePPG(end) - tCyclePPG(1);
    widthW1          = (idxRightW1 - idxLeftW1) / fs;
    widthW2          = (idxRightW2 - idxLeftW2) / fs;
    w1W2Ratio        = widthW1 / widthW2;
    w1centerTime     = (idxLeftW1 + idxRightW1) / fs;
    relWidthW1       = widthW1 / cycleDuration;
    relWidthW2       = widthW2 / cycleDuration;
    heartRate        = 60 / cycleDuration;
    sysTime          = tCyclePPG(maxIdx) - tCyclePPG(1);
    diasTime         = tCyclePPG(end) - tCyclePPG(maxIdx);
 
    %% Out
    outExtractW1W2.tLeftW1      = tLeftW1;
    outExtractW1W2.tRightW1     = tRightW1;    
    outExtractW1W2.tLeftW2      = tLeftW2;
    outExtractW1W2.tRightW2     = tRightW2;
    outExtractW1W2.idxLeftW1    = idxLeftW1;
    outExtractW1W2.idxLeftW2    = idxLeftW2;
    outExtractW1W2.idxRightW1   = idxRightW1;
    outExtractW1W2.idxRightW2   = idxRightW2;
    outExtractW1W2.valW1        = valW1;
    outExtractW1W2.valW2        = valW2;
    
    outExtractW1W2.cycleDuration    = cycleDuration;
    outExtractW1W2.widthW1          = widthW1;
    outExtractW1W2.widthW2          = widthW2;
    outExtractW1W2.w1W2Ratio        = w1W2Ratio;
    outExtractW1W2.w1centerTime     = w1centerTime;
    outExtractW1W2.relWidthW1       = relWidthW1;
    outExtractW1W2.relWidthW2       = relWidthW2;
    outExtractW1W2.heartRate        = heartRate;
    outExtractW1W2.sysTime          = sysTime;
    outExtractW1W2.diasTime         = diasTime;
end