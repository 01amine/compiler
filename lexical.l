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
%{
#include "syn.tab.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int line = 1;      // Ligne actuelle
int column = 1;    // Colonne actuelle

#define YY_USER_ACTION column += yyleng;
%}

%%

\n                   { line++; column = 1; }
[ \t]+               ; // Ignorer les espaces blancs
"--"[^\n]*          ; // Commentaire sur une ligne
\{-([^{}]|(\{-.*\}-))*\} ; // Commentaire multi-ligne
DEBUT                { return DEBUT; }
FIN                  { return FIN; }
EXECUTION            { return EXECUTION; }
SI                   { return SI; }
ALORS                { return ALORS; }
SINON                { return SINON; }
TANTQUE              { return TANTQUE; }
FAIRE                { return FAIRE; }
FIXE                 { return FIXE; }
ET                   { return ET; }
OU                   { return OU; }
afficher             { return AFFICHER; }
lire                 { return LIRE; }

"<-"                 { return ASSIGN; }
":"                  { return COLON; }
";"                  { return SEMICOLON; }
"["                  { return LBRACKET; }
"]"                  { return RBRACKET; }
"{"                  { return LBRACE; }
"}"                  { return RBRACE; }
"("                  { return LPAREN; }
")"                  { return RPAREN; }
"="                  { return EQUAL; }
"<"                  { return LT; }
">"                  { return GT; }
"<="                 { return LE; }
">="                 { return GE; }
"!="                 { return NE; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }
-?[0-9]+\.[0-9]+      { yylval.real = atof(yytext); return REALNUMBER; }
-?[0-9]+              { yylval.num = atoi(yytext); return INTEGER; }
\"[^\"]*\"            { yylval.str = strdup(yytext); return STRING; }

.                     { printf("Erreur lexicale à la ligne %d, colonne %d : caractère inattendu '%s'\n", line, column, yytext); }
%%

int yywrap() {
    return 1;
}

