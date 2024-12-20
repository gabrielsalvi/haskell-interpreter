module TypeChecker where

import Lexer

type Context = [(String, Ty)]

typeof :: Context -> Expr -> Maybe Ty
typeof _ (Num _) = Just TNum
typeof _ BTrue = Just TBool
typeof _ BFalse = Just TBool

typeof ctx (Add e1 e2) = case (typeof ctx e1, typeof ctx e2) of
                        (Just TNum, Just TNum) -> Just TNum
                        _ -> Nothing
typeof ctx (Minus e1 e2) = case (typeof ctx e1, typeof ctx e2) of
                        (Just TNum, Just TNum) -> Just TNum
                        _ -> Nothing
typeof ctx (Mult e1 e2) = case (typeof ctx e1, typeof ctx e2) of
                         (Just TNum, Just TNum) -> Just TNum
                         _ -> Nothing
typeof ctx (And e1 e2) = case (typeof ctx e1, typeof ctx e2) of
                        (Just TBool, Just TBool) -> Just TBool
                        _ -> Nothing
typeof ctx (Or e1 e2) = case (typeof ctx e1, typeof ctx e2) of
                        (Just TBool, Just TBool) -> Just TBool
                        _ -> Nothing
typeof ctx (If e e1 e2) = case typeof ctx e of
                            Just TBool -> case (typeof ctx e1, typeof ctx e2) of
                                            (Just t1, Just t2) | t1 == t2 -> Just t1
                                                               | otherwise -> Nothing
                                            _ -> Nothing
                            _ -> Nothing

typeof ctx (Lt e1 e2) = case (typeof ctx e1, typeof ctx e2) of
                             (Just TNum, Just TNum) -> Just TBool
                             _                      -> Nothing
typeof ctx (Gt e1 e2) = case (typeof ctx e1, typeof ctx e2) of
                                (Just TNum, Just TNum) -> Just TBool
                                _                      -> Nothing
typeof ctx (Var v) = lookup v ctx
typeof ctx (Lam v t1 b) = let Just t2 = typeof ((v, t1) : ctx) b
                            in Just (TFun t1 t2)
typeof ctx (App e1 e2) = case (typeof ctx e1, typeof ctx e2) of
                           (Just (TFun t11 t12), Just t2) | t11 == t2 -> Just t12
                                                          | otherwise -> Nothing
                           _ -> Nothing

typeof ctx (List l) = case l of
    [] -> Just (TList TNum)
    (x:xs) -> case typeof ctx x of
        Just t -> if all (\e -> typeof ctx e == Just t) xs
                  then Just (TList t)
                  else Nothing
        _ -> Nothing


typeof ctx (ListHead e) = case typeof ctx e of
                            Just (TList t) -> Just t
                            _ -> Nothing

typeof ctx (ListTail e) = case typeof ctx e of
                            Just (TList t) -> Just (TList t)
                            _ -> Nothing

typecheck :: Expr -> Expr
typecheck e = case typeof [] e of
                (Just _) -> e
                _ -> error ("Erro verificando tipo da expressão: " ++ show e)
