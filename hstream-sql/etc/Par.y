-- This Happy file was machine-generated by the BNF converter
{
{-# OPTIONS_GHC -fno-warn-incomplete-patterns -fno-warn-overlapping-patterns #-}
module HStream.SQL.Par
  ( happyError
  , myLexer
  , pSQL
  ) where

import Prelude

import qualified HStream.SQL.Abs
import HStream.SQL.Lex
import qualified Data.Text

}

%name pSQL_internal SQL
-- no lexer declaration
%monad { Err } { (>>=) } { return }
%tokentype {Token}
%token
  '&&' { PT _ (TS _ 1) }
  '(' { PT _ (TS _ 2) }
  ')' { PT _ (TS _ 3) }
  '*' { PT _ (TS _ 4) }
  '+' { PT _ (TS _ 5) }
  ',' { PT _ (TS _ 6) }
  '-' { PT _ (TS _ 7) }
  '.' { PT _ (TS _ 8) }
  ':' { PT _ (TS _ 9) }
  ';' { PT _ (TS _ 10) }
  '<' { PT _ (TS _ 11) }
  '<=' { PT _ (TS _ 12) }
  '<>' { PT _ (TS _ 13) }
  '=' { PT _ (TS _ 14) }
  '>' { PT _ (TS _ 15) }
  '>=' { PT _ (TS _ 16) }
  'ABS' { PT _ (TS _ 17) }
  'ACOS' { PT _ (TS _ 18) }
  'ACOSH' { PT _ (TS _ 19) }
  'AND' { PT _ (TS _ 20) }
  'AS' { PT _ (TS _ 21) }
  'ASIN' { PT _ (TS _ 22) }
  'ASINH' { PT _ (TS _ 23) }
  'ATAN' { PT _ (TS _ 24) }
  'ATANH' { PT _ (TS _ 25) }
  'AVG' { PT _ (TS _ 26) }
  'BETWEEN' { PT _ (TS _ 27) }
  'BY' { PT _ (TS _ 28) }
  'CEIL' { PT _ (TS _ 29) }
  'CHANGES' { PT _ (TS _ 30) }
  'COS' { PT _ (TS _ 31) }
  'COSH' { PT _ (TS _ 32) }
  'COUNT' { PT _ (TS _ 33) }
  'COUNT(*)' { PT _ (TS _ 34) }
  'CREATE' { PT _ (TS _ 35) }
  'DATE' { PT _ (TS _ 36) }
  'DAY' { PT _ (TS _ 37) }
  'DROP' { PT _ (TS _ 38) }
  'EMIT' { PT _ (TS _ 39) }
  'EXIST' { PT _ (TS _ 40) }
  'EXP' { PT _ (TS _ 41) }
  'FALSE' { PT _ (TS _ 42) }
  'FLOOR' { PT _ (TS _ 43) }
  'FORMAT' { PT _ (TS _ 44) }
  'FROM' { PT _ (TS _ 45) }
  'GROUP' { PT _ (TS _ 46) }
  'HAVING' { PT _ (TS _ 47) }
  'HOPPING' { PT _ (TS _ 48) }
  'IF' { PT _ (TS _ 49) }
  'INNER' { PT _ (TS _ 50) }
  'INSERT' { PT _ (TS _ 51) }
  'INTERVAL' { PT _ (TS _ 52) }
  'INTO' { PT _ (TS _ 53) }
  'IS_ARRAY' { PT _ (TS _ 54) }
  'IS_BOOL' { PT _ (TS _ 55) }
  'IS_DATE' { PT _ (TS _ 56) }
  'IS_FLOAT' { PT _ (TS _ 57) }
  'IS_INT' { PT _ (TS _ 58) }
  'IS_MAP' { PT _ (TS _ 59) }
  'IS_NUM' { PT _ (TS _ 60) }
  'IS_STR' { PT _ (TS _ 61) }
  'IS_TIME' { PT _ (TS _ 62) }
  'JOIN' { PT _ (TS _ 63) }
  'LEFT' { PT _ (TS _ 64) }
  'LEFT_TRIM' { PT _ (TS _ 65) }
  'LOG' { PT _ (TS _ 66) }
  'LOG10' { PT _ (TS _ 67) }
  'LOG2' { PT _ (TS _ 68) }
  'MAX' { PT _ (TS _ 69) }
  'MIN' { PT _ (TS _ 70) }
  'MINUTE' { PT _ (TS _ 71) }
  'MONTH' { PT _ (TS _ 72) }
  'NOT' { PT _ (TS _ 73) }
  'ON' { PT _ (TS _ 74) }
  'OR' { PT _ (TS _ 75) }
  'OUTER' { PT _ (TS _ 76) }
  'QUERIES' { PT _ (TS _ 77) }
  'REPLICATE' { PT _ (TS _ 78) }
  'REVERSE' { PT _ (TS _ 79) }
  'RIGHT_TRIM' { PT _ (TS _ 80) }
  'ROUND' { PT _ (TS _ 81) }
  'SECOND' { PT _ (TS _ 82) }
  'SELECT' { PT _ (TS _ 83) }
  'SESSION' { PT _ (TS _ 84) }
  'SHOW' { PT _ (TS _ 85) }
  'SIN' { PT _ (TS _ 86) }
  'SINH' { PT _ (TS _ 87) }
  'SQRT' { PT _ (TS _ 88) }
  'STREAM' { PT _ (TS _ 89) }
  'STREAMS' { PT _ (TS _ 90) }
  'STRLEN' { PT _ (TS _ 91) }
  'SUM' { PT _ (TS _ 92) }
  'TAN' { PT _ (TS _ 93) }
  'TANH' { PT _ (TS _ 94) }
  'TIME' { PT _ (TS _ 95) }
  'TO_LOWER' { PT _ (TS _ 96) }
  'TO_STR' { PT _ (TS _ 97) }
  'TO_UPPER' { PT _ (TS _ 98) }
  'TRIM' { PT _ (TS _ 99) }
  'TRUE' { PT _ (TS _ 100) }
  'TUMBLING' { PT _ (TS _ 101) }
  'VALUES' { PT _ (TS _ 102) }
  'WEEK' { PT _ (TS _ 103) }
  'WHERE' { PT _ (TS _ 104) }
  'WITH' { PT _ (TS _ 105) }
  'WITHIN' { PT _ (TS _ 106) }
  'YEAR' { PT _ (TS _ 107) }
  '[' { PT _ (TS _ 108) }
  ']' { PT _ (TS _ 109) }
  '{' { PT _ (TS _ 110) }
  '||' { PT _ (TS _ 111) }
  '}' { PT _ (TS _ 112) }
  L_Ident  { PT _ (TV _) }
  L_doubl  { PT _ (TD _) }
  L_integ  { PT _ (TI _) }
  L_quoted { PT _ (TL _) }
  L_SString { PT _ (T_SString _) }

%%

Ident :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.Ident) }
Ident  : L_Ident { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.Ident (tokenText $1)) }

Double  :: { (HStream.SQL.Abs.BNFC'Position, Double) }
Double   : L_doubl  { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), (read (Data.Text.unpack (tokenText $1))) :: Double) }

Integer :: { (HStream.SQL.Abs.BNFC'Position, Integer) }
Integer  : L_integ  { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), (read (Data.Text.unpack (tokenText $1))) :: Integer) }

String  :: { (HStream.SQL.Abs.BNFC'Position, String) }
String   : L_quoted { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), (Data.Text.unpack ((\(PT _ (TL s)) -> s) $1))) }

SString :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.SString) }
SString  : L_SString { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.SString (tokenText $1)) }

PNInteger :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.PNInteger) }
PNInteger : '+' Integer { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.PInteger (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $2)) }
          | Integer { (fst $1, HStream.SQL.Abs.IPInteger (fst $1) (snd $1)) }
          | '-' Integer { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.NInteger (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $2)) }

PNDouble :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.PNDouble) }
PNDouble : '+' Double { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.PDouble (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $2)) }
         | Double { (fst $1, HStream.SQL.Abs.IPDouble (fst $1) (snd $1)) }
         | '-' Double { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.NDouble (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $2)) }

SQL :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.SQL) }
SQL : Select ';' { (fst $1, HStream.SQL.Abs.QSelect (fst $1) (snd $1)) }
    | Create ';' { (fst $1, HStream.SQL.Abs.QCreate (fst $1) (snd $1)) }
    | Insert ';' { (fst $1, HStream.SQL.Abs.QInsert (fst $1) (snd $1)) }
    | ShowQ ';' { (fst $1, HStream.SQL.Abs.QShow (fst $1) (snd $1)) }
    | Drop ';' { (fst $1, HStream.SQL.Abs.QDrop (fst $1) (snd $1)) }

Create :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.Create) }
Create : 'CREATE' 'STREAM' Ident 'WITH' '(' ListStreamOption ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.DCreate (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3) (snd $6)) }
       | 'CREATE' 'STREAM' Ident 'AS' Select 'WITH' '(' ListStreamOption ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.CreateAs (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3) (snd $5) (snd $8)) }

ListStreamOption :: { (HStream.SQL.Abs.BNFC'Position, [HStream.SQL.Abs.StreamOption]) }
ListStreamOption : {- empty -} { (HStream.SQL.Abs.BNFC'NoPosition, []) }
                 | StreamOption { (fst $1, (:[]) (snd $1)) }
                 | StreamOption ',' ListStreamOption { (fst $1, (:) (snd $1) (snd $3)) }

StreamOption :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.StreamOption) }
StreamOption : 'FORMAT' '=' String { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.OptionFormat (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
             | 'REPLICATE' '=' PNInteger { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.OptionRepFactor (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }

Insert :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.Insert) }
Insert : 'INSERT' 'INTO' Ident '(' ListIdent ')' 'VALUES' '(' ListValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.DInsert (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3) (snd $5) (snd $9)) }
       | 'INSERT' 'INTO' Ident 'VALUES' String { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.InsertBinary (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3) (snd $5)) }
       | 'INSERT' 'INTO' Ident 'VALUES' SString { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.InsertJson (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3) (snd $5)) }

ListIdent :: { (HStream.SQL.Abs.BNFC'Position, [HStream.SQL.Abs.Ident]) }
ListIdent : {- empty -} { (HStream.SQL.Abs.BNFC'NoPosition, []) }
          | Ident { (fst $1, (:[]) (snd $1)) }
          | Ident ',' ListIdent { (fst $1, (:) (snd $1) (snd $3)) }

ListValueExpr :: { (HStream.SQL.Abs.BNFC'Position, [HStream.SQL.Abs.ValueExpr]) }
ListValueExpr : {- empty -} { (HStream.SQL.Abs.BNFC'NoPosition, []) }
              | ValueExpr { (fst $1, (:[]) (snd $1)) }
              | ValueExpr ',' ListValueExpr { (fst $1, (:) (snd $1) (snd $3)) }

ShowQ :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.ShowQ) }
ShowQ : 'SHOW' ShowOption { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.DShow (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $2)) }

ShowOption :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.ShowOption) }
ShowOption : 'QUERIES' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ShowQueries (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }
           | 'STREAMS' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ShowStreams (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }

Drop :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.Drop) }
Drop : 'DROP' 'STREAM' Ident { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.DDrop (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
     | 'DROP' 'STREAM' 'IF' 'EXIST' Ident { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.DropIf (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $5)) }

Select :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.Select) }
Select : Sel From Where GroupBy Having 'EMIT' 'CHANGES' { (fst $1, HStream.SQL.Abs.DSelect (fst $1) (snd $1) (snd $2) (snd $3) (snd $4) (snd $5)) }

Sel :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.Sel) }
Sel : 'SELECT' SelList { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.DSel (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $2)) }

SelList :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.SelList) }
SelList : '*' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.SelListAsterisk (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }
        | ListDerivedCol { (fst $1, HStream.SQL.Abs.SelListSublist (fst $1) (snd $1)) }

ListDerivedCol :: { (HStream.SQL.Abs.BNFC'Position, [HStream.SQL.Abs.DerivedCol]) }
ListDerivedCol : {- empty -} { (HStream.SQL.Abs.BNFC'NoPosition, []) }
               | DerivedCol { (fst $1, (:[]) (snd $1)) }
               | DerivedCol ',' ListDerivedCol { (fst $1, (:) (snd $1) (snd $3)) }

DerivedCol :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.DerivedCol) }
DerivedCol : ValueExpr { (fst $1, HStream.SQL.Abs.DerivedColSimpl (fst $1) (snd $1)) }
           | ValueExpr 'AS' Ident { (fst $1, HStream.SQL.Abs.DerivedColAs (fst $1) (snd $1) (snd $3)) }

From :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.From) }
From : 'FROM' ListTableRef { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.DFrom (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $2)) }

ListTableRef :: { (HStream.SQL.Abs.BNFC'Position, [HStream.SQL.Abs.TableRef]) }
ListTableRef : {- empty -} { (HStream.SQL.Abs.BNFC'NoPosition, []) }
             | TableRef { (fst $1, (:[]) (snd $1)) }
             | TableRef ',' ListTableRef { (fst $1, (:) (snd $1) (snd $3)) }

TableRef :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.TableRef) }
TableRef : Ident { (fst $1, HStream.SQL.Abs.TableRefSimple (fst $1) (snd $1)) }
         | TableRef 'AS' Ident { (fst $1, HStream.SQL.Abs.TableRefAs (fst $1) (snd $1) (snd $3)) }
         | TableRef JoinType 'JOIN' TableRef JoinWindow JoinCond { (fst $1, HStream.SQL.Abs.TableRefJoin (fst $1) (snd $1) (snd $2) (snd $4) (snd $5) (snd $6)) }

JoinType :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.JoinType) }
JoinType : 'INNER' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.JoinInner (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }
         | 'LEFT' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.JoinLeft (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }
         | 'OUTER' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.JoinOuter (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }

JoinWindow :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.JoinWindow) }
JoinWindow : 'WITHIN' '(' Interval ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.DJoinWindow (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }

JoinCond :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.JoinCond) }
JoinCond : 'ON' SearchCond { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.DJoinCond (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $2)) }

Where :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.Where) }
Where : {- empty -} { (HStream.SQL.Abs.BNFC'NoPosition, HStream.SQL.Abs.DWhereEmpty HStream.SQL.Abs.BNFC'NoPosition) }
      | 'WHERE' SearchCond { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.DWhere (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $2)) }

GroupBy :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.GroupBy) }
GroupBy : {- empty -} { (HStream.SQL.Abs.BNFC'NoPosition, HStream.SQL.Abs.DGroupByEmpty HStream.SQL.Abs.BNFC'NoPosition) }
        | 'GROUP' 'BY' ListGrpItem { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.DGroupBy (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }

ListGrpItem :: { (HStream.SQL.Abs.BNFC'Position, [HStream.SQL.Abs.GrpItem]) }
ListGrpItem : {- empty -} { (HStream.SQL.Abs.BNFC'NoPosition, []) }
            | GrpItem { (fst $1, (:[]) (snd $1)) }
            | GrpItem ',' ListGrpItem { (fst $1, (:) (snd $1) (snd $3)) }

GrpItem :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.GrpItem) }
GrpItem : ColName { (fst $1, HStream.SQL.Abs.GrpItemCol (fst $1) (snd $1)) }
        | Window { (fst $1, HStream.SQL.Abs.GrpItemWin (fst $1) (snd $1)) }

Window :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.Window) }
Window : 'TUMBLING' '(' Interval ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.TumblingWindow (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
       | 'HOPPING' '(' Interval ',' Interval ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.HoppingWindow (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3) (snd $5)) }
       | 'SESSION' '(' Interval ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.SessionWindow (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }

Having :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.Having) }
Having : {- empty -} { (HStream.SQL.Abs.BNFC'NoPosition, HStream.SQL.Abs.DHavingEmpty HStream.SQL.Abs.BNFC'NoPosition) }
       | 'HAVING' SearchCond { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.DHaving (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $2)) }

ValueExpr :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.ValueExpr) }
ValueExpr : ValueExpr '||' ValueExpr1 { (fst $1, HStream.SQL.Abs.ExprOr (fst $1) (snd $1) (snd $3)) }
          | '[' ListValueExpr ']' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ExprArr (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $2)) }
          | '{' ListLabelledValueExpr '}' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ExprMap (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $2)) }
          | ScalarFunc { (fst $1, HStream.SQL.Abs.ExprScalarFunc (fst $1) (snd $1)) }
          | ValueExpr1 { (fst $1, (snd $1)) }

ValueExpr1 :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.ValueExpr) }
ValueExpr1 : ValueExpr1 '&&' ValueExpr2 { (fst $1, HStream.SQL.Abs.ExprAnd (fst $1) (snd $1) (snd $3)) }
           | ValueExpr2 { (fst $1, (snd $1)) }

ValueExpr2 :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.ValueExpr) }
ValueExpr2 : ValueExpr2 '+' ValueExpr3 { (fst $1, HStream.SQL.Abs.ExprAdd (fst $1) (snd $1) (snd $3)) }
           | ValueExpr2 '-' ValueExpr3 { (fst $1, HStream.SQL.Abs.ExprSub (fst $1) (snd $1) (snd $3)) }
           | ValueExpr3 { (fst $1, (snd $1)) }

ValueExpr3 :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.ValueExpr) }
ValueExpr3 : ValueExpr3 '*' ValueExpr4 { (fst $1, HStream.SQL.Abs.ExprMul (fst $1) (snd $1) (snd $3)) }
           | ValueExpr4 { (fst $1, (snd $1)) }

ValueExpr4 :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.ValueExpr) }
ValueExpr4 : PNInteger { (fst $1, HStream.SQL.Abs.ExprInt (fst $1) (snd $1)) }
           | PNDouble { (fst $1, HStream.SQL.Abs.ExprNum (fst $1) (snd $1)) }
           | String { (fst $1, HStream.SQL.Abs.ExprString (fst $1) (snd $1)) }
           | Boolean { (fst $1, HStream.SQL.Abs.ExprBool (fst $1) (snd $1)) }
           | Date { (fst $1, HStream.SQL.Abs.ExprDate (fst $1) (snd $1)) }
           | Time { (fst $1, HStream.SQL.Abs.ExprTime (fst $1) (snd $1)) }
           | Interval { (fst $1, HStream.SQL.Abs.ExprInterval (fst $1) (snd $1)) }
           | ColName { (fst $1, HStream.SQL.Abs.ExprColName (fst $1) (snd $1)) }
           | SetFunc { (fst $1, HStream.SQL.Abs.ExprSetFunc (fst $1) (snd $1)) }
           | '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), (snd $2)) }

Boolean :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.Boolean) }
Boolean : 'TRUE' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.BoolTrue (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }
        | 'FALSE' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.BoolFalse (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }

Date :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.Date) }
Date : 'DATE' PNInteger '-' PNInteger '-' PNInteger { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.DDate (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $2) (snd $4) (snd $6)) }

Time :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.Time) }
Time : 'TIME' PNInteger ':' PNInteger ':' PNInteger { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.DTime (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $2) (snd $4) (snd $6)) }

TimeUnit :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.TimeUnit) }
TimeUnit : 'YEAR' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.TimeUnitYear (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }
         | 'MONTH' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.TimeUnitMonth (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }
         | 'WEEK' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.TimeUnitWeek (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }
         | 'DAY' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.TimeUnitDay (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }
         | 'MINUTE' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.TimeUnitMin (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }
         | 'SECOND' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.TimeUnitSec (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }

Interval :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.Interval) }
Interval : 'INTERVAL' PNInteger TimeUnit { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.DInterval (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $2) (snd $3)) }

ListLabelledValueExpr :: { (HStream.SQL.Abs.BNFC'Position, [HStream.SQL.Abs.LabelledValueExpr]) }
ListLabelledValueExpr : {- empty -} { (HStream.SQL.Abs.BNFC'NoPosition, []) }
                      | LabelledValueExpr { (fst $1, (:[]) (snd $1)) }
                      | LabelledValueExpr ',' ListLabelledValueExpr { (fst $1, (:) (snd $1) (snd $3)) }

LabelledValueExpr :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.LabelledValueExpr) }
LabelledValueExpr : Ident ':' ValueExpr { (fst $1, HStream.SQL.Abs.DLabelledValueExpr (fst $1) (snd $1) (snd $3)) }

ColName :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.ColName) }
ColName : Ident { (fst $1, HStream.SQL.Abs.ColNameSimple (fst $1) (snd $1)) }
        | Ident '.' Ident { (fst $1, HStream.SQL.Abs.ColNameStream (fst $1) (snd $1) (snd $3)) }
        | ColName '[' Ident ']' { (fst $1, HStream.SQL.Abs.ColNameInner (fst $1) (snd $1) (snd $3)) }
        | ColName '[' PNInteger ']' { (fst $1, HStream.SQL.Abs.ColNameIndex (fst $1) (snd $1) (snd $3)) }

SetFunc :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.SetFunc) }
SetFunc : 'COUNT(*)' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.SetFuncCountAll (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }
        | 'COUNT' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.SetFuncCount (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
        | 'AVG' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.SetFuncAvg (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
        | 'SUM' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.SetFuncSum (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
        | 'MAX' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.SetFuncMax (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
        | 'MIN' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.SetFuncMin (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }

ScalarFunc :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.ScalarFunc) }
ScalarFunc : 'SIN' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncSin (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'SINH' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncSinh (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'ASIN' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncAsin (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'ASINH' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncAsinh (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'COS' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncCos (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'COSH' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncCosh (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'ACOS' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncAcos (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'ACOSH' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncAcosh (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'TAN' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncTan (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'TANH' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncTanh (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'ATAN' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncAtan (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'ATANH' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncAtanh (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'ABS' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncAbs (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'CEIL' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncCeil (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'FLOOR' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncFloor (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'ROUND' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncRound (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'SQRT' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncSqrt (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'LOG' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncLog (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'LOG2' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncLog2 (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'LOG10' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncLog10 (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'EXP' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncExp (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'IS_INT' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncIsInt (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'IS_FLOAT' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncIsFloat (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'IS_NUM' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncIsNum (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'IS_BOOL' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncIsBool (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'IS_STR' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncIsStr (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'IS_MAP' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncIsMap (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'IS_ARRAY' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncIsArr (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'IS_DATE' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncIsDate (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'IS_TIME' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncIsTime (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'TO_STR' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncToStr (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'TO_LOWER' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncToLower (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'TO_UPPER' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncToUpper (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'TRIM' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncTrim (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'LEFT_TRIM' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncLTrim (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'RIGHT_TRIM' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncRTrim (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'REVERSE' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncRev (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }
           | 'STRLEN' '(' ValueExpr ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.ScalarFuncStrlen (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $3)) }

SearchCond :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.SearchCond) }
SearchCond : SearchCond 'OR' SearchCond1 { (fst $1, HStream.SQL.Abs.CondOr (fst $1) (snd $1) (snd $3)) }
           | SearchCond1 { (fst $1, (snd $1)) }

SearchCond1 :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.SearchCond) }
SearchCond1 : SearchCond1 'AND' SearchCond2 { (fst $1, HStream.SQL.Abs.CondAnd (fst $1) (snd $1) (snd $3)) }
            | SearchCond2 { (fst $1, (snd $1)) }

SearchCond2 :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.SearchCond) }
SearchCond2 : 'NOT' SearchCond3 { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.CondNot (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1)) (snd $2)) }
            | SearchCond3 { (fst $1, (snd $1)) }

SearchCond3 :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.SearchCond) }
SearchCond3 : ValueExpr CompOp ValueExpr { (fst $1, HStream.SQL.Abs.CondOp (fst $1) (snd $1) (snd $2) (snd $3)) }
            | ValueExpr 'BETWEEN' ValueExpr 'AND' ValueExpr { (fst $1, HStream.SQL.Abs.CondBetween (fst $1) (snd $1) (snd $3) (snd $5)) }
            | '(' SearchCond ')' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), (snd $2)) }

CompOp :: { (HStream.SQL.Abs.BNFC'Position, HStream.SQL.Abs.CompOp) }
CompOp : '=' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.CompOpEQ (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }
       | '<>' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.CompOpNE (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }
       | '<' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.CompOpLT (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }
       | '>' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.CompOpGT (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }
       | '<=' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.CompOpLEQ (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }
       | '>=' { (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1), HStream.SQL.Abs.CompOpGEQ (uncurry HStream.SQL.Abs.BNFC'Position (tokenLineCol $1))) }
{

type Err = Either String

happyError :: [Token] -> Err a
happyError ts = Left $
  "syntax error at " ++ tokenPos ts ++
  case ts of
    []      -> []
    [Err _] -> " due to lexer error"
    t:_     -> " before `" ++ (prToken t) ++ "'"

myLexer :: Data.Text.Text -> [Token]
myLexer = tokens

-- Entrypoints

pSQL :: [Token] -> Err HStream.SQL.Abs.SQL
pSQL = fmap snd . pSQL_internal
}

