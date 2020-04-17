%% Housekeeping
close all
clear table  

%% Local variables
t=out.output_RO.time;
Aw=3.812*10^(-12); %[m^3/(Ns)]
Bs=6.986*10^(-8); %[ms-1]
Am=7.2; %m^2
eps=6*10^4*1*10^(-8);
Nt=size(t,1);

%% Water Production

Q_feed=out.output_RO.signals.values(:,3); %[m^3/s]
Q_perm=out.output_RO.signals.values(:,4); %[m^3/s]
Q_brin=out.output_RO.signals.values(:,9); %[m^3/s]

Q_feed=Q_feed*1000; %[L/s]
Q_perm=Q_perm*1000; %[L/s]
Q_brin=Q_brin*1000; % [L/s]

%% Salinity

% Salinity of the permeate (derived from the diffusion model)
dP=out.output_RO.signals.values(:,2);
X_feed=35000; %[mg/L]
X_perm_ini=X_feed./(dP*Aw/Bs+1); % [mg/L] % We need to modify the modify the expression X_perm (from the diffusion model)
% because it is only valid when there is actually a flow
X_perm=zeros(Nt,1);
for i=1:Nt
    if Q_perm(i,1)<=eps
        X_perm(i,1)=0;
    else
        X_perm(i,1)=X_perm_ini(i,1);
    end %if
end %Nt

% Derive the mean of the Permeate salinity taking into account the Volume
% change
Xavg_perm=trapz(X_perm.*Q_perm);
Vtot_perm=trapz(Q_perm);
Xavg_perm=Xavg_perm/Vtot_perm;

X_brin=(X_feed.*Q_feed-X_perm.*Q_perm)./Q_brin; % [mg/L]

%% Foundation Load [N]
F_PTO=out.output_Power.signals.values(:,1);
P_PTO=abs(out.output_Power.signals.values(:,2));
Velo=out.output_Power.signals.values(:,3);

%% Saving the relevant parameters into a structure

result.Pavg_PTO=mean(P_PTO); % [W]
result.Pmax_PTO=max(P_PTO); % [W]
result.Fmax_PTO=max(abs(F_PTO) ); % [N]
result.Qavg_brin=60*mean(Q_brin); %  [Lmin-1]
result.Qavg_feed=60*mean(Q_feed); % [Lmin-1]
result.Qavg_perm=60*mean(Q_perm); % [Lmin-1]
result.Xavg_brin=nanmean(X_brin); %[ppm]
result.Xavg_feed=mean(X_feed); %[ppm]
result.Xavg_perm=Xavg_perm; % [ppm]
result.Xmax_perm=max(X_perm); %[ppm]

results_Water_tab(1,1)=result.Qavg_feed; 
results_Water_tab(1,2)=result.Qavg_perm; 
results_Water_tab(1,3)=result.Xavg_perm; 
results_Water_tab(1,4)=result.Qavg_brin; 
results_Water_tab(1,5)=result.Xavg_brin;

results_Pow_tab(1,1)=result.Pavg_PTO; 
results_Pow_tab(1,2)=result.Pmax_PTO; 
results_Pow_tab(1,3)=result.Fmax_PTO;

%% Plots

figure();
plot(t,P_PTO/10^3,'k',t,mean(P_PTO)/10^3*ones(1,Nt),'--r',t,max(P_PTO)/10^3*ones(1,Nt),'--m')
set(findall(gcf,'type','axes'),'fontsize',16);
legend('Absorbed Power',['Avg Absorbed Power : ',num2str(mean(P_PTO)/10^3,4),' kW'],['Max Absorbed Power : ',num2str(max(P_PTO)/10^3,4),' kW'],'Location','northwest')
xlabel('Time [s]')
ylabel('Absorbed Power [kW]')
title('Absorbed Power')
grid on

figure();
plot(t,(Q_perm*60),'b',t,(mean(Q_perm*60))*ones(1,Nt),'--b',t,eps*60*ones(1,Nt),'--')
set(findall(gcf,'type','axes'),'fontsize',16);
legend('Permeate Rate',['Avg Permeate Rate : ',num2str(mean(Q_perm)*60,4),' L.min^{-1}'],'\epsilon','Location','northwest')
xlabel('Time [s]')
ylabel('Flow rate [L.min^{-1}]')
title('Permeate Flow Rate, Q_{p} ')
grid on

figure()
plot(t,X_perm,'b',t,Xavg_perm*ones(1,Nt),'--b',t,500*ones(1,Nt),'--g',t,1000*ones(1,Nt),'--r')
set(findall(gcf,'type','axes'),'fontsize',16);
legend('Salinity',['Avg Permeate Water Salinity : ',num2str(Xavg_perm,4),' ppm'],'Max Drinking Water Salinity : 500 ppm','Max TDS admissible : 1000 ppm','Location','northwest')
xlabel('Time [s]')
ylabel('Water Salinity [ppm]')
title('Permeate Water Salinity, C_{p} ')
grid on


figure()
%{
subplot(4,1,1)

plot(t,waves.waveAmpTime(:,2),'Color',[0.3010, 0.7450, 0.9330])
xlabel('Time [s]')
ylabel('Wave elevation [m]')
%}
subplot(3,1,1)
plot(t,60*Q_brin,'k',t,60*Q_feed,'--r',t,60*Q_perm,'b')
legend('Q_{brine}','Q_{feed}','Q_{perm}','Location','northwest')
xlabel('Time [s]')
ylabel('Flow rate [L.min^{-1}]')
subplot(3,1,2)
plot(t,out.output_RO.signals.values(:,5)/10^5,'r')
xlabel('Time [s]')
ylabel('Feed Pressure [bar]')
subplot(3,1,3)
plot(t,X_perm,'--b')
xlabel('Time [s]')
ylabel('C_{p} [ppm]')

%% Additional plots

% figure()
% plot(t,Q_perm,t,Qavg_perm*ones(n,m),'r-')
% text(0,Qavg_perm,num2str(Qavg_perm))
% legend('Permeate Flow','Average value')
% xlabel('t [s]')
% ylabel('Water Production [L/min]')

% figure()
% plot(t,Q_feed,t,Qavg_feed*ones(n,m),'r-')
% text(0,Qavg_feed,num2str(Qavg_feed))
% legend('Feed Flow','Average value')
% xlabel('t [s]')
% ylabel('Water Production [L/min]')
% 
% figure()
% plot(t,Q_brin,t,Qavg_brin*ones(n,m),'r-')
% text(0,Qavg_brin,num2str(Qavg_brin))
% legend('Brine Flow','Average value')
% xlabel('t [s]')
% ylabel('Water Production [L/min]')
% 
% figure()
% plot(t,Q_perm,'b',t,Q_feed,'r',t,Q_brin,'g-')
% legend('Permeate Flow','Feed Flow','Brine Flow')
% xlabel('t [s]')
% ylabel('Water Production [L/min]')
% 
% %%%
% 
% figure()
% plot(t,X_perm,t,Xavg_perm*ones(n,m),'r-')
% text(0,Xavg_perm,num2str(Xavg_perm))
% legend('Permeate Flow','Average value')
% xlabel('t [s]')
% ylabel('Water Salinity [mg/L]')
% 
% figure()
% plot(t,X_feed,t,Xavg_feed*ones(n,m),'r-')
% text(0,Xavg_feed,num2str(Xavg_feed))
% legend('Feed Flow','Average value')
% xlabel('t [s]')
% ylabel('Water Salinity [mg/L]')
% 
% figure()
% plot(t,X_brin,t,Xavg_brin*ones(n,m),'r-')
% text(0,Xavg_brin,num2str(Xavg_brin))
% legend('Brine Flow','Average value')
% xlabel('t [s]')
% ylabel('Water Salinity [mg/L]')
% 
% figure()
% plot(t,X_perm,'b',t,X_feed,'r',t,X_brin,'g-')
% legend('Permeate Flow','Feed Flow','Brine Flow')
% xlabel('t [s]')
% ylabel('Water Salinity [mg/L]')
% 
% 
% 
% % figure()
% % plot(t,X_feed/10^3,t,X_perm/10^3,t,X_brin/10^3)
% % legend('Feed Flow','Permeate Flow','Brine Flow')
% % xlabel('t [s]')
% % ylabel('10^3 Water Salinity [mg/L]')
% % 
% % 
% % 
% % figure()
% % plot(t,6*10^4*Q_feed,t,6*10^4*Q_perm,t,6*10^4*Q_brin)
% % legend('Feed Flow','Permeate Flow','Brine Flow')
% % xlabel('t[s]')
% % ylabel('Water Production [L/min]')
% 
% 






% Fmax_PTO=max(F_PTO);
% Pavg_PTO=mean(P_PTO);
% Pmax_PTO=max(P_PTO);
% 
% %%%% Average Intake Rates
% 
% 
% 
% %%%%% 
% 
% 
% Xmax_perm=max(X_perm);
% Xavg_feed=mean(X_feed);
% Xavg_perm=mean(X_perm);
% Xavg_brin=mean(X_brin);
% [n,m]=size(Q_feed);
% 
% Xmodif_perm=zeros(n,m);
% %%%%Modified Concentration
% for i=1:n
%     for j=1:m
%         Xmodif_perm(i,j)=X_perm(i,j);
%         if Q_perm(i,j)<=eps
%             Xmodif_perm(i,j)=0;
%         end %if
%     end %i
% end %j
% figure()
% plot(t,X_perm/mean(X_perm),t,Q_perm/mean(Q_perm))
% legend('perm','Q_perm')
% figure()
% plot(t,X_perm)
% title('X_{perm} ')
% figure()
% plot(t,Q_perm,t,eps*ones(n,m))
% title('Q_{perm}')
% xlabel('t [s]')
% ylabel('Q_{perm} [Ls^{-1}]')
% legend('Q_{perm}','\epsilon')
% figure()
% plot(Xmodif_perm)
% title('Xmodif_perm')
% 
% 
% Xmodif_perm_avg=trapz(Xmodif_perm.*Q_perm);
% V_perm=trapz(Q_perm);
% Xmodif_perm_avg=Xmodif_perm_avg/V_perm;
% 
% %Xmodif_perm_avg=Xmodif_perm_avg/V_perm;
% % 
% % 
% % 
% %% Table data
% % 
% % Q_feed=6*10^4*Q_feed; %[L/min]
% % Q_perm=6*10^4*Q_perm; %[L/min]
% % Q_brin=6*10^4*Q_brin; %[L/min]
% 
% Qavg_feed=mean(Q_feed);
% Qavg_perm=mean(Q_perm);
% Qavg_brin=mean(Q_brin);
% 
% data.Pavg_PTO=Pavg_PTO;
% data.Pmax_PTO=Pmax_PTO;
% data.Fmax_PTO=Fmax_PTO;
% data.Q_brin=Qavg_brin;
% data.Q_feed=Qavg_feed;
% data.Q_perm=Qavg_perm;
% data.X_brin=Xavg_brin;
% data.X_feed=Xavg_feed;
% data.X_perm=Xavg_perm;
% data.Xmax_perm=Xmax_perm;
% %% Plots 
% 
% figure()
% plot(t,P_PTO,t,Pavg_PTO*ones(n,m),'-r',t,Pmax_PTO*ones(n,m))
% text(0,Pavg_PTO,num2str(Pavg_PTO))
% text(0,Pmax_PTO,num2str(Pmax_PTO))
% legend('Absorbed','Average value','Max value')
% xlabel('t [s]')
% ylabel('Absorbed Power [W]')
% 
% figure()
% plot(t,Q_perm,t,Qavg_perm*ones(n,m),'r-')
% text(0,Qavg_perm,num2str(Qavg_perm))
% legend('Permeate Flow','Average value')
% xlabel('t [s]')
% ylabel('Water Production [L/min]')
% 
% figure()
% plot(t,Q_feed,t,Qavg_feed*ones(n,m),'r-')
% text(0,Qavg_feed,num2str(Qavg_feed))
% legend('Feed Flow','Average value')
% xlabel('t [s]')
% ylabel('Water Production [L/min]')
% 
% figure()
% plot(t,Q_brin,t,Qavg_brin*ones(n,m),'r-')
% text(0,Qavg_brin,num2str(Qavg_brin))
% legend('Brine Flow','Average value')
% xlabel('t [s]')
% ylabel('Water Production [L/min]')
% 
% figure()
% plot(t,Q_perm,'b',t,Q_feed,'r',t,Q_brin,'g-')
% legend('Permeate Flow','Feed Flow','Brine Flow')
% xlabel('t [s]')
% ylabel('Water Production [L/min]')
% 
% %%%
% 
% figure()
% plot(t,X_perm,t,Xavg_perm*ones(n,m),'r-')
% text(0,Xavg_perm,num2str(Xavg_perm))
% legend('Permeate Flow','Average value')
% xlabel('t [s]')
% ylabel('Water Salinity [mg/L]')
% 
% figure()
% plot(t,X_feed,t,Xavg_feed*ones(n,m),'r-')
% text(0,Xavg_feed,num2str(Xavg_feed))
% legend('Feed Flow','Average value')
% xlabel('t [s]')
% ylabel('Water Salinity [mg/L]')
% 
% figure()
% plot(t,X_brin,t,Xavg_brin*ones(n,m),'r-')
% text(0,Xavg_brin,num2str(Xavg_brin))
% legend('Brine Flow','Average value')
% xlabel('t [s]')
% ylabel('Water Salinity [mg/L]')
% 
% figure()
% plot(t,X_perm,'b',t,X_feed,'r',t,X_brin,'g-')
% legend('Permeate Flow','Feed Flow','Brine Flow')
% xlabel('t [s]')
% ylabel('Water Salinity [mg/L]')
% 
% 
% 
% % figure()
% % plot(t,X_feed/10^3,t,X_perm/10^3,t,X_brin/10^3)
% % legend('Feed Flow','Permeate Flow','Brine Flow')
% % xlabel('t [s]')
% % ylabel('10^3 Water Salinity [mg/L]')
% % 
% % 
% % 
% % figure()
% % plot(t,6*10^4*Q_feed,t,6*10^4*Q_perm,t,6*10^4*Q_brin)
% % legend('Feed Flow','Permeate Flow','Brine Flow')
% % xlabel('t[s]')
% % ylabel('Water Production [L/min]')
% 
% 
% 
% % set(0,'DefaultFigureWindowStyle','docked')
% % 
% % figure();
% % plot(output.ptosim.time,output.ptosim.pistonNCF.topPressure/1e6,output.ptosim.time,output.ptosim.pistonNCF.bottomPressure/1e6)
% % set(findall(gcf,'type','axes'),'fontsize',16)
% % xlabel('Time (s)')
% % ylabel('Pressure (MPa)')
% % title('Piston Pressure')
% % legend('topPressure','bottomPressure')
% % grid on
% % 
% % figure();
% % plot(output.ptosim.time,output.ptosim.pistonNCF.force/1e6)
% % set(findall(gcf,'type','axes'),'fontsize',16)
% % xlabel('Time (s)')
% % ylabel('Force (MN)')
% % title('PTO Force')
% % grid on
% % 
% % 
% % figure();
% % plot(output.ptosim.time,output.ptosim.pistonNCF.absPower/1e3,output.ptosim.time,output.ptosim.rotaryGenerator.genPower/1e3,output.ptosim.time,output.ptosim.rotaryGenerator.elecPower/1e3)
% % set(findall(gcf,'type','axes'),'fontsize',16)
% % xlabel('Time (s)')
% ylabel('Power (kW)')
% title('Absorbed Power, Mechanical Power, and Electrical Power')
% legend('absPower','mechPower','elecPower')
% grid on
% 
% figure();
% plot(output.ptosim.time,output.ptosim.hydraulicMotor.angVel)
% set(findall(gcf,'type','axes'),'fontsize',16)
% xlabel('Time (s)')
% ylabel('Speed (rad/s)')
% title('Motor Speed')
% grid on

% figure()
% subplot(3,1,1)
% plot(output.ptosim.time,(output.ptosim.accumulator(1).pressure-output.ptosim.accumulator(2).pressure)/1e6)
% set(findall(gcf,'type','axes'),'fontsize',16)
% xlabel('Time (s)')
% ylabel('Pressure (MPa)')
% title('Pressure Differential Between the Two Accumulators')
% grid on
% subplot(3,1,2)
% plot(output.ptosim.time,output.ptosim.hydraulicMotor.volFlowM./output.ptosim.hydraulicMotor.angVel)
% set(findall(gcf,'type','axes'),'fontsize',16)
% xlabel('Time (s)')
% ylabel('Volume (m^3)')
% title('Hydraulic Motor Volume')
% grid on
% subplot(3,1,3)
% plot(output.ptosim.time,((output.ptosim.accumulator(1).pressure-output.ptosim.accumulator(2).pressure).*(output.ptosim.hydraulicMotor.volFlowM./output.ptosim.hydraulicMotor.angVel))/(ptosim.rotaryGenerator.desiredSpeed*1.05))
% set(findall(gcf,'type','axes'),'fontsize',16)
% xlabel('Time (s)')
% ylabel('Damping (kg-m^2/s)')
% title('Generator Damping')
% grid on
