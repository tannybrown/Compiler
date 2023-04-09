/****************************************************/
/* File: cminus.l                                     */
/* Lex specification for cminus                       */
/* Compiler Construction: Principles and Practice   */
/* taehwan kim                                      */
/****************************************************/

%{
#include "globals.h"
#include "util.h"
#include "scan.h"
/* lexeme of identifier or reserved word */
char tokenString[MAXTOKENLEN+1];
%}

digit       [0-9]
number      {digit}+
letter      [a-zA-Z]
identifier  [a-zA-Z][a-zA-Z0-9]*
newline     \n
whitespace  [ \t]+

%%

"if"            {return IF;}
"int"          {return INT;}
"void"          {return VOID;}
"else"           {return ELSE;}
"while"        {return WHILE;}
"return"         {return RETURN;}
"="            {return ASSIGN;}
"=="             {return EQ;}
"!="            {return NE;}
"<="            {return LE;}
">="            {return GE;}
"<"             {return LT;}
">"             {return GT;}
"+"             {return PLUS;}
"-"             {return MINUS;}
"*"             {return TIMES;}
"/"             {return OVER;}
"("             {return LPAREN;}
")"             {return RPAREN;}
"{"             {return LCURLY;}
"}"             {return RCURLY;}
"["             {return LBRACE;}
"]"             {return RBRACE;}
";"             {return SEMI;}
","             {return COMMA;}
{number}        {return NUM;}
{identifier}    {return ID;}
{newline}       {lineno++;}
{whitespace}    {/* skip whitespace */}
"/*"             { char c;
                    char old ='a';
                   
                  do
                  { c = input();
                    
                    if (old == '*' && c == '/'){
                    break;
                    } 
                    if (c == EOF || c == '\0') break;
                    if (c == '\n') lineno++;
                    old = c;
                  } while (1);
                }
.               {return ERROR;}

%%

TokenType getToken(void)
{ static int firstTime = TRUE;
  TokenType currentToken;
  if (firstTime)
  { firstTime = FALSE;
    lineno++;
    yyin = source;
    yyout = listing;
  }
  currentToken = yylex();
  strncpy(tokenString,yytext,MAXTOKENLEN);
  if (TraceScan) {
    fprintf(listing,"\t%d: ",lineno);
    printToken(currentToken,tokenString);
  }
  return currentToken;
}


