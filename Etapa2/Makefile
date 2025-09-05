# Nome do executável
TARGET = etapa2

# Fontes manuais
SRCS = main.c

# Fontes gerados automaticamente
BISON_SRC = parser.y
FLEX_SRC  = scanner.l

# Arquivos que serão gerados
BISON_C   = parser.tab.c
BISON_H   = parser.tab.h
FLEX_C    = lex.yy.c

# Objetos
OBJS = main.o parser.tab.o lex.yy.o

.PHONY: all clean

# Compilador e flags
CC = gcc
CFLAGS = -Wall -g

# Regra padrão
all: $(TARGET)

# Compilação final
$(TARGET): $(OBJS)
	@$(CC) $(OBJS) -o $(TARGET)

# Gera parser.tab.c e parser.tab.h
$(BISON_C) $(BISON_H): $(BISON_SRC)
	@bison -d $(BISON_SRC)

# Gera lex.yy.c
$(FLEX_C): $(FLEX_SRC) $(BISON_H)
	@flex $(FLEX_SRC)

# Compila main.c
main.o: main.c $(BISON_H)
	@$(CC) $(CFLAGS) -c main.c

# Compila parser.tab.c
parser.tab.o: $(BISON_C)
	@$(CC) $(CFLAGS) -c parser.tab.c

# Compila lex.yy.c (-Wno-unused-function para suprimir warnings de funções não utilizadas)
lex.yy.o: $(FLEX_C)
	@$(CC) $(CFLAGS) -Wno-unused-function -c lex.yy.c

# Limpeza
clean:
	@rm -f $(OBJS) $(TARGET) $(BISON_C) $(BISON_H) $(FLEX_C)
