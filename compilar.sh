#!/bin/bash

# Verificar se flex e bison estão instalados
if ! command -v flex &> /dev/null || ! command -v bison &> /dev/null; then
    echo "Erro: flex e/ou bison não estão instalados"
    echo "Por favor, instale com:"
    echo "sudo apt-get install flex bison"
    exit 1
fi

# Criar diretório de build se não existir
mkdir -p build
cd build

# Gerar arquivos do flex e bison
flex -o lexer.cpp ../src/flex_bison/lexer.l
bison -d -o parser.cpp ../src/flex_bison/parser.y

# Configurar e compilar o projeto
cmake ..
make

# Verificar se a compilação foi bem sucedida
if [ $? -eq 0 ]; then
    echo "Compilação concluída com sucesso!"
    echo "Para compilar um arquivo de exemplo, execute:"
    echo "./TrabalhoDeCompiladores ../exemplos/exemplo1.txt > exemplo1.cpp"
    
    # Executar os exemplos
    ./TrabalhoDeCompiladores ../exemplos/exemplo1.txt > exemplo1.cpp
    ./TrabalhoDeCompiladores ../exemplos/exemplo2.txt > exemplo2.cpp
    ./TrabalhoDeCompiladores ../exemplos/exemplo3.txt > exemplo3.cpp
else
    echo "Erro na compilação!"
    exit 1
fi