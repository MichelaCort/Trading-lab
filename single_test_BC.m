function [filter] = single_test_BC(a,t,n)
 
 
tic
% OPPURE se non lavoro su matrice ma input anagrafici manuali
%function [ output_args ] = test_CP(a)
 
% Adatto a pay-off "Bonus Cap", classe Equity Procection (editor Fausto Tenini).
% Matrice input (a): una serie storica prezzi del sottostante (punti per i decimali). 
% Matrice input (t): vettore riga contenente dati input anagrafici DI TESTO (Import- CELL ARRAY). 
% Matrice input (n): vettore riga contenente dati input anagrafici NUMERICI (Import- NUMERIC MATRIX). 
 
 
% Inizializzazione function, DATI DI INPUT tabella con anagrafiche prodotto
% ISIN  
% EMITTENTE 
% SOTTOSTANTE
% CODICE SERIE STORICA
% SCADENZA  
% Data_rilevazione_ultima_cedola
% TIPO
% P_SOTTOSTANTE 
% P_LETTERA 
% RIMBORSO MINIMO   
% STRIKE    
% CEDOLA    
% FREQUENZA ANNUA CEDOLA OPZ
% numero iterazioni bootstrap (num loop)
% quantile_VaR, per cut-off.
 
% Lavorazione anagrafiche:
 
ISIN=t(1,1);
%save("ISIN")
EMITTENTE=t(1,2);
%save("EMITTENTE")
SOTTOSTANTE=t(1,3);
%save("SOTTOSTANTE")
CODICE_SERIE_STORICA=t(1,4);
%save("CODICE_SERIE_STORICA")
 
% Trasformo le date di input formato "Cell Array" in date formato MATLAB; 
 
DateStrings=t(1,5);
SCADENZA=DateStrings;
%SCADENZA=datetime(DateStrings,'InputFormat','dd/MM/yyyy')
% Uso questa sopra se input dati di tempo è numerico tipo 12/10/2021;
%save("SCADENZA")
TIPO=n(1,7);
%save("TIPO")
P_SOTTOSTANTE=n(1,8);
%save("P_SOTTOSTANTE")
P_LETTERA=n(1,9);
%save("P_LETTERA")
RIMBORSO_MINIMO=n(1,10);
%save("RIMBORSO")
STRIKE=n(1,11);
%save("STRIKE")
CEDOLA=n(1,12);
%save("CEDOLA")
FREQUENZA_ANNUA_CEDOLA_Opz=n(1,13);
%save("FREQUENZA_ANNUA_CEDOLA_Opz")
 
ventipercento=n(1,8)*0.20;
barriera1=n(1,8)+ventipercento;
barriera2=n(1,8)-ventipercento;
BONUS=n(1,15);
CAP=n(1,16);
 
% Dati MANUALI x Test:
%ISIN="IT0005041832";
%EMITTENTE="Aletti";
%SOTTOSTANTE="Eni";
%CODICE_SERIE_STORICA= ENISPA;
%P_LETTERA=98.95;
%RIMBORSO=100;
%SCADENZA='22/08/2019';
%STRIKE=18.98;
%CEDOLA=0.0255;
%Data_rilevazione_ultima_cedola='20/08/2019';
%FREQUENZA_ANNUA_CEDOLA_Opz=1;
 
% ALTRI INPUT:
num_loop=1;
% Per test veloci:
%num_loop=200;
quantile_VaR=0.025;
 
% Data valutazione = oggi, cioè coincide con data elaborazione.
data_val=today;
% Per test su date specifiche:
%data_val=737170;
Valutazione=data_val;
formatOut = 'dd-mm-yyyy';
% Se voglio visualizzare in formato calendario:
Data_val = datestr(Valutazione,formatOut,'local');
 
% Conversione data scadenza solo per input dati manuali:
%formatIn = 'dd/mm/yyyy';
%data_scad= datenum(SCADENZA,formatIn);
% Conversione data scadenza:%
data_scad= datenum(DateStrings);
 
% Se voglio visualizzare in formato calendario:
 
% Calcolo giorni residui a scadenza:
Giorni_residui= data_scad-Valutazione;
 
    % Definisco holding period e costruisco Piano Cedole;
    holding_period=Giorni_residui+1;
    
% warning('off','all');
% Inizializzo ciclo su iterazioni:
Values=ones(num_loop,1);
 
% Se mi aggancio alla serie storica di input (a) per ultimo prezzo;
%last_price=a(size(a,1));
% Se mi aggancio a P_SOTTOSTANTE:
last_price=a(1000,1);
 
% Calcolo serie rendimenti log senza trend;
    b=a(1:end-1,:);
    d=a(2:end,:);
    LN_raw=log(d./b);
    LN=LN_raw-mean(LN_raw);
    mean(LN);
 
% identifico numerosità e creo matrici di appoggio;
    num=size(a,1)-1;
    items=ones(num,1);
    random_items=ones(num,2);
 
% Depotenzio volatilità storica per adattarmi a estensione temporale
% (giorni festivi non vengono esclusi):
Vol_factor=252/365;
LN=LN*Vol_factor;
matrix_LN=[items LN];
 
 
% Calcolo del rateo gg della componente ZC per i prodotti che rimborsano 100;
if RIMBORSO_MINIMO==100
Rateo_gg=(RIMBORSO_MINIMO/P_LETTERA-1)/Giorni_residui;
else
end
 
% Calcolo del multiplo del certificato (Multiplo*Sottostante= Rimborso):
Multiplo=100/STRIKE;
barrier_event=zeros(num_loop,1);
asset_forecast=zeros(num_loop,holding_period+1);
for z=1:1:num_loop;
   
    % Entro all'interno del singolo loop.
    
    % SIMULAZIONE BOOTSTRAP:
            
    % ciclo for per riempimento matrici date e date random;
    % for i=1:1:3;
    % per test veloci;
    for i=1:1:(num)
        items(i,1)=i;
        ceil(rand*(num));
        random_items(i,:)=ceil(rand*(num));
    end
    items;
           
    % identificazione data random su serie storica
    random_past_days=random_items(:,1);
    
    % identificazione dei log rendimenti associati alle date random (Asset log in Excel);
    random_LN=matrix_LN(random_past_days,:);
    % simulazione della dinamica futura dell'underlying su holding period;
    if holding_period>=size(random_LN(1))
    random_LN=[random_LN;random_LN;random_LN]; 
    else
    end
    asset_simulation=ones(holding_period,1).*last_price;
    for i=1:1:holding_period
        %for i=1:1:5
        asset_simulation(i+1,1)=asset_simulation(i,1)*exp(random_LN(i,2));
    end
    asset_simulation;
    %plot(asset_simulation);
    asset_simulation(end);
    Valore_finale_sottostante=asset_simulation(end)
    
    % Calcolo Rateo_gg per strutture con protezione diversa da 100:
    if RIMBORSO_MINIMO<100 | RIMBORSO_MINIMO>100
    Final_teoric_value=asset_simulation(end);
    Rimborso_teorico_puro=Multiplo*Final_teoric_value;
    Rimborso_teorico_puro_CAP=min(Rimborso_teorico_puro,CAP)
    %if Final_teoric_value>= BARRIERA
    Min_asset=min(asset_simulation);
    if min(asset_simulation)>= barriera1 | min(asset_simulation)<= barriera2
    barrier_event(z)=0;
    %RIMBORSO_SCADENZA=max(BONUS,Rimborso_teorico_puro_CAP);
    RIMBORSO_SCADENZA=0;
    else
    RIMBORSO_SCADENZA=CAP;
    barrier_event(z)=1;
    end
    RIMBORSO_SCADENZA;
    Rateo_gg=(RIMBORSO_SCADENZA/P_LETTERA-1)/Giorni_residui;
    asset_forecast(z,:)=asset_simulation;
    else
    end
    loop=z;
    RIMBORSO_SCADENZA
    
    
    % riscalo il pattern simulato dell'underlying in base 100 (start value prodotto)
    first=asset_simulation(1,:);
    asset_normalised=ones(size(asset_simulation));
    size(asset_simulation,1);
    %for i=1:1:5;
    for i=1:1:size(asset_simulation,1);
        asset_normalised(i,:)=asset_simulation(i,:)./first*100;
    end
    asset_normalised;
    %plot(asset_normalised);
    
    
    % SVILUPPO DEL PAY-OFF DEL PRODOTTO SU SIMULAZIONE BOOTSTRAP:
            
    % Calcolo del Pay-Off della componente ZC;
    pay_off_ZC=ones(holding_period,1).*100;
    for i=1:1:holding_period
        pay_off_ZC(i)=100+100*Rateo_gg*i;
    end
    pay_off_ZC;
        
    % PAY-OFF FINALE:
    Pay_off_dinamico=pay_off_ZC;
    %plot(Pay_off_dinamico)
    Pay_off_scadenza(z)=Pay_off_dinamico(end);
end
barrier_event;
NO_barrier_event_Prob=(num_loop-sum(barrier_event))/num_loop*100;
Pay_off_scadenza';
pay_off_ordinato=sortrows(Pay_off_scadenza');
min_value=min(pay_off_ordinato);
filtro_min_value=max(find(pay_off_ordinato==min_value));
 
asset_forecast=asset_forecast';
 
% ANALISI VAR: identifico valore di cut-off sul quantile, ed estraggo VaR A SCADENZA puntuale corrispondente
% Non è VaR periodale
%cut_off=quantile_VaR*num_loop;
%Prezzo_asset_normalizzato=pay_off_ordinato(cut_off);
%Prezzo_asset_in_euro=Prezzo_asset_normalizzato/100*last_price;
 
Dist_perc_Barriera1=(barriera1/P_SOTTOSTANTE-1)*100;
Dist_perc_Barriera2=(barriera2/P_SOTTOSTANTE-1)*100;
%Perc_MaxDD_cutoff=min((Prezzo_asset_normalizzato/100-1)*100,0);
 
%%%%%hist(Pay_off_scadenza,20);
%%%%%asset_SX=zeros(1000,num_loop);
%%%%%for p=1:1:num_loop
%%%%%asset_SX(:,num_loop)=a';
%%%%%end
%size(asset_SX)
%%%%%plot(asset_SX)
%%%%%size(asset_forecast)
%%%%%plot(asset_forecast)
%%%%%asset_mesh=[asset_SX ;asset_forecast];
 
% Per graficizzare:
xdates = floor(today) + (0:length(asset_simulation)-1);
    subplot(2,1,1);plot(xdates,asset_forecast,'-','LineWidth',1)
    datetick('x', 12)
    title('Simulazione Monte Carlo sul sottostante')
    ylabel('Prezzo del sottostante') % x-axis label
    hold on
plot(asset_forecast)
 
Pay_normalised=round(((Pay_off_scadenza)/100-1)*100/(Giorni_residui/365),2)
Pay_normalised_PERIODAL=round(((Pay_off_scadenza)/100-1)*100,1)
subplot(2,1,2);hist(Pay_normalised_PERIODAL,20);
%hist(Pay_normalised_PERIODAL,20);
%title('Simulazione PayOff Bonus Cap continuo su 5000 scenari')
xlabel('Rendimento PERIODALE in %') % x-axis label
%ylabel('Casistica eventi') % y-axis label
%hold off
 
%plot(pay_off_ordinato);
 
% Analisi cluster probabilità condizionali evento barriera:
%num_cluster=2;
%T= clusterdata(pay_off_ordinato,num_cluster);
%plot(T)
% Identifico la prob associata a NON evento barriera:
%NO_Barrier_Exp_Prob=round((num_loop-min(find(T==1)))/num_loop*100,3);
%cut_off_NO_2_cluster=0.01*num_loop;
%Perc_MaxDD_cutoff_NO_2_cluster=min(((pay_off_ordinato(cut_off_NO_2_cluster)/100-1)*100),0);
%if Perc_MaxDD_cutoff_NO_2_cluster==0
%NO_Barrier_Exp_Prob=99.9;
%else
%end
    
% ANALISI RENDIMENTI ATTESI E REND/RISCHIO:
% DEVO CALCOLARE UN VALORE ATTESO ASSOCIATO A CLUSTER 1;
%start_cluster1=min(find(T==1));
%Filt_Cluster1_returns=pay_off_ordinato(start_cluster1:end);
NO_Barrier_Exp_Ret=round(max((Pay_off_scadenza/100-1)*100));
NO_Barrier_Exp_Ret_Y=round(max((Pay_off_scadenza/100-1)*100)/(Giorni_residui/365),3);
Periodal_Yield_Fair_Value=round((mean(Pay_off_scadenza)/100-1)*100,3);
Annual_Yield_Fair_Value=round(Periodal_Yield_Fair_Value/(Giorni_residui/365),3);
Minimum_Annual_Yield=round(min((Pay_off_scadenza/100-1)*100)/(Giorni_residui/365),3);
Maximum_Annual_Yield=round(max((Pay_off_scadenza/100-1)*100)/(Giorni_residui/365),3);
Minimum_Annual_Yield_Prob=round(filtro_min_value/num_loop,3)*100;
max_value=max(pay_off_ordinato);
filtro_max_value=min(find(pay_off_ordinato==max_value));
if Minimum_Annual_Yield>=0
FilterR_R=0;
else
FilterR_R=abs(Minimum_Annual_Yield);
end
R_R=(1+Annual_Yield_Fair_Value)/(1+FilterR_R);
 
% Analisi quartili per Prob e Rend. atteso:
 
if NO_barrier_event_Prob>94
Q_Prob=4;
else
end
if NO_barrier_event_Prob<=94 & NO_barrier_event_Prob>85
Q_Prob=3;
else
end
if NO_barrier_event_Prob<=85 & NO_barrier_event_Prob>75
Q_Prob=2;
else
end
if NO_barrier_event_Prob<=75 
Q_Prob=1;
else
end
 
if NO_Barrier_Exp_Ret_Y>=1.5
Q_Return=4;
else
end
if NO_Barrier_Exp_Ret_Y>=0.5 & NO_Barrier_Exp_Ret_Y<1.5
Q_Return=3;
else
end
if NO_Barrier_Exp_Ret_Y>=0 & NO_Barrier_Exp_Ret_Y<0.5
Q_Return=2;
else
end
if NO_Barrier_Exp_Ret_Y<0
Q_Return=1;
else
end
 
Q_position=Q_Prob+Q_Return;
 
% Salvataggio dati elaborati:
%output = [TIPO,ISIN,EMITTENTE,SOTTOSTANTE,P_SOTTOSTANTE,P_LETTERA,RIMBORSO,SCADENZA,STRIKE,CEDOLA,Data_rilevazione_ultima_cedola,FREQUENZA_ANNUA_CEDOLA_Opz,Periodal_Yield_Fair_Value,Annual_Yield_Fair_Value,Minimum_Annual_Yield];
%filter=[Dist_perc_Barriera,Perc_MaxDD_cutoff,NO_barrier_event_Prob,NO_Barrier_Exp_Ret_Y,Q_position,"-","-"];
Prob_NO_barriera=NO_barrier_event_Prob;
% Stampa singola riga:
%fileID = fopen('Estrazione.txt','w');
%fprintf(fileID,'%5g %5g %5g %5g %5g %5g \n',Exp_Ret___Y_ExpRet___Min_Y_Yield___Min_Y_Prob');
toc


