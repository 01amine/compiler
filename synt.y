%{
#include <stdio.h>
#include <string.h>
#include "synt.tab.h"  
int nb_ligne = 1;
int nb_colonnes = 1;
char sauvType[20];
char tempVal[20];
char taille[10];
char express[100];
%}

%union {
    int entier;
    char* chaine;
    float floa;
}

%type <chaine> Idf_tab tabID NOM_BIB MODIFICATEUR VAL
%token <chaine> mc_import pvg bib_io bib_lang err mc_public mc_private mc_protected
%token <chaine> mc_class idf_v aco_ov aco_fr mc_entier mc_reel mc_chaine mc_const
%token vrg idf_tab pls mns mlt divise <entier> nb p_ou p_fr aft mc_for sup inf supe infe
%token mc_In g mc_Out br_ov br_fr <chaine> chaine <floa> reel

%%

S: LISTE_BIB HEADER_CLASS aco_ov CORPS aco_fr {
       printf("Programme syntaxiquement correct\n");
       YYACCEPT;
    }
;

LISTE_BIB: BIB LISTE_BIB
         | 
;

BIB: mc_import NOM_BIB pvg {
        if (doubleDeclaration($2) == 0) {
            insererTYPE($2, "BIB");
        } else {
            printf("Erreur Semantique: Double declaration de la bibliotheque %s a la ligne %d, position %d\n", $2, nb_ligne, nb_colonnes);
        }
    }
;

NOM_BIB: bib_io
       | bib_lang
;

HEADER_CLASS: MODIFICATEUR mc_class idf_v {
        if (doubleDeclaration($3) == 0) {
            insererTYPE($3, "Classe");
        } else {
            printf("Erreur Semantique: Double declaration de la classe %s a la ligne %d, position %d\n", $3, nb_ligne, nb_colonnes);
        }
    }
;

MODIFICATEUR: mc_public
            | mc_private
            | mc_protected
            | { strcpy($$, ""); }
;

CORPS: LISTE_DEC LISTE_INST
;

LISTE_DEC: DEC LISTE_DEC
         |
;

DEC: DEC_VAR
    | DEC_TAB
    | DEC_CONST
;

DEC_CONST: mc_const TYPE LISTE_CONST pvg
;

LISTE_CONST: idf_v vrg LISTE_CONST {
        insererConstante($1, "");
        if (doubleDeclaration($1) == 0) {
            insererTYPE($1, sauvType);
        } else {
            printf("Erreur Semantique: Double declaration de %s a la ligne %d, position %d\n", $1, nb_ligne, nb_colonnes);
        }
    }
    | idf_v {
        insererConstante($1, "");
        if (doubleDeclaration($1) == 0) {
            insererTYPE($1, sauvType);
        } else {
            printf("Erreur Semantique: Double declaration de %s a la ligne %d, position %d\n", $1, nb_ligne, nb_colonnes);
        }
    }
    | idf_v aft VAL {
        insererConstante($1, $3);
        if (doubleDeclaration($1) == 0) {
            insererTYPE($1, sauvType);
        } else {
            printf("Erreur Semantique: Double declaration de %s a la ligne %d, position %d\n", $1, nb_ligne, nb_colonnes);
        }
    }
    | idf_v aft VAL vrg LISTE_CONST {
        insererConstante($1, $3);
        if (doubleDeclaration($1) == 0) {
            insererTYPE($1, sauvType);
        } else {
            printf("Erreur Semantique: Double declaration de %s a la ligne %d, position %d\n", $1, nb_ligne, nb_colonnes);
        }
    }
;

VAL: nb {
        sprintf(tempVal, "%d", $1);
        $$ = tempVal;
        sauvegardeTypeExpression("Entier", tempVal);
    }
    | chaine {
        sprintf(tempVal, "%s", $1);
        $$ = tempVal;
        sauvegardeTypeExpression("Chaine", $1);
    }
    | reel {
        sprintf(tempVal, "%.3f", $1);
        $$ = tempVal;
        sauvegardeTypeExpression("Reel", tempVal);
    }
;

DEC_VAR: TYPE LISTE_IDF pvg
;

TYPE: mc_entier { strcpy(sauvType, $1); }
    | mc_reel { strcpy(sauvType, $1); }
    | mc_chaine { strcpy(sauvType, $1); }
;

LISTE_IDF: idf_v vrg LISTE_IDF {
        if (doubleDeclaration($1) == 0) {
            insererTYPE($1, sauvType);
        } else {
            printf("Erreur Semantique: Double declaration de %s a la ligne %d, position %d\n", $1, nb_ligne, nb_colonnes);
        }
    }
    | idf_v {
        if (doubleDeclaration($1) == 0) {
            insererTYPE($1, sauvType);
        } else {
            printf("Erreur Semantique: Double declaration de %s a la ligne %d, position %d\n", $1, nb_ligne, nb_colonnes);
        }
    }
;

DEC_TAB: TYPE LISTE_IDF_TAB pvg
;

LISTE_IDF_TAB: Idf_tab vrg LISTE_IDF_TAB {
        if (doubleDeclaration($1) == 0) {
            insererTYPE($1, sauvType);
        } else {
            printf("Erreur Semantique: Double declaration de %s a la ligne %d, position %d\n", $1, nb_ligne, nb_colonnes);
        }
    }
    | Idf_tab {
        if (doubleDeclaration($1) == 0) {
            insererTYPE($1, sauvType);
        } else {
            printf("Erreur Semantique: Double declaration de %s a la ligne %d, position %d\n", $1, nb_ligne, nb_colonnes);
        }
    }
;

Idf_tab: idf_tab br_ov nb br_fr {
        if ($3 < 0) {
            printf("Erreur Semantique: La taille de tableau %s doit etre positive a la ligne %d, position %d\n", $1, nb_ligne, nb_colonnes);
        } else {
            sprintf(taille, "%d", $3);
            int V = insererTailleTab($1, taille);
            if (V == -1) {
                printf("Erreur Semantique: Depassement de la taille du tableau %s a la ligne %d, position %d\n", $1, nb_ligne, nb_colonnes);
            }
        }
    }
;

LISTE_INST: INST LISTE_INST
          |
;

INST: Affectation
    | Lecture
    | Ecriture
;

Affectation: tabID aft Expression pvg {
        // Handle affectation rules
    }
;

// Additional rules omitted for brevity

%%

int main() {
    return yyparse();
}

void yyerror(const char* msg) {
    printf("Erreur Syntaxique: %s a la ligne %d, position %d\n", msg, nb_ligne, nb_colonnes);
}
