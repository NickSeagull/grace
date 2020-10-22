{
module Grace.Parser where

import Grace.Lexer (Token)

import qualified Grace.Lexer  as Lexer
import qualified Grace.Syntax as Syntax
}

%name parseExpression
%tokentype { Token }
%error { parseError }

%token
    '&&'    { Lexer.And              }
    '->'    { Lexer.Arrow            }
    '@'     { Lexer.At               }
    Bool    { Lexer.Bool             }
    ')'     { Lexer.CloseParenthesis }
    ':'     { Lexer.Colon            }
    '='     { Lexer.Equals           }
    False   { Lexer.False            }
    forall  { Lexer.Forall           }
    in      { Lexer.In               }
    int     { Lexer.Int $$           }
    Kind    { Lexer.Kind             }
    '\\'    { Lexer.Lambda           }
    let     { Lexer.Let              }
    '('     { Lexer.OpenParenthesis  }
    '||'    { Lexer.Or               }
    True    { Lexer.True             }
    Type_   { Lexer.Type             }
    label   { Lexer.Label $$         }

%%

Expression
    : '\\' '(' label ':' Expression ')' '->' Expression
        { Syntax.Lambda $3 $5 $8 }
    | forall '(' label ':' Expression ')' '->' Expression
        { Syntax.Forall $3 $5 $8 }
    | ApplicationExpression '->' Expression
        { Syntax.Forall "_" $1 $3 }
    | let label ':' Expression '=' Expression in Expression
        { Syntax.Let $2 $4 $6 $8 }
    | AnnotationExpression
        { $1 }

AnnotationExpression
    : OrExpression ':' AnnotationExpression
        { Syntax.Annotation $1 $3 }
    | OrExpression
        { $1 }

OrExpression
    : OrExpression '||' AndExpression
        { Syntax.Or $1 $3 }
    | AndExpression
        { $1 }

AndExpression
    : AndExpression '&&' ApplicationExpression
        { Syntax.And $1 $3 }
    | ApplicationExpression
        { $1 }

ApplicationExpression
    : ApplicationExpression PrimitiveExpression
        { Syntax.Application $1 $2 }
    | PrimitiveExpression
        { $1 }

PrimitiveExpression
    : label
        { Syntax.Variable $1 0 }
    | label '@' int
        { Syntax.Variable $1 $3 }
    | Bool
        { Syntax.Bool }
    | True
        { Syntax.True }
    | False
        { Syntax.False }
    | Type_
        { Syntax.Type }
    | Kind
        { Syntax.Kind }
    | '(' Expression ')' 
       { $2 }

{
parseError :: [Token] -> a
parseError = error . show
}
