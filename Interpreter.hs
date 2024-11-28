module Interpreter where

import Lexer

isValue :: Expr -> Bool
isValue BTrue = True
isValue BFalse = True
isValue (Num _) = True
isValue (Lam _ _ _) = True
isValue _ = False

-- Parâmetros: Variável (Parâmetro formal), Expressão (Parâmetro atual), Corpo da função
-- Retorno: Corpo da função substituído
subst :: String -> Expr -> Expr -> Expr
subst x n b@(Var v) = if v == x then n else b
subst x n (Add e1 e2) = (Add (subst x n e1) (subst x n e2))
subst x n (Mult e1 e2) = (Mult (subst x n e1) (subst x n e2))
subst x n (Minus e1 e2) = (Minus (subst x n e1) (subst x n e2))
subst x n (And e1 e2) = (And (subst x n e1) (subst x n e2))
subst x n (Eq e1 e2) = (Eq (subst x n e1) (subst x n e2))
subst x n (If e e1 e2) = (If (subst x n e) (subst x n e1) (subst x n e2))
subst x n (Lam v t b) = (Lam v t (subst x n b))
subst x n (App e1 e2) = (App (subst x n e1) (subst x n e2))
subst _ _ e = e

step :: Expr -> Expr

-- Add
step (Add (Num n1) (Num n2)) = Num (n1 + n2)
step (Add (Num nv) e2) = let e2' = step e2 in Add (Num nv) e2'
step (Add e1 e2) = Add (step e1) e2

-- Mult
step (Mult (Num n1) (Num n2)) = Num (n1 * n2)
step (Mult (Num n1) e2) = let e2' = step e2 in Mult (Num n1) e2'
step (Mult e1 e2) = Mult (step e1) e2

-- Minus
step (Minus (Num n1) (Num n2)) = Num (n1 - n2)
step (Minus (Num n1) e2) = let e2' = step e2 in Minus (Num n1) e2'
step (Minus e1 e2) = Minus (step e1) e2

-- And
step (And BFalse e) = BFalse
step (And BTrue e) = e
step (And e1 e2) = And (step e1) e2

-- If
step (If BTrue e1 e2) = e1
step (If BFalse e1 e2) = e2
step (If e e1 e2) = If (step e) e1 e2

-- Eq
step (Eq e1 e2) | isValue e1 && isValue e2 = if (e1 == e2) then BTrue else BFalse
                | isValue e1 = Eq e1 (step e2)
                | otherwise = Eq (step e1) e2

-- Lam
step (App (Lam v t b) e) | isValue e = subst v e b
                         | otherwise = (App (Lam v t b) (step e))
step (App e1 e2) = App (step e1) e2
step e = error (show e)

-- Eval
eval :: Expr -> Expr
eval e = if (isValue e) then e else eval (step e)