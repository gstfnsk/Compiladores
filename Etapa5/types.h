#ifndef _TYPES_H_
#define _TYPES_H_

typedef enum { 
    INT,
    FLOAT,
} Type;

char* get_label_type(Type type);

#endif //_TYPES_H_