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
        deriving (Show, Eq)

data Ty = TBool
        | TNum
        | TFun Ty Ty
        | TCoord
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
           deriving (Show)

isSymb :: Char -> Bool
isSymb c = c `elem` "+-*/=><\\"

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
lexerSymbol cs = case span isSymb cs of
                    ("->", rest) -> TokenArrow : lexer rest
                    ("\\", rest) -> TokenLam : lexer rest
                    ("+", rest) -> TokenAdd : lexer rest
                    ("-", rest) -> TokenMinus : lexer rest
                    ("*", rest) -> TokenMult : lexer rest
                    ("==", rest) -> TokenEq : lexer rest
                    (">", rest) -> TokenGreaterThan : lexer rest
                    ("<", rest) -> TokenLessThan : lexer rest
                    _ -> error "Lexical error: invalid symbol!"
