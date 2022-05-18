close all; clc; clear all; clear global params_;
global params_
for id = 1 : 20
    params_.user.case_id = id;
    InitializeParams();
    LoadCase(); % This function is used to get benchmark case setup.
    DrawParkingScenario();
end

function LoadCase()
global params_
V = readmatrix([pwd, '\BenchmarkCases\Case', num2str(params_.user.case_id), '.csv']);
params_.task.x0 = V(1);
params_.task.y0 = V(2);
params_.task.theta0 = V(3);
params_.task.xf = V(4);
params_.task.yf = V(5);
params_.task.thetaf = V(6);

params_.obstacle.num_obs = V(7);
num_vertexes = V((7 + 1) : (7 + params_.obstacle.num_obs));
V(1 : (7 + params_.obstacle.num_obs)) = [];
params_.obstacle.obs = cell(1, params_.obstacle.num_obs);

for ii = 1 : params_.obstacle.num_obs
    x = [];
    y = [];
    for jj = 1 : num_vertexes(ii)
        x = [x, V(1)];
        y = [y, V(2)];
        V(1:2) = [];
    end

    elem.x = [x, x(1)];
    elem.y = [y, y(1)];
    params_.obstacle.obs{ii} = elem;
end
end

function DrawParkingScenario()
global params_
figure(params_.user.case_id);
set(0, 'DefaultLineLineWidth', 1);
hold on;
box on;
grid minor;
axis equal;
xmin = min(params_.task.x0, params_.task.xf) - 15;
xmax = max(params_.task.x0, params_.task.xf) + 15;
ymin = min(params_.task.y0, params_.task.yf) - 15;
ymax = max(params_.task.y0, params_.task.yf) + 15;
axis([xmin xmax ymin ymax]);
set(gcf, 'outerposition', get(0,'screensize'));

for jj = 1 : params_.obstacle.num_obs
    V = params_.obstacle.obs{jj};
    fill(V.x, V.y, [0.5 0.5 0.5], 'EdgeColor', 'None');
end

Arrow([params_.task.x0, params_.task.y0], [params_.task.x0 + cos(params_.task.theta0), params_.task.y0 + sin(params_.task.theta0)], 'Length', 16, 'BaseAngle', 90, 'TipAngle', 16, 'Width', 2);
Arrow([params_.task.xf, params_.task.yf], [params_.task.xf + cos(params_.task.thetaf), params_.task.yf + sin(params_.task.thetaf)], 'Length', 16, 'BaseAngle', 90, 'TipAngle', 16, 'Width', 2);

V = CreateVehiclePolygon(params_.task.x0, params_.task.y0, params_.task.theta0);
plot(V.x, V.y, 'g--', 'LineWidth', 2);

V = CreateVehiclePolygon(params_.task.xf, params_.task.yf, params_.task.thetaf);
plot(V.x, V.y, 'r--', 'LineWidth', 2);

text(xmin + 2, ymax - 2, ['Case ', num2str(params_.user.case_id)], 'FontSize', 24, 'FontName', 'Arial Narrow', 'FontWeight', 'bold');
end

function InitializeParams()
global params_
params_.vehicle.lw = 2.8;       % vehicle wheelbase
params_.vehicle.lf = 0.96;      % vehicle front hang length
params_.vehicle.lr = 0.929;     % vehicle rear hang length
params_.vehicle.lb = 1.942;     % vehicle width
end

function V = CreateVehiclePolygon(x, y, theta)
global params_
cos_theta = cos(theta);
sin_theta = sin(theta);
vehicle_half_width = params_.vehicle.lb * 0.5;
AX = x + (params_.vehicle.lf + params_.vehicle.lw) * cos_theta - vehicle_half_width * sin_theta;
BX = x + (params_.vehicle.lf + params_.vehicle.lw) * cos_theta + vehicle_half_width * sin_theta;
CX = x - params_.vehicle.lr * cos_theta + vehicle_half_width * sin_theta;
DX = x - params_.vehicle.lr * cos_theta - vehicle_half_width * sin_theta;
AY = y + (params_.vehicle.lf + params_.vehicle.lw) * sin_theta + vehicle_half_width * cos_theta;
BY = y + (params_.vehicle.lf + params_.vehicle.lw) * sin_theta - vehicle_half_width * cos_theta;
CY = y - params_.vehicle.lr * sin_theta - vehicle_half_width * cos_theta;
DY = y - params_.vehicle.lr * sin_theta + vehicle_half_width * cos_theta;
V.x = [AX, BX, CX, DX, AX];
V.y = [AY, BY, CY, DY, AY];
end