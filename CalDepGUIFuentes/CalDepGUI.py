import tkinter as tk
from tkinter import ttk, filedialog
import subprocess
from minizinc import Instance, Model, Solver
import datetime
# import os

# absolutepath = os.path.abspath(__file__)
# print(absolutepath)

# seleccionar el archivo de entrada
def select_dzn_file():
    file_path = filedialog.askopenfilename()
    if file_path:
        parse_input_file(file_path)

# leer el archivo de entrada y crear el archivo intermedio
def parse_input_file(file_path):
    with open(file_path, "r") as file:
        lines = file.read().splitlines()

    n = int(lines[0])
    Min = int(lines[1])
    Max = int(lines[2])
    D = []
    for line in lines[3:]:
        row = list(map(int, line.split()))
        D.append(row)

    # Mostrar la entrada en el panel correspondiente
    text_input.config(state="normal")
    text_input.delete("1.0", tk.END)
    text_input.insert(tk.END, f"Datos leídos:\n\n")
    text_input.insert(tk.END, f"n   = {n}\n")
    text_input.insert(tk.END, f"Min = {Min}\n")
    text_input.insert(tk.END, f"Max = {Max}\n")
    text_input.insert(tk.END, f"D   = \n")
    for row in D:
        text_input.insert(tk.END, f"      {row}\n")
        
    text_input.config(state="disabled")

    create_data_file(n, Min, Max, D)
    #execute_model(n, Min, Max, D)

# archivo intermedio se usa para guardar los datos en un formato que MiniZinc pueda leer
def create_data_file(n, Min, Max, D):
    with open("DatosCalDep.dzn", "w") as file:
        file.write(f"n={n};\n")
        file.write(f"Min={Min};\n")
        file.write(f"Max={Max};\n")
        file.write("D=[|\n")
        for row in D:
            file.write("  ")
            file.write(", ".join(str(x) for x in row))
            file.write(" |\n")
        file.write("|];\n")


def print_matrix(xd, matrix):
    print(xd)
    for row in matrix:
        print(row)

# ejecutar el modelo de MiniZinc
def execute_model():

    # Mostrar la salida en el panel correspondiente
    text_output.config(state="normal")
    text_output.delete("1.0", tk.END)

    try:
        model = Model("CalDep.mzn")
        model.add_file("DatosCalDep.dzn")
        solver = Solver.lookup("chuffed")
        instance = Instance(solver, model)
        # instance["n"] = n
        # instance["Min"] = Min
        # instance["Max"] = Max
        # instance["D"] = D
        start = datetime.datetime.now()
        result = instance.solve(timeout=datetime.timedelta(seconds=210))
        end = datetime.datetime.now()

        if result:
            costo = result.objective
            cal_matrix = result["Cal"]
            text_output.insert(tk.END, f"Solución encontrada:\n\n")
            text_output.insert(tk.END, f"Costo total = {costo}\n")

            text_output.insert(tk.END, f"Cal = \n")
            for row in cal_matrix:
                text_output.insert(tk.END, f"      {row}\n")
            text_output.insert(tk.END, f"\n")

        elif end - start < datetime.timedelta(seconds=220):
            text_output.insert(tk.END, f"Solución NO encontrada:\n\n")
            text_output.insert(tk.END, f"EL PROBLEMA ES INSATISFACIBLE\n\n")
        else:
            text_output.insert(tk.END, f"Solución NO encontrada:\n\n")
            text_output.insert(tk.END, f"No se ha podido encontrar una solución en el tiempo dado\n\n")

        text_output.insert(tk.END, f"Tiempo de ejecución: {end-start}\n\n")
        text_output.config(state="disabled")

    except subprocess.CalledProcessError as e:
        # Manejar el caso de error en la ejecución del modelo
        error_message = e.output.decode()
        text_output.delete("1.0", tk.END)
        text_output.insert(tk.END, f"Error en la ejecución del modelo:\n{error_message}")




# Crea la ventana principal
window = tk.Tk()
window.geometry("1200x700")
window.title("ADAII - CalDep")

# Estilo de la interfaz
style = ttk.Style()
style.theme_use("clam") # ("clam", "alt", "default", "classic")

# Cambia el estilo del botón "Cargar archivo .dzn"
style.configure("Custom.TButton", foreground="white", background="red", 
                font=("Helvetica", 12, "bold"), 
                relief="raised", 
                borderwidth=3, 
                padding=10, 
                width=20,
                hoverbackground="green",
                hoverforeground="red")

# Dividir la ventana en dos paneles
frame_input = ttk.Frame(window, padding=10)
frame_input.grid(row=0, column=0, sticky="nsew")
frame_output = ttk.Frame(window, padding=10)
frame_output.grid(row=0, column=1, sticky="nsew")

# Crea el botón para seleccionar el archivo .dzn
button_select_dzn = ttk.Button(
    frame_input, text="Cargar archivo .dzn", command=select_dzn_file, style="Custom.TButton", cursor="hand2")
button_select_dzn.pack(pady=10)

button_solve = ttk.Button(
    frame_input, text="Resolver", command=execute_model, style="Custom.TButton", cursor="hand2")
button_solve.pack(pady=10)

# Crea el panel de entrada
label_input = ttk.Label(frame_input, text="Entrada")
label_input.pack()

# Crea el scroll de y
scrollbar_input = ttk.Scrollbar(frame_input)
scrollbar_input.pack(side="right", fill="y")

# Crea el scroll de x
scrollbar_input_x = ttk.Scrollbar(frame_input, orient="horizontal")
scrollbar_input_x.pack(side="bottom", fill="x")

# Cuadro de texto de entrada
text_input = tk.Text(
    frame_input, height=45, width=70, yscrollcommand=scrollbar_input.set, xscrollcommand=scrollbar_input_x.set, state="disabled", wrap="none")
text_input.pack()
scrollbar_input.config(command=text_input.yview)
scrollbar_input_x.config(command=text_input.xview)


# Crea el panel de salida
label_output = ttk.Label(frame_output, text="Salida")
label_output.pack()

# Crea el scroll de y
scrollbar_output = ttk.Scrollbar(frame_output)
scrollbar_output.pack(side="right", fill="y")

# Crea el scroll de x
scrollbar_output_x = ttk.Scrollbar(frame_output, orient="horizontal")
scrollbar_output_x.pack(side="bottom", fill="x")

text_output = tk.Text(
    frame_output, height=40, width=70, yscrollcommand=scrollbar_output.set, xscrollcommand=scrollbar_output_x.set, state="disabled", wrap="none")
text_output.pack()
scrollbar_output.config(command=text_output.yview)
scrollbar_output_x.config(command=text_output.xview)

# Expande los paneles para que ocupen todo el espacio disponible
window.grid_rowconfigure(0, weight=1)
window.grid_columnconfigure(0, weight=1)
window.grid_columnconfigure(1, weight=1)

# Ejecutar la ventana principal
window.mainloop()
