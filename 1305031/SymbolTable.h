#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <string.h>
#include<string>
#include <new>
using namespace std;

class Symbol{
    char name[25];
    char type[22];

    int dataType; // 1 for int, 2 for float, 3 for char, 4 intArray, 5floatArray
    // 6 charArray
    /*
    7 GT
    8 LT
    9 GTEQ
    10 LTEQ
    11 EQ
    12 NE
    13 AND
    14 OR
    15 add
    16 minus
    17 mod
    18 div
    19 19
    */
    float singleValue;
    float* a;
    int length;
    Symbol *nextSymbol;

public:
    Symbol(char* name,char* type){
        strcpy(this->name,name);
        strcpy(this->type,type);

        this->singleValue=0;
        nextSymbol = 0;
    }

    Symbol(char* name,char* type,int dataType){
        strcpy(this->name,name);
        strcpy(this->type,type);

	this->dataType = dataType;
        this->singleValue=0;
        nextSymbol = 0;
    }

    Symbol(char* name,char* type,int dataType,float val){
        strcpy(this->name,name);
        strcpy(this->type,type);

	this->dataType = dataType;
        this->singleValue=val;
        nextSymbol = 0;
    }

    Symbol(char* name,char* type,int dataType,float val,int length){
        strcpy(this->name,name);
        strcpy(this->type,type);

	this->dataType = dataType;
        this->singleValue=val;
        nextSymbol = 0;
        this->length=length;
        a=new float[length];
        for(int i=0;i<length;i++)a[i]=-1;

    }


  
    void setDataType(int dataType){	
	this->dataType = dataType;
	}

    void setValue(float val){
	this->singleValue=val;
	}

    void setLength(int length){
	this->length=length;
	}

    void setArrVal(float val,int ind)
	{
		a[ind]=val;}

    void setNextSymbol(Symbol* symbol)
	{
		this->nextSymbol=symbol;}

    char* getName()
	{return name;}

    char* getType()
	{return type;}


    int getDataType()
	{return dataType;}

    float getSingleValue()
	{return singleValue;}

    int getLength()
	{return length;}

    float* getA()
	{return a;}

    int getIndex(float val){


    int j = 0;
    while(j < length)
{
	if(a[j] == val) return j; j++;
}
    return 0;
    }

    Symbol* getNextSymbol(){return nextSymbol;}

};

class SymbolTable{
    Symbol **symbolTable;
    int size;

public:

    SymbolTable(int size){
        this->size=size;
        symbolTable = new Symbol*[size];
        for(int i=0;i<size;i++)symbolTable[i]=0;
    }

    int hashNumber(char*name){
        int index=0;
	int sum = 0;
	int len = strlen(name);
        for(int i = 0;i<len;i++) sum += name[i];
	index = sum % size;
        return index;
    }



	void insert(Symbol *sym){
        Symbol *symbol;
        
        symbol = new Symbol(sym->getName(), sym->getType(),sym->getDataType(),sym->getSingleValue());
        int index = hashNumber(symbol->getName());
        Symbol *temp = symbolTable[index];
        int link = 0;
        if(temp==0){
            symbolTable[index]=symbol;
        }
        else{
            link=1;
            while(temp->getNextSymbol()!=0){
                    temp=temp->getNextSymbol();
                    link++;
            }
            temp->setNextSymbol(symbol);
        }
        return ;
    }

    

     void insert(Symbol *sym,int length){
        Symbol *symbol;

        symbol = new Symbol(sym->getName(), sym->getType(),sym->getDataType(),sym->getSingleValue(),length);
        int index = hashNumber(symbol->getName());
        Symbol *temp = symbolTable[index];
        int link = 0;
        if(temp==0){
            symbolTable[index]=symbol;
        }
        else{
            link=1;
            while(temp->getNextSymbol()!=0){
                    temp=temp->getNextSymbol();
                    link++;
            }
            temp->setNextSymbol(symbol);
        }
        return ;
    }



    bool search(char* key){
        int index = hashNumber(key);
        Symbol *temp = symbolTable[index];
        int link = 0;
        if(temp == 0){
            return NULL;
        }
        else{
            while(temp!=0){
                    if(strcmp(temp->getName(),key)==0){
                        return true;
                    }
                    temp=temp->getNextSymbol();
                    link++;
            }
        }
        return false;
    }

    Symbol* lookUp(char* name){
        int i = hashNumber(name);
        Symbol *t = symbolTable[i];

        if(t == 0){
            return 0;
        }
        else{
            while(t!=0){
                    if(strcmp(t->getName(),name)==0){
                        return t;
                    }
                    t=t->getNextSymbol();

            }
        }
        return 0;
    }

    bool modifySingleValue(char* name,float modifiedVal){
        int i = hashNumber(name);
        Symbol *t = symbolTable[i];

        if(t == 0){
            return false;
        }
        else{
            while(t!=0){
                    if(strcmp(t->getName(),name)==0){
                        t->setValue(modifiedVal);
                        return true;
                    }
                    t=t->getNextSymbol();

            }
        }
	return false;
    }

     bool modifyArrayValue(char* name,float changedVal,int index){
        int i = hashNumber(name);
        Symbol *t = symbolTable[i];

        if(t == 0){
            return false;
        }
        else{
            while(t!=0){
                    if(strcmp(t->getName(),name)==0){
                        t->setArrVal(changedVal,index);
                        return true;
                    }
                    t=t->getNextSymbol();

            }
        }
	return false;
    }

 

void printTable(FILE *logfile){
        for(int i=0;i<size;i++){

            Symbol *temp = symbolTable[i];
            if(temp!=0){fprintf(logfile,"%d-> ",i);
            while(temp!=0){
		fprintf(logfile,"<%s,%s, ",temp->getName(),temp->getType());
                if(temp->getDataType() == 1)fprintf(logfile," %d>,",(int)temp->getSingleValue());

                if(temp->getDataType() == 2)fprintf(logfile," %f>,",temp->getSingleValue());

                if(temp->getDataType() == 3)fprintf(logfile," %c>,",(char)((int)temp->getSingleValue()));

                if(temp->getDataType() == 4){
                fprintf(logfile," {");
		float *t;
		t = temp->getA();
                for(int i=0;i<temp->getLength();i++)fprintf(logfile,"%d ",(int)t[i]);
                fprintf(logfile,"}>");
                }

                if(temp->getDataType() == 5){
                fprintf(logfile," {" );
		float *t;
		t = temp->getA();
                for(int i=0;i<temp->getLength();i++)fprintf(logfile,"%f ",t[i]);
                fprintf(logfile,"}>");
                }

                if(temp->getDataType() == 6){
                fprintf(logfile," {" );
		float *t;
		t = temp->getA();
                for(int i=0;i<temp->getLength();i++)fprintf(logfile,"%c ",(char)((int)t[i]));
                fprintf(logfile,"}>");
                }

                temp=temp->getNextSymbol();
            }
            fprintf(logfile,"\n");}
        }
        fprintf(logfile,"\n");
    }

  

};


