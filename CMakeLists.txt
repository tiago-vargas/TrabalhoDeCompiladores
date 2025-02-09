cmake_minimum_required(VERSION 3.10)
project(TrabalhoDeCompiladores)

# Encontrar Flex e Bison
find_package(BISON REQUIRED)
find_package(FLEX REQUIRED)

# Definir onde os arquivos gerados serão colocados
set(FLEX_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR})
set(BISON_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR})

# Gerar parser com Bison
BISON_TARGET(Parser
    src/flex_bison/parser.y
    ${BISON_OUTPUT_DIR}/parser.tab.cpp
    DEFINES_FILE ${BISON_OUTPUT_DIR}/parser.tab.hpp
)

# Gerar scanner com Flex
FLEX_TARGET(Scanner
    src/flex_bison/lexer.l
    ${FLEX_OUTPUT_DIR}/lexer.cpp
    DEFINES_FILE ${FLEX_OUTPUT_DIR}/lexer.hpp
)

# Adicionar dependência do Flex no Bison
ADD_FLEX_BISON_DEPENDENCY(Scanner Parser)

# Incluir diretórios
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_BINARY_DIR}
    ${FLEX_INCLUDE_DIRS}  # Adicionar include do Flex
)

# Adicionar o executável
add_executable(TrabalhoDeCompiladores
    src/main.cpp
    src/parser.cpp
    src/code_generator.cpp
    src/ast_printer.cpp
    src/symbol_table.cpp
    ${BISON_Parser_OUTPUTS}
    ${FLEX_Scanner_OUTPUTS}
)

# Definir C++17
set_target_properties(TrabalhoDeCompiladores PROPERTIES
    CXX_STANDARD 17
    CXX_STANDARD_REQUIRED ON
)

# Adicionar flags do Flex
target_compile_definitions(TrabalhoDeCompiladores PRIVATE
    YY_DECL="int AnalisadorLexico::yylex()"
)