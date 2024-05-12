lexer grammar Lexer;

WS: [ \t\n\r]+ -> skip;
Name: LETTER (LETTER | DIGIT | '_')*;
Literal: ESCAPED_STR | Number;
Boolean: 'true' | 'false';
fragment Number: DIGIT+;

fragment DIGIT: [0-9];
fragment LETTER: [a-zA-Z];
fragment ESCAPED_STR : '\'' .*? '\'';

fragment SEPARATOR: ';';