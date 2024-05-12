grammar dsl;
import Lexer;

prog: ('given' knowledge)? ('where' conditions)?;

knowledge: use (',' use)*;
use: crenca
    | goal;
crenca: modifier? 'B' structure;
goal: modifier? 'G' structure;
modifier: '-' | '~' | '+';
structure: Name ('(' patterns (',' patterns)*  ')')? source?;
source: 'from' Name;

patterns: Literal
    | bind
    |;

bind: Name;
function_call: function_path '(' function_params? ')';
function_path: Name ('.' Name)*;
function_params: expr (',' expr)* ;

conditions: (condition (',' condition)*)?;
condition: expr
    | pattern_match_expr
    | pattern_match_tuple;
pattern_match_expr: expr 'is' pattern ('|' pattern)*;
pattern_match_tuple: tuple 'is' tuple_pattern ('|' tuple_pattern)*;

pattern: function_call
    | <assoc=right> ('!' | '-') pattern
    | '!=' pattern
    | op=('<' | '<=' | '>=' | '>') pattern
    | pattern 'and' pattern
    | '(' pattern ')'
    | array_pattern
    | range_pattern
    | inclusive_range_pattern
    | '_'
    | Name
    | Literal;

array_pattern: '[' (expr ',')* ('*' bind?)? (',' expr)* ']';
range_pattern: expr '..' expr;
inclusive_range_pattern: expr '..=' expr;

tuple: '(' expr (',' expr)* ','? ')';
tuple_pattern: '(' pattern (',' pattern)* ','? ')';

expr: <assoc=right> ('!' | '-') expr
    | expr op=('*' | '/') expr
    | expr op=('+' | '-') expr
    | expr op=('=' | '!=') expr
    | expr op=('<' | '<=' | '>=' | '>') expr
    | expr 'and' expr
    | expr 'or' expr
    | expr '[' expr ']'
    | expr '.' expr
    | '(' expr ')'
    | function_call
    | Name '.' function_call
    | Name ':=' expr
    | Name
    | Boolean
    | Literal;
