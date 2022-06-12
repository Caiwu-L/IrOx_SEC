filename='Population_base'
filename1=strcat(filename,'.csv');
Data=readtable(filename1);
Data=table2array(Data);
%select data range
Potential=Data(:,1); 
Pop=Data(:,2);
% cut potential range for fitting
Start_potential=0.55;
End_potential=0.78;

%convert population to coverage, using maximum of Pop1 as upper bound.
Max_Pop=2.24E16; %check number from raw data, not usally as maxium but the mean of mxiumn
Theta=Pop./Max_Pop;

% cut potential
Potential_index=Potential>=Start_potential&Potential<=End_potential;
Potential_cut=Potential(Potential_index);
Theta_cut=Theta(Potential_index);
plot(Potential_cut,Theta_cut,'ko')
hold on;

guess_r=0.3;
guess_E0=0.6;
coeff=fminsearch('Frumkin_fit',[guess_r,guess_E0],[],Theta_cut,Potential_cut);
r=coeff(1);
E0=coeff(2);

theta_fit=0.0001:0.0001:0.9999;
potential_fit=0.0256*log(theta_fit./(1-theta_fit))+r*theta_fit+E0;
plot(potential_fit,theta_fit,'r-')

%R square calculation residuals/variance
Res_square=sum(((0.0256*log(Theta_cut./(1-Theta_cut))+r*Theta_cut+E0-Potential_cut).^2));
Total_sum_square=sum((Potential_cut-mean(Potential_cut)).^2);
R_sqaure=1-Res_square/Total_sum_square

sprintf('r=%d,E0=%d,R_sqaure=%d',r,E0,R_sqaure)
fit_data=[theta_fit',potential_fit']
%csvwrite(sprintf('%s_frumkin_fit_E0=%d r=%d R=%d.csv',filename,E0,r,R_sqaure),fit_data);


