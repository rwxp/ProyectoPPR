import tkinter as tk
from tkinter import ttk, filedialog
import subprocess

# seleccionar el archivo de entrada
def select_dzn_file():
    file_path = filedialog.askopenfilename(filetypes=[("DZN files", "*.dzn")])
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

    create_data_file(n, Min, Max, D)
    execute_model(n, Min, Max, D)

# archivo intermedio se usa para guardar los datos en un formato que MiniZinc pueda leer
def create_data_file(n, Min, Max, D):
    with open("data.dzn", "w") as file:
        file.write(f"n={n};\n")
        file.write(f"Min={Min};\n")
        file.write(f"Max={Max};\n")
        file.write("D=[|\n")
        for row in D:
            file.write("  ")
            file.write(", ".join(str(x) for x in row))
            file.write(" |\n")
        file.write("|];\n")

# ejecutar el modelo de MiniZinc
def execute_model(n, Min, Max, D):
    try:
        output = subprocess.check_output(["minizinc", "CalDep.mzn", "--data", "data.dzn"])

        # Extraer la matriz "Cal" de la salida
        cal_start_index = output.decode().find("Cal=[") + 5
        cal_end_index = output.decode().find("];", cal_start_index)
        cal_matrix = output.decode()[cal_start_index:cal_end_index]

        # Mostrar la entrada en el panel correspondiente
        text_input.delete("1.0", tk.END)
        text_input.insert(tk.END, f"Entrada:\n\n")
        text_input.insert(tk.END, f"n={n}\n")
        text_input.insert(tk.END, f"Min={Min}\n")
        text_input.insert(tk.END, f"Max={Max}\n")
        text_input.insert(tk.END, f"D={D}\n\n")

        # Mostrar la salida en el panel correspondiente
        text_output.delete("1.0", tk.END)
        text_output.insert(tk.END, f"Salida:\n\n")
        text_output.insert(tk.END, f"Cal={cal_matrix}]")  # Agregar el corchete "]" al final

    except subprocess.CalledProcessError as e:
        # Manejar el caso de error en la ejecución del modelo
        error_message = e.output.decode()
        text_output.delete("1.0", tk.END)
        text_output.insert(tk.END, f"Error en la ejecución del modelo:\n{error_message}")




# Crea la ventana principal
window = tk.Tk()
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

# Crea el panel de entrada
label_input = ttk.Label(frame_input, text="Entrada")
label_input.pack()
scrollbar_input = ttk.Scrollbar(frame_input)
scrollbar_input.pack(side="right", fill="y")
text_input = tk.Text(
    frame_input, height=15, width=30, yscrollcommand=scrollbar_input.set)
text_input.pack()
scrollbar_input.config(command=text_input.yview)

# Crea el panel de salida
label_output = ttk.Label(frame_output, text="Salida")
label_output.pack()
scrollbar_output = ttk.Scrollbar(frame_output)
scrollbar_output.pack(side="right", fill="y") 
text_output = tk.Text(
    frame_output, height=15, width=50, yscrollcommand=scrollbar_output.set)
text_output.pack()
scrollbar_output.config(command=text_output.yview)

# Expande los paneles para que ocupen todo el espacio disponible no funciona bien jajjaja
window.grid_rowconfigure(0, weight=1)
window.grid_columnconfigure(0, weight=1)
window.grid_columnconfigure(1, weight=1)

# Ejecutar la ventana principal
window.mainloop()
