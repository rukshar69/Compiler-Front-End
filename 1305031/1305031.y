%{
#include <stdlib.h>
#include <stdio.h>
#include "SymbolTable.h"

int yydebug;
int yyparse(void);
int yylex(void);
SymbolTable hashTable(97);
FILE *logFile;
extern FILE* yyin;


int dt;
int at;

extern int line_count;
extern int error;





void yyerror(const char *s)
{
	fprintf(logFile,"Error: line no. %d: %s\n\n",line_count,s);
        error++;
	return;
}

%}

%union {
	int integer;
	float f;
	char ch;
	Symbol* sym;}




%token  RETURN VOID MAIN PRINTLN SEMICOLON COMMA LPAREN RPAREN LCURL IF ELSE FOR WHILE INT FLOAT DOUBLE CHAR RCURL LTHIRD RTHIRD INCOP DECOP

%token <sym> NOT CONST_INT CONST_FLOAT  ADDOP MULOP ASSIGNOP RELOP LOGICOP CONST_CHAR ID

%type <sym> expression
%type <sym> term
%type <sym> unary_expression
%type <sym> simple_expression
%type <sym> rel_expression
%type <sym> logic_expression
%type <sym> factor
%type <sym> variable

%left ADDOP MULOP INCOP DECOP RELOP LOGICOP 
%right ASSIGNOP NOT

%start Program

%error-verbose 


%%
Program : INT MAIN LPAREN RPAREN compound_statement 
{
	fprintf(logFile,"Program : INT MAIN LPAREN RPAREN compound_statement\n\n");
}
	;


compound_statement : LCURL var_declaration statements RCURL
{
	fprintf(logFile,"compound_statement : LCURL var_declaration statements RCURL\n\n");
}
		   | LCURL statements RCURL
{	
	fprintf(logFile,"compound_statement : LCURL statements RCURL\n\n");
}
		   | LCURL RCURL
{	
	fprintf(logFile,"compound_statement : LCURL RCURL\n\n");
}
		   ;

			 
var_declaration	: type_specifier declaration_list SEMICOLON
{
	fprintf(logFile,"var_declaration : type_specifier declaration_list SEMICOLON\n\n");
}
		|  var_declaration type_specifier declaration_list SEMICOLON
{
	fprintf(logFile,"var_declaration : var_declaration type_specifier declaration_list SEMICOLON\n\n");
}
		;

type_specifier	: INT 
{
	fprintf(logFile,"type_specifier : INT \n\n");
	
	dt = 1;
	at = 4;
}
		| FLOAT
{

	fprintf(logFile,"type_specifier : FLOAT\n\n");
	
	dt = 2;
	at = 5;
}
		| CHAR
{
	fprintf(logFile,"type_specifier : CHAR\n\n");
	
	dt = 3;
	at = 6;
}
		;
			
declaration_list : declaration_list COMMA ID 
{

	fprintf(logFile,"declaration_list : declaration_list COMMA ID  \n\n");

	bool isPresent;

	isPresent = hashTable.search((char*)$3->getName());
	if(isPresent)yyerror((char*)"Already in table, so multiple declarations");
	else 
	{

		$3->setDataType(dt);
		hashTable.insert($3);
		hashTable.printTable(logFile);
	}


}

		 | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
{

	fprintf(logFile,"declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD \n\n");

	
	bool isPresent;
	isPresent = hashTable.search((char*)$3->getName());
	if(isPresent)
		yyerror((char*)"Already in table, so multiple declarations");
	else 
	{

		$3->setDataType(at);
		hashTable.insert($3, (int)$5->getSingleValue());
		hashTable.printTable(logFile);
	}
}
		 | ID 
{

fprintf(logFile,"declaration_list : ID  \n\n");
	
	bool isPresent;
	isPresent = hashTable.search((char*)$1->getName());
	if(isPresent)yyerror((char*)"Already in table, so multiple declarations");
	else 
	{

		$1->setDataType(dt);
		hashTable.insert($1);
		hashTable.printTable(logFile);
	}

}
		 | ID LTHIRD CONST_INT RTHIRD 
{

	fprintf(logFile,"declaration_list : ID LTHIRD CONST_INT RTHIRD  \n\n");
	
	bool isPresent;
	isPresent = hashTable.search((char*)$1->getName());
	if(isPresent)yyerror((char*)"Already in table, so multiple declarations");
	else 
	{

		$1->setDataType(at);
		hashTable.insert($1, (int)$3->getSingleValue());
		hashTable.printTable(logFile);
	}

}
		 ;

statements : statement 
{
	fprintf(logFile,"statements : statement  \n\n");
}
	   | statements statement 
{
	fprintf(logFile,"statement : statements statement \n\n");
}
	   ;


statement  : expression_statement 
{
	fprintf(logFile,"statement : expression_statement\n\n");
}
	   | compound_statement
{
	fprintf(logFile,"statement : compound_statement  \n\n");
	} 
	   | FOR LPAREN expression_statement expression_statement expression RPAREN statement 
{
	fprintf(logFile,"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement  \n\n");
}
	   | IF LPAREN expression RPAREN statement
{
	fprintf(logFile,"statement : IF LPAREN expression RPAREN statement  \n\n");
}
	   | IF LPAREN expression RPAREN statement ELSE statement
{	
	fprintf(logFile,"statement : IF LPAREN expression RPAREN statement ELSE statement  \n\n");
}
	   | WHILE LPAREN expression RPAREN statement 
{
	fprintf(logFile,"statement : WHILE LPAREN expression RPAREN statement  \n\n");
}
	   | PRINTLN LPAREN ID RPAREN SEMICOLON 
{
	fprintf(logFile,"statement : PRINTLN LPAREN ID RPAREN SEMICOLON  \n\n");
}
	   | RETURN expression SEMICOLON 
{	
	fprintf(logFile,"statement : RETURN expression SEMICOLON   \n\n");
}
	   ;
		
expression_statement	: SEMICOLON	
{
	fprintf(logFile,"expression_statement : SEMICOLON  \n\n");
}		
			| expression SEMICOLON 
{
	fprintf(logFile,"expression_statement : expression SEMICOLON  \n\n");
}
			;
						
variable : ID 	
{

	fprintf(logFile,"variable : ID  \n\n");

	Symbol *s= hashTable.lookUp($1->getName());

	if(s==0)
		yyerror((char*)"could not find the identifier");

	else if(s->getDataType() >= 4 && s->getDataType() <= 6)
		yyerror((char*)"Accessing array pointer 	instead of explicit array value");
	else{
		Symbol* t=new Symbol((char*)s->getName(),(char*)s->getType(),s->getDataType(),s->getSingleValue());
		$$=t;
	}

}	
	 | ID LTHIRD expression RTHIRD 
{

	fprintf(logFile,"variable : ID LTHIRD expression RTHIRD   \n\n");

	Symbol *s= hashTable.lookUp($1->getName());

	if(s==0)
		yyerror((char*)"could not find the identifier");
	else if ((int)$3->getSingleValue()>=s->getLength())
		yyerror((char*)"array index out of bound");
	else{
		float *a;
		a = s->getA();
		int index = (int)$3->getSingleValue();
		Symbol* t=new Symbol((char*)s->getName(),(char*)s->getType(),s->getDataType(),a[index]);
		$$=t;
}

}	 ;
			
expression : logic_expression	
{
	fprintf(logFile,"expression : logic_expression  \n\n");

	$$=$1;

}
	   | variable ASSIGNOP logic_expression 
{

	fprintf(logFile,"expression : variable ASSIGNOP logic_expression \n\n");

	

	if($1->getDataType() <= 3)
	{
		if(($1->getDataType() == 1 || $1->getDataType() == 3) && $3->getDataType() == 2 )yyerror((char*)"cannot assign float to int/char type");

		    else{
			float changedVal = $3->getSingleValue();
			hashTable.modifySingleValue($1->getName(),changedVal);
			hashTable.printTable(logFile);
	    		}	
	}
	else if($1->getDataType() >= 4  && $1->getDataType() <= 6 )
	{
		if(($1->getDataType() == 4 ||$1->getDataType() == 6) && $3->getDataType() == 2)fprintf(logFile,":Type Mismatch. Assigning float type to int / char type\n\n");

		    else{
			Symbol *s= hashTable.lookUp($1->getName());
			int index = s->getIndex($1->getSingleValue());
			float changedVal = $3->getSingleValue();
			hashTable.modifyArrayValue($1->getName(),changedVal,index);
			hashTable.printTable(logFile);
		    }
	}
	 
}

	
	   ;
			
logic_expression : rel_expression 
{
	fprintf(logFile,"logic_expression : rel_expression  \n\n");
	$$=$1;
	printf("%f",$$->getSingleValue());
}	
		 | rel_expression LOGICOP rel_expression 	
{

	fprintf(logFile,"logic_expression : rel_expression LOGICOP rel_expression   \n\n");

	$$=$1;

	if($2->getDataType() == 13 )

{
				float a = $1->getSingleValue(); 
				float b = $3->getSingleValue();
				float res = a&&b;
				$$->setValue(res);
	}
	else if($2->getDataType() == 14)

{
				float a = $1->getSingleValue(); 
				float b = $3->getSingleValue();
				float res = a||b;
				$$->setValue(res);
	}

}
		 ;
			
rel_expression	: simple_expression 
{

	fprintf(logFile,"rel_expression : simple_expression   \n\n");
	$$=$1;
	printf("%f",$$->getSingleValue());

}
		| simple_expression RELOP simple_expression	
{

	fprintf(logFile,"rel_expression : simple_expression RELOP simple_expression  \n\n");

	$$=$1;

	if($2->getDataType() == 7)

	{
				float a = $1->getSingleValue(); 
				float b = $3->getSingleValue();
				float res = a>b;
				$$->setValue(res);
	}
	else if($2->getDataType() ==  9)

{
				float a = $1->getSingleValue(); 
				float b = $3->getSingleValue();
				float res = a>=b;
				$$->setValue(res);
	}
	else if($2->getDataType() == 8)
		
{
				float a = $1->getSingleValue(); 
				float b = $3->getSingleValue();
				float res = a<b;
				$$->setValue(res);
	}
	else if($2->getDataType() == 10)
		
{
				float a = $1->getSingleValue(); 
				float b = $3->getSingleValue();
				float res = a<=b;
				$$->setValue(res);
	}
	else if($2->getDataType() == 11)
		
{
				float a = $1->getSingleValue(); 
				float b = $3->getSingleValue();
				float res = (a==b);
				$$->setValue(res);
	}
	else if($2->getDataType() == 12)
		
{
				float a = $1->getSingleValue(); 
				float b = $3->getSingleValue();
				float res = (a!=b);
				$$->setValue(res);
	}

}
		;
				
simple_expression : term 
{

	fprintf(logFile,"simple_expression : term   \n");

	$$=$1;

}
		  | simple_expression ADDOP term 
{

	fprintf(logFile,"simple_expression : simple_expression ADDOP term \n");

	$$=$1;

	if($2->getDataType() == 15)
		
		{
			
				float a = $1->getSingleValue(); 
				float b = $3->getSingleValue();
				float res = (a+b);
				$$->setValue(res);
		}
	else if($2->getDataType() == 16)
		
		{
			
				float a = $1->getSingleValue(); 
				float b = $3->getSingleValue();
				float res = (a-b);
				$$->setValue(res);
		}

}
		  ;
					
term :	unary_expression
{

	fprintf(logFile,"term : unary_expression   \n\n");

	$$=$1;


}
     |  term MULOP unary_expression
{

	fprintf(logFile,"term : term MULOP unary_expression  \n\n");

	$$=$1;

	if($2->getDataType() == 17){
	      if(($1->getDataType() == 1 || $1->getDataType() == 4) && ($3->getDataType() == 1 || $3->getDataType() == 4 ))

		{
			int a = int($1->getSingleValue()); 
			int b = int ($3->getSingleValue());
			int res = a/b;
			$$->setValue(res);
			
		}
	      else {
		   yyerror((char*)"modulus cannot deal with non-integers\n");
		   $$->setValue(-9999999);
	      }
	};

	
	if($2->getDataType() == 18)
		{
			float a = $1->getSingleValue(); 
			float b = $3->getSingleValue();
			float res = a/b;
			if(b == 0) {yyerror((char*)"Error : divide by zero\n\n"); $$->setValue(-999999);}
			else 
			$$->setValue(res);
		}
	else if($2->getDataType() == 19)
		{
			float a = $1->getSingleValue(); 
			float b = $3->getSingleValue();
			float res = a*b;
			$$->setValue(res);
		}
	
}
     ;

unary_expression : ADDOP unary_expression  
{

	fprintf(logFile,"unary_expression : ADDOP unary_expression   \n\n");

	$$=$2;

	if($1->getDataType() == 15)
		$$->setValue(1*$2->getSingleValue());
	else if($1->getDataType() == 16)
		$$->setValue(-1*$2->getSingleValue());

}
		 | NOT unary_expression 
{

	fprintf(logFile,"unary_expression : NOT unary_expression  \n\n");

	$$=$1;
	int t = $1->getSingleValue();
	t = !t;

	$$->setValue(float(t));

}
		 | factor 
{

	fprintf(logFile,"unary_expression : factor   \n\n");

	$$=$1;


}
		 ;
	
factor	: variable 
{

	fprintf(logFile,"factor : variable   \n\n");
	$$=$1;

}
	| LPAREN expression RPAREN 
{

	fprintf(logFile,"factor : LPAREN expression RPAREN   \n\n");

}
	| CONST_INT 
{

	fprintf(logFile,"factor : CONST_INT  \n\n");

	$$=$1;
	int i = (int)$$->getSingleValue();

	fprintf(logFile,"%d\n\n",i);

}
	| CONST_FLOAT
{
	fprintf(logFile,"factor : CONST_FLOAT   \n\n");

	$$=$1;
	float t = $$->getSingleValue();

	fprintf(logFile,"%f\n\n",t);

}
	| CONST_CHAR
{

	fprintf(logFile,"factor : CONST_CHAR  \n\n");

	$$=$1;
	char c = (char)$$->getSingleValue();

	fprintf(logFile,"%c\n\n",c);

}
	| factor INCOP 
{

	fprintf(logFile,"factor : variable  \n\n");

	$$=$1;
	float val = $$->getSingleValue();

	$$->setValue(val+1);

}
	| factor DECOP
{

	fprintf(logFile,"factor : factor DECOP   \n\n");

	$$=$1;
	float val = $$->getSingleValue();

	$$->setValue(val-1);

}
	;
%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("absent input file\n");
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("can't open file\n");
		return 0;
	}
	yyin=fin;
	logFile= fopen("log31.txt","w");
        
	yyparse();
        hashTable.printTable(logFile);
        fprintf(logFile,"Line count: %d and Error count: %d\n\n",line_count,error);
	fclose(fin);
	fclose(logFile);
        
        
	return 0;
}


