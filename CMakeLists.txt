cmake_minimum_required(VERSION 3.30)
project(TrabalhoDeCompiladores)

# Encontrar Flex e Bison
find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

# Gerar arquivos do scanner e parser
FLEX_TARGET(Scanner src/flex_bison/lexer.l ${CMAKE_CURRENT_BINARY_DIR}/lexer.cpp)
BISON_TARGET(Parser src/flex_bison/parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.cpp
             DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/parser.tab.hpp)
ADD_FLEX_BISON_DEPENDENCY(Scanner Parser)

# Configurar o projeto
set(CMAKE_CXX_STANDARD 26)
include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src)

# Lista de arquivos fonte
set(SOURCES
    src/main.cpp
    src/code_generator.cpp
    ${FLEX_Scanner_OUTPUTS}
    ${BISON_Parser_OUTPUTS}
)

add_executable(TrabalhoDeCompiladores ${SOURCES})