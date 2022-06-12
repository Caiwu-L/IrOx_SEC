%imput decay filename, adjust the name in order
filename(1)="500nm A-Test DAQ_1.22-1.24";
filename(2)="500nm A-Test DAQ_1.22-1.25";
filename(3)="500nm A-Test DAQ_1.22-1.26";
filename(4)="500nm A-Test DAQ_1.22-1.27";
filename(5)="500nm A-Test DAQ_1.22-1.29";
filename(6)="500nm A-Test DAQ_1.22-1.32";
filename(7)="500nm A-Test DAQ_1.22-1.35";
filename(8)="500nm A-Test DAQ_1.22-1.40";
filename(9)="500nm A-Test DAQ_1.22-1.45";
filename(10)="500nm A-Test DAQ_1.22-1.50";
%filename(11)="500nm ATest DAQ_1.30";
%filename(12)="500nm ATest DAQ_1.35";
%filename(13)="500nm ATest DAQ_1.40";
N=10; %imput the totall amount of files
Potential=[
1.49954115,
1.509115075,
1.5184268,
1.527410775,
1.54377275,
1.5649235,
1.58279675,
1.60756,
1.6293735,
1.64954825
]; %imput the corresponding potential for the files
t_start_set=6.007; %imput the decay start time, note that not exactly 20s as setting,
                    %check data first,and better put several 20ms before
                    %the start point to cancell out the smooth effect on start point
                    
percentage=0.80; %imput select percentage of calculation
smoothing_weight=100; %sgolay smooth, span=100 looks nice
Delta_OD_decay_record={};
Delta_OD_record=[];
for i=1:N  %for loop to get evry file input
    file=strcat(filename(i),'.txt');
    Data=load(file);
    time_array=Data(:,1);
    OD_array_raw=Data(:,2); 
    OD_array=smooth(OD_array_raw,smoothing_weight,'sgolay',3)%smoothing_weight);;)
    %OD_array=smooth(OD_array_raw,smoothing_weight)%smoothing_weight);;)


    %find the decay start point
    Delta_t=abs(time_array-t_start_set);
    [Delta_t_min,t_min_index]=min(Delta_t);
    t_start_real=time_array(t_min_index);
    Delta_OD_start=mean(OD_array(t_min_index-100:t_min_index));
    
    % Delta_OD=Delta_OD./max(Delta_OD); %normalize signal to 1
    
    OD_array_end=mean(OD_array(end-100:end));
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
Delta_OD_decay_record=horzcat(Delta_OD_decay_record,Delta_OD_decay);

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
Final=[Potential,time_constant'];
Final1=[time_array_decay,Delta_OD_decay_record];
percentage=percentage*100; %0.9 cannot set as a file name
fileN=sprintf("percentage_%d_time_constant_smooth.csv",percentage);
fileN1=sprintf("percentage_%d_OD_decay_smooth.csv",percentage);
csvwrite(fileN,Final);
csvwrite(fileN1,Final1)