%{
#include <stdio.h>
#include <stdlib.h>
int nb_ligne = 1;
int col = 1;
void yyerror(char *msg);
%}

%start S
%union {
    int entier;
    char* str;
}

%token mc_debut mc_execution mc_inbegin mc_inend mc_program mc_pdec err
%token <str> mc_integer mc_real idf
%token <entier> cst
%type <str> listeparams type
%type <entier> Instruction

%%

S: mc_debut DECLARATION mc_execution INSTRUCTION {
        printf("Programme syntaxiquement correct.\n");
        YYACCEPT;
    }
;

DECLARATION: type listeparams ';' DECLARATION 
            | type listeparams ';'
;

listeparams: listeparams ',' idf 
           | idf
;

type: mc_integer 
    | mc_real 
;

INSTRUCTION: mc_inbegin ListeInstr mc_inend
;

ListeInstr: ListeInstr Instruction
          | Instruction
;

Instruction: instaff
           | instdiv
           | instadd
;

instaff: idf '=' idf ';'
       | idf '=' cst ';'
;

instdiv: idf '=' idf '/' idf ';'
       | idf '=' idf '/' cst ';'
;

instadd: idf '=' idf '+' idf ';'
       | idf '=' idf '+' cst ';'
;

%%

void yyerror(char *msg) {
    printf("Erreur syntaxique %s, à la ligne %d\n", msg, nb_ligne);
}

int main() {
    yyparse();
    return 0;
}

int yywrap() {
    return 1;
}
