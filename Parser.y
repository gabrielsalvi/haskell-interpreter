{
module Parser where

import Lexer
}

%name parser
%tokentype { Token }
%error { parseError }

%token
    true { TokenTrue }
    false { TokenFalse }
    num { TokenNum $$ }
    '+' { TokenAdd }
    '-' { TokenMinus }
    '*' { TokenMult }
    and { TokenAnd }
    or { TokenOr }
    "==" { TokenEq }
    '>' { TokenGreaterThan }
    '<' { TokenLessThan }
    if { TokenIf }
    then { TokenThen }
    else { TokenElse }
    '[' { TokenOpenSquareBracket }
    ']' { TokenCloseSquareBracket }
    ',' { TokenComma }

%nonassoc if then else
%left '+' '-' and or
%left '*'
%left "==" '<' '>'

%%

Exp : true { BTrue }
    | false { BFalse }
    | num { Num $1 }
    | Exp '+' Exp { Add $1 $3 }
    | Exp '-' Exp { Minus $1 $3 }
    | Exp '*' Exp { Mult $1 $3 }
    | Exp and Exp { And $1 $3 }
    | if Exp then Exp else Exp { If $2 $4 $6 }
    | Exp "==" Exp { Eq $1 $3 }
    | Exp '<' Exp { Lt $1 $3 }
    | Exp '>' Exp { Gt $1 $3 }
    | '[' ListExp ']' { List $2 }

ListExp : { [] }
        | Exp { [$1] }
        | Exp ',' ListExp { $1 : $3 }

{

parseError :: [Token] -> a
parseError ts = error "Syntax error: sequência de instruções inválidas"
}
