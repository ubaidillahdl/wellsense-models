clear; clc; close all;

% 1. BACA DATA
sbp = readtable('features\nca_sbp_features.csv');
dbp = readtable('features\nca_dbp_features.csv');
hb = readtable('features\nca_hb_features.csv');

% ============================================================
% 2. STATISTIK DESKRIPTIF
% ============================================================
fprintf('=== STATISTIK DESKRIPTIF ===\n\n');
fprintf('Jumlah sampel SBP/DBP\t: %d\n', height(sbp));
fprintf('Jumlah sampel HB\t\t: %d\n\n', height(hb));

fprintf('SBP\t: Min = %.1f, Max = %.1f, Mean = %.1f\n', min(sbp.sbp), max(sbp.sbp), mean(sbp.sbp));
fprintf('DBP\t: Min = %.1f, Max = %.1f, Mean = %.1f\n', min(dbp.dbp), max(dbp.dbp), mean(dbp.dbp));
fprintf('HB\t: Min = %.1f, Max = %.1f, Mean = %.1f\n\n', min(hb.hb), max(hb.hb), mean(hb.hb));

fprintf('Usia SBP/DBP\t: Min = %.1f, Max = %.1f, Mean = %.1f\n', min(sbp.age), max(sbp.age), mean(sbp.age));
fprintf('Usia HB\t\t\t: Min = %.1f, Max = %.1f, Mean = %.1f\n\n', min(hb.age), max(hb.age), mean(hb.age));

fprintf('Gender SBP/DBP\t: Laki-laki = %d (%.1f%%), Perempuan = %d (%.1f%%)\n', ...
    sum(sbp.gender==1), sum(sbp.gender==1)/height(sbp)*100, ...
    sum(sbp.gender==0), sum(sbp.gender==0)/height(sbp)*100);
fprintf('Gender HB\t\t: Laki-laki = %d (%.1f%%), Perempuan = %d (%.1f%%)\n\n', ...
    sum(hb.gender==1), sum(hb.gender==1)/height(hb)*100, ...
    sum(hb.gender==0), sum(hb.gender==0)/height(hb)*100);

% ============================================================
% 3. PROPORSI KATEGORI SBP (Berdasarkan Klasifikasi Tekanan Darah)
% ============================================================
fprintf('=== PROPORSI KATEGORI SBP ===\n');
normal = sum(sbp.sbp >= 100 & sbp.sbp <= 140);
ekstrem_rendah = sum(sbp.sbp < 100);
ekstrem_tinggi = sum(sbp.sbp > 140);

fprintf('SBP Normal (100-140)\t: %d (%.1f%%)\n', normal, normal/height(sbp)*100);
fprintf('SBP Ekstrem Rendah (<100)\t: %d (%.1f%%)\n', ekstrem_rendah, ekstrem_rendah/height(sbp)*100);
fprintf('SBP Ekstrem Tinggi (>140)\t: %d (%.1f%%)\n\n', ekstrem_tinggi, ekstrem_tinggi/height(sbp)*100);

% ============================================================
% 4. PROPORSI KATEGORI DBP (Berdasarkan Klasifikasi Tekanan Darah)
% ============================================================
fprintf('=== PROPORSI KATEGORI DBP ===\n');
dbp_normal = sum(dbp.dbp >= 60 & dbp.dbp <= 90);
dbp_rendah = sum(dbp.dbp < 60);
dbp_tinggi = sum(dbp.dbp > 90);

fprintf('DBP Normal (60-90)\t: %d (%.1f%%)\n', dbp_normal, dbp_normal/height(dbp)*100);
fprintf('DBP Rendah (<60)\t: %d (%.1f%%)\n', dbp_rendah, dbp_rendah/height(dbp)*100);
fprintf('DBP Tinggi (>90)\t: %d (%.1f%%)\n\n', dbp_tinggi, dbp_tinggi/height(dbp)*100);

% ============================================================
% 5. PROPORSI KATEGORI HB (Berdasarkan Kadar Hemoglobin Normal)
% ============================================================
fprintf('=== PROPORSI KATEGORI HB ===\n');
hb_normal = sum(hb.hb >= 120 & hb.hb <= 160);
hb_rendah = sum(hb.hb < 120);
hb_tinggi = sum(hb.hb > 160);

fprintf('HB Normal (120-160)\t: %d (%.1f%%)\n', hb_normal, hb_normal/height(hb)*100);
fprintf('HB Rendah (<120)\t: %d (%.1f%%)\n', hb_rendah, hb_rendah/height(hb)*100);
fprintf('HB Tinggi (>160)\t: %d (%.1f%%)\n\n', hb_tinggi, hb_tinggi/height(hb)*100);

%% ============================================================
% 6. FIGURE 1: DISTRIBUSI TARGET (SBP, DBP, HB)
% ============================================================
figure();
pos = get(gcf, 'Position'); 
set(gcf, 'Position', [pos(1), pos(2), pos(3), pos(4)/3]);

subplot(1,3,1);
histogram(sbp.sbp, 'NumBins', 7);
xlabel('mmHg');
ylabel('Frekuensi');
title('Distribusi SBP');
grid on;

subplot(1,3,2);
histogram(dbp.dbp, 'NumBins', 7);
xlabel('mmHg');
% ylabel('Frekuensi');
title('Distribusi DBP');
grid on;

subplot(1,3,3);
histogram(hb.hb, 'NumBins', 7);
xlabel('g/L');
% ylabel('Frekuensi');
title('Distribusi Hb');
grid on;