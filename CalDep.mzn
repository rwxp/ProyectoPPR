% Use this editor as a MiniZinc scratch book

int: n;
array [1..n, 1..n] of int: D;
int: Min;
int: Max;
%Recordar que se debe incluir los negativos en el dominio.
array [1..2*(n-1), 1..n] of var -n..n: Cal;
array [1..2*(n-1)+1, 1..n ] of var int: Costos;
array[1..n] of var int: sum_costos;
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


% Restringiendo las permanencias a ser inferiores o iguales a Max
constraint forall (e in 1..n) (max([Gira[f,e]| f in 1..2*(n-1) where Gira[f,e]>0]) <= Max);

% Restringiendo las permanencias a ser superiores o iguales a Min
constraint forall (e in 1..n) (min([Gira[f,e]| f in 1..2*(n-1) where Gira[f,e]>0]) >= Min);


%-------------------------------------------------------

%Garantiza que todos los elemntos de las filas de Cal sean dftes.
constraint forall(i in 1..2*(n-1), j in 1..n, k in 1..n where j != k) (
   Cal[i,j] != Cal[i,k]
);
%Garantiza que todos los elementos de las columnas de Cal sean dftes.
constraint forall(j in 1..n, k in 1..2*(n-1), l in 1..2*(n-1) where k != l) (
   Cal[k,j] != Cal[l,j]
);

%Garantiza que todos los elementos de la matriz sean dftes de cero.
constraint forall(i in 1..2*(n-1), j in 1..n)(
  Cal[i,j] != 0
);
%Garantiza que exista el inverso aditivo para cada partido programado.
constraint forall(j in 1..n, k in 1..n where j!=k)(
  exists(i1, i2 in 1..2*(n-1))(
    Cal[i1,j]==k /\ Cal[i2,j]==-k
  )
);

%Garantiza que hayan n/2 partidos por fecha.
constraint forall(i in 1..2*(n-1))(
      sum([bool2int(Cal[i, j] > 0) | j in 1..n]) = n/2
);

%Garantiza que Cal[i,j]=k <-> Cal[i,k]=-j Si uno juega de local
% entonces el otro juega de visitante contra  mi.
constraint forall(i in 1..2*(n-1), j in 1..n, k in 1..n where k!= j)(
  (Cal[i,j] = k) <-> (Cal[i,k] = -j)
);
%Garantiza que no se jueguen partidos repetidos en dos fechas consecutivas.
constraint forall(j in 1..n, i in 1..2*(n-1)-1)(
  abs(Cal[i,j]) != abs(Cal[i+1,j]) 
);
constraint forall(j in 1..n)(
   if Cal[1, j] < 0 then 
     Costos[1,j] =  D[j, abs(Cal[1,j])]
   else
     Costos[1,j] = 0
   endif
   
);

constraint forall(j in 1..n)(
  if Cal[2*(n-1), j] < 0 then
      Costos[2*(n-1)+1, j] = D[abs(Cal[2*(n-1), j]), j]
   else
     Costos[2*(n-1)+1, j] = 0 
   endif
);

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
    sum_costos[j] = sum([Costos[i,j] | i in 1..2*(n-1)+1])
);

solve minimize sum([sum_costos[j]| j in 1..n]);


