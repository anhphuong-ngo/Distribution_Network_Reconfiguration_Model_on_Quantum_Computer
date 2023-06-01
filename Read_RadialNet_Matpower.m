%Matpower to GAMS
%you have to install GAMS.m https://gams-matlab.readthedocs.io/en/latest/gams-m.html
%this is for https://github.com/power-grid-lib/pglib-opf
%e.g., pglib_opf_case5_pjm
function [Pd, Pgmax, Pgmin, Gen2Bus, GenVarCost0, GenVarCost,  MVAlim, A]=Read_RadialNet_Matpower(case_file)
%if case_file ==''
    %mpc = case33bw;
%else
    if isa(case_file,'char')
        case_file = eval(case_file);
    mpc = case_file;
	mpc=ext2int(mpc);
    Sbase = mpc.baseMVA;
	[Sbase, bus, gen, branch] = deal(mpc.baseMVA, mpc.bus, mpc.gen, mpc.branch);
%bus data
    bus_data=bus;
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

    
%branch data
%% branch data
%	fbus	tbus	r	x	b	rateA	rateB	rateC	ratio	angle	status	angmin	angmax
%mpc.branch = [  %% (r and x specified in ohms here, converted to p.u. below)
%note that at the end matpower convert to pu     
%status: connect or open switches
    branch_data=branch;
%    L= size(branch_data); L=L(1);
    from_bus= branch_data(:,1);
    to_bus = branch_data(:,2);
    L=length(from_bus);
    r=zeros(L,1); x=zeros(L,1); status=zeros(L,1); MVAlim=zeros(L,1); 
    Y=zeros(L,1); G=zeros(L,1); B=zeros(L,1);
    i=sqrt(-1.00);connex = zeros(I,I);
    for line =1: L
        r(line) = branch_data(line,3);
        x(line) = branch_data(line,4);
        connex(from_bus(line), to_bus(line))=branch_data(line,11);
        status(line)=branch_data(line,11); %this is connection matrix of Kostas
		if branch_data(line,6) == 0 %rateA of the line
			MVAlim(line) = 10*mpc.baseMVA;
        else
			MVAlim(line) = branch_data(line,6);
		end
		% most distribution test cases do not have line limit data 
		% in the code, we use the suggested value of Lucient Lobo Second-order cone relaxations of the optimal power flow for active distribution grids: Comparison of methods
		% to constrain Imax as 4pu
        Y(line) = inv( branch_data(line,3)+ i*branch_data(line,4));
        G(line) = real(Y(line)); 
        B(line) = -imag(Y(line)); 
    end

    if I == 33
        for line =1:L
            MVAlim(line) =270;
        end
    end
    
    if sum(MVAlim)==0
        MVAlim=360*ones(length(MVAlim),1);
    end
  %  save('Radial.mat', 'Sbase', 'Pgmax', 'Pgmin', 'Qgmax', 'Qgmin', 'GenVarCost0', 'GenVarCost', 'G', 'B', 'MVAlim', 'connex', 'Pd', 'Qd', 'Vmax', 'Vmin','Gen2Bus', 'I');
    save('Radial_Netdata.mat', 'from_bus','to_bus','Sbase', 'G', 'B', 'MVAlim', 'status', 'Pd', 'Qd', 'Vmax', 'Vmin','I', 'bs', 'gs', 'r', 'x', 'L','connex');
end 

 
 
 
 
 
 