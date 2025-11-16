#!/bin/bash

# This script creates a gzipped tar archive (tgz) with the
# specific source files required for the project submission.

# The list of files to be included in the archive.
FILES_TO_ARCHIVE="
Makefile
asd.c
asd.h
errors.c
errors.h
main.c
parser.y
scanner.l
symbol_table.c
symbol_table.h
types.c
types.h
"

# The name of the output archive.
OUTPUT_FILE="etapa5.tgz"

# Create the archive.
# -c : Create a new archive
# -v : Verbosely list files processed
# -z : Compress the archive with gzip (.gz)
# -f : Use archive file (the next argument is the file name)
echo "Creating $OUTPUT_FILE..."
tar -cvzf $OUTPUT_FILE $FILES_TO_ARCHIVE

echo "Archive created successfully."
echo "You can check its contents with: tar -tzf $OUTPUT_FILE"