
%option noyywrap



%{
#include "SymbolTable.h"
#include "y.tab.h"




extern YYSTYPE yylval;
void yyerror(char *);
extern int line_count=1;
extern int error=0;



%}



digit [0-9]
letter [A-Za-z]
delim [ \t\r\f\v]
newline \n
ws [delim]+
id (_|{letter})(_|{letter}|{digit})*
integer {digit}+
number {digit}*(\.{digit}+)?(E[+-]?{digit}+)?
character [']{letter}[']
ADDOP [+-] 
MULOP [*/%]

%%

{delim}+	{}
{newline} {line_count++;}

"if" {return IF;}
"else" {return ELSE;}
"for" {return FOR;}
"while" {return WHILE;}
"int" {return INT;}
"float" {return FLOAT;}
"double" {return DOUBLE;}
"char" {return CHAR;}
"return" {return RETURN;}
"void" {return VOID;}
"main"	{return MAIN;}
"println"	{return PRINTLN;}

{ADDOP} {               Symbol *s;
			
			s= new Symbol((char*)yytext,(char*)"ADDOP");
			if(strcmp(yytext,"+")==0)
				s->setDataType(15);
                        else if(strcmp(yytext,"-")==0)
				s->setDataType(16);
                        yylval.sym = s;	
			return ADDOP;
		}



{MULOP}	{               
                        Symbol *s;
			
			s= new Symbol((char*)yytext,(char*)"MULOP");
			if(strcmp(yytext,"%")==0)
				s->setDataType(17);
	                else if(strcmp(yytext,"/")==0)
				s->setDataType(18);
                        else if(strcmp(yytext,"*")==0)
				s->setDataType(19);
		
                        yylval.sym = s;			
			return MULOP;
		}


"=" 	{return ASSIGNOP;}

">" |
"<" |
">=" |
"<=" |
"==" |
"!=" {
                        Symbol *s;
			
			s= new Symbol((char*)yytext,(char*)"RELOP");
			if(strcmp(yytext,">")==0)
				s->setDataType(7);	
                        else if(strcmp(yytext,"<")==0)
				s->setDataType(8);		
                        else if(strcmp(yytext,">=")==0)
				s->setDataType(9);	
	                else if(strcmp(yytext,"<=")==0)
				s->setDataType(10);	
                        else if(strcmp(yytext,"==")==0)
				s->setDataType(11);		
                        else if(strcmp(yytext,"!=")==0)
				s->setDataType(12);
	
                        yylval.sym = s;	
		        return RELOP;
	}

"&&"	|
"||"	{               
                        Symbol *s;
		
			s= new Symbol((char*)yytext,(char*)"LOGICOP");
			if(strcmp(yytext,"&&"))
				s->setDataType(13);
	                if(strcmp(yytext,"||"))
				s->setDataType(14);
		
                        yylval.sym = s;	
			
			return LOGICOP;
		}
"!"		{	return NOT; }


";" 	{return SEMICOLON;}
"," 	{return COMMA;}
"(" 	{return LPAREN;}
")" 	{return RPAREN;}
"{" 	{return LCURL;}
"}" 	{return RCURL;}
"[" 	{return LTHIRD;}
"]" 	{return RTHIRD;}
"++" 	{return INCOP;}
"--" 	{return DECOP;}



{integer}	{
				Symbol *s= new Symbol((char*)yytext,(char*)"CONST_INT",1,atoi(yytext));
                                yylval.sym = s;	
                                printf("%s\n",yytext);	
				return CONST_INT;
			}
{number} 	{	
				Symbol *s= new Symbol((char*)yytext,(char*)"CONST_FLOAT",2,atof(yytext));
                                yylval.sym = s;	
                                printf("%s\n",yytext);
				return CONST_FLOAT; 
                }
			
{character} 	{	
				Symbol *s= new Symbol((char*)yytext,(char*)"CONST_CHAR",3,(float)yytext[1]);
                                yylval.sym = s;	
                                printf("%s\n",yytext);
                                printf("%c oh yeah",yytext[1]);
				return CONST_CHAR; 
			}
{id} 		{	 
				Symbol *s= new Symbol((char*)yytext,(char*)"ID",0,-9999999);printf("%s\n",yytext);
				yylval.sym = s;			
				return ID;
			}


%%







