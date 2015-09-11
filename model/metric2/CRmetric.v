(*
Copyright © 2006-2008 Russell O’Connor

Permission is hereby granted, free of charge, to any person obtaining a copy of
this proof and associated documentation files (the "Proof"), to deal in
the Proof without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Proof, and to permit persons to whom the Proof is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Proof.

THE PROOF IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE PROOF OR THE USE OR OTHER DEALINGS IN THE PROOF.
*)

Require Export Complete.
Require Export Prelength.
Require Import Qmetric.
Require Import CornTac.
Require Import canonical_names.
Require Import stdlib_rationals.

Set Implicit Arguments.

Open Local Scope uc_scope.

(**
* Complete Metric Space: Computable Reals (CR)
*)

Definition CR := Complete Q_as_MetricSpace.

Delimit Scope CR_scope with CR.
Bind Scope CR_scope with CR.

Instance inject_Q_CR: Cast Q CR := (@Cunit Q_as_MetricSpace).

(* 
Since (@Cunit Q_as_MetricSpace) is a bundled function with a modulus 
and uses a bundled representation of a metricspace as its domain, we 
can't define:
  Coercion inject_Q: Q_as_MetricSpace --> CR := (@Cunit Q_as_MetricSpace).
However, is is possible to define:
  Coercion inject_Q' (x : Q) : CR := (@Cunit Q_as_MetricSpace x).
We omit this for backward, and forward, compatibity 
(we can't define it for Q → AR either).
*)

(* begin hide *)
Instance inject_Q_CR_wd: Proper ((=) ==> (=)) inject_Q_CR.
Proof uc_wd (@Cunit Q_as_MetricSpace).
(* end hide *)

Notation "' x" := (inject_Q_CR x) : CR_scope.

Notation "x == y" := (@st_eq CR x y) (at level 70, no associativity) : CR_scope.
