% The main task is to process the IMU data, including calculating the Euler 
% angles (roll, pitch, yaw), the Direction Cosine Matrix (DCM), the local 
% gravity as well as the angular velocity of the Earth's rotation, and 
% representing the initial orientation as an axis/angle of rotation and a 
% quaternion. The results of each step are displayed on the console.
% Author, Date: Shiqi Jiang, 09.11.2023
%% Task 0: Data initialisation
clear; clc;
% Load IMU data
imuDataset = load('ex01_10042889.mat');
imuDataset_test = load('ex_01a_example_imubsp.mat');
imuData = imuDataset.imudata;

% Extract timestamp, gyros and accelerometer data from dataset
% timestamp = imuData(:, 1); % Timestamp data
gyroData = imuData(:, 2:4); % Gyro data
accelData = imuData(:, 5:7); % Accelerometer data
%% Task 1: Roll-， pitch and yaw angles, DCM
% Calculating Euler angles
roll = atan2(-mean(accelData(:, 2)), -mean(accelData(:, 3)));
pitch = atan(mean(accelData(:, 1)) / sqrt(mean(accelData(:, 2))^2 + ...
    mean(accelData(:, 3))^2));
yaw = atan2(-mean(gyroData(:, 2)), mean(gyroData(:, 1)));

% Converts radians to angles and limits them to [-180, 180].
roll_deg = wrapTo180(rad2deg(roll));
pitch_deg = wrapTo180(rad2deg(pitch));
yaw_deg = wrapTo180(rad2deg(yaw));

% Calculating the DCM - Method 1
C1_roll = [1 0 0; 0 cos(roll) sin(roll); 0 -sin(roll), cos(roll)];
C2_pitch = [cos(pitch) 0 -sin(pitch); 0 1 0; sin(pitch) 0 cos(pitch)];
C3_yaw = [cos(yaw) sin(yaw) 0; -sin(yaw) cos(yaw) 0; 0 0 1];
C_M1 = C1_roll * C2_pitch * C3_yaw;

% Calculating the DCM - Method 2
C_11 = cos(pitch)*cos(yaw);
C_12 = -cos(roll)*sin(yaw)+sin(roll)*sin(pitch)*cos(yaw);
C_13 = sin(roll)*sin(yaw)+cos(roll)*sin(pitch)*cos(yaw);
C_21 = cos(pitch)*sin(yaw);
C_22 = cos(roll)*cos(yaw)+sin(roll)*sin(pitch)*sin(yaw);
C_23 = -sin(roll)*cos(yaw)+cos(roll)*sin(pitch)*sin(yaw);
C_31 = -sin(pitch);
C_32 = sin(roll)*cos(pitch);
C_33 = cos(roll)*cos(pitch);
C_M2 = [C_11, C_12, C_13; C_21, C_22, C_23; C_31, C_32, C_33]'; % n -> b

% Calculating the DCM - Method 3
C_M3 = angle2dcm(yaw, pitch, roll);

% Displays the calculated Euler angles with deg and the DCM
disp("Initial roll angle [deg]: " + roll_deg);
disp("Initial pitch angle [deg]: : " + pitch_deg);
disp("Initial yaw angle [deg]: : " + yaw_deg);
disp("DCM with Method 1: ");
disp(C_M1);
disp("DCM with Method 2: ");
disp(C_M2);
disp("DCM with Method 3: ");
disp(C_M3);
%% Task 2: Gravity and Earth rotation
% Estimate the local gravity g, as well as the Earth rotation rate w_e
% g = sqrt(mean(accelData(:, 1))^2 + mean(accelData(:, 2))^2 + ...
%     mean(accelData(:, 3))^2);
% omega_e = sqrt(mean(gyroData(:, 1))^2 + mean(gyroData(:, 2))^2 + ...
%     mean(gyroData(:, 3))^2);

g = norm([mean(accelData(:, 1)), mean(accelData(:, 2)), ...
    mean(accelData(:, 3))]);
omega_e = norm([mean(gyroData(:, 1)), mean(gyroData(:, 2)), ...
    mean(gyroData(:, 3))]);
omega_e_deg_h = rad2deg(omega_e * 3600);

% Display the results
disp("The estimated local Gravity: " + g + ' [m/s^2]');
disp("The estimated Earth rotation rate: " + omega_e_deg_h + ' [deg/h]');
%% Task 3: Rotation vector and Quaternion
% Express the initial orientation by the rotation axis/angle representation
C = C_M1;
deltaV = [C(3, 2) - C(2, 3); C(1, 3) - C(3, 1); C(2, 1) - C(1, 2)];
u_nb = deltaV / norm(deltaV);

cos_delta = (trace(C) - 1) / 2;
sin_delta = sqrt(1 - cos_delta^2);
delta = atan2(sin_delta, cos_delta);

% Quaternion - Method 1
q_M1 = [cos(delta/2); sin(delta/2) .* u_nb];
% Quaternion - Method 2
a = (1/2) * sqrt(1 + trace(C));
q_M2 = [a; (1/(4*a)) .* deltaV];
q = q_M1;

% Display the results
disp("The initial orientation expressed by the rotation axis:");
disp(u_nb);
disp("and the angle: " + delta + " [rad]");
disp("and by the corresponding quaternion:");
disp(q);
