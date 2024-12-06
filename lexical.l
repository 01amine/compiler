%{
#include "synt.tab.h"
#include "stdio.h"
#include "string.h"
#include "stdlib.h"
#include "fonctions.h"

extern int nb_ligne;
extern int nb_colonnes;
extern YYSTYPE yylval;

void inserer(const char* text, const char* type);
%}

lettreMin     [a-z]
lettreMaj     [A-Z]
lettres       {lettreMin}|{lettreMaj}
chiffres      [0-9]
num           [+-]?{chiffres}+
reel          ({chiffres}+"."{chiffres}+)|("-"?{chiffres}+"."{chiffres}+)
loc           {lettres}|{chiffres}
idf           {lettreMaj}({loc}|_?{loc})*
chaine        \"(\\.|[^"\\])*\" // String literals
commentaire   --([^\n#]|(#[^#]*)?)*##
commentaire2  \{-([^{}]|(\{[^{}]*\}))*-\}
ws            [ \t]+
nl            \n

%%

"NUM"       { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return mc_num; }
"REAL"      { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return mc_real; }
"TEXT"      { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return mc_text; }
"FIX"       { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return mc_fix; }
"TANTQUE"   { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return mc_tantque; }
"FAIRE"     { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return mc_faire; }
"DEBUT"     { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return mc_debut; }
"EXECUTION" { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return mc_execution; }
"FIN"       { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return mc_fin; }
"AFFICHE"   { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return mc_affiche; }
"LIRE"      { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return mc_lire; }
"SI"        { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return mc_si; }
"ALORS"     { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return mc_alors; }
"SINON"     { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return mc_sinon; }

{idf} {
    if (strlen(yytext) > 25) {
        printf("Erreur lexicale: Identificateur %s trop long à la ligne %d, colonne %d.\n", yytext, nb_ligne, nb_colonnes);
    }
    inserer(yytext, "idf");
    yylval.chaine = strdup(yytext);
    nb_colonnes += yyleng;
    return idf;
}

{commentaire} {
    int length = strlen(yytext);
    for (int i = 0; i < length; i++) {
        if (yytext[i] == '\n') {
            nb_ligne++;
            nb_colonnes = 1;
        } else {
            nb_colonnes++;
        }
    }
}

","         { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return vrg; }
":"         { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return decl; }
"{"         { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return aco_ov; }
"}"         { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return aco_fr; }
"["         { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return br_ov; }
"]"         { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return br_fr; }
"("         { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return p_ou; }
")"         { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return p_fr; }
"+"         { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return pls; }
"-"         { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return mns; }
"*"         { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return mlt; }
"/"         { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return divise; }
"<-"        { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return aft; }
"="         { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return egl; }
">"         { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return sup; }
"<"         { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return inf; }
"<="        { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return infe; }
">="        { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return supe; }
";"         { yylval.chaine = strdup(yytext); nb_colonnes += yyleng; return pvg; }

{ws}       { nb_colonnes += yyleng; }
{nl}       { nb_ligne++; nb_colonnes = 1; }

.          {
    printf("Erreur lexicale: '%s' non reconnue à la ligne %d, colonne %d.\n", yytext, nb_ligne, nb_colonnes);
    return err;
}

%%

int yywrap() {
    return 1; 
}
