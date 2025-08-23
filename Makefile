# Nome do executável
EXEC = e1
FILE ?= arquivo_teste.txt

# Regras principais
all: $(EXEC)

# Gera o executável a partir dos objetos
$(EXEC): main.o lex.yy.o
	@gcc main.o lex.yy.o -o $(EXEC)

# Compila main.c
main.o: main.c
	@gcc main.c -c

# Compila lex.yy.c (gerado pelo flex)
lex.yy.o: lex.yy.c
	@gcc lex.yy.c -c

# Gera lex.yy.c a partir do scanner.l
lex.yy.c: scanner.l
	@flex scanner.l

# Roda o programa com arquivo parametrizado ou arquivo_teste.txt e retorna true para não mostrar o erro
run: $(EXEC)
	@cat $(FILE) | ./$(EXEC) || true 

# Limpeza dos arquivos
clean:
	@rm -f *.o lex.yy.c $(EXEC)

