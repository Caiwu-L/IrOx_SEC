%imput decay filename, adjust the name in order
filename(1)="500_Kinetic_SMOOTHED_ocv-1.05-1.11OSP-SP";
filename(2)="500_Kinetic_SMOOTHED_ocv-1.05-1.13OSP-SP";
filename(3)="500_Kinetic_SMOOTHED_ocv-1.05-1.15OSP-SP";
filename(4)="500_Kinetic_SMOOTHED_ocv-1.05-1.17OSP-SP";
filename(5)="500_Kinetic_SMOOTHED_ocv-1.05-1.18OSP-SP";
filename(6)="500_Kinetic_SMOOTHED_ocv-1.05-1.19OSP-SP";
filename(7)="500_Kinetic_SMOOTHED_ocv-1.05-1.20OSP-SP";
filename(8)="500_Kinetic_SMOOTHED_ocv-1.05-1.21OSP-SP";
filename(9)="500_Kinetic_SMOOTHED_ocv-1.05-1.22OSP-SP";
filename(10)="500_Kinetic_SMOOTHED_ocv-1.05-1.24OSP-SP";
%filename(11)="500_Kinetic_SMOOTHED_ocv-1.05-1.31OSP-SP";
%filename(12)="500_Kinetic_SMOOTHED_ocv-1.05-1.25OSP-SP"
%filename(12)=500_Kinetic_SMOOTHED_ocv-1.05-1.07OSP-SP
N=10; %imput the totall amount of files
Potential=[1.11,1.13,1.15,1.17,1.18,1.19,1.20,1.21,1.22,1.24]; %imput the corresponding potential for the files
t_start_set=22.4; %imput the decay start time, note that not exactly 20s as setting,check data first
percentage=0.75; %impt select percentage of calculation
Delta_OD_decay_record={};
Delta_OD_record=[]
for i=1:N  %for loop to get evry file input
    file=strcat(filename(i),'.csv');
    Data=csvread(file);
    time_array=Data(:,1);
    OD_array=Data(:,2); 
  


    %find the decay start point
    Delta_t=abs(time_array-t_start_set);
    [Delta_t_min,t_min_index]=min(Delta_t);
    t_start_real=time_array(t_min_index);
    Delta_OD_start=OD_array(t_min_index);
    
    % Delta_OD=Delta_OD./max(Delta_OD); %normalize signal to 1
    
    OD_array_end=mean(OD_array(end-50:end));
    OD_array=(OD_array-OD_array_end)./(Delta_OD_start-OD_array_end);
    
    %record delta OD
    Delta_OD_record=[Delta_OD_record,(Delta_OD_start-OD_array_end)]
    
    %set start ponit as 1 after normalize
    Delta_OD_start=OD_array(t_min_index);
   
 %find the select calculate point, according to the set percentage
 %the same percentage has two points, we peak the decay period point
decay_index=(time_array>=t_start_real);
time_array_decay=time_array(decay_index);
Delta_OD_decay=OD_array(decay_index);
Delta_OD_cal_set=percentage*Delta_OD_start;
Delta=abs(Delta_OD_decay-Delta_OD_cal_set);
[Delta_min,OD_min_index]=min(Delta);
Delta_OD_cal_real=Delta_OD_decay(OD_min_index);
t_cal=time_array_decay(OD_min_index);



%Calculate time constant by normalize signal decay divide decay time period
time_constant(i)=(t_cal-t_start_real)/(Delta_OD_start-Delta_OD_cal_real);
  %if i>2
    figure (1)
    hold on
    plot(time_array_decay,Delta_OD_decay)
    hold off  
  %end
%store delta OD array 
 %length=length(Delta_OD_decay)
Delta_OD_decay_record=horzcat(Delta_OD_decay_record,[time_array_decay,Delta_OD_decay])

end

%plot potential vs time constant
figure
scatter(Potential,time_constant,'k','linewidth',0.5,'markerfacecolor',[36, 169, 225]/255)
xlabel('Potential (V vs Ag/AgCl)')
ylabel('Time constant(s)')
set(gca,'linewidth',1.1,'Fontsize',16,'fontname','times');
box on;
%ylim([0 1]);

% Write data
Final=[Potential',time_constant'];
Final1=[time_array_decay,Delta_OD_decay]
percentage=percentage*100; %0.9 cannot set as a file name
fileN=sprintf("percentage_%d_time_constant.csv",percentage);
fileN1=sprintf("percentage_%d_OD_decay.csv",percentage)
csvwrite(fileN,Final);
csvwrite(fileN1,Final1)