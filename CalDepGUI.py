import tkinter as tk
from tkinter import filedialog
import subprocess


def select_dzn_file():
    file_path = filedialog.askopenfilename(filetypes=[("DZN files", "*.dzn")])
    if file_path:
        execute_model(file_path)


def execute_model(file_path):
    # Ejecutar el modelo utilizando MiniZinc
    output = subprocess.check_output(["minizinc", "CalDep.mzn", file_path])
    # Escribir el contenido en el archivo solution.txt
    with open("solution.txt", "wb") as file:
        file.write(output)

    # Mostrar un mensaje de éxito
    text_results.delete("1.0", tk.END)
    text_results.insert(tk.END, "El contenido se ha guardado en solution.txt.")


# Crear la ventana principal
window = tk.Tk()

# Crear el botón para seleccionar el archivo .dzn
button_select_dzn = tk.Button(
    window, text="Cargar archivo .dzn", command=select_dzn_file)
button_select_dzn.pack()

text_results = tk.Text(window, height=10, width=30)
text_results.pack()

# Ejecutar la ventana principal
window.mainloop()
