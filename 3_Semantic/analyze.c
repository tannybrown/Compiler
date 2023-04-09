/****************************************************/
/* File: analyze.c                                  */
/* Semantic analyzer implementation                 */
/* for the TINY compiler                            */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#include "globals.h"
#include "symtab.h"
#include "analyze.h"
#include "util.h"

/* counter for variable memory locations */
static int location = 0;
static int globalNum = 0;
 

Scope globalScope;
/* Procedure traverse is a generic recursive 
 * syntax tree traversal routine:
 * it applies preProc in preorder and postProc 
 * in postorder to tree pointed to by t
 */
static void traverse( TreeNode * t,
               void (* preProc) (TreeNode *),
               void (* postProc) (TreeNode *) )
{ if (t != NULL)
  { preProc(t);
    { int i;
      for (i=0; i < MAXCHILDREN; i++)
        traverse(t->child[i],preProc,postProc);
    }
    postProc(t);
    traverse(t->sibling,preProc,postProc);
  }
}

static void InsertNodef(TreeNode * t)
{ 
  if (t->nodekind == StmtK)
		if(t->kind.stmt == CompK)
			scope_pop();
	if (t==NULL) return;
	return;
}

/* nullProc is a do-nothing procedure to 
 * generate preorder-only or postorder-only
 * traversals from traverse
 */
static void nullProc(TreeNode * t)
{ if (t==NULL) return;
  else return;
}




/* Procedure insertNode inserts 
 * identifiers stored int into 
 * the symbol table 
 */
static void insertNode( TreeNode * t)
{ switch (t->nodekind)
  { case StmtK:
      switch (t->kind.stmt)
      {
          case StmtK:
          break;
        default:
          break;
      }
      break;
    case ExpK:
      switch (t->kind.exp)
      { 
				case VarDecK:
					if(st_lookup_excluding_parent(scope_top()->name, t->attr.name) !=NULL)
					{
                        fprintf(listing,"Symbol \"%s\" is redefined at line %d\n",t->attr.name,t->lineno);
						break;
					}
					t->scopeName = scope_top()->name;
					if(t->type == Void)
					{	
						fprintf(listing,"The void-type variable is declared at line %d (name : \"%s\")\n",t->lineno,t->attr.name);
						break;
					}
					if(strcmp(scope_top()->name, "global") == 0){
						st_insert(t->attr.name, t->type, t->lineno, globalNum++, t);
					}
					
					else
					{
						st_insert(t->attr.name, t->type, t->lineno, location++ ,t);
					}
					break;

				case FunDecK:
					{
						location = 0;
						if(st_lookup(scope_top()->name, t->attr.name) != NULL)
						fprintf(listing,"Symbol \"%s\" is redefined at line %d\n",t->attr.name,t->lineno);                        

						if(strcmp(scope_top()->name, "global") == 0){
							st_insert(t->attr.name, t->type, t->lineno, globalNum++, t);
						}
						Scope scope = makeScope(t->attr.name);
						scope->parent = scope_top();
						scope_push(scope);
						t->scopeName = scope_top()->name;
						
						break;
					}
				case CallK:
				{
					BucketList b = st_lookup(scope_top()->name, t->attr.name);
					if(b == NULL)
						fprintf(listing,"Undeclared function \"%s\" is called at line %d\n",t->attr.name,t->lineno);
		
					break;
				}
				case ParamK:
				{
					if(t->type != Void){
						if(st_lookup_excluding_parent(scope_top()->name, t->attr.name) != NULL){
							fprintf(listing,"Symbol \"%s\" is redefined at line %d\n",t->attr.name,t->lineno);
							break;
						}
						st_insert(t->attr.name, t->type, t->lineno, location++, t);
						t->scopeName = scope_top()->name;
					}
					break;
				}
				case VarK:
				{
					BucketList b = st_lookup(scope_top()->name, t->attr.name);
					if(b == NULL)
					{
						fprintf(listing, "Undefined variable \"%s\" is used at line %d\n",t->attr.name,t->lineno);
						break;
                    }	
					break;
				}
				default:
          break;
      }
      break;
    default:
      break;
  }
}

void init()
{	
	globalScope = makeScope("global");
	scope_push(globalScope);	
}


/* Function buildSymtab constructs the symbol 
 * table by preorder traversal of the syntax tree
 */
void buildSymtab(TreeNode * syntaxTree)
{ 
	init();
	traverse(syntaxTree,insertNode,InsertNodef);
  if (TraceAnalyze)
  { fprintf(listing,"\nSymbol table:\n\n");
    printSymTab(listing);
  }
	scope_pop();
}


/* Procedure checkNode performs
 * type checking at a single tree node
 */
static void checkNode(TreeNode * t)
{ 

}

/* Procedure typeCheck performs type checking 
 * by a postorder syntax tree traversal
 */
void typeCheck(TreeNode * syntaxTree)
{	
	globalScope = makeScope("global");
	scope_push(globalScope);

	traverse(syntaxTree,nullProc,checkNode);
	scope_pop();
}
