clear; clc; close all;

% ============================================================
% 1. BACA DATA TERPISAH (Sesuai Gambar)
% ============================================================

% Data SBP (19 baris)
sbp_age = [24; 23; 19; 18; 18; 18; 18; 18; 25; 18; 21; 17; 17; 22; 18; 17; 17; 18; 17];
sbp_gender = [1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 0; 0; 0; 0; 0; 0; 0; 0]; % 1=L, 0=P
sbp_val = [130; 124; 129; 136; 120; 118; 118; 108; 117; 123; 121; 100; 110; 127; 116; 117; 122; 123; 123];

sbp = table(sbp_age, sbp_gender, sbp_val, 'VariableNames', {'age', 'gender', 'sbp'});


% Data DBP (21 baris)
dbp_age = [24; 23; 19; 18; 18; 18; 18; 18; 25; 18; 21; 17; 17; 22; 18; 17; 18; 17; 18; 17; 18];
dbp_gender = [1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0]; % 1=L, 0=P
dbp_val = [86; 61; 64; 71; 70; 66; 66; 62; 64; 65; 70; 61; 60; 77; 63; 73; 80; 77; 62; 70; 82];

dbp = table(dbp_age, dbp_gender, dbp_val, 'VariableNames', {'age', 'gender', 'dbp'});


% Data HB (20 baris)
hb_age = [24; 23; 19; 18; 18; 18; 18; 18; 18; 21; 17; 22; 18; 17; 18; 17; 18; 17; 17; 18];
hb_gender = [1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0]; % 1=L, 0=P
hb_val = [156; 153; 174; 160; 140; 137; 127; 160; 158; 148; 137; 130; 132; 130; 138; 134; 121; 123; 142; 132];

hb = table(hb_age, hb_gender, hb_val, 'VariableNames', {'age', 'gender', 'hb'});

% ============================================================
% 2. STATISTIK DESKRIPTIF
% ============================================================
fprintf('=== STATISTIK DESKRIPTIF ===\n\n');
fprintf('Jumlah sampel SBP\t: %d\n', height(sbp));
fprintf('Jumlah sampel DBP\t: %d\n', height(dbp));
fprintf('Jumlah sampel HB\t\t: %d\n\n', height(hb));

fprintf('SBP\t: Min = %.1f, Max = %.1f, Mean = %.1f\n', min(sbp.sbp), max(sbp.sbp), mean(sbp.sbp));
fprintf('DBP\t: Min = %.1f, Max = %.1f, Mean = %.1f\n', min(dbp.dbp), max(dbp.dbp), mean(dbp.dbp));
fprintf('HB\t: Min = %.1f, Max = %.1f, Mean = %.1f\n\n', min(hb.hb), max(hb.hb), mean(hb.hb));

fprintf('Usia SBP\t: Min = %.1f, Max = %.1f, Mean = %.1f\n', min(sbp.age), max(sbp.age), mean(sbp.age));
fprintf('Usia DBP\t: Min = %.1f, Max = %.1f, Mean = %.1f\n', min(dbp.age), max(dbp.age), mean(dbp.age));
fprintf('Usia HB\t\t\t: Min = %.1f, Max = %.1f, Mean = %.1f\n\n', min(hb.age), max(hb.age), mean(hb.age));

fprintf('Gender SBP\t: Laki-laki = %d (%.1f%%), Perempuan = %d (%.1f%%)\n', ...
    sum(sbp.gender==1), sum(sbp.gender==1)/height(sbp)*100, ...
    sum(sbp.gender==0), sum(sbp.gender==0)/height(sbp)*100);
fprintf('Gender DBP\t: Laki-laki = %d (%.1f%%), Perempuan = %d (%.1f%%)\n', ...
    sum(dbp.gender==1), sum(dbp.gender==1)/height(dbp)*100, ...
    sum(dbp.gender==0), sum(dbp.gender==0)/height(dbp)*100);
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

fprintf('SBP Normal (100-140)\t\t: %d (%.1f%%)\n', normal, normal/height(sbp)*100);
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

% ============================================================
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
title('Distribusi DBP');
grid on;

subplot(1,3,3);
histogram(hb.hb, 'NumBins', 7);
xlabel('g/L');
title('Distribusi Hb');
grid on;