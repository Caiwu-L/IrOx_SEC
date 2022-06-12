%Enter the value of the reference potential 
baseline_potential_AgAgCl =0.6; %in AgAgCl
Correct_baseline=0; %SET TO 0 IF NOT CORRECTING BASELINE
RHE_conv_factor=0;
iR=25;%input R obtain in EIS, put 0 if no need iR correct.
iR_compen=0.95; %input iR compensation percentage
smoothing_weight=100;
WL_max=840;
WL_min=420;
filename1='IrOx_2000s_RHESEC';
filename2='WL';
filename3='IrOx_2000s_RHE_JV';
filename=strcat(filename1,'.csv');
filename2_=strcat(filename2,'.csv');
filename3_=strcat(filename3,'.csv');

% read data
SEC_data_array  = csvread(filename);
WL_array  = csvread(filename2_);
JV=csvread(filename3_);
 
% Trim the array - remove outlying wavelengths
wavelengths_array = SEC_data_array(:,1);
wavelengths_array0=WL_array(:,1);
WL_TF=wavelengths_array0>WL_min & wavelengths_array0<WL_max;
data_array=SEC_data_array(WL_TF,2:end);
wavelengths_array = wavelengths_array0(WL_TF);
% baseline correction if needed
if Correct_baseline==1
O_percent_correction = csvread(filename3_);
O_percent_correction=O_percent_correction(WL_TF,2:end);
O_percent_correction=mean(O_percent_correction,2);
data_array=data_array-O_percent_correction;
end

% get the potentials - note removing the padding zero from first value
potentials_array= SEC_data_array(1,2:end);
potentials_array_RHE= potentials_array+RHE_conv_factor;
baseline_potential = baseline_potential_AgAgCl+RHE_conv_factor;


%Find position of reference potential in array
c = ismember(potentials_array_RHE, baseline_potential);
indexes = find(c);
Ref_potential_check=potentials_array_RHE(c);
potentials_array2=potentials_array_RHE>=Ref_potential_check;
%get the potentials after the ref potential note the transpose at the end
potentials_array2=potentials_array_RHE(potentials_array2)';

% get referance array for DOD using logical indexing

Ref_array=data_array(:,c);
log_RA=log10(Ref_array);

% calculate DOD array
N=size(data_array);
N=N(2);

for i=1:N
    
    DOD(:,i)=-log10(data_array(:,i))+log_RA;
   %if i==1
    %DOD_smooth(:,i)=DOD(:,i);
   %else
   DOD_smooth(:,i)=smooth(DOD(:,i),smoothing_weight);%,'sgolay',3);
   %end 
   
end   
% get the data region that is more than the ref potential
output_data=DOD(:,indexes:end);
output_dataS=DOD_smooth(:,indexes:end);

%iR compensation if needed, and also find position of reference potential in array
if iR~=0
current=JV(2:end-1,2); %delete the start 0 to make it the same with potential array in SEC
potential=JV(2:end-1,1);
potential=flipud(potential);
current=flipud(current);%the arrange of potential and current in JV is upside down

%(to match both forward scan and backward scan)
    if baseline_potential<=potentials_array(end)
        iR_correct_region=(baseline_potential_AgAgCl<=potential&potential<=potentials_array(end));
    else
        iR_correct_region=(baseline_potential_AgAgCl>=potential&potential>=potentials_array(end));
    end
    
iR_correct_region=(baseline_potential_AgAgCl<=potential&potential<=potentials_array(end));
potential_iR=potential(iR_correct_region)-iR*current(iR_correct_region)*iR_compen;
potentials_array_RHE=potential_iR+RHE_conv_factor;
potentials_array_RHE=potentials_array_RHE'; %transport for data writing
end
%Plot data
columns = size(output_data);
columns = columns(2);
set(0,'DefaultAxesColorOrder',jet(columns))
plot(wavelengths_array,output_data,'linewidth',3);
xlabel('Wavelength (nm)') 
ylabel('Delta O.D.')
set(gca,'Fontsize',20);
set(gca,'linew',3);
set(gcf,'color','w');
axis square

 % plot smoothed spectra
tite=num2str(potentials_array_RHE(1));
tite=strcat('Spectrum vs.',tite,' V RHE' );
figure
plot(wavelengths_array,output_dataS,'linewidth',3)
xlabel('Wavelength (nm)') 
ylabel('Delta O.D.')
set(gca,'Fontsize',20);
set(gca,'linew',3);
%xlim([WL_min+50 WL_max-50]);
leg=num2str(potentials_array2);
title(tite, 'fontsize', 12);
legend(leg);
lgd.FontSize = 12;
lgnd.BoxFace.ColorType='truecoloralpha';
lgnd.BoxFace.ColorData=uint8(255*[1 1 1 0.75]');
set(gcf,'color','w');
axis square
%createfigure(wavelengths_array,output_dataS);

%figure
%surface(potentials_array2,wavelengths_array,output_dataS,'EdgeColor','none');
%xlabel('Applied potential (V vs RHE)', 'FontSize', 25)
%set(gcf,'color','w');
%set(gca,'Fontsize',20);
%ylabel('Wavelength (nm)', 'FontSize', 25)
%colorbar()
%axis square

%title('SEC data summary')

% put it all together
Final=[potentials_array_RHE;output_data];
%add a padding 0 to WL to match dimensions
wavelengths_array=[0;wavelengths_array];
Final=[wavelengths_array,Final];

FinalS=[potentials_array_RHE;output_dataS];
FinalS=[wavelengths_array,FinalS];

fileN=strcat(filename1,'DOD_iR.csv');
fileNS=strcat(filename1,'smooth','DOD_iR.csv');

csvwrite(fileN,Final);
csvwrite(fileNS,FinalS);

clear
clc


