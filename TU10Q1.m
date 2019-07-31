kc = [ 0 15 30 45 60 75];
kp = 0.503;
tau = 12.4;

for i = 1:6
    CE_solution(i,:) = roots([tau.^3 3*tau.^2 3.*tau (1+kp.^3*kc(i))]);
    
    graph_title = ['kc=' num2str(kc(i))];
    figure(1)
    subplot(3,2,i)
    plot(CE_solution(i,:),'b*')
    title(graph_title,'fontsize',12,'FontWeight','bold')
end

CE_solution(7,:) = roots([tau.^3 3*tau.^2 3.*tau 1]);