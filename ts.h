#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SYMBOLS 1000
#define MAX_NAME_LENGTH 50

typedef enum { TYPE_NUM, TYPE_TEXT, TYPE_REAL } VariableType;
typedef enum { CATEGORY_VARIABLE, CATEGORY_CONSTANT, CATEGORY_ARRAY } SymbolCategory;

typedef struct {
    char name[MAX_NAME_LENGTH];
    VariableType type;
    SymbolCategory category;
    int isInitialized;
    int intValue;
    double realValue;
    char stringValue[MAX_NAME_LENGTH];
    int arraySize;
} Symbol;

typedef struct {
    Symbol symbols[MAX_SYMBOLS];
    int count;
} SymbolTable;

SymbolTable symbolTable;

void initSymbolTable() {
    symbolTable.count = 0;
}

int addSymbol(const char* name, VariableType type, SymbolCategory category, int arraySize) {
    if (findSymbol(name) != -1) return -1; // Existe déjà
    Symbol* s = &symbolTable.symbols[symbolTable.count++];
    strncpy(s->name, name, MAX_NAME_LENGTH);
    s->type = type;
    s->category = category;
    s->isInitialized = 0;
    s->arraySize = arraySize;
    return 0;
}

int findSymbol(const char* name) {
    for (int i = 0; i < symbolTable.count; i++) {
        if (strcmp(symbolTable.symbols[i].name, name) == 0) return i;
    }
    return -1;
}

void setSymbolValue(const char* name, int intValue, double realValue, const char* stringValue) {
    int idx = findSymbol(name);
    if (idx == -1) return;
    Symbol* s = &symbolTable.symbols[idx];
    s->isInitialized = 1;
    if (s->type == TYPE_NUM) s->intValue = intValue;
    else if (s->type == TYPE_REAL) s->realValue = realValue;
    else if (s->type == TYPE_TEXT) strncpy(s->stringValue, stringValue, MAX_NAME_LENGTH);
}

#endif
