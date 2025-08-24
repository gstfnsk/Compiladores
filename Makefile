# Nome do executável
EXEC = etapa1

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

# Roda o programa (espera arquivo de teste)
run: $(EXEC)
	./$(EXEC)

# Limpeza dos arquivos
clean:
	@echo "CLEAN"
	@rm -f *.o lex.yy.c $(EXEC)

