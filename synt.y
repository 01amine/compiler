%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ts.h"

void yyerror(const char *s);
int yylex();
%}

%union {
    int num;
    double real;
    char* str;
}

%token <str> IDENTIFIER
%token <num> INTEGER
%token <real> REALNUMBER
%token <str> STRING
%token DEBUT FIN EXECUTION SI ALORS SINON TANTQUE FAIRE FIXE NUM TEXT REAL
%token ET OU AFFICHER LIRE
%token ASSIGN COLON SEMICOLON LBRACKET RBRACKET LBRACE RBRACE LPAREN RPAREN
%token EQUAL LT GT LE GE NE

%type <num> expression

%left OU
%left ET
%left LT LE GT GE EQUAL NE
%right ASSIGN

%%

program:
    DEBUT declarations EXECUTION statements FIN
    ;

declarations:
    /* Vide */
    | declarations declaration
    ;

declaration:
    type COLON IDENTIFIER SEMICOLON {
        if (addSymbol($3, $1, CATEGORY_VARIABLE, 0) == -1) {
            yyerror("Double déclaration");
        }
    }
    | FIXE type COLON IDENTIFIER ASSIGN value SEMICOLON {
        if (addSymbol($4, $2, CATEGORY_CONSTANT, 0) == -1) {
            yyerror("Double déclaration");
        }
        setSymbolValue($4, $5, 0, NULL); // Initialiser une constante
    }
    | type COLON IDENTIFIER LBRACKET INTEGER RBRACKET SEMICOLON {
        if (addSymbol($3, $1, CATEGORY_ARRAY, $5) == -1) {
            yyerror("Double déclaration");
        }
    }
    ;

type:
    NUM { $$ = TYPE_NUM; }
    | TEXT { $$ = TYPE_TEXT; }
    | REAL { $$ = TYPE_REAL; }
    ;

value:
    INTEGER { $$ = $1; }
    | REALNUMBER { $$ = $1; }
    | STRING { $$ = $1; }
    ;

statements:
    /* Vide */
    | statements statement
    ;

statement:
    assignment
    | condition
    | loop
    | io_operation
    ;

assignment:
    IDENTIFIER ASSIGN expression SEMICOLON {
        int index = findSymbol($1);
        if (index == -1) {
            yyerror("Variable non déclarée");
        } else if (symbolTable.symbols[index].category == CATEGORY_CONSTANT) {
            yyerror("Modification de la valeur d'une constante");
        } else {
            setSymbolValue($1, $3, 0, NULL);
        }
    }
    | IDENTIFIER LBRACKET expression RBRACKET ASSIGN expression SEMICOLON {
        int index = findSymbol($1);
        if (index == -1) {
            yyerror("Tableau non déclaré");
        } else if ($3 < 0 || $3 >= symbolTable.symbols[index].arraySize) {
            yyerror("Dépassement de la taille du tableau");
        }
    }
    ;

expression:
    INTEGER { $$ = $1; }
    | REALNUMBER { $$ = $1; }
    | IDENTIFIER {
        if (findSymbol($1) == -1) {
            yyerror("Variable non déclarée");
        }
    }
    | expression '/' expression {
        if ($3 == 0) {
            yyerror("Division par zéro");
        }
    }
    ;

condition:
    SI LPAREN expression RPAREN ALORS LBRACE statements RBRACE
    | SI LPAREN expression RPAREN ALORS LBRACE statements RBRACE SINON LBRACE statements RBRACE
    ;

loop:
    TANTQUE LPAREN expression RPAREN FAIRE LBRACE statements RBRACE
    ;

io_operation:
    AFFICHER LPAREN expression RPAREN SEMICOLON
    | LIRE LPAREN IDENTIFIER RPAREN SEMICOLON {
        if (findSymbol($2) == -1) {
            yyerror("Variable non déclarée");
        }
    }
    ;
%%

void yyerror(const char *s) {
    fprintf(stderr, "Erreur syntaxique à la ligne %d, colonne %d : %s\n", line, column, s);
}

int main() {
    initSymbolTable();
    return yyparse();
}