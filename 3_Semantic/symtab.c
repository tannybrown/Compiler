/****************************************************/
/* File: symtab.c                                   */
/* Symbol table implementation for the TINY compiler*/
/* (allows only one symbol table)                   */
/* Symbol table is implemented as a chained         */
/* hash table                                       */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"


/* the hash function */
static int hash ( char * key )
{ int temp = 0;
  int i = 0;
  while (key[i] != '\0')
  { temp = ((temp << SHIFT) + key[i]) % SIZE;
    ++i;
  }
  return temp;
}


static Scope ScopeArray[SIZE];
static int Scope_Count=0;

static Scope ScopeStack[SIZE];
static int stackNum=0;


//return top
Scope scope_top()
{
	if(Scope_Count == 0)
		return NULL;
	return ScopeStack[stackNum-1];
}

//pop stack



//push stack
void scope_push(Scope sc)
{
	ScopeStack[stackNum++] = sc;
}

void scope_pop(){
    stackNum--;
}

Scope makeScope(char* scope_name)
{
	Scope sc = (Scope) malloc(sizeof(struct ScopeListRec));
	sc->name = scope_name;
	sc->parent = scope_top();

	ScopeArray[Scope_Count++] = sc;
	return sc;
}


/* Procedure st_insert inserts line numbers and
 * memory locations into the symbol table
 * loc = memory location is inserted only the
 * first time, otherwise ignored
 */
void st_insert(char * name, ExpType type, int lineno, int loc, TreeNode *t)
{ 
	int h = hash(name);
	Scope sc = scope_top();
	BucketList l =  sc->bucket[h];

	while ((l != NULL) && (strcmp(name,l->name) != 0))
		l = l->next;
	if (l == NULL)
	{ l = (BucketList) malloc(sizeof(struct BucketListRec));
		l->name = name;
		l->lines = (LineList) malloc(sizeof(struct LineListRec));
		l->lines->lineno = lineno;
		l->memloc = loc;
		l->lines->next = NULL;
		l->next = sc->bucket[h];
		l->type = type;
		l->tree = t;
		sc->bucket[h] = l; 
	}
	else 
	{
		LineList newLine = (LineList) malloc(sizeof(struct LineListRec));
		newLine->lineno = lineno;
		newLine->next = NULL;
		LineList tmp = l->lines;
		while(tmp->next != NULL){
			tmp = tmp->next;
		}
		tmp->next = newLine;
	}
} /* st_insert */

/* Function st_lookup returns the memory 
 * location of a variable or -1 if not found
 */
BucketList st_lookup ( char * scope, char * name )
{ 
	int h = hash(name);
  Scope sc;
	BucketList l;

	for(int i = 0; i <= Scope_Count; i++){
		if(strcmp(ScopeArray[i]->name, scope) == 0){
			sc = ScopeArray[i];
			break;
		}
	}
	if(sc == NULL)
		return NULL;

	while(sc != NULL){
		l = sc->bucket[h];
  	while ((l != NULL) && (strcmp(name,l->name) != 0))
    	l = l->next;
  	if (l != NULL) 
			return l;
		sc = sc->parent;
	}
	return NULL;
}

BucketList st_lookup_excluding_parent ( char * scope, char * name)
{
	int h = hash(name);
    Scope sc;


	for(int i = 0; i <= Scope_Count; i++){
		if(strcmp(ScopeArray[i]->name, scope) == 0){
			sc = ScopeArray[i];
			break;
		}
	}
	if(sc == NULL)
		return NULL;

	l = sc->bucket[h];
  while ((l != NULL) && (strcmp(name,l->name) != 0))
    l = l->next;
	
	return l;
}
/* Procedure printSymTab prints a formatted 
 * listing of the symbol table contents 
 * to the listing file
 */
void printSymTab(FILE * listing)
{ 

}
/* printSymTab */
