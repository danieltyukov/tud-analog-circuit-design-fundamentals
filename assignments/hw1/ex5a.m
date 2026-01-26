% Load LTspice exported data
data = readmatrix('5a.txt');   % assumes columns: vg, Id(M1), Id(M2)
Vg   = data(:,1);              % gate voltage sweep
Id_n = data(:,2);              % NMOS drain current
Id_p = -data(:,3);             % PMOS drain current (flip sign)

% Device geometry
W = 3e-6;      % 3 µm
L = 0.18e-6;   % 0.18 µm
WL = W/L;

%% --- NMOS extraction ---
% Consider strong inversion region for fitting (e.g. Vg > 0.4 V)
idx_n = Vg > 0.4 & Vg < 1.0;  

x_n = Vg(idx_n);
y_n = sqrt(Id_n(idx_n));

p_n = polyfit(x_n, y_n, 1);  % linear fit
slope_n = p_n(1);
intercept_n = p_n(2);

Vth_n = -intercept_n/slope_n;   % x-intercept = threshold voltage
muCox_n = (2/WL) * slope_n^2;   % slope^2 = µCox*W/(2L)

%% --- PMOS extraction ---
% For PMOS, VSG = vg (since you swept source at VDD, gate down to 0)
idx_p = Vg > 0.4 & Vg < 1.0;  

x_p = Vg(idx_p);
y_p = sqrt(Id_p(idx_p));

p_p = polyfit(x_p, y_p, 1);
slope_p = p_p(1);
intercept_p = p_p(2);

Vth_p = -intercept_p/slope_p;
muCox_p = (2/WL) * slope_p^2;

%% --- Plot results ---
figure;
subplot(1,2,1);
plot(Vg, sqrt(Id_n), 'b'); hold on;
plot(x_n, polyval(p_n, x_n), 'r--');
xlabel('V_GS (V)'); ylabel('\surd I_D (A^{1/2})');
title('NMOS Extraction');
legend('Data','Fit');

subplot(1,2,2);
plot(Vg, sqrt(Id_p), 'm'); hold on;
plot(x_p, polyval(p_p, x_p), 'r--');
xlabel('V_SG (V)'); ylabel('\surd I_D (A^{1/2})');
title('PMOS Extraction');
legend('Data','Fit');

%% --- Print extracted parameters ---
fprintf('NMOS: Vth = %.3f V, µnCox = %.3e A/V^2\n', Vth_n, muCox_n);
fprintf('PMOS: Vth = %.3f V, µpCox = %.3e A/V^2\n', Vth_p, muCox_p);
