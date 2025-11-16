#include "types.h"

char* get_label_type(Type type){
  switch (type)
  {
    case INT:
      return "INT";
    case FLOAT:
      return "FLOAT";
    default:
      return "UNKNOWN";
  }
}