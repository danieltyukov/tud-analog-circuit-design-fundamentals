% === Load data (columns: v1, V(vsp), V(n001), Id(M1), Id(M2)) ===
T = readmatrix('5b.txt');            % exported from LTspice
VDSn = T(:,1);                        % NMOS: drain supply sweep (VDS > 0)
IDn  = T(:,4);                        % NMOS drain current

VSDp = T(:,2);                        % PMOS: source–drain (positive)
IDp  = T(:,5);                        % PMOS current (already positive in your file)
% If your Id(M2) had been negative, use: IDp = -T(:,5);

% === Choose a saturation window: top 30% of the sweep ===
frac = 0.30;
Nn = numel(VDSn);
Np = numel(VSDp);
idx_n = ( (1:Nn)' > (1-frac)*Nn );
idx_p = ( (1:Np)' > (1-frac)*Np );

% --- NMOS: fit ID vs VDS in saturation ---
pn = polyfit(VDSn(idx_n), IDn(idx_n), 1);   % ID ≈ m*VDS + b
m_n = pn(1);  b_n = pn(2);
lambda_n = m_n / b_n;                       % λn

% --- PMOS: treat VSD as the positive sweep variable ---
pp = polyfit(VSDp(idx_p), IDp(idx_p), 1);   % ID ≈ m*VSD + b
m_p = pp(1);  b_p = pp(2);
lambda_p = m_p / b_p;                       % λp  (using VSD; same magnitude)

% === Plots ===
figure; 
plot(VDSn, IDn, '.'); hold on; 
plot(VDSn(idx_n), polyval(pn, VDSn(idx_n)), 'LineWidth',1.5);
xlabel('V_{DS,n} (V)'); ylabel('I_{D,n} (A)'); title('NMOS: I_D–V_{DS} fit');

figure; 
plot(VSDp, IDp, '.'); hold on; 
plot(VSDp(idx_p), polyval(pp, VSDp(idx_p)), 'LineWidth',1.5);
xlabel('V_{SD,p} (V)'); ylabel('I_{D,p} (A)'); title('PMOS: I_D–V_{SD} fit');

% === Print results ===
fprintf('lambda_n = %.4f 1/V (from top %.0f%% of VDS range)\n', lambda_n, 100*frac);
fprintf('lambda_p = %.4f 1/V (from top %.0f%% of VSD range)\n', lambda_p, 100*frac);
