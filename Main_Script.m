%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   CALCULATING THE ENERGY DISTRIBUTION                   %
%This script focuses on the Pierson-Moskowitz and JONSWAP equations,      %
%comparing both equations to hindcast data.                               %
%Author: Ben Churchill                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Implementing NC Toolbox

cd C:\Users\Ben\Desktop\Modelling_the_Sea_Surface_of_Cardigan_Bay\nctoolbox-master\

dir

version('-java')
java


setup_nctoolbox

%Calling the GEBSCO Database

GEBSCOncFile = 'C:\Users\Ben\Desktop\Modelling_the_Sea_Surface_of_Cardigan_Bay\GEBCO_18_Mar_2024_2f383aefa43b\gebco_2023_n53.0296_s51.8925_w-5.6332_e-3.9029.nc';
ncinfo(GEBSCOncFile)
ncdisp(GEBSCOncFile)
GEBSCOascFile = importdata('C:\Users\Ben\Desktop\Modelling_the_Sea_Surface_of_Cardigan_Bay\GEBCO_18_Mar_2024_2f383aefa43b\gebco_2023_n53.0296_s51.8925_w-5.6332_e-3.9029.asc')

elevation = ncread(GEBSCOncFile,'elevation');
longitute = ncread(GEBSCOncFile,'lon');
latitude = ncread(GEBSCOncFile,'lat');

ncdispelevation = ncread(GEBSCOncFile,'elevation');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     PLOTTING BATHYMETRIC DATA                           %
%Bathymetric data is the sea depth of a given area. %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure

imagesc(ncdispelevation')
set(gca,'YDir','normal')
c = colorbar;
c.Label.String = 'Height Above Mean Sea Level [m]';
colorbar
clim([-200 50])
colormap(winter)
title("Bathymetric Map of Cardigan Bay")
xlabel("Map Centred Coordinates [X Direction]")
ylabel("Map Centred Coordinates [Y Direction]")

figure

surf(ncdispelevation','EdgeColor','none')
set(gca,'YDir','normal')
% 
title("Bathymetric Map of Cardigan Bay")
xlabel("Map Centred Coordinates [X Direction]")
ylabel("Map Centred Coordinates [Y Direction]")
zlim([-200 0])
zlabel("Depth of Sea Bed [m]")


colormapvalues = colormap;

%Data

%
%Table Includes: Mean Wind Speed, Mean Wind Direction, Max Gust in the
%Hour, Air Temperature, Relative Humidity, MSL Pressure, Significant Wave
%Height, Average Wave Period, Peak Energy Wave Period, Direction of
%Dominant Waves
%

WeatherDataTable = readtable("C:\Users\Ben\Desktop\Modelling_the_Sea_Surface_of_Cardigan_Bay\WeatherData.xlsx");

%Tidy the table

WeatherData = rows2vars(WeatherDataTable);
WeatherData = removevars(WeatherData,["OriginalVariableNames","Var8","Var9"]);
WeatherData([1 12],:) = [];
WeatherData.Properties.VariableNames = ["Date","Time","10MinuteMeanWind", "MAX gust in the hour [KT]","Air temperature [C]","Relative Humidity [%]","MSL Pressure (QFF)[hPa]","SignificantWaveHeight","Average Wave Period [s]","Peak Energy Wave Period [s]","Direction of Dominant Waves [from DEG true]"]
MWindSpeed = [11;5;4;3;3;6;7;5;5;4;10;13;13;10;10;16;16;15;16]
MeanWindSpeed = MWindSpeed .* 0.5144444;
MeanWindDirection = [140;100;90;80;90;130;160;130;40;50;120;120;120;150;170;140;140;140;140]
DataSetWaveHeight = [0.3;0.3;0.4;0.4;0.4;0.5;0.5;0.4;0.4;0.3;0.7;0.6;0.6;0.5;0.5;0.5;0.5;0.4;0.4]
%RawWWDataWaveHeight = [NaN;NaN;0.47;NaN;NaN;0.55;NaN;NaN;0.46;NaN;NaN;NaN;0.14;NaN;NaN;0.11;NaN;NaN;0.15]
WWDataWaveHeight = [0.47;0.55;0.46;0.14;0.11;0.15]
DataSetWaveHeight4WW = [0.4;0.5;0.4;0.6;0.5;0.4]
%MeanWindSpeed = MeanWindSpeed ./ 0.5144444;
WeatherData = addvars(WeatherData,MeanWindSpeed,'before',"MAX gust in the hour [KT]");
WeatherData = addvars(WeatherData,MeanWindDirection,'before',"MAX gust in the hour [KT]");
WeatherData = addvars(WeatherData,DataSetWaveHeight,'before',"MAX gust in the hour [KT]");
%WeatherData = addvars(WeatherData,WWDataWaveHeight, 'before',"MAX gust in the hour [KT]");

FirstJuneWeatherData = WeatherData(1:10,:);
SecondJuneWeatherData = WeatherData(end-8:end,:);

FirstJuneWeatherData = table2struct(FirstJuneWeatherData); %#ok
SecondJuneWeatherData = table2struct(SecondJuneWeatherData); %#ok


figure,
plot(DataSetWaveHeight4WW, "x-")
hold on
plot(WWDataWaveHeight, "x-")
hold off
title('Significant Wave Height from the project "Earth" by Cameron Beccario')
xlabel('Time of Day')
xticks([1:6])
xticklabels({'10am','1pm','4pm','10am','1pm','4pm'} )
ylabel('Significant Wave Height [m]')
ylim([0 1])
legend("Ground Truth",'"Earth" project by Cameron Beccario')

%Interpolation of Wavewatch 3 Values


%idxs = ~isnan(WWDataWaveHeight);
%WWDataWaveHeight = griddedInterpolant(RawWWDataWaveHeight,,'linear')


%CONSTANTS


jgamma = 3.3;
gravStrength = 9.81;
angFrequency = (((1:100).*0.5)/100)*2*pi;

%Equation

peakFrequency = 0.877.*(gravStrength./WeatherData.MeanWindSpeed);
omegaZero = gravStrength./WeatherData.MeanWindSpeed;

CorrectedWindSpeed = MeanWindSpeed ./ (10 ./ (440./3.28084)).^0.11;

PMWaveSpectra = PiersonMoskowitz(gravStrength, angFrequency, omegaZero);
%PMSignificantWaveHeight(PMWaveSpectra);

JWaveSpectra = Jonswap(peakFrequency,gravStrength, angFrequency, jgamma);
%JSignificantWaveHeight(JWaveSpectra);

PMSignWaveHeight = PMSignificantWaveHeight(PMWaveSpectra)
JSignWaveHeight = JSignificantWaveHeight(JWaveSpectra);



%Plots/Figures

% Add Titles, Axis, Labels, and Legends

figure, plot(peakFrequency, "x-")
hold on
xticks([1:19])
xticklabels({'8am', '9am', '10am','11am','12pm', '1pm', '2pm', '3pm', '4pm', '5pm', '8am', '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm', '4pm'} )
title("Comparison of Max Wind Speed and Peak Frequency over Time")
xlabel("Time of Day")
ylabel("Wind Speed [m/s]")
ylim([0 10])

% legend('Max Wind Speed')
yyaxis right
plot(WeatherData.MeanWindSpeed, "x-")
ylabel("Peak Frequency [Hertz]")
ylim([0 10])
legend('Max Wind Speed', 'Peak Frequency')
hold off

figure, 
subplot(2,2,2)
imagesc(PMWaveSpectra)
title("Wave Spectral Density from the Pierson-Moskowitz Equation")
xlabel("Angular Frequency [Rad/s]")
xticks([1 12.5 25 37.5 50 62.5 75 87.5 100])
xticklabels({'0', '$\frac{1}{4} \pi$', '$\frac{1}{2} \pi$', '$\frac{3}{4} \pi$', '$\pi$', '$\frac{5}{4} \pi$', '$\frac{3}{2} \pi$', '$\frac{7}{4} \pi$', '$ 2 \pi$'})
set(gca, 'TickLabelInterpreter', 'latex');
ylabel("Wind Speed [m/s]")
yticks([1:19])
yticklabels({'8am', '9am', '10am','11am','12pm', '1pm', '2pm', '3pm', '4pm', '5pm', '8am', '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm', '4pm'} )
set(gca, 'YDir','normal');
c = colorbar;
c.Label.String = 'Wave Spectral Density [m^2 / Rad /s]';
subplot(2,2,1)
plot(PMWaveSpectra)
title("Wave Spectral Density vs Mean Wind Speed")
ylabel("Wave Spectral Density [m^2 / Rad /s]")
xlabel("Wind Speed [m/s]")
subplot(2,2,3)
surf(PMWaveSpectra,'LineStyle',":")
title("Wave Spectral Density from the Pierson-Moskowitz Equation")
zlabel("Wave Spectral Density [m^2 / Rad /s]")
xlabel("Angluar Frequency [Rad/s]")
ylabel("Mean Wind Speed [m/s]")
yticks([1:19])
yticklabels({'8am', '9am', '10am','11am','12pm', '1pm', '2pm', '3pm', '4pm', '5pm', '8am', '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm', '4pm'} )
xticks([1 12.5 25 37.5 50 62.5 75 87.5 100])
xticklabels({'0', '$\frac{1}{4} \pi$', '$\frac{1}{2} \pi$', '$\frac{3}{4} \pi$', '$\pi$', '$\frac{5}{4} \pi$', '$\frac{3}{2} \pi$', '$\frac{7}{4} \pi$', '$ 2 \pi$'})
set(gca, 'TickLabelInterpreter', 'latex');
subplot(2,2,4)
plot(PMWaveSpectra')
title("Wave Spectral Density vs Angular Frequency")
ylabel("Wave Spectral Density [m^2 / Rad /s]")
xlabel("Angular Frequency [Rad/s]")
xticks([1 12.5 25 37.5 50 62.5 75 87.5 100])
xticklabels({'0', '$\frac{1}{4} \pi$', '$\frac{1}{2} \pi$', '$\frac{3}{4} \pi$', '$\pi$', '$\frac{5}{4} \pi$', '$\frac{3}{2} \pi$', '$\frac{7}{4} \pi$', '$ 2 \pi$'})
set(gca, 'TickLabelInterpreter', 'latex');

figure, 
subplot(2,2,2)
imagesc(JWaveSpectra)
title("Wave Spectral Density from the JONSWAP Equation")
xlabel("Angular Frequency [Rad/s]")
xticks([1 12.5 25 37.5 50 62.5 75 87.5 100])
xticklabels({'0', '$\frac{1}{4} \pi$', '$\frac{1}{2} \pi$', '$\frac{3}{4} \pi$', '$\pi$', '$\frac{5}{4} \pi$', '$\frac{3}{2} \pi$', '$\frac{7}{4} \pi$', '$ 2 \pi$'})
set(gca, 'TickLabelInterpreter', 'latex');
ylabel("Wind Speed [m/s]")
set(gca, 'YDir','normal');
c = colorbar;
c.Label.String = 'Wave Spectral Density [m^2 / Rad /s]';
subplot(2,2,1)
plot(JWaveSpectra)
title("Wave Spectral Density vs Mean Wind Speed")
ylabel("Wave Spectral Density [m^2 / Rad /s]")
xlabel("Wind Speed [m/s]")
subplot(2,2,3)
surf(JWaveSpectra,'LineStyle',":")
title("Wave Spectral Density from the JONSWAP Equation")
zlabel("Wave Spectral Density [m^2 / Rad /s]")
xlabel("Angluar Frequency [Rad/s]")
ylabel("Mean Wind Speed [m/s]")
xticks([1 12.5 25 37.5 50 62.5 75 87.5 100])
xticklabels({'0', '$\frac{1}{4} \pi$', '$\frac{1}{2} \pi$', '$\frac{3}{4} \pi$', '$\pi$', '$\frac{5}{4} \pi$', '$\frac{3}{2} \pi$', '$\frac{7}{4} \pi$', '$ 2 \pi$'})
set(gca, 'TickLabelInterpreter', 'latex');
subplot(2,2,4)
plot(JWaveSpectra')
title("Wave Spectral Density vs Angular Frequency")
ylabel("Wave Spectral Density [m^2 / Rad /s]")
xlabel("Angular Frequency [Rad/s]")
xticks([1 12.5 25 37.5 50 62.5 75 87.5 100])
xticklabels({'0', '$\frac{1}{4} \pi$', '$\frac{1}{2} \pi$', '$\frac{3}{4} \pi$', '$\pi$', '$\frac{5}{4} \pi$', '$\frac{3}{2} \pi$', '$\frac{7}{4} \pi$', '$ 2 \pi$'})
set(gca, 'TickLabelInterpreter', 'latex');






figure, 
subplot(2,2,[1 2])
plot(DataSetWaveHeight, "b-")
title("Comparrison of Methods for Calculating Significant Waveheight")
ylabel("Significant Waveheight [m]")
xticks([1:19])
xticklabels({'8am', '9am', '10am','11am','12pm', '1pm', '2pm', '3pm', '4pm', '5pm', '8am', '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm', '4pm'} )
xlabel("Time of Day")
%ylim([0 1])
% hold on
% plot(WWDataWaveHeight(idxs), "r-")
% hold on
% plot(PMSignWaveHeight10)
% hold on
% plot(PMSignWaveHeight19)
% hold on
% plot(PMSignWaveHeightApprox)

% hold on
% plot(PeakPMSigWaveHeight)
% hold on
% plot(PeakJSigWaveHeight)
% legend('Location','eastoutside')
% legend("Data Set", "Approximation, Wind Speed @ 10m", "Approximation, Wind Speed @ 19.5m","Approximation, For Loop","Pierson-Moskowitz Peak Significant Waveheight","Jonswap Peak Significant Waveheight")
% hold off
% subplot(2,2,3)
% surf(PMSignWaveHeight','LineStyle',":")
% title("Significant Wave Height (Pierson-Moskowitz)")
% ylabel("Mean Wind Speed [m/s]")
% zlabel("Significant Wave Height [m]")
% xlabel("Angular Frequency [Rad/s]")
% xticks([1 12.5 25 37.5 50 62.5 75 87.5 100])
% xticklabels({'0', '$\frac{1}{4} \pi$', '$\frac{1}{2} \pi$', '$\frac{3}{4} \pi$', '$\pi$', '$\frac{5}{4} \pi$', '$\frac{3}{2} \pi$', '$\frac{7}{4} \pi$', '$ 2 \pi$'})
% set(gca, 'TickLabelInterpreter', 'latex');
% subplot(2,2,4)
% surf(JSignWaveHeight','LineStyle',":")
% title("Significant Wave Height (JONSWAP)")
% ylabel("Mean Wind Speed [m/s]")
% zlabel("Significant Wave Height [m]")
% xlabel("Angular Frequency [Rad/s]")
% xticks([1 12.5 25 37.5 50 62.5 75 87.5 100])
% xticklabels({'0', '$\frac{1}{4} \pi$', '$\frac{1}{2} \pi$', '$\frac{3}{4} \pi$', '$\pi$', '$\frac{5}{4} \pi$', '$\frac{3}{2} \pi$', '$\frac{7}{4} \pi$', '$ 2 \pi$'})
% set(gca, 'TickLabelInterpreter', 'latex');


% figure,
% subplot(2,2,1)
% surf(,PMSignificantWaveHeight)


PMSignWaveHeight10 = 0.22 * (WeatherData.MeanWindSpeed).^2 ./ (gravStrength);
PMSignWaveHeight19 = 0.21 * (WeatherData.MeanWindSpeed).^2 ./ (gravStrength);
PMSignWaveHeightApprox = 0.21 * (CorrectedWindSpeed).^2 ./ (gravStrength);

PeakPMSigWaveHeight = max(PMSignWaveHeight);
AveragePMSigWaveHeight = mean(PMSignWaveHeight);

PeakJSigWaveHeight = max(JSignWaveHeight);
AverageJSigWaveHeight = mean(JSignWaveHeight);



figure, plot(DataSetWaveHeight, "b-")
title("Significant Wave Height (Pierson-Moskowitz)")
ylabel("Significant Waveheight [m]")
xticks([1:19])
xticklabels({'8am', '9am', '10am','11am','12pm', '1pm', '2pm', '3pm', '4pm', '5pm', '8am', '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm', '4pm'} )
xlabel("Time of Day")
hold on
plot(AveragePMSigWaveHeight)
hold on
plot(PeakPMSigWaveHeight)
legend("Dataset","Average Significant Waveheight (Pierson-Moskowitz)","Peak Significant Waveheight (Pierson-Moskowitz)")

figure, plot(DataSetWaveHeight, "b-")
title("Significant Wave Height (JONSWAP)")
ylabel("Significant Waveheight [m]")
xticks([1:19])
xticklabels({'8am', '9am', '10am','11am','12pm', '1pm', '2pm', '3pm', '4pm', '5pm', '8am', '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm', '4pm'} )
xlabel("Time of Day")
hold on
plot(AverageJSigWaveHeight)
hold on
plot(PeakJSigWaveHeight)
legend("Dataset","Average Significant Waveheight (JONSWAP)","Peak Significant Waveheight (JONSWAP)")

figure, plot(DataSetWaveHeight, "b-")
title("Average Significant Wave Heights")
ylabel("Significant Waveheight [m]")
xticks([1:19])
xticklabels({'8am', '9am', '10am','11am','12pm', '1pm', '2pm', '3pm', '4pm', '5pm', '8am', '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm', '4pm'} )
xlabel("Time of Day")
hold on
plot(AveragePMSigWaveHeight)
hold on
plot(AverageJSigWaveHeight)
legend("Dataset","Average Significant Waveheight (Pierson-Moskowitz)","Average Significant Waveheight (JONSWAP)")

figure, plot(DataSetWaveHeight, "b-")
title("Significant Wave Height (Approximations)")
ylabel("Significant Waveheight [m]")
xticks([1:19])
xticklabels({'8am', '9am', '10am','11am','12pm', '1pm', '2pm', '3pm', '4pm', '5pm', '8am', '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm', '4pm'} )
xlabel("Time of Day")
hold on
plot(PMSignWaveHeight10)
hold on
plot(PMSignWaveHeight19)
hold on
plot(PMSignWaveHeightApprox')
legend("Dataset","Mean Wind Speed @10m AMSL","Mean Wind Speed @19.5m AMSL", "Mean Wind Speed @440ft AMSL")























figure, 
subplot(2,2,3)
imagesc(PMWaveSpectra)
title("Wave Spectral Density from the Pierson-Moskowitz Equation")
xlabel("Angular Frequency [Rad/s]")
xticks([1 12.5 25 37.5 50 62.5 75 87.5 100])
xticklabels({'0', '$\frac{1}{4} \pi$', '$\frac{1}{2} \pi$', '$\frac{3}{4} \pi$', '$\pi$', '$\frac{5}{4} \pi$', '$\frac{3}{2} \pi$', '$\frac{7}{4} \pi$', '$ 2 \pi$'})
set(gca, 'TickLabelInterpreter', 'latex');
ylabel("Time of Day [1st and 2nd June]")
yticks([1:19])
yticklabels({'8am', '9am', '10am','11am','12pm', '1pm', '2pm', '3pm', '4pm', '5pm', '8am', '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm', '4pm'} )
set(gca, 'YDir','normal');
c = colorbar;
c.Label.String = 'Wave Spectral Density [m^2 / Rad /s]';
subplot(2,2,4)
surf(PMWaveSpectra,'LineStyle',":")
title("Wave Spectral Density from the Pierson-Moskowitz Equation")
zlabel("Wave Spectral Density [m^2 / Rad /s]")
xlabel("Angluar Frequency [Rad/s]")
ylabel("Time of Day [1st and 2nd June]")
yticks([1:19])
yticklabels({'8am', '9am', '10am','11am','12pm', '1pm', '2pm', '3pm', '4pm', '5pm', '8am', '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm', '4pm'} )
xticks([1 12.5 25 37.5 50 62.5 75 87.5 100])
xticklabels({'0', '$\frac{1}{4} \pi$', '$\frac{1}{2} \pi$', '$\frac{3}{4} \pi$', '$\pi$', '$\frac{5}{4} \pi$', '$\frac{3}{2} \pi$', '$\frac{7}{4} \pi$', '$ 2 \pi$'})
set(gca, 'TickLabelInterpreter', 'latex');
subplot(2,2,1)
plot(PMWaveSpectra')
title("Wave Spectral Density vs Angular Frequency")
ylabel("Wave Spectral Density [m^2 / Rad /s]")
xlabel("Angular Frequency [Rad/s]")
xticks([1 12.5 25 37.5 50 62.5 75 87.5 100])
xticklabels({'0', '$\frac{1}{4} \pi$', '$\frac{1}{2} \pi$', '$\frac{3}{4} \pi$', '$\pi$', '$\frac{5}{4} \pi$', '$\frac{3}{2} \pi$', '$\frac{7}{4} \pi$', '$ 2 \pi$'})
set(gca, 'TickLabelInterpreter', 'latex');
subplot(2,2,2)
surf(PMSignWaveHeight','LineStyle',":")
title("Significant Wave Height (Pierson-Moskowitz)")
ylabel("Time of Day [1st and 2nd June]")
yticks([1:19])
yticklabels({'8am', '9am', '10am','11am','12pm', '1pm', '2pm', '3pm', '4pm', '5pm', '8am', '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm', '4pm'} )
zlabel("Significant Wave Height [m]")
xlabel("Angular Frequency [Rad/s]")
xticks([1 12.5 25 37.5 50 62.5 75 87.5 100])
xticklabels({'0', '$\frac{1}{4} \pi$', '$\frac{1}{2} \pi$', '$\frac{3}{4} \pi$', '$\pi$', '$\frac{5}{4} \pi$', '$\frac{3}{2} \pi$', '$\frac{7}{4} \pi$', '$ 2 \pi$'})
set(gca, 'TickLabelInterpreter', 'latex');




figure, 
subplot(2,2,3)
imagesc(JWaveSpectra)
title("Wave Spectral Density from the JONSWAP Equation")
xlabel("Angular Frequency [Rad/s]")
xticks([1 12.5 25 37.5 50 62.5 75 87.5 100])
xticklabels({'0', '$\frac{1}{4} \pi$', '$\frac{1}{2} \pi$', '$\frac{3}{4} \pi$', '$\pi$', '$\frac{5}{4} \pi$', '$\frac{3}{2} \pi$', '$\frac{7}{4} \pi$', '$ 2 \pi$'})
set(gca, 'TickLabelInterpreter', 'latex');
ylabel("Time of Day [1st and 2nd June]")
yticks([1:19])
yticklabels({'8am', '9am', '10am','11am','12pm', '1pm', '2pm', '3pm', '4pm', '5pm', '8am', '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm', '4pm'} )
set(gca, 'YDir','normal');
c = colorbar;
c.Label.String = 'Wave Spectral Density [m^2 / Rad /s]';
subplot(2,2,4)
surf(JWaveSpectra,'LineStyle',":")
title("Wave Spectral Density from the JONSWAP Equation")
zlabel("Wave Spectral Density [m^2 / Rad /s]")
xlabel("Angluar Frequency [Rad/s]")
ylabel("Time of Day [1st and 2nd June]")
yticks([1:19])
yticklabels({'8am', '9am', '10am','11am','12pm', '1pm', '2pm', '3pm', '4pm', '5pm', '8am', '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm', '4pm'} )
xticks([1 12.5 25 37.5 50 62.5 75 87.5 100])
xticklabels({'0', '$\frac{1}{4} \pi$', '$\frac{1}{2} \pi$', '$\frac{3}{4} \pi$', '$\pi$', '$\frac{5}{4} \pi$', '$\frac{3}{2} \pi$', '$\frac{7}{4} \pi$', '$ 2 \pi$'})
set(gca, 'TickLabelInterpreter', 'latex');
subplot(2,2,1)
plot(JWaveSpectra')
title("Wave Spectral Density vs Angular Frequency")
ylabel("Wave Spectral Density [m^2 / Rad /s]")
xlabel("Angular Frequency [Rad/s]")
xticks([1 12.5 25 37.5 50 62.5 75 87.5 100])
xticklabels({'0', '$\frac{1}{4} \pi$', '$\frac{1}{2} \pi$', '$\frac{3}{4} \pi$', '$\pi$', '$\frac{5}{4} \pi$', '$\frac{3}{2} \pi$', '$\frac{7}{4} \pi$', '$ 2 \pi$'})
set(gca, 'TickLabelInterpreter', 'latex');
subplot(2,2,2)
surf(JSignWaveHeight','LineStyle',":")
title("Significant Wave Height (JONSWAP)")
ylabel("Time of Day [1st and 2nd June]")
yticks([1:19])
yticklabels({'8am', '9am', '10am','11am','12pm', '1pm', '2pm', '3pm', '4pm', '5pm', '8am', '9am', '10am', '11am', '12pm', '1pm', '2pm', '3pm', '4pm'} )
zlabel("Significant Wave Height [m]")
xlabel("Angular Frequency [Rad/s]")
xticks([1 12.5 25 37.5 50 62.5 75 87.5 100])
xticklabels({'0', '$\frac{1}{4} \pi$', '$\frac{1}{2} \pi$', '$\frac{3}{4} \pi$', '$\pi$', '$\frac{5}{4} \pi$', '$\frac{3}{2} \pi$', '$\frac{7}{4} \pi$', '$ 2 \pi$'})
set(gca, 'TickLabelInterpreter', 'latex');














function PMWaveSpectra = PiersonMoskowitz(gravStrength, angFrequency, omegaZero)

alpha = 0.0081;
beta = 0.74;

for ii = 1:size(angFrequency,2) %this loop should go through each of the omega elements

    %in her spectra equation - save to an array (data structure)
    PMWaveSpectra(:,ii) = (alpha .* gravStrength^2)./angFrequency(ii).^5 .* exp(-1 .* beta .* (omegaZero./angFrequency(ii)).^4);

end

end

function JWaveSpectra = Jonswap(peakFrequency, gravStrength, angFrequency, jgamma)

%fetch = 125774.59;
alpha = 0.0081;
%alpha = 0.076 * (MeanWindSpeed .^ 2 ./ fetch * gravStrength).^0.22;
%peakFrequency = 22*(gravStrength^2./MeanWindSpeed.*fetch).^(1/3);

%alpha = 0.076 * (CorrectedWindSpeed .^ 2 ./ gravStrength).^0.22;
%peakFrequency = 22*(gravStrength^2./CorrectedWindSpeed).^(1/3);

for jj = 1:size(angFrequency,2)

    if angFrequency(jj) < peakFrequency
        sigma = 0.07;
    else
        sigma = 0.09;
    end

    rFactor = exp(-((angFrequency(jj) - peakFrequency).^2)./(2*sigma.^2 .* peakFrequency.^2));

    JWaveSpectra(:,jj) = (alpha .* gravStrength^2)./angFrequency(jj).^5 .* exp(-1.*(5/4).*(peakFrequency./angFrequency(jj)).^4).*jgamma.^rFactor;

end

end


function PMSignWaveHeight = PMSignificantWaveHeight(PMWaveSpectra)

for kk = 1:19

    spectraInt = integral(@(angFrequency) PMWaveSpectra(kk,:),0,1,"ArrayValued",true);
    % PMSignWaveHeight(:,kk) = 4.*spectraInt .^ (1/2);
    PMSignWaveHeight(:,kk) = 4.*sqrt(spectraInt);

end

end

function JSignWaveHeight = JSignificantWaveHeight(JWaveSpectra)

for ll = 1:19
    spectraInt = integral(@(angFrequency) JWaveSpectra(ll,:),0,1,"ArrayValued",true);
    JSignWaveHeight(:,ll) = 4.*spectraInt .^ (1/2);
end

end
