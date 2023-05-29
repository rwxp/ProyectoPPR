% Use this editor as a MiniZinc scratch book
include "globals.mzn";
include "DatosCalDep.dzn";
int: n;
array [1..n, 1..n] of int: D;
int: Min;
int: Max;
%Recordar que se debe incluir los negativos en el dominio.
array [1..2*(n-1), 1..n] of var -n..n: Cal;
array [1..2*(n-1)+1, 1..n ] of var int: Costos;
array[1..n] of var int: sum_costos;

%Garantiza que todos los elemntos de las filas de Cal sean dftes.
constraint forall(i in 1..2*(n-1)) (
    alldifferent([Cal[i, j] | j in 1..n])
);
%Garantiza que todos los elementos de las columnas de Cal sean dftes.
constraint forall(j in 1..n) (
    alldifferent([Cal[i, j] | i in 1..2*(n-1)])
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

%Garantiza que no exista el inverso aditivo para cada fila.
% constraint forall(i in 1..2*(n-1) )(
%   forall(j in 1..(n-1), k in 1..n where j != k)(
%     Cal[i,j]==k /\ Cal[i,j+1] != -k
%   )
% );

%Garantiza que toda gira se encuentre en el rango [Min,Max]
constraint forall(j in 1..n)(
  sum(i in 1..2*(n-1)-1)(if Cal[i,j] < 0 /\ Cal[i+1,j] < 0 then 1 else 0 endif)+1 >= Min /\
  sum(i in 1..2*(n-1)-1)(if Cal[i,j] < 0 /\ Cal[i+1,j] < 0 then 1 else 0 endif)+1 <= Max 
  

);
%%la idea es sacar ell min y max de giras
% constraint forall(j in 1..n) (
%     let {
%         array [1..2*(n-1)] of var int: consecutiveNegatives;
%         var int: minNegatives = n + 1;
%         var int: maxNegatives = 0;
%         var int: currentNegatives = 0;
%     }in
%     (
%         forall(i in 1..2*(n-1))(
%             if Cal[i,j] < 0 then
%                 currentNegatives = currentNegativess + 1 /\
%                 maxNegatives = max(maxNegatives, currentNegatives)
%             else
%                 minNegatives = min(minNegatives, currentNegatives) /\
%                 currentNegatives = 0
%             endif;
%         consecutiveNegatives = [minNegatives, maxNegatives]
%         )
%     )
%     (
%         minConsecutiveNegatives[j],
%         maxConsecutiveNegatives[j]
%     )
% );


%Garantiza que toda permanencia se encuentre en el rango [Min,Max]
constraint forall(j in 1..n)(
  sum(i in 1..2*(n-1)-1)(if Cal[i,j] > 0 /\ Cal[i+1,j] > 0 then 1 else 0 endif)+1 >= Min /\
  sum(i in 1..2*(n-1)-1)(if Cal[i,j] > 0 /\ Cal[i+1,j] > 0 then 1 else 0 endif)+1 <= Max 
  
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