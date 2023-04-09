/****************************************************/
/* File: symtab.h                                   */
/* Symbol table interface for the TINY compiler     */
/* (allows only one symbol table)                   */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/

#ifndef _SYMTAB_H_
#define _SYMTAB_H_
#include "globals.h"
/* Procedure st_insert inserts line numbers and
 * memory locations into the symbol table
 * loc = memory location is inserted only the
 * first time, otherwise ignored
 */
/* SIZE is the size of the hash table */
#define SIZE 211

/* SHIFT is the power of two used as multiplier
   in hash function  */
#define SHIFT 4

typedef struct LineListRec
   { int lineno;
     struct LineListRec * next;
   } * LineList;

/* The record in the bucket lists for
 * each variable, including name, 
 * assigned memory location, and
 * the list of line numbers in which
 * it appears in the source code
 */
typedef struct BucketListRec
   { char * name;
     LineList lines;
     int memloc ; /* memory location for variable */
		 ExpType type;
     struct BucketListRec * next;
     TreeNode* tree;
   } * BucketList;

typedef struct ScopeListRec
	 { char * name;
		 BucketList bucket[SIZE];
		 struct ScopeListRec * parent;
	 } * Scope;

Scope scope_top();
void scope_pop();
void scope_push(Scope sc);
Scope makeScope(char* scope_name);

void st_insert(char * name, ExpType type, int lineno, int loc, TreeNode *t);

/* Function st_lookup returns the memory 
 * location of a variable or -1 if not found
 */

BucketList st_lookup ( char * scope, char * name );
BucketList st_lookup_excluding_parent ( char * scope, char * name );

/* Procedure printSymTab prints a formatted 
 * listing of the symbol table contents 
 * to the listing file
 */
void printSymTab(FILE * listing);

#endif
