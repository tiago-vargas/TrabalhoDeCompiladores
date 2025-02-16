cmake_minimum_required(VERSION 3.30)
project(TrabalhoDeCompiladores)

set(CMAKE_CXX_STANDARD 26)

find_package(BISON REQUIRED)
find_package(FLEX REQUIRED)

# Bison command
add_custom_command(
	OUTPUT ${CMAKE_SOURCE_DIR}/src/aux/parser.tab.h ${CMAKE_SOURCE_DIR}/src/aux/parser.tab.c
	DEPENDS ${CMAKE_SOURCE_DIR}/src/parser.y
	COMMAND bison --defines --verbose -Werror=conflicts-sr -Wcounterexamples --output=${CMAKE_SOURCE_DIR}/src/aux/parser.tab.c ${CMAKE_SOURCE_DIR}/src/parser.y
	COMMENT "Running Bison"
)

# Flex command
add_custom_command(
	OUTPUT ${CMAKE_SOURCE_DIR}/src/aux/lexer.h ${CMAKE_SOURCE_DIR}/src/aux/lex.yy.c
	DEPENDS ${CMAKE_SOURCE_DIR}/src/lexer.l
	COMMAND flex --header-file=${CMAKE_SOURCE_DIR}/src/aux/lexer.h --outfile=${CMAKE_SOURCE_DIR}/src/aux/lex.yy.c ${CMAKE_SOURCE_DIR}/src/lexer.l
	COMMENT "Running Flex"
)

# Define a library for the parser and lexer
add_library(compiler_lib ${CMAKE_SOURCE_DIR}/src/aux/parser.tab.c ${CMAKE_SOURCE_DIR}/src/aux/lex.yy.c)
target_link_libraries(compiler_lib fl)

# Define the main executable
add_executable(TrabalhoDeCompiladores ${CMAKE_SOURCE_DIR}/src/main.cpp)
target_link_libraries(TrabalhoDeCompiladores compiler_lib)

# Ensure the parser and lexer are built before the main executable
add_dependencies(TrabalhoDeCompiladores compiler_lib)
