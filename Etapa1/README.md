# Compiladores

## Etapa 1
Comandos:
- **`make`**
  Compila todos os arquivos e gera o executável `e1`.
- **`make run`**
  Executa o programa usando o arquivo padrão `arquivo_teste.txt`.
- **`make run FILE=<arquivo>`**
  Executa o programa usando um arquivo de entrada especificado.
  Exemplo:
  ```bash
  make run FILE=meu_arquivo.txt
- **`make clean`** 
  Remove os artefatos gerados (*.o, lex.yy.c, e1).
