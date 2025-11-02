# Grupo D
# 00228729 - Matheus Henrique Sabadin
# 00289108 - Giulia Chimini Stefainski

# Nome do executável
EXEC = etapa4

# Arquivos
PARSER = parser.y
LEXER  = scanner.l
ASD    = asd.c
SYMBOL_TABLE = symbol_table.c
ERRORS = errors.c
TYPES = types.c

# Arquivos gerados pelo Bison/Flex
PARSER_C = parser.tab.c
PARSER_H = parser.tab.h
LEXER_C  = scanner.lex.c

# Compilador e flags
CC = gcc
# CFLAGS = -fsanitize=address -g -Werror -Wall
LDFLAGS = -lfl -lm

# Regra principal
$(EXEC): main.c $(ASD) $(SYMBOL_TABLE) $(ERRORS) $(TYPES) $(PARSER_C) $(LEXER_C)
	$(CC) $(CFLAGS) -o $@ main.c $(ASD) $(SYMBOL_TABLE) $(ERRORS) $(TYPES) $(PARSER_C) $(LEXER_C) $(LDFLAGS)

# Gerar parser.tab.c e parser.tab.h
$(PARSER_C) $(PARSER_H): $(PARSER)
	@bison -d $<

# Gerar scanner.lex.c
$(LEXER_C): $(LEXER)
	@flex -o $@ $<

# Limpeza
clean:
	@rm -f $(EXEC) $(PARSER_C) $(PARSER_H) $(LEXER_C)
