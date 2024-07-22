%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Global Self-consistent, Hierarchical, High-resolution Geography Database%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This script displays the shorelines from the GSHHG Database.             %
%https://www.soest.hawaii.edu/pwessel/gshhg/                              %
%It also constrains it to Cardigan Bay, Wales.                            %
%Author: Ben Churchill                                                    %
%Date modified: 22nd July 2024                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Calling the L1 Database, L1 being the hierarchical layer that displays the
%boundary between the land and the ocean.
gshhgShapeFilePath = 'C:\Users\Ben\Desktop\Modelling_the_Sea_Surface_of_Cardigan_Bay\Pre-Poster\GSHHG-SHP\GSHHS_shp\c\GSHHS_c_L1';
gshhgData = shaperead(gshhgShapeFilePath);

%This database needs to use NC Toolbox.
license('test', 'Mapping_Toolbox')

%The first figure displays the complete L1 Database from GSHHG
figure;
geoshow( [gshhgData.Y], [gshhgData.X], 'DisplayType', 'polygon', 'FaceColor', 'green');
title('GSHHG Database');
xlabel('Latitude')
ylabel('Longitude')

%The second figure constrains it to Cardigan Bay.
figure;
geoshow([gshhgData.Y], [gshhgData.X], 'DisplayType', 'polygon', 'FaceColor', 'green');
xlim([-5.554 -3.692]) %Limits for Cardigan Bay [-5.554 -3.692], 'broader' [-6 -3]
ylim([51.802 52.956]) %Limits for Cardigan Bay [51.802 52.956], 'broader' [51 54]
title('GSHHG Coastline Boundaries (Cardigan Bay)');
xlabel('Latitude')
ylabel('Longitude')