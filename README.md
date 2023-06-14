# El Problema de la Planificación del Calendario de Torneos Deportivos
## Proyecto 2 Análisis y Diseño de Algoritmos

Este repositorio contiene el código para solucionar el problema de planificación de calendario de torneos deportivos, el cual fue abordado utilizando MiniZinc junto con Python. En este repositorio se incluye el modelo utilizado y el programa para visualizar entradas y salidas de forma gráfica

### Integrantes
- Betancourt Narváez Juan Esteban - 1927215
- Caicedo Martinez Sebastian - 1841245
- Moyano Gonzalez Laura - 2023906
- Montaño Zalazar Geider - 1840292

### Contenido de la entrega
En el repositorio se entrega, el modelo, llamado ```CalDep.mzn```, y un archivo de datos utilizado para escribir la información que se lee en los archivos de prueba, llamado ```DatosCalDep.mzn```, este varía durante la ejecución del programa.

En la carpeta CalDepGUIFuentes se encuentra el archivo ```CalDepGUI.py```, el cual contiene la interfaz del programa.

En la carpeta MisInstancias se incluyen 5 archivos de prueba utilizados en el modelo (diferentes de los archivos dados).

El archivo ```requirements.txt``` contiene los requerimientos que se deben instalar para ejecutar el programa

**Nota:** En la carpeta CalDepGUIFuentes también se encuentran los archivos del modelo y datos, esto por si se quiere ejecutar el archivo de la interfaz gráfica desde el directorio CalDepGUIFuentes.

# ```Instrucciones de uso```
- Clonar el repositorio
```
git clone https://github.com/rwxp/ADArestricciones.git
```

Una vez clonado este repositorio, nos dirigimos a la carpeta donde se encuentran los archivos y ejecutamos la interfaz
### Creación de un ambiente virtual de Python (opcional)

##### En Windows
```
python -m venv .venv
./.venv/Scripts/activate
```
##### En Linux
```
python3 -m venv .venv
./.venv/bin/activate
```

### Instalación de requerimientos

##### En Windows
```
pip install -r requirements.txt
```
##### En Linux
```
pip3 install -r requirements.txt
```

### Ejecución del programa
Finalmente ejecutamos el programa ```CalDepGUI.py``` que se encuentra en el directiorio _CalDepGUIFuentes_.
##### En Windows
```
python CalDepGUIFuentes/CalDepGUI.py
```
##### En Linux
```
python3 CalDepGUIFuentes/CalDepGUI.py
```
