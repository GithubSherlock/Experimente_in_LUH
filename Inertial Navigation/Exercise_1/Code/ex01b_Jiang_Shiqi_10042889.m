% This code implements loading the IMU data, extracting the timestamps, 
% gyroscope and accelerometer data and pre-processing them. Then the 
% average values of the gravitational acceleration and the angular velocity
% of the Earth's rotation are computed and the Direction Cosine Matrix 
% (DCM) is computed based on these values. Finally, cyclic updating of the 
% DCM using the gyroscope data and the timestamp data completes the 
% processing of the IMU data and updating the attitude.
% Author, Date: Shiqi Jiang, 13.11.2023
%% Task 0: Data initialisation and pre-proccessing
clear; clc;
% Load IMU data
imuDataset = load('ex01_10042889.mat');
imuDataset_test = load('ex_01b_example_FOG_IMU.mat');
imuData = imuDataset.imudata;

% Extract timestamp, gyros and accelerometer data from dataset
timestamp = imuData(:, 1); % Timestamp data
gyroData = imuData(:, 2:4); % Gyros data
accelData = imuData(:, 5:7); % Accelerometer data

% Data pre-proccessing
Delta_t = (timestamp(end, 1) - timestamp(1, 1)) / size(timestamp, 1);
varphi_deg = 52.385828; % deg
varphi = deg2rad(varphi_deg);
I = eye(3);
EulerAngles = [];
output = []; % Initialize result matrix
%% Task 4: Direct calculation of the direction cosine matrix
% Direct calculation
g = norm([mean(accelData(:, 1)), mean(accelData(:, 2)), ...
    mean(accelData(:, 3))]);
omega_e = norm([mean(gyroData(:, 1)), mean(gyroData(:, 2)), ...
    mean(gyroData(:, 3))]);
omega_e_deg_h = rad2deg(omega_e * 3600); % Equal to the result in part A
g_N = [0; 0; -g];
omega_N_ie = omega_e * [cos(varphi); 0; -sin(varphi)];
f_B_ib = [mean(accelData(:, 1)); mean(accelData(:, 2)); ...
    mean(accelData(:, 3))];
omega_B_ib = [mean(gyroData(:, 1)); mean(gyroData(:, 2)); ...
    mean(gyroData(:, 3))];

C_B_n = [f_B_ib omega_B_ib cross(f_B_ib, omega_B_ib)] / ...
        [g_N omega_N_ie cross(g_N, omega_N_ie)];

% Check if the new matrix is still orthogonal
disp("The DCM is:")
disp(C_B_n)
if round(C_B_n * C_B_n.') == eye(size(C_B_n))
    disp("The DCM is orthogonal!")
else
    disp("The DCM is NOT orthogonal!")
end

% Reorthogonalization
C_ort = C_B_n * (C_B_n' * C_B_n)^(-0.5);
disp("The reorthogonalized DCM is:")
disp(C_ort)

if round(C_ort' * C_ort) == eye(size(C_ort))
    disp("The reorthogonalized DCM is orthogonal!")
else
    disp("The reorthogonalized DCM is NOT orthogonal!")
end

%% Task 5: Attitude Update
% Attitude Update
C_N_b = C_ort';
for i = 1:size(timestamp, 1) % for-loop for index of imudata
    omega_x = gyroData(i,1); % Index of gyros data in x-Coordinate
    omega_y = gyroData(i,2); % Index of gyros data in y-Coordinate
    omega_z = gyroData(i,3); % Index of gyros data in z-Coordinate
    t = timestamp(i);
    % Calculating the Transportation rate and Earth turn rate
    omega_B_ib = [omega_x; omega_y; omega_z];
    omega_N_en = [0; 0; 0];
    omega_B_nb = omega_B_ib - C_ort *(omega_N_ie + omega_N_en);
    % Closed from solution
    delta = omega_B_nb * Delta_t;
    deltaNorm = norm(delta);
    % Orientation matrix
    D = [0 -delta(3, 1) delta(2, 1); delta(3, 1) 0 -delta(1, 1); ...
        -delta(2, 1) delta(1, 1) 0];
    % Calculating the new DCM for update and its reorthogonalization
    C2Update_N_b = C_N_b * (I + (sin(deltaNorm)/deltaNorm) * D + ...
        (1-cos(deltaNorm))/(deltaNorm^2) * D^2); % Rodrigues' formula
    C2Update_ort = C2Update_N_b * (C2Update_N_b' * C2Update_N_b)^(-0.5); % Reorthogonalization
    % Calculating Euler angles
    roll = atan2(C2Update_ort(3, 2), C2Update_ort(3, 3));
    pitch = asin(-C2Update_ort(3, 1));
    yaw = atan2(C2Update_ort(2, 1), C2Update_ort(1, 1));
    roll_deg = wrapTo180(rad2deg(roll));
    pitch_deg = wrapTo180(rad2deg(pitch));
    yaw_deg = wrapTo180(rad2deg(yaw));
    % Save output and update
    EulerAngles = [t, roll_deg, pitch_deg, yaw_deg];
    output = [output; EulerAngles];
    C_N_b = C2Update_ort;
    C_ort = C_N_b';
end

% Display the estimation the final Euler Angles of imuData
disp("The estimated final Roll Angle is: " + output(end, 2));
disp("The estimated final Pitch Angle is: " + output(end, 3));
disp("The estimated final Yaw Angle is: " + output(end, 4));

% Visualization 1
% figure; % Plot Roll
% plot(output(:, 1), output(:, 2));
% xlabel('t[s]');
% ylabel('roll[deg]');
% title('Roll[deg] over time');
% 
% figure; % Plot Pitch
% plot(output(:, 1), output(:, 3));
% xlabel('t[s]');
% ylabel('pitch[deg]');
% title('Pitch[deg] over time');
% 
% figure; % Plot Yaw
% plot(output(:, 1), output(:, 4));
% xlabel('t[s]');
% ylabel('yaw[deg]');
% title('Yaw[deg] over time');

% Visualization 2 - Subplot
figure;
subplot(3, 1, 1); % Plot Roll and divide the window into the first section
plot(output(:, 1), output(:, 2));
% xlabel('time [s]');
ylabel('roll [deg]');
title('Roll over time');
grid on;

subplot(3, 1, 2); % Plot Pitch and divide the window into the second section
plot(output(:, 1), output(:, 3));
% xlabel('time [s]');
ylabel('pitch [deg]');
title('Pitch over time');
grid on;

subplot(3, 1, 3); % Plot Pitch and divide the window into the third section
plot(output(:, 1), output(:, 4));
xlabel('time [s]');
ylabel('yaw [deg]');
title('Yaw over time');
grid on;

sgtitle('Euler Angles over time');
