module Lexer where

import Data.Char

data Expr = BTrue
        | BFalse
        | Num Int
        | Add Expr Expr
        | Minus Expr Expr
        | Mult Expr Expr
        | And Expr Expr
        | Or Expr Expr
        | Eq Expr Expr
        | Gt Expr Expr
        | Lt Expr Expr
        | If Expr Expr Expr
        | Var String
        | Lam String Ty Expr
        | App Expr Expr
        | List [Expr]
        deriving (Show, Eq)

data Ty = TBool
        | TNum
        | TFun Ty Ty
        | TList Ty
        deriving (Show, Eq)

data Token = TokenTrue
           | TokenFalse
           | TokenNum Int
           | TokenAdd
           | TokenMinus
           | TokenMult
           | TokenAnd
           | TokenOr
           | TokenEq
           | TokenGreaterThan
           | TokenLessThan
           | TokenIf
           | TokenThen
           | TokenElse
           | TokenVar String
           | TokenLam
           | TokenArrow
           | TokenOpenSquareBracket
           | TokenCloseSquareBracket
           | TokenComma
           deriving (Show)

isSymb :: Char -> Bool
isSymb c = c `elem` "+-*/=><\\,[]"

lexer :: String -> [Token]
lexer [] = []
lexer (c:cs)
    | isSpace c = lexer cs
    | isSymb c = lexerSymbol (c:cs)
    | isAlpha c = lexerKW (c:cs)
    | isDigit c = lexerNum (c:cs)

lexerNum :: String -> [Token]
lexerNum cs = case span isDigit cs of
                (num, rest) -> TokenNum (read num) : lexer rest

lexerKW :: String -> [Token]
lexerKW cs = case span isAlpha cs of
                ("true", rest) -> TokenTrue : lexer rest
                ("false", rest) -> TokenFalse : lexer rest
                ("and", rest) -> TokenAnd : lexer rest
                ("or", rest) -> TokenOr : lexer rest
                ("if", rest) -> TokenIf : lexer rest
                ("then", rest) -> TokenThen : lexer rest
                ("else", rest) -> TokenElse : lexer rest
                (var, rest) -> TokenVar var : lexer rest

lexerSymbol :: String -> [Token]
lexerSymbol (c:cs) = case c of
    '[' -> TokenOpenSquareBracket : lexer cs
    ']' -> TokenCloseSquareBracket : lexer cs
    ',' -> TokenComma : lexer cs
    '+' -> TokenAdd : lexer cs
    '-' -> TokenMinus : lexer cs
    '*' -> TokenMult : lexer cs
    '>' -> TokenGreaterThan : lexer cs
    '<' -> TokenLessThan : lexer cs
    '\\' -> TokenLam : lexer cs
    _ -> error "Lexical error: invalid symbol!"
lexerSymbol [] = error "Lexical error: unexpected end of input!"
