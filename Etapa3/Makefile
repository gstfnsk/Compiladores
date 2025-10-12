# Nome do executável
EXEC = etapa3

# Arquivos
PARSER = parser.y
LEXER  = scanner.l
ASD    = asd.c

# Arquivos gerados pelo Bison/Flex
PARSER_C = parser.tab.c
PARSER_H = parser.tab.h
LEXER_C  = scanner.lex.c

# Compilador e flags
CC = gcc
CFLAGS = -fsanitize=address -g -Werror
LDFLAGS = -ll -lm

# Regra principal
$(EXEC): main.c $(ASD) $(PARSER_C) $(LEXER_C)
	$(CC) $(CFLAGS) -o $@ main.c $(ASD) $(PARSER_C) $(LEXER_C) $(LDFLAGS)

# Gerar parser.tab.c e parser.tab.h
$(PARSER_C) $(PARSER_H): $(PARSER)
	@bison -d $<

# Gerar scanner.lex.c
$(LEXER_C): $(LEXER)
	@flex -o $@ $<

# Limpeza
clean:
	@rm -f $(EXEC) $(PARSER_C) $(PARSER_H) $(LEXER_C)
