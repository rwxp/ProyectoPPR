% Use this editor as a MiniZinc scratch book
include "globals.mzn";
include "DatosCalDep.dzn";
int: n;
array [1..n, 1..n] of int: D;
int: Min;
int: Max;
%Recordar que se debe incluir los negativos en el dominio.
array [1..2*(n-1), 1..n] of var -n..n: Cal;
array [1..2*(n-1), 1..n] of var int: Costos;

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
%Garantizar que
%Garantiza que toda gira se encuentre en el rango [Min,Max]
constraint forall(j in 1..n) (
    sum([bool2int(Cal[i, j] < 0) | i in 1..2*(n-1)]) >= Min /\
    sum([bool2int(Cal[i, j] < 0) | i in 1..2*(n-1)]) <= Max
);
%Garantiza que toda permanencia se encuentre en el rango [Min,Max]
constraint forall(j in 1..n) (
    sum([bool2int(Cal[i, j] > 0) | i in 1..2*(n-1)]) >= Min /\
    sum([bool2int(Cal[i, j] > 0) | i in 1..2*(n-1)]) <= Max
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

% constraint forall(j in 1..n, i in 2..2*(n-1))(
%   (Cal[i-1,j] > 0) -> ()
% );
constraint forall(j in 1..n)(
    forall(i in 2..2*(n-1))(
        if Cal[i-1,j] > 0 then
            Costos[i-1,j] = 0
        else
           if Cal[i,j] > 0 then
              Costos[i-1,j] = 2*D[j, abs(Cal[i-1,j])]
           else
              Costos[i-1, j] = D[j, abs(Cal[i-1,j])]
               /\ Costos[i,j] = D[abs(Cal[i-1,j]), abs(Cal[i,j])] 
           endif
        endif
    )
);
