% Use this editor as a MiniZinc scratch book
include "globals.mzn";

int: n;
array [1..n, 1..n] of int: D;
int: Min;
int: Max;
%Recordar que se debe incluir los negativos en el dominio.

array [1..2*(n-1), 1..n] of var -n..n: Cal;
array [1..2*(n-1)+1, 1..n ] of var 0..max(D): Costos;
array[1..n] of var int: sumCostos;
var int: costoTotal;
array[1..2*(n-1), 1..n] of var 0..n: ConteoPerm;
array[1..2*(n-1), 1..n] of var 0..n: ConteoGira;
array[1..2*(n-1), 1..n] of var 0..n: Perm;
array[1..2*(n-1), 1..n] of var 0..n: Gira;



%Calculando ConteoPerm
constraint forall (e in 1..n) (if Cal[1,e]>0 then (ConteoPerm[1,e]=1) 
                               else (ConteoPerm[1,e]=0) endif);
                               
constraint forall (e in 1..n, f in 2..2*(n-1)) (if Cal[f,e]>0 then 
                  (ConteoPerm[f,e]=ConteoPerm[f-1,e]+1) 
                  else (ConteoPerm[f,e]=0) endif);

constraint forall (e in 1..n, f in 1..2*(n-1)-1) (if ConteoPerm[f,e]>ConteoPerm[f+1,e] then 
                  (Perm[f,e]=ConteoPerm[f,e]) 
                  else (Perm[f,e]=0) endif);
                  
constraint forall (e in 1..n) (Perm[2*(n-1),e]=ConteoPerm[2*(n-1),e]);


% Restringiendo las permanencias a ser inferiores o iguales a Max
constraint forall (e in 1..n) (max([Perm[f,e]| f in 1..2*(n-1) where Perm[f,e]>0]) <= Max);

% Restringiendo las permanencias a ser superiores o iguales a Min
constraint forall (e in 1..n) (min([Perm[f,e]| f in 1..2*(n-1) where Perm[f,e]>0]) >= Min);
%----------------------------------------------------------------------

%Calculando ConteoGira
constraint forall (e in 1..n) (if Cal[1,e]<0 then (ConteoGira[1,e]=1) 
                               else (ConteoGira[1,e]=0) endif);
                               
constraint forall (e in 1..n, f in 2..2*(n-1)) (if Cal[f,e]<0 then 
                  (ConteoGira[f,e]=ConteoGira[f-1,e]+1) 
                  else (ConteoGira[f,e]=0) endif);

constraint forall (e in 1..n, f in 1..2*(n-1)-1) (if ConteoGira[f,e]>ConteoGira[f+1,e] then 
                  (Gira[f,e]=ConteoGira[f,e]) 
                  else (Gira[f,e]=0) endif);
                  
constraint forall (e in 1..n) (Gira[2*(n-1),e]=ConteoGira[2*(n-1),e]);


% Restringiendo las giras a ser inferiores o iguales a Max
constraint forall (e in 1..n) (max([Gira[f,e]| f in 1..2*(n-1) where Gira[f,e]>0]) <= Max);

% Restringiendo las giras a ser superiores o iguales a Min
constraint forall (e in 1..n) (min([Gira[f,e]| f in 1..2*(n-1) where Gira[f,e]>0]) >= Min);

%-------------------------------------------------------

%Garantiza que todos los elemntos de las columnas de Cal sean dftes.
constraint forall(i in 1..2*(n-1)) (
    alldifferent([Cal[i, j] | j in 1..n]));

%Garantiza que todos los elemntos de las filas de Cal sean dftes.
constraint forall(j in 1..n) (
     alldifferent([Cal[i, j] | i in 1..2*(n-1)]));


%Garantiza que todos los elementos de la matriz Cal sean dftes de cero.
 constraint forall(i in 1..2*(n-1), j in 1..n)(
   Cal[i,j] != 0
 );


%Garantiza que exista el inverso aditivo para cada partido programado.
% constraint forall(j in 1..n, k in 1..n where j!=k)(
%   exists(i1, i2 in 1..2*(n-1))(
%       Cal[i1,j]==k /\ Cal[i2,j]==-k
%   )
% );

%Garantiza que hayan n-1 partidos por equipo de permanencia
constraint forall(j in 1..n)(
      sum([bool2int(Cal[i, j] > 0) | i in 1..2*(n-1)]) = n-1
);
%Garantiza que hayan n-1  partidos por equipo de gira 
constraint forall(j in 1..n)(
      sum([bool2int(Cal[i, j] < 0) | i in 1..2*(n-1)]) = n-1
);

%Garantiza que hayan n/2 partidos de local por fecha.
constraint forall(i in 1..2*(n-1))(
      sum([bool2int(Cal[i, j] > 0) | j in 1..n]) = n/2
);

constraint forall(i in 1..2*(n-1))(
      sum([bool2int(Cal[i, j] < 0) | j in 1..n]) = n/2
);


%Garantiza que Cal[i,j]=k <-> Cal[i,k]=-j Si uno juega de local
% entonces el otro juega de visitante contra  mi.
constraint forall(i in 1..2*(n-1)) ( 
  forall(j, k in 1..n where k!= j)(
    (Cal[i,j] = k) <-> (Cal[i,k] = -j)
  )
);

%Garantiza que no se jueguen partidos repetidos en dos fechas consecutivas.
constraint forall(j in 1..n) ( 
  forall( i in 1..2*(n-1)-1)(
    abs(Cal[i,j]) != abs(Cal[i+1,j]) 
    )
);

%Garantiza que un equipo no juegue contra si mismo
constraint forall(j in 1..n) ( forall( i in 1..2*(n-1))(
  abs(Cal[i,j]) != j
    )
);


%Se usa para que primero se jueguen los partidos de ida y luego los de vuelta.
constraint forall(j in 1..n)(
  alldifferent([abs(Cal[i,j]) | i in 1..n-1 where abs(Cal[i,j]) != j ] )  
  
);
  



%Rompe simetrías
constraint Cal[1,1] > 0;



constraint forall(j in 1..n) (
       forall(i in 1..2*(n-1)+1)(
        if i = 1 /\ Cal[i,j] < 0 then
              Costos[i,j] = D[j, abs(Cal[i,j])]     
        else
        if i = 2*(n-1)+1 /\ Cal[i-1,j] < 0 then
              Costos[i,j] = D[abs(Cal[i-1,j]), j]     
        else
        if i != 1 /\ i != 2*(n-1)+1 /\ Cal[i-1,j] < 0 /\ Cal[i,j] > 0 then
              Costos[i,j] = D[abs(Cal[i-1,j]), j]
        else
        if i != 1 /\ i != 2*(n-1)+1 /\ Cal[i-1 ,j] > 0 /\ Cal[i,j] < 0 then
              Costos[i,j] =  D[j, abs(Cal[i,j])]
        else
        if i != 1 /\ i != 2*(n-1)+1 /\ Cal[i-1, j] < 0 /\ Cal[i, j] < 0 then
             Costos[i,j] = D[abs(Cal[i-1, j]), abs(Cal[i, j])]
        else
        Costos[i,j] = 0 
        
        endif
        endif
        endif
        endif
        endif
       )  
);



constraint forall(j in 1..n) (
    sumCostos[j] = sum([Costos[i,j] | i in 1..2*(n-1)+1])
);

constraint costoTotal = sum(sumCostos);

%solve :: int_search(Cal, input_order, indomain_min, complete) minimize costoTotal;


%12_0
%solve :: int_search(Cal, smallest, indomain_min, complete) minimize costoTotal;
%12_4
%solve :: int_search(Cal, smallest, indomain_median, complete) minimize costoTotal;
%16_0
%solve :: int_search(Cal, smallest, indomain_split, complete) minimize costoTotal;
%16_1 16_2 16_3 16_4
solve :: int_search(Cal, first_fail, indomain_min, complete) minimize costoTotal;



