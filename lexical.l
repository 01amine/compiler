%{
#include "synt.tab.h"
#include "stdio.h"
#include "string.h"
#include "stdlib.h"

extern int nb_ligne;
extern int nb_colonnes;
extern YYSTYPE yylval;

%}

lettreMin     [a-z]
lettreMaj     [A-Z]
lettres       {lettreMin}|{lettreMaj}
chiffres      [0-9]
num           [+-]?{chiffres}+
reel          ({chiffres}+"."{chiffres}+)|([+-]{chiffres}+"."{chiffres}+)
loc           {lettres}|{chiffres}
idf           {lettreMaj}({loc}|_?{loc})*
chaine        \"(\\.|[^"\\])*\" // String literals
commentaire   --([^\n#]|(#[^#]*)?)*##
commentaire2  \{-([^{}]|(\{[^{}]*\}))*-\}
ws            [ \t]+
nl            \n

%%

"NUM"       {nb_colonnes++ ; return mc_num; }
"REAL"      {nb_colonnes++ ; return mc_real; }
"TEXT"      {nb_colonnes++ ; return mc_text; }
"FIXE"       {nb_colonnes++ ; return mc_fix; }
"TANTQUE"   {nb_colonnes++ ; return mc_tantque; }
"FAIRE"     {nb_colonnes++ ; return mc_faire; }
"DEBUT"     {nb_colonnes++ ; return mc_debut; }
"EXECUTION" {nb_colonnes++ ; return mc_execution; }
"FIN"       {nb_colonnes++ ; return mc_fin; }
"AFFICHE"   {nb_colonnes++ ; return mc_affiche; }
"LIRE"      {nb_colonnes++ ; return mc_lire; }
"SI"        {nb_colonnes++ ; return mc_si; }
"ALORS"     {nb_colonnes++ ; return mc_alors; }
"SINON"     {nb_colonnes++ ; return mc_sinon; }

{idf} {
    if (strlen(yytext) > 25) {
        printf("Erreur lexicale: Identificateur %s trop long à la ligne %d, colonne %d.\n", yytext, nb_ligne, nb_colonnes);
    }
    inserer(yytext, "idf");
    yylval.str = strdup(yytext);
    nb_colonnes += yyleng;
    return idf;
}
{commentaire} {

}
{commentaire2} {
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

","         { return vrg; }
":"         { return decl; }
"{"         { return aco_ov; }
"}"         { return aco_fr; }
"["         { return br_ov; }
"]"         { return br_fr; }
"("         { return p_ou; }
")"         { return p_fr; }
"+"         { return pls; }
"-"         { return mns; }
"*"         { return mlt; }
"/"         { return divise; }
"<-"        { return aft; }
"="         { return egl; }
">"         { return sup; }
"<"         { return inf; }
"<="        { return infe; }
">="        { return supe; }
";"         { return pvg; }
"OU"        { return ou; }
"ET"        { return et; }
"NON"       { return non; }

{ws}        {
     nb_colonnes += yyleng; 
     }
{nl}        { 
    nb_ligne++; nb_colonnes = 1; 
    }
.           {
    printf("Erreur lexicale: '%s' non reconnue à la ligne %d, colonne %d.\n", yytext, nb_ligne, nb_colonnes);
    return err;
}

%%

int yywrap() {
    return 1; 
}
