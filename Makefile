BUILD_DIR = build
BIN = $(BUILD_DIR)/babyfoot-app

.PHONY: all run clean

# Commande par défaut (exécutée quand on tape juste 'make') : configure et compile
all: $(BIN)

# Si le dossier de build ou CMakeCache n'existe pas, on configure le projet
$(BUILD_DIR)/CMakeCache.txt: CMakeLists.txt
	cmake -B $(BUILD_DIR) -S .

# Compile l'exécutable
$(BIN): $(BUILD_DIR)/CMakeCache.txt
	cmake --build $(BUILD_DIR)

# Compile puis lance l'application
run: $(BIN)
	./$(BIN)

# Supprime le dossier de build pour repartir de zéro
clean:
	rm -rf $(BUILD_DIR)