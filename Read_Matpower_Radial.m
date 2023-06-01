%Matpower to GAMS
%you have to install GAMS.m https://gams-matlab.readthedocs.io/en/latest/gams-m.html
%this is for https://github.com/power-grid-lib/pglib-opf
%e.g., pglib_opf_case5_pjm
function [Pd, Pgmax, Pgmin, Gen2Bus, GenVarCost0, GenVarCost,  MVAlim, A]=Read_Matpower_Radial(case_file)
%if case_file ==''
    %mpc = case33bw;
%else
    if isa(case_file,'char')
        case_file = eval(case_file);
    mpc = case_file;
    Sbase = mpc.baseMVA;
%bus data
    bus_data=mpc.bus;
    I=size(mpc.bus); I =I(1); %number of bus;
    %bus_i	type	Pd	Qd	Gs	Bs	area	Vm	Va	baseKV	zone	Vmax	Vmin
    Pd= bus_data(:,3); %MW
    Qd= bus_data(:,4); %MW
    Vmax = bus_data(:,12); %pu
    Vmin = bus_data(:,13); %pu
    gs   = bus_data(:,5);
    bs   = bus_data(:,6);
    
    
 %% generator data
%	bus	Pg	Qg	Qmax	Qmin	Vg	mBase	status	Pmax	Pmin	Pc1	Pc2	Qc1min	Qc1max	Qc2min	Qc2max	ramp_agc	ramp_10	ramp_30	ramp_q	apf
%     gen_data = mpc.gen;
%     G=size(mpc.gen); G =G(1); %number of gen; 
%     Pgmax= gen_data(:,9);
%     Pgmin= gen_data(:,10);
%     Qgmax = gen_data(:,4);V
%     Qgmin = gen_data(:,5);
%     Gen2Bus =zeros(G,I);
%     for line = 1:G
%         Gen2Bus(line,gen_data(line,1))=1;
%     end
%     gencost_data = mpc.gencost; %GenVarCost =gencost_data(:,6);
%     index = size(gencost_data);
%     index = index(2);
%     GenVarCost0 =   gencost_data(:,index);
%     GenVarCost  =   gencost_data(:,index-1);
%     GenVarCost2 =   gencost_data(:,index-2);
%     
    
    
%branch data
%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
%mpc.branch = [  %% (r and x specified in ohms here, converted to p.u. below)
%note that at the ened matpower convert to pu     
%status: connect or open switches
    branch_data=mpc.branch;
%    L= size(branch_data); L=L(1);
    connex = zeros(I,I);  
    MVAlim =zeros(I,I);
    G = zeros(I,I); 
    B = zeros(I,I); 
    Y = zeros(I,I); 
    r = zeros(I,I);
    x = zeros(I,I);
    i=sqrt(-1.00);
    from_bus= branch_data(:,1);
    to_bus = branch_data(:,2);
    L=length(from_bus);
    for line =1: L
        r(from_bus(line), to_bus(line)) = branch_data(line,3);
        r(to_bus(line),from_bus(line)) = branch_data(line,3);
        x(from_bus(line), to_bus(line)) = branch_data(line,4);
        x(to_bus(line), from_bus(line)) = branch_data(line,4);
        connex(from_bus(line), to_bus(line))=branch_data(line,11); %this is connection matrix of Kostas
        MVAlim(from_bus(line), to_bus(line)) = branch_data(line,7);  MVAlim(to_bus(line), from_bus(line)) = branch_data(line,7);
        Y(from_bus(line), to_bus(line)) = inv( branch_data(line,3)+ i*branch_data(line,4));
        G(from_bus(line), to_bus(line)) = real(Y(from_bus(line), to_bus(line))); 
        G(to_bus(line), from_bus(line)) = real(Y(from_bus(line), to_bus(line))); 
        B(from_bus(line), to_bus(line)) = -imag(Y(from_bus(line), to_bus(line))); 
        B(to_bus(line), from_bus(line)) = -imag(Y(from_bus(line), to_bus(line))); 
    end
    [YBUS, ~, ~] = makeYbus(case_file);
    G1 = abs(real(full(YBUS)));G1=G1.*(connex+connex');
    B1 = abs(imag(full(YBUS)));B1 =B1.*(connex+connex') ;
    if I == 33
        for i =1:L
            MVAlim(from_bus(i), to_bus(i)) =270;
            MVAlim(to_bus(i) , from_bus(i)) =270;
        end
    end
  %  save('Radial.mat', 'Sbase', 'Pgmax', 'Pgmin', 'Qgmax', 'Qgmin', 'GenVarCost0', 'GenVarCost', 'G', 'B', 'MVAlim', 'connex', 'Pd', 'Qd', 'Vmax', 'Vmin','Gen2Bus', 'I');
    save('Radial.mat', 'from_bus','to_bus','Sbase', 'G', 'B', 'MVAlim', 'connex', 'Pd', 'Qd', 'Vmax', 'Vmin','I', 'bs', 'gs', 'r', 'x', 'L','G1','B1');
end 

 
 
 
 
 
 