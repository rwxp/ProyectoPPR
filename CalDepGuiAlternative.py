import sys
from PyQt5.QtWidgets import QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, QLabel, QTextEdit, QPushButton, QFileDialog
from PyQt5.QtCore import Qt
import subprocess

class CalDepGUI(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("ADAII - CalDep")
        self.initUI()

    def initUI(self):
        # Crea el widget central
        central_widget = QWidget()
        self.setCentralWidget(central_widget)

        # Crea el diseño vertical para los paneles
        vbox = QVBoxLayout()
        central_widget.setLayout(vbox)

        # Crea el panel de entrada
        input_panel = QWidget()
        input_layout = QVBoxLayout()
        input_panel.setLayout(input_layout)
        vbox.addWidget(input_panel)

        input_label = QLabel("Entrada")
        input_layout.addWidget(input_label)

        self.input_text = QTextEdit()
        self.input_text.setReadOnly(True)
        input_layout.addWidget(self.input_text)

        # Crear el panel de salida
        output_panel = QWidget()
        output_layout = QVBoxLayout()
        output_panel.setLayout(output_layout)
        vbox.addWidget(output_panel)

        output_label = QLabel("Salida")
        output_layout.addWidget(output_label)

        self.output_text = QTextEdit()
        self.output_text.setReadOnly(True)
        output_layout.addWidget(self.output_text)

        # Crear el botón para seleccionar el archivo .dzn
        button_select_dzn = QPushButton("Cargar archivo .dzn", self)
        button_select_dzn.clicked.connect(self.select_dzn_file)
        button_select_dzn.setStyleSheet("QPushButton { background-color: red; }")
        vbox.addWidget(button_select_dzn)

    def select_dzn_file(self):
        file_path, _ = QFileDialog.getOpenFileName(self, "Seleccionar archivo .dzn", "", "DZN files (*.dzn)")
        if file_path:
            self.parse_input_file(file_path)

    def parse_input_file(self, file_path):
        with open(file_path, "r") as file:
            lines = file.read().splitlines()

        n = int(lines[0])
        Min = int(lines[1])
        Max = int(lines[2])
        D = []
        for line in lines[3:]:
            row = list(map(int, line.split()))
            D.append(row)

        self.create_data_file(n, Min, Max, D)
        self.execute_model(n, Min, Max, D)

    def create_data_file(self, n, Min, Max, D):
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

    def execute_model(self, n, Min, Max, D):
        try:
            output = subprocess.check_output(["minizinc", "CalDep.mzn", "--data", "data.dzn"])

            # Extrae la matriz "Cal" de la salida
            cal_start_index = output.decode().find("Cal=[") + 5
            cal_end_index = output.decode().find("];", cal_start_index)
            cal_matrix = output.decode()[cal_start_index:cal_end_index]

            # entrada en el panel correspondiente
            self.input_text.setText("Entrada:\n\n")
            self.input_text.append(f"n={n}")
            self.input_text.append(f"Min={Min}")
            self.input_text.append(f"Max={Max}")
            self.input_text.append(f"D={D}")

            # alida en el panel correspondiente
            self.output_text.setText("Salida:\n\n")
            self.output_text.append(f"Cal={cal_matrix}]")

        except subprocess.CalledProcessError as e:
            # caso de error en la ejecución del modelo
            error_message = e.output.decode()
            self.output_text.setText(f"Error en la ejecución del modelo:\n{error_message}")


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = CalDepGUI()
    window.show()
    sys.exit(app.exec_())
