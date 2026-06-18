function [idxValidPeaks, idxValleysBefore, idxValleysAfter] = validPeaks(idxPeaks, idxValleys)
    idxValidPeaks = [];
    idxValleysBefore = [];
    idxValleysAfter = [];
    
    for i = 1:length(idxPeaks)
        currentPeak = idxPeaks(i);

        % Cari lembah sebelum dan sesudah puncak ini
        prevValleyIdx = find(idxValleys < currentPeak, 1, 'last');
        nextValleyIdx = find(idxValleys > currentPeak, 1, 'first');

        % Jika kedua lembah ditemukan, simpan puncak dan lembah terkait sebagai valid
        if ~isempty(prevValleyIdx) && ~isempty(nextValleyIdx)
            idxValidPeaks(end+1) = currentPeak;            %#ok<AGROW>
            idxValleysBefore(end+1) = idxValleys(prevValleyIdx); %#ok<AGROW>
            idxValleysAfter(end+1) = idxValleys(nextValleyIdx);   %#ok<AGROW>
        end
    end
end
