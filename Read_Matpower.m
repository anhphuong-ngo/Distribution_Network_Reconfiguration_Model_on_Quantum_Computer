%Matpower to GAMS
%you have to install GAMS.m https://gams-matlab.readthedocs.io/en/latest/gams-m.html
%this is for https://github.com/power-grid-lib/pglib-opf
%e.g., pglib_opf_case5_pjm
function [Pd, Pgmax, Pgmin, Gen2Bus, GenVarCost0, GenVarCost, Bij, MVAlim, A]=Read_Matpower(case_file)
%if case_file ==''
    %mpc = pglib_opf_case5_pjm;
%else
    mpc = case_file;
%bus data
    bus_data=mpc.bus;
    I=size(mpc.bus); I =I(1); %number of bus;
    %bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
    Pd= bus_data(:,3);%Pd
%    Qd= GAMS.param('Qd', bus_data(:,4), i.uels );%Qd
 %% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
    gen_data = mpc.gen;
    G=size(mpc.gen); G =G(1); %number of gen; 
    Pgmax=gen_data(:,9);
    Pgmin=gen_data(:,10);
    Gen2Bus =zeros(G,I);
    for iter = 1:G
        Gen2Bus(iter,gen_data(iter,1))=1;
    end
    gencost_data = mpc.gencost; %GenVarCost =gencost_data(:,6);
    index = size(gencost_data);
    index = index(2);
    GenVarCost0 =   gencost_data(:,index);
    GenVarCost  =   gencost_data(:,index-1);
    GenVarCost2 =   gencost_data(:,index-2);
%branch data
    branch_data=mpc.branch;
    L= size(branch_data); L=L(1);
    connect = zeros(I,I);  
    Bij = 1./branch_data(:,4); MVAlim =branch_data(:,7);
    for iter =1: L
        connect(branch_data(iter,1), branch_data(iter,2))=1; %this is connection matrix
    %    Bij(iter) =1/branch_data(iter,4); %1/X   
    end
      
    from_bus= branch_data(:,1);
    to_bus = branch_data(:,2);
    
    A=zeros(L,I);
    for l =1: L
        A(l,from_bus(l))=1;
        A(l,to_bus(l))=-1;
    end
    
%     mat2np(Pd,'Pd.pkl','float64');
%     mat2np(Pgmax,'Pgmax.pkl','float64');
%     mat2np(Gen2Bus,'Gen2Bus.pkl','int16');
%     mat2np(GenVarCost0,'GenVarCost0.pkl','float64');
%     mat2np(GenVarCost,'GenVarCost.pkl','float64');
%     mat2np(Bij,'Bij.pkl','float64');
%     mat2np(MVAlim,'MVAlim.pkl','float64');
%     mat2np(A,'A.pkl', 'int16')
      B= Bij.*A;
      AB = A'*B;
      
      F = [B zeros(L,G);
           -B zeros(L,G);
           zeros(G,I) eye(G);
           zeros(G,I) -eye(G);
           -AB          Gen2Bus'];
       size(F)
      b=[-MVAlim;
         - MVAlim;
          Pgmin;
          -Pgmax;
          Pd] ;
      
      bbt = b*b';
      
       one =zeros(length(b),1);
       one(1)=1;
       eyeM = eye(length(b));
    save('TestData.mat', 'Pd', 'Pgmax', 'Pgmin', 'Gen2Bus', 'GenVarCost0', 'GenVarCost', 'Bij', 'MVAlim', 'A', 'B', 'AB', 'F', 'b','one', 'bbt', 'eyeM');
end 

 
 
 
 
 
 