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

Require Export CRmetric.
Require Import QMinMax.
Require Import COrdAbs.
Require Import Qordfield.
Require Import Qmetric.
Require Import CornTac.

Set Implicit Arguments.

Opaque CR Qmin Qmax.

Open Local Scope uc_scope.

(**
** Addition
Lifting addition over [Q] by one parameter yields a rational translation
function. *)
Lemma Qtranslate_uc_prf (a:Q) : is_UniformlyContinuousFunction (fun b:Q => (a[+]b):Q) Qpos2QposInf.
Proof.
intros a e b0 b1 H.
simpl in *.
unfold Qball in *.
stepr (b0-b1) by (simpl; ring).
assumption.
Qed.

Definition Qtranslate_uc (a:Q_as_MetricSpace) : Q_as_MetricSpace --> Q_as_MetricSpace :=
Build_UniformlyContinuousFunction (Qtranslate_uc_prf a).

Definition translate (a:Q) : CR --> CR := Cmap QPrelengthSpace (Qtranslate_uc a).

Lemma translate_ident : forall x:CR, (translate 0 x==x)%CR.
Proof.
intros x.
unfold translate.
assert (H:ms_eq (Qtranslate_uc 0) (uc_id _)).
intros a.
simpl.
ring.

simpl.
rewrite H.
rewrite Cmap_fun_correct.
rapply MonadLaw1.
Qed.

(** Lifting translate yields binary addition over CR. *)
Lemma Qplus_uc_prf :  is_UniformlyContinuousFunction Qtranslate_uc Qpos2QposInf.
Proof.
intros e a0 a1 H b.
simpl in *.
repeat rewrite (fun x => Qplus_comm x b).
apply Qtranslate_uc_prf.
assumption.
Qed.

Definition Qplus_uc : Q_as_MetricSpace --> Q_as_MetricSpace --> Q_as_MetricSpace :=
Build_UniformlyContinuousFunction Qplus_uc_prf.

Definition CRplus : CR --> CR --> CR := Cmap2 QPrelengthSpace QPrelengthSpace Qplus_uc.

Notation "x + y" := (ucFun2 CRplus x y) : CR_scope.

Lemma CRplus_translate : forall (a:Q) (y:CR), (' a + y == translate a y)%CR.
Proof.
intros a y.
unfold ucFun2, CRplus.
unfold Cmap2.
unfold inject_Q.
simpl.
do 2 rewrite Cmap_fun_correct.
rewrite Cap_fun_correct.
rewrite MonadLaw3.
rewrite StrongMonadLaw1.
reflexivity.
Qed.

Hint Rewrite CRplus_translate : CRfast_compute.

Lemma translate_Qplus : forall a b:Q, (translate a ('b)=='(a+b)%Q)%CR.
Proof.
intros a b.
unfold translate, Cmap.
simpl.
rewrite Cmap_fun_correct.
rapply MonadLaw3.
Qed.

Hint Rewrite translate_Qplus : CRfast_compute.
(**
** Negation
Lifting negation on [Q] yields negation on CR.
*)
Lemma Qopp_uc_prf : is_UniformlyContinuousFunction Qopp Qpos2QposInf.
Proof.
intros e a b H.
simpl in *.
unfold Qball in *.
stepr (b - a) by (simpl;ring).
rapply AbsSmall_minus.
assumption.
Qed.

Definition Qopp_uc : Q_as_MetricSpace --> Q_as_MetricSpace :=
Build_UniformlyContinuousFunction Qopp_uc_prf.

Definition CRopp : CR -> CR := Cmap QPrelengthSpace Qopp_uc.

Notation "- x" := (CRopp x) : CR_scope.

(**
** Subtraction
There is no subtraction on CR.  It is simply notation for adding a
negated quantity.  This way all lemmas about addition automatically
apply to subtraction.
*)
Notation "x - y" := (x + (- y))%CR : CR_scope.
(* begin hide *)
Add Morphism CRopp with signature (@ms_eq _) ==> (@ms_eq _) as CRopp_wd.
Proof.
rapply uc_wd.
Qed.
(* end hide *)
(**
** Inequality
First a predicate for nonnegative numbers is defined. *)
Definition CRnonNeg (x:CR) := forall e:Qpos, (-e) <= (approximate x e).
(* begin hide *)
Add Morphism CRnonNeg with signature (@ms_eq _) ==> iff as CRnonNeg_wd.
assert (forall x1 x2 : RegularFunction Q_as_MetricSpace,
regFunEq x1 x2 -> CRnonNeg x1 -> CRnonNeg x2).
intros x y Hxy Hx e.
apply Qnot_lt_le.
intros He.
rewrite Qlt_minus_iff in He.
pose (e' := mkQpos He).
pose (H1:=(Hx ((1#3)*e')%Qpos)).
pose (H2:=(Hxy ((1#3)*e')%Qpos e)).
destruct H2 as [_ H2].
simpl in H2.
rewrite Qle_minus_iff in H1.
rewrite Qle_minus_iff in H2.
autorewrite with QposElim in *.
ring_simplify in H1.
ring_simplify in H2.
assert (H3: 0+0<=(approximate x ((1 # 3) * e')%Qpos + (1 # 3) * e') + ((1 # 3) * e' + e + (-1 # 1) * approximate x ((1 # 3) * e')%Qpos + approximate y e)).
rsapply plus_resp_leEq_both; assumption.
ring_simplify in H3.
setoid_replace ((6 # 9) * e' + e + approximate y e) with ((6#9)*e'-e') in H3.
ring_simplify in H3.
apply (Qle_not_lt _ _ H3).
rewrite Qlt_minus_iff.
ring_simplify.
rsapply mult_resp_pos.
constructor.
apply Qpos_prf.
unfold e'.
rewrite QposAsmkQpos.
ring.

intros.
split.
apply H; assumption.
apply H.
change (y==x)%CR.
symmetry.
assumption.
Qed.
(* end hide *)
(** And similarly for nonpositive. *)
Definition CRnonPos (x:CR) := forall e:Qpos, (approximate x e) <= e.
(* begin hide *)
Add Morphism CRnonPos with signature (@ms_eq _) ==> iff as CRnonPos_wd.
assert (forall x1 x2 : RegularFunction Q_as_MetricSpace,
regFunEq x1 x2 -> CRnonPos x1 -> CRnonPos x2).
intros x y Hxy Hx e.
apply Qnot_lt_le.
intros He.
rewrite Qlt_minus_iff in He.
pose (e' := mkQpos He).
pose (H1:=(Hx ((1#3)*e')%Qpos)).
pose (H2:=(Hxy ((1#3)*e')%Qpos e)).
destruct H2 as [H2 _].
simpl in H2.
rewrite Qle_minus_iff in H1.
rewrite Qle_minus_iff in H2.
autorewrite with QposElim in *.
ring_simplify in H1.
ring_simplify in H2.
assert (H3: 0+0<=((1 # 3) * e' + (-1 # 1) * approximate x ((1 # 3) * e')%Qpos)+(approximate x ((1 # 3) * e')%Qpos + (-1 # 1) * approximate y e + (1 # 3) * e' + e)).
rsapply plus_resp_leEq_both; assumption.
ring_simplify in H3.
setoid_replace ((6 # 9) * e' + (-1 # 1) * approximate y e + e) with ((6#9)*e'-e') in H3.
ring_simplify in H3.
apply (Qle_not_lt _ _ H3).
rewrite Qlt_minus_iff.
ring_simplify.
rsapply mult_resp_pos.
constructor.
apply Qpos_prf.
unfold e'.
rewrite QposAsmkQpos.
ring.

intros.
split.
apply H; assumption.
apply H.
change (y==x)%CR.
symmetry.
assumption.
Qed.
(* end hide *)
(** Inequality is defined in terms of nonnegativity. *)
Definition CRle (x y:CR) := (CRnonNeg (y - x))%CR.

Infix "<=" := CRle : CR_scope.
(* begin hide *)
Add Morphism CRle with signature (@ms_eq _) ==> (@ms_eq _) ==> iff as CRle_wd.
intros x1 x2 Hx y1 y2 Hy.
change (x1==x2)%CR in Hx.
change (y1==y2)%CR in Hy.
unfold CRle.
rapply CRnonNeg_wd.
apply ucFun2_wd.
assumption.
apply CRopp_wd.
assumption.
Qed.
(* end hide *)
(** Basic properties of inequality *)
Lemma CRle_refl : forall x, (x <= x)%CR.
Proof.
intros x e.
simpl.
unfold Cap_raw.
simpl.
rewrite Qle_minus_iff.
ring_simplify.
apply Qpos_nonneg.
Qed.

Lemma CRle_def : forall x y, (x==y <-> (x <= y /\ y <= x))%CR.
Proof.
intros x y.
split;[intros H;rewrite H;split; apply CRle_refl|].
intros [H1 H2].
rewrite <- (doubleSpeed_Eq x).
rewrite <- (doubleSpeed_Eq y).
rapply regFunEq_e.
intros e.
apply ball_weak.
split;[rapply H2|].
rsapply inv_cancel_leEq.
replace RHS with (approximate y ((1 # 2) * e)%Qpos - approximate x ((1 # 2) * e)%Qpos) by ring.
rapply H1.
Qed.

Lemma CRle_trans : forall x y z, (x <= y -> y <= z -> x <= z)%CR.
Proof.
intros x y z H1 H2.
unfold CRle.
rewrite <- (doubleSpeed_Eq (z-x)%CR).
intros e.
assert (H1':=H1 ((1#2)*e)%Qpos).
assert (H2':=H2 ((1#2)*e)%Qpos).
clear H1 H2.
simpl in *.
unfold Cap_raw in *.
simpl in *.
replace RHS with ((approximate z ((1 # 2) * ((1 # 2) * e))%Qpos
- approximate y ((1 # 2) * ((1 # 2) * e))%Qpos
+ (approximate y ((1 # 2) * ((1 # 2) * e))%Qpos
- approximate x ((1 # 2) * ((1 # 2) * e))%Qpos))) by ring.
replace LHS with (-(1#2)*e + - (1#2)*e) by ring.
apply Qplus_le_compat;assumption.
Qed.

(**
** Maximum
[QboundBelow] ensures that a real number is at least some fixed
rational number.  It is the lifting of the first parameter of [Qmax].
*)
Lemma QboundBelow_uc_prf (a:Q) : is_UniformlyContinuousFunction (fun b:Q => (Qmax a b):Q) Qpos2QposInf.
Proof.
intros a e b0 b1 H.
simpl in *.
assert (X:forall a b0 b1, Qball e b0 b1 -> b0 <= a <= b1 -> Qball e a b1).
clear a b0 b1 H.
intros a b0 b1 H [H1 H2].
unfold Qball in *.
unfold AbsSmall in *.
split.
apply Qle_trans with (b0-b1).
tauto.
rapply (minus_resp_leEq _ b0).
assumption.
apply Qle_trans with 0.
rapply (shift_minus_leEq _ a).
stepr b1.
assumption.
simpl; ring.
apply Qpos_nonneg.

do 2 apply Qmax_case;
intros H1 H2.
rapply ball_refl.
eapply X.
apply H.
tauto.
rapply ball_sym.
apply X with b1.
rapply ball_sym.
apply H.
tauto.
assumption.
Qed.

Definition QboundBelow_uc (a:Q_as_MetricSpace) : Q_as_MetricSpace --> Q_as_MetricSpace :=
Build_UniformlyContinuousFunction (QboundBelow_uc_prf a).

Definition boundBelow (a:Q) : CR --> CR := Cmap QPrelengthSpace (QboundBelow_uc a).

(** CRmax is the lifting of [QboundBelow]. *)
Lemma Qmax_uc_prf :  is_UniformlyContinuousFunction QboundBelow_uc Qpos2QposInf.
Proof.
intros e a0 a1 H b.
simpl in *.
repeat rewrite (fun x => Qmax_comm x b).
apply QboundBelow_uc_prf.
assumption.
Qed.

Definition Qmax_uc : Q_as_MetricSpace --> Q_as_MetricSpace --> Q_as_MetricSpace :=
Build_UniformlyContinuousFunction Qmax_uc_prf.

Definition CRmax : CR --> CR --> CR := Cmap2 QPrelengthSpace QPrelengthSpace Qmax_uc.

Lemma CRmax_boundBelow : forall (a:Q) (y:CR), (CRmax (' a) y == boundBelow a y)%CR.
Proof.
intros a y.
unfold ucFun2, CRmax.
unfold Cmap2.
unfold inject_Q.
simpl.
do 2 rewrite Cmap_fun_correct.
rewrite Cap_fun_correct.
rewrite MonadLaw3.
rewrite StrongMonadLaw1.
reflexivity.
Qed.
(** Basic properties of CRmax. *)
Lemma CRmax_ub_l : forall x y, (x <= CRmax x y)%CR.
Proof.
intros x y e.
simpl.
unfold Cap_raw.
simpl.
unfold Cap_raw.
simpl.
rewrite Qmax_plus_distr_l.
eapply Qle_trans;[|apply Qmax_ub_l].
cut (AbsSmall (e:Q) (approximate x ((1 # 2) * ((1 # 2) * e))%Qpos +
- approximate x ((1 # 2) * e)%Qpos));[unfold AbsSmall;tauto|].
change (ball e (approximate x ((1 # 2) * ((1 # 2) * e))%Qpos)
 (approximate x ((1 # 2) * e)%Qpos)).
eapply ball_weak_le;[|apply regFun_prf].
autorewrite with QposElim.
rewrite Qle_minus_iff.
ring_simplify.
rapply mult_resp_nonneg.
discriminate.
apply Qpos_nonneg.
Qed.

Lemma CRmax_ub_r : forall x y, (y <= CRmax x y)%CR.
Proof.
intros y x e.
simpl.
unfold Cap_raw.
simpl.
unfold Cap_raw.
simpl.
rewrite Qmax_plus_distr_l.
eapply Qle_trans;[|apply Qmax_ub_r].
cut (AbsSmall (e:Q) (approximate x ((1 # 2) * ((1 # 2) * e))%Qpos +
- approximate x ((1 # 2) * e)%Qpos));[unfold AbsSmall;tauto|].
change (ball e (approximate x ((1 # 2) * ((1 # 2) * e))%Qpos)
 (approximate x ((1 # 2) * e)%Qpos)).
eapply ball_weak_le;[|apply regFun_prf].
autorewrite with QposElim.
rewrite Qle_minus_iff.
ring_simplify.
rapply mult_resp_nonneg.
discriminate.
apply Qpos_nonneg.
Qed.

Lemma CRmax_lub: forall x y z : CR, (x <= z -> y <= z -> CRmax x y <= z)%CR.
Proof.
intros x y z Hx Hy.
rewrite <- (doubleSpeed_Eq z) in * |- *.
intros e.
assert (Hx':=Hx ((1#2)*e)%Qpos).
assert (Hy':=Hy ((1#2)*e)%Qpos).
clear Hx Hy.
simpl in *.
unfold Cap_raw in *.
simpl in *.
unfold Cap_raw.
simpl.
replace LHS with ((-(1#2)*e) + (- (1#2)*e)) by ring.
replace RHS with ((approximate z ((1#2)*((1 # 2) * e))%Qpos +
- approximate z ((1#2)*((1 # 2) * ((1 # 2) * e)))%Qpos) +
(approximate z ((1#2)*((1 # 2) * ((1 # 2) * e)))%Qpos
- Qmax (approximate x ((1 # 2) * ((1 # 2) * e))%Qpos)
  (approximate y ((1 # 2) * ((1 # 2) * e))%Qpos))) by ring.
apply Qplus_le_compat;[|apply Qmax_case;intro;assumption].
cut (ball ((1#2)*e)%Qpos (approximate z ((1#2)*((1 # 2) * e))%Qpos)
(approximate z ((1#2)*((1 # 2) * ((1 # 2) * e)))%Qpos));[intros [A B]; assumption|].
rapply ball_weak_le;[|apply regFun_prf].
rewrite Qle_minus_iff.
autorewrite with QposElim.
ring_simplify.
rapply mult_resp_nonneg.
discriminate.
apply Qpos_nonneg.
Qed.
(**
** Minimum
[QboundAbove] ensures that a real number is at most some fixed
rational number.  It is the lifting of the first parameter of [Qmin].
*)
Lemma QboundAbove_uc_prf (a:Q) : is_UniformlyContinuousFunction (fun b:Q => (Qmin a b):Q) Qpos2QposInf.
Proof.
intros a e b0 b1 H.
simpl in *.
unfold Qball.
stepr ((Qmax (- a) (-b1)) - (Qmax (-a) (-b0))).
apply QboundBelow_uc_prf.
rapply Qopp_uc_prf.
rapply ball_sym.
assumption.
unfold Qminus.
simpl.
rewrite Qmin_max_de_morgan.
rewrite Qmax_min_de_morgan.
repeat rewrite Qopp_involutive.
ring.
Qed.

Definition QboundAbove_uc (a:Q_as_MetricSpace) : Q_as_MetricSpace --> Q_as_MetricSpace :=
Build_UniformlyContinuousFunction (QboundAbove_uc_prf a).

Definition boundAbove (a:Q) : CR --> CR := Cmap QPrelengthSpace (QboundAbove_uc a).

(** CRmin is the lifting of [QboundAbove]. *)
Lemma Qmin_uc_prf :  is_UniformlyContinuousFunction QboundAbove_uc Qpos2QposInf.
Proof.
intros e a0 a1 H b.
simpl in *.
repeat rewrite (fun x => Qmin_comm x b).
apply QboundAbove_uc_prf.
assumption.
Qed.

Definition Qmin_uc : Q_as_MetricSpace --> Q_as_MetricSpace --> Q_as_MetricSpace :=
Build_UniformlyContinuousFunction Qmin_uc_prf.

Definition CRmin : CR --> CR --> CR := Cmap2 QPrelengthSpace QPrelengthSpace Qmin_uc.

Lemma CRmin_boundAbove : forall (a:Q) (y:CR), (CRmin (' a) y == boundAbove a y)%CR.
Proof.
intros a y.
unfold ucFun2, CRmin.
unfold Cmap2.
unfold inject_Q.
simpl.
do 2 rewrite Cmap_fun_correct.
rewrite Cap_fun_correct.
rewrite MonadLaw3.
rewrite StrongMonadLaw1.
reflexivity.
Qed.

(** Basic properties of CRmin. *)
Lemma CRmin_lb_l : forall x y, (CRmin x y <= x)%CR.
Proof.
intros x y e.
simpl.
unfold Cap_raw.
simpl.
unfold Cap_raw.
simpl.
rewrite Qmin_max_de_morgan.
rewrite Qmax_plus_distr_r.
eapply Qle_trans;[|apply Qmax_ub_l].
cut (AbsSmall (e:Q) (approximate x ((1 # 2) * e)%Qpos +
- approximate x ((1 # 2) * ((1 # 2) * e))%Qpos));[unfold AbsSmall;tauto|].
change (ball e (approximate x ((1 # 2) * e)%Qpos) (approximate x ((1 # 2) * ((1 # 2) * e))%Qpos)).
eapply ball_weak_le;[|apply regFun_prf].
autorewrite with QposElim.
rewrite Qle_minus_iff.
ring_simplify.
rapply mult_resp_nonneg.
discriminate.
apply Qpos_nonneg.
Qed.

Lemma CRmin_lb_r : forall x y, (CRmin x y <= y)%CR.
Proof.
intros y x e.
simpl.
unfold Cap_raw.
simpl.
unfold Cap_raw.
simpl.
rewrite Qmin_max_de_morgan.
rewrite Qmax_plus_distr_r.
eapply Qle_trans;[|apply Qmax_ub_r].
cut (AbsSmall (e:Q) (approximate x ((1 # 2) * e)%Qpos +
- approximate x ((1 # 2) * ((1 # 2) * e))%Qpos));[unfold AbsSmall;tauto|].
change (ball e (approximate x ((1 # 2) * e)%Qpos)
 (approximate x ((1 # 2) * ((1 # 2) * e))%Qpos)).
eapply ball_weak_le;[|apply regFun_prf].
autorewrite with QposElim.
rewrite Qle_minus_iff.
ring_simplify.
rapply mult_resp_nonneg.
discriminate.
apply Qpos_nonneg.
Qed.

Lemma CRmin_glb: forall x y z : CR, (z <= x -> z <= y -> z <= CRmin x y)%CR.
Proof.
intros x y z Hx Hy.
rewrite <- (doubleSpeed_Eq z) in * |- *.
intros e.
assert (Hx':=Hx ((1#2)*e)%Qpos).
assert (Hy':=Hy ((1#2)*e)%Qpos).
clear Hx Hy.
simpl in *.
unfold Cap_raw in *.
simpl in *.
unfold Cap_raw.
simpl.
replace LHS with ((-(1#2)*e) + (- (1#2)*e)) by ring.
replace RHS with ((approximate z ((1#2)*((1 # 2) * ((1 # 2) * e)))%Qpos +
- approximate z ((1#2)*((1 # 2) * e))%Qpos) +
(Qmin (approximate x ((1 # 2) * ((1 # 2) * e))%Qpos)
  (approximate y ((1 # 2) * ((1 # 2) * e))%Qpos) +
- approximate z ((1#2)*((1 # 2) * ((1 # 2) * e)))%Qpos)) by ring.
apply Qplus_le_compat;[|apply Qmin_case;intro;assumption].
cut (ball ((1#2)*e)%Qpos (approximate z ((1#2)*((1 # 2) * ((1 # 2) * e)))%Qpos)
(approximate z ((1#2)*((1 # 2) * e))%Qpos));[intros [A B]; assumption|].
rapply ball_weak_le;[|apply regFun_prf].
rewrite Qle_minus_iff.
autorewrite with QposElim.
ring_simplify.
rapply mult_resp_nonneg.
discriminate.
apply Qpos_nonneg.
Qed.