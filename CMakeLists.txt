cmake_minimum_required(VERSION 3.30)
project(TrabalhoDeCompiladores)

set(CMAKE_CXX_STANDARD 26)

find_package(BISON)
find_package(FLEX)

add_custom_command(
	OUTPUT ${CMAKE_SOURCE_DIR}/src/aux/parser.tab.c ${CMAKE_SOURCE_DIR}/src/aux/parser.tab.h
	DEPENDS ${CMAKE_SOURCE_DIR}/src/parser.y
	COMMAND bison --defines --verbose -Wcounterexamples --output=${CMAKE_SOURCE_DIR}/src/aux/parser.tab.c ${CMAKE_SOURCE_DIR}/src/parser.y
	COMMENT "Running Bison"
)

add_custom_command(
	OUTPUT ${CMAKE_SOURCE_DIR}/src/aux/lexer.h ${CMAKE_SOURCE_DIR}/src/aux/lex.yy.c
	DEPENDS ${CMAKE_SOURCE_DIR}/src/lexer.l
	COMMAND flex --header-file=${CMAKE_SOURCE_DIR}/src/aux/lexer.h ${CMAKE_SOURCE_DIR}/src/lexer.l
	COMMENT "Running Flex"
)

add_custom_target(compiler ALL
	DEPENDS ${CMAKE_SOURCE_DIR}/src/aux/parser.tab.c ${CMAKE_SOURCE_DIR}/src/aux/lex.yy.c
	COMMAND gcc ${CMAKE_SOURCE_DIR}/src/aux/parser.tab.c ${CMAKE_SOURCE_DIR}/src/aux/lex.yy.c -lfl --output=compiler
	COMMENT "Building compiler"
)

add_executable(TrabalhoDeCompiladores ${CMAKE_SOURCE_DIR}/src/main.cpp)
add_dependencies(TrabalhoDeCompiladores compiler)
