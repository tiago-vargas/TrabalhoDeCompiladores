#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "=== Compilando o Tradutor ==="

# Entra no diretório src
cd src

# Limpa arquivos antigos
make clean

# Compila
if make; then
    echo -e "${GREEN}Compilação bem sucedida!${NC}"
else
    echo -e "${RED}Erro na compilação${NC}"
    exit 1
fi

# Volta para o diretório principal
cd ..

# Cria diretório para os arquivos de saída se não existir
mkdir -p output

echo "=== Traduzindo arquivos de exemplo ==="

# Lista de arquivos de exemplo
EXAMPLES=("exemplo1.txt" "exemplo2.txt" "exemplo3.txt")

for example in "${EXAMPLES[@]}"; do
    if [ -f "src/examples/$example" ]; then
        echo "Traduzindo $example..."
        ./src/tradutor "src/examples/$example" "output/${example%.txt}.cpp"
    else
        echo -e "${RED}Arquivo $example não encontrado${NC}"
    fi
done

echo "=== Processo completo ===" 