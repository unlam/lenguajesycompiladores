%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
int yystopparser=0;
FILE *yyin;

// More @ http://dinosaur.compilertools.net/bison/bison_5.html

/* ************************************************** */
/* *************** TABLA DE SIMBOLOS **************** */
/* ************************************************** */
/* Data type for links in the chain of symbols.       */
struct symrec {
  char *name;  /* name of symbol                      */
  int type;    /* type of symbol: either VAR or CONST */
  union {
    double var;           /* value of a VAR           */
  } value;
  struct symrec *next;    /* link field               */
};
typedef struct symrec symrec;
/* The symbol table: a chain of `struct symrec'.     */
symrec *sym_table = NULL;
/* Util functions                                    */
symrec *putsym ();
symrec *getsym ();
/* ************************************************** */
/* ************* FIN TABLA DE SIMBOLOS ************** */
/* ************************************************** */

// Auxiliar para el calculo del mayor numero en una lista
int mayor;

// Auxiliar para insersion en tabla de simbolos
char *asig_aux;

int init_table();
int yylex();
int yyerror(char *);
%}

%union {
int intval;
char *str_val;
}

%token <intval>CTE
%token <str_val>ID

%token COMA
%token OP_AS
%token OP_SUMA
%token TIPO_ENTERO

%start S

%%

S    : C                           ;

C    : C A                         ;

C    : A                           ;

A    : TIPO_ENTERO VAR             {
                                      putsym(asig_aux, yylval.intval);
                                   }
       OP_AS CTE                   ;

A    : VAR                         {
                                      if (!getsym(asig_aux)) {
                                        printf("%s no se encuentra en tabla de simbolos.\n", asig_aux);
                                        exit(1);
                                      } else {
                                        printf("insertar_en_polaca(%s) \n", asig_aux);
                                      }
                                   }
       OP_AS VAR                   {
                                     if (!getsym(asig_aux)) {
                                       printf("%s no se encuentra en tabla de simbolos.\n", asig_aux);
                                       exit(1);
                                     } else {
                                       printf("insertar_en_polaca(%s) \n", asig_aux);
                                     }
                                   }
       OP_SUMA VAR                 {
                                      if (!getsym(asig_aux)) {
                                        printf("%s no se encuentra en tabla de simbolos.\n", asig_aux);
                                        exit(1);
                                      } else {
                                        printf("insertar_en_polaca(%s) \n", asig_aux);
                                      }
                                      printf("insertar_en_polaca(+) \n");
                                      printf("insertar_en_polaca(:=) \n");
                                   };

VAR  : ID                          {
                                     /*
                                        Al no poder obtener yylval.str_val & yylval.intval en la misma regla
                                        ya que "str_val" es pisada con algo mas por haber terminales en ella,
                                        almaceno el ID en un auxiliar que luego uso para insertar en tabla de simbolos.
                                     */
                                     asig_aux = (char *) malloc(strlen(yylval.str_val) + 1);
                                     strcpy(asig_aux, yylval.str_val);
                                   };

%%

int main(int argc,char *argv[]) {
  if ((yyin = fopen(argv[1], "rt")) == NULL) {
		printf("\nNo se puede abrir el archivo: %s\n", argv[1]);
  } else {
    printf("\n");
    init_table();
		yyparse();
    printf("\n\n");
  }

  fclose(yyin);
  return 0;
}

/*
 * Inicializo la tabla de simbolos en caso de ser necesario
 */
int init_table() {
  //putsym("x", 10);
  //putsym("y", 20);
  //putsym("z", 3);
  return 0;
}

/*
 * Insertar en tabla de simbolos
 * TODO: Actualizar en caso de ya existir la variable
 */
symrec *putsym (char *sym_name, int sym_value) {
  symrec *ptr;
  ptr = (symrec *) malloc (sizeof (symrec));
  ptr->name = (char *) malloc (strlen (sym_name) + 1);
  strcpy (ptr->name, sym_name);
  ptr->type = 0;
  ptr->value.var = sym_value; /* set value to 0 even if fctn.  */
  ptr->next = (struct symrec *)sym_table;
  sym_table = ptr;
  return ptr;
}

/*
 * Obtener de tabla de simbolos
 */
symrec *getsym (char *sym_name) {
  symrec *ptr;
  for (ptr = sym_table; ptr != (symrec *) 0;
       ptr = (symrec *)ptr->next)
    if (strcmp (ptr->name,sym_name) == 0)
      return ptr;
  return 0;
}

int yyerror(char * err) {
	printf("\nSyntax Error. %s\n", err);
	exit(1);
}
