function [B,M]=ltp(sp)
    n=length(sp);
    %Establish upper and lower pitch search limits
    pmin=50; pmax=200;
    sp2=sp.^2; %pre-calculate to save time
    for M=pmin:pmax
       e_del=sp(1:n-M);
       e=sp(M+1:n);
       e2=sp2(M+1:n);
       E(1+M-pmin)=sum((e_del.*e).^2)/sum(e2);
    end
    %Find M, the optimum pitch period
    [null, M]=max(E);
    M=M+pmin;
    %Find B, the pitch gain
    e_del=sp(1:n-M);
    e=sp(M+1:n);
    e2=sp2(M+1:n);
    B=sum(e_del.*e)/sum(e2);
end