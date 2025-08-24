# Nome do executável
EXEC = e1
FILE ?= arquivo_teste.txt

# Ferramentas
CC = gcc

# Objetos que compõem o executável
OBJS = main.o lex.yy.o

.PHONY: all run clean

# Regra principal
all: $(EXEC)

# Gera o executável a partir dos objetos
$(EXEC): $(OBJS)
	@echo "Linkando: $^ -> $@"
	@$(CC) $(OBJS) -o $@

# Qualquer .o depende do .c de mesmo nome
%.o: %.c
	@echo "Compilando: $<"
	@$(CC) -c $< -o $@

# Gera lex.yy.c a partir do scanner.l
lex.yy.c: scanner.l
	@echo "Gerando Flex: $<"
	@flex $<

# Roda o programa com arquivo parametrizado ou arquivo_teste.txt e retorna true para não mostrar o erro
run: $(EXEC)
	@cat $(FILE) | ./$(EXEC) || true 

# Limpeza dos arquivos
clean:
	@echo "CLEAN"
	@rm -f *.o lex.yy.c $(EXEC)

