%{
#define LIST				strcat(buf, yytext)
#define token(t)			{LIST; if (Opt_T) printf("<%s>\n", #t);}
#define tokenChar(t)		{LIST; if (Opt_T) printf("<%s>\n", (t));}
#define tokenInteger(t, i)	{LIST; if (Opt_T) printf("<%s: %d>\n", #t, (i));}
#define tokenString(t, s)	{LIST; if (Opt_T) printf("<%s: %s>\n", #t, (s));}
#define tokenSstring(s, len){LIST; int i; if (Opt_T) { printf("<string: "); for( i=1; i<len-1; i++ ){ printf("%c", s[i]); if( s[i]==34 ) i++; }	printf(">\n"); } }
#define tokenKeyword(t)		{LIST; if (Opt_T) printf("<KW%s>\n", t);}
#define openS()				{LIST; Opt_S = 1;}
#define closeS()			{LIST; Opt_S = 0;}
#define openT()				{LIST; Opt_T = 1;}
#define closeT()			{LIST; Opt_T = 0;}

#define MAX_LINE_LENG      256

int Opt_S = 1;
int Opt_T = 1;
int linenum = 1;
char buf[MAX_LINE_LENG];
%}

%Start COMMENT

delimiters	[,;:\(\)\[\]]
arithmetric	[\+\-\*/]|mod
assignment	:=
relation	<|<=|<>|>=|>|=
logical		and|or|not
keyword		array|begin|boolean|def|do|else|end|false|for|integer|if|of|print|read|real|string|then|to|true|return|var|while
identifier	[a-zA-Z][a-zA-Z0-9]*
integer		[1-9][0-9]*|0
octinteger	0[0-7]+
float		{integer}\.[0-9]*
scientific	({integer}|{octinteger}|{float})[Ee][\+\-]?({integer}|{octinteger})
string		\"([^\n\"]|\"\")*\"
space		[ \t]

%%

<INITIAL>{delimiters}	{ tokenChar(yytext); }
<INITIAL>{arithmetric}	{ tokenChar(yytext); }
<INITIAL>{assignment}	{ tokenChar(yytext); }
<INITIAL>{relation}		{ tokenChar(yytext); }
<INITIAL>{logical}		{ tokenChar(yytext); }
<INITIAL>{keyword}		{ tokenKeyword(yytext); }
<INITIAL>{identifier}	{ tokenString(id, yytext); }
<INITIAL>{integer}		{ tokenString(integer, yytext); }
<INITIAL>{octinteger}	{ tokenString(oct_integer, yytext); }
<INITIAL>{scientific}	{ tokenString(scientific, yytext); }
<INITIAL>{float}		{ tokenString(float, yytext); }
<INITIAL>{string}		{ tokenSstring(yytext, yyleng); }
<INITIAL>{space}		{ LIST; }

<INITIAL>\/\/\&T\+.*	{ openT(); }
<INITIAL>\/\/\&T\-.*	{ closeT(); }
<INITIAL>\/\/\&S\+.*	{ openS(); }
<INITIAL>\/\/\&S\-.*	{ closeS(); }
<INITIAL>\/\/.*			{ LIST; }
<INITIAL>\/\*			{ LIST; BEGIN COMMENT; }

<COMMENT>.*\*\/			{ LIST; BEGIN INITIAL; }
<COMMENT>.*				{ LIST; }

\n				{	
					LIST;
					if (Opt_S)
						printf("%d: %s", linenum, buf);
					linenum++;
					buf[0] = '\0';
				}

%%
int main( int argc, char **argv )
{
  if( argc != 2 ) {
    fprintf( stderr, "Usage: ./scanner [filename]\n" );
    exit(0);
  }
	
  FILE *fp = fopen( argv[1], "r" );
  if( fp == NULL ) {
    fprintf( stderr, "Open file error\n" );
    exit(-1);
  }
	
  yyin = fp;

  yylex();

  exit(0);
}
