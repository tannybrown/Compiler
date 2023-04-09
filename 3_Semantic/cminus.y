/****************************************************/
/* File: tiny.y                                     */
/* The TINY Yacc/Bison specification file           */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/
%{
#define YYPARSER /* distinguishes Yacc output from other code files */

#include "globals.h"
#include "util.h"
#include "scan.h"
#include "parse.h"

#define YYSTYPE TreeNode *
static TreeNode * savedTree; /* stores syntax tree for later return */
int yyerror(char * message);
static int yylex(void);
%}

%token IF ELSE WHILE RETURN INT VOID
%token ID NUM 
%token ASSIGN EQ NE LT LE GT GE PLUS MINUS TIMES OVER SEMI COMMA
%token LPAREN RPAREN LBRACE RBRACE LCURLY RCURLY
%token ERROR
%nonassoc OTHER
 

%% /* Grammar for CMINUS */

program     			: declaration_list
                 			{ savedTree = $1;} 
            				;

declaration_list		: declaration_list declaration
                        { 
                        YYSTYPE t = $1;
						if (t != NULL)
						  { while (t->sibling != NULL)
							t = t->sibling;
							t->sibling = $2;
							$$ = $1;
						}
						else
						$$ = $2;
						}
						| declaration {$$ = $1;}
						;

declaration				: var_declaration {$$ = $1;}
						| fun_declaration {$$ = $1;}
						;

var_declaration			: type_specifier id SEMI
						{ $$ = newExpNode(VarDecK);
						  $$->attr.name = $2->attr.name;
						  $$->type = $1->type;
						}
						| type_specifier id LBRACE num RBRACE SEMI
						{ $$ = newExpNode(VarDecK);
						  $$->child[0] = $4;
                          $$->attr.name = $2->attr.name;
                          $$->size = $4->attr.val;
                          if ($1->type == Void)
                              $$->type = VoidArray;
                          else $$->type = IntArray;
						}
						;

type_specifier			: INT
                        { $$ = newExpNode(VarK);
						  $$->type = Integer;
						}
						| VOID
                        { $$ = newExpNode(VarK);
						  $$->type = Void;
						}
						;

id						: ID
						{ $$ = newExpNode(VarK);
						  $$->attr.name = copyString(tokenString);
						}
						;

num						: NUM
						{ $$ = newExpNode(ConstK);
						  $$->attr.val = atoi(tokenString);
						}
						;

fun_declaration			: type_specifier id LPAREN params RPAREN compound_stmt
						{ $$ = newExpNode(FunDecK);
						  $$->type = $1->type;
						  $$->attr.name = $2->attr.name;
						  $$->child[0] = $4;
						  $$->child[1] = $6;
						}
						;

params					: param_list { $$ = $1; }
						| VOID
						{ $$ = newExpNode(ParamK);
						  $$->type = Void;
						}
						;

param_list				: param_list COMMA param
						{ YYSTYPE t = $1;
						  if( t != NULL )
							{ while(t->sibling != NULL)
							  t = t->sibling;
							  t->sibling = $3;
							  $$ = $1;
							}
						  else 
							  $$ = $3;
						}
						| param { $$ = $1; }
						;

param					: type_specifier id
						{ $$ = newExpNode(ParamK);
						  $$->type = $1->type;
						  $$->attr.name = $2->attr.name;
						}
						| type_specifier id LBRACE RBRACE
						{ $$ = newExpNode(ParamK);
						  if ($1->type == Void)
                                $$->type = VoidArray;
                          else $$->type = IntArray;
						  $$->attr.name = $2->attr.name;
						}
						;

compound_stmt			: LCURLY local_declaration stmt_list RCURLY
						{ $$ = newStmtNode(CompK);
						  $$->child[0] = $2;
						  $$->child[1] = $3;
						}
						;

local_declaration	    : local_declaration var_declaration
						{ YYSTYPE t = $1;
						  if( t != NULL )
						  {	while(t->sibling != NULL)
							t = t->sibling;
							t->sibling = $2;
							$$ = $1;
				  		  }
						  else
							$$ = $2;
						}
						|	{$$ = NULL;}
						;

stmt_list			    : stmt_list stmt
						{ YYSTYPE t = $1;
						  if( t != NULL )
							{ while(t->sibling != NULL)
							  t = t->sibling;
							  t->sibling = $2;
							  $$ = $1;
                            }
							else
			    				$$ = $2;
						}
						|	{$$ = NULL;}
						;

stmt        		    : expression_stmt { $$ = $1; }
            			| compound_stmt { $$ = $1; }
            			| selection_stmt { $$ = $1; }
            			| iteration_stmt { $$ = $1; }
            			| return_stmt { $$ = $1; }
            			;

expression_stmt			: expression SEMI { $$ = $1; }
				    	| SEMI { $$ = NULL; }
						;

selection_stmt			: IF LPAREN expression RPAREN stmt %prec OTHER
			 			{ $$ = newStmtNode(IfK);
						  $$->child[0] = $3;
						  $$->child[1] = $5;
						}
						| IF LPAREN expression RPAREN stmt ELSE stmt	
						{	$$ = newStmtNode(ElseK);
							$$->child[0] = $3;
							$$->child[1] = $5;
							$$->child[2] = $7;
						}
						;

iteration_stmt 			: WHILE LPAREN expression RPAREN stmt
                 		{ $$ = newStmtNode(WhileK);
                   		  $$->child[0] = $3;
                   		  $$->child[1] = $5;
                		}
            			;

return_stmt				: RETURN SEMI { $$ = newStmtNode(ReturnK); }
						| RETURN expression SEMI
						{	$$ = newStmtNode(ReturnK);
							$$->child[0] = $2;
						}
						;

expression 		  	    : var ASSIGN expression
						{	$$ = newExpNode(AssignK);
	    					$$->child[0] = $1;
							$$->child[1] = $3;
						}
						| simple_expression { $$ = $1; }
						;

var 					: id
						{	$$ = newExpNode(VarK);
							$$->attr.name = $1->attr.name;
						}
						| id LBRACE expression RBRACE
						{	$$ = newExpNode(VarK);
							$$->attr.name = $1->attr.name;
		    				$$->child[0] = $3;
						}
						;

simple_expression  	    : additive_expression relop additive_expression 
                 		{ $$ = newExpNode(OpK);
                   		  $$->child[0] = $1;
                   		  $$->child[1] = $3;
                   		  $$->attr.op = $2->attr.op;
                 		}
						| additive_expression { $$ = $1; }
						;

relop					: LE
				    	{	$$ = newExpNode(OpK);
							$$->attr.op = LE;
						}
						| LT
						{	$$ = newExpNode(OpK);
							$$->attr.op = LT;
						}
						| GE
						{	$$ = newExpNode(OpK);
		    				$$->attr.op = GE;
						}
						| GT
						{	$$ = newExpNode(OpK);
							$$->attr.op = GT;
						}
						| EQ
						{	$$ = newExpNode(OpK);
							$$->attr.op = EQ;
						}
						| NE
						{	$$ = newExpNode(OpK);
							$$->attr.op = NE;
						}
						;
										
additive_expression     : additive_expression addop term
						{ $$ = newExpNode(OpK);
					  	  $$->child[0] = $1;
						  $$->child[1] = $3;
						  $$->attr.op = $2->attr.op;
						}
						| term { $$ = $1; }
						;

addop					: PLUS
						{ $$ = newExpNode(OpK);
					  	  $$->attr.op = PLUS;
						}
						| MINUS
						{	$$ = newExpNode(OpK);
							$$->attr.op = MINUS;
						}
						;

term        			: term mulop factor 
                 		{ $$ = newExpNode(OpK);
                   		  $$->child[0] = $1;
                   		  $$->child[1] = $3;
                   		  $$->attr.op = $2->attr.op;
                 		}
            			| factor { $$ = $1; }
            			;

mulop					: TIMES
						{ $$ = newExpNode(OpK);
						  $$->attr.op = TIMES;
						}
						| OVER
						{ $$ = newExpNode(OpK);
						  $$->attr.op = OVER;
						}

factor      		    : LPAREN expression RPAREN { $$ = $2; }
            			| var { $$ = $1; }
						| call { $$ = $1; }
						| num { $$ = $1; }
						;

call					: id LPAREN args RPAREN
						{ $$ = newExpNode(CallK);
						  $$->attr.name = $1->attr.name;
					      $$->child[0] = $3;
						}

args					: arg_list { $$ = $1; }
						|  { $$ = NULL; }
						;

arg_list 		    	: arg_list COMMA expression
						{	YYSTYPE t = $1;
							if( t != NULL)
							{ while( t->sibling != NULL)
                              t = t->sibling;
					  		  t->sibling = $3;
							  $$ = $1;
							}
							else
						    	$$ = $3;
						}
						| expression { $$ = $1; }
						;

%%

int yyerror(char * message)
{ fprintf(listing,"Syntax error at line %d: %s\n",lineno,message);
  fprintf(listing,"Current token: ");
  printToken(yychar,tokenString);
  Error = TRUE;
  return 0;
}

/* yylex calls getToken to make Yacc/Bison output
 * compatible with ealier versions of the TINY scanner
 */
static int yylex(void)
{ return getToken(); }

TreeNode * parse(void)
{ yyparse();
  return savedTree;
}
