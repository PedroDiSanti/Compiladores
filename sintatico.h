/* A Bison parser, made by GNU Bison 2.5.  */

/* Bison interface for Yacc-like parsers in C
   
      Copyright (C) 1984, 1989-1990, 2000-2011 Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     T_PROGRAMA = 258,
     T_INICIO = 259,
     T_FIM = 260,
     T_IDENTIF = 261,
     T_LEIA = 262,
     T_ESCREVA = 263,
     T_ENQTO = 264,
     T_FACA = 265,
     T_FIMENQTO = 266,
     T_SE = 267,
     T_ENTAO = 268,
     T_SENAO = 269,
     T_FIMSE = 270,
     T_ATRIB = 271,
     T_VEZES = 272,
     T_DIV = 273,
     T_MAIS = 274,
     T_MENOS = 275,
     T_MAIOR = 276,
     T_MENOR = 277,
     T_IGUAL = 278,
     T_E = 279,
     T_OU = 280,
     T_V = 281,
     T_F = 282,
     T_NUMERO = 283,
     T_NAO = 284,
     T_ABRE = 285,
     T_FECHA = 286,
     T_ABREV = 287,
     T_FECHAV = 288,
     T_LOGICO = 289,
     T_INTEIRO = 290
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


