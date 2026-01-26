% === Load data ===
T = readmatrix('5c.txt');   % columns: vg, Id(Mn), Id(Mp), vg (dup)
Vg   = T(:,1);
Id_n = T(:,2);              % NMOS drain current
Id_p = -T(:,3);             % PMOS |drain current| (flip sign)

% Remove any nonpositive currents to avoid div-by-zero at exactly off
valid_n = Id_n > 0;
valid_p = Id_p > 0;

% --- Numerical gm = dId/dVg (central differences via gradient) ---
gm_n  = gradient(Id_n(valid_n), Vg(valid_n));
gm_p  = gradient(Id_p(valid_p), Vg(valid_p));

gmId_n = gm_n ./ Id_n(valid_n);
gmId_p = gm_p ./ Id_p(valid_p);

% Optional mild smoothing (comment out if you want raw values)
% gmId_n = smoothdata(gmId_n, 'movmean', 5);
% gmId_p = smoothdata(gmId_p, 'movmean', 5);

% --- Find maximum gm/Id for each device ---
[gmId_n_max, in] = max(gmId_n);
[gmId_p_max, ip] = max(gmId_p);

Vg_at_max_n = Vg(valid_n); Vg_at_max_n = Vg_at_max_n(in);
Vg_at_max_p = Vg(valid_p); Vg_at_max_p = Vg_at_max_p(ip);

% --- Technology "maximum gm/Id" and slope factor n ---
VT = 0.02585;                            % thermal voltage at ~300 K
gmId_max_tech = max(gmId_n_max, gmId_p_max);
n_est = 1 / (VT * gmId_max_tech);        % from gm/Id = 1/(n*VT) in subthreshold

% --- Plots ---
figure;
plot(Vg(valid_n), gmId_n, 'b-', 'DisplayName','NMOS'); hold on;
plot(Vg(valid_p), gmId_p, 'm-', 'DisplayName','PMOS');
plot(Vg_at_max_n, gmId_n_max, 'bo', 'DisplayName','NMOS max');
plot(Vg_at_max_p, gmId_p_max, 'mo', 'DisplayName','PMOS max');
xlabel('V_G (V)'); ylabel('g_m/I_D (1/V)'); grid on;
title('g_m/I_D vs V_G');
legend('Location','best');

% --- Print results ---
fprintf('NMOS: max gm/Id = %.2f 1/V at Vg = %.3f V\n', gmId_n_max, Vg_at_max_n);
fprintf('PMOS: max gm/Id = %.2f 1/V at Vg = %.3f V\n', gmId_p_max, Vg_at_max_p);
fprintf('Technology max gm/Id = %.2f 1/V  ->  slope factor n ≈ %.2f (at 300 K)\n', ...
        gmId_max_tech, n_est);
