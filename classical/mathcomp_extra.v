(* mathcomp analysis (c) 2022 Inria and AIST. License: CeCILL-C.              *)
From mathcomp Require Import ssreflect ssrbool ssrfun ssralg.
Require Import boolp classical_sets.

(******************************************************************************)
(* This files contains lemmas and definitions missing from MathComp.          *)
(*                                                                            *)
(*                oflit f := Some \o f                                        *)
(*          pred_omap T D := [pred x | oapp (mem D) false x]                  *)
(*                 f \* g := fun x => f x * g x                               *)
(*                                                                            *)
(******************************************************************************)

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Reserved Notation "f \* g" (at level 40, left associativity).

Lemma all_sig2_cond {I : Type} {T : Type} (D : pred I)
   (P Q : I -> T -> Prop) : T ->
    (forall x : I, D x -> {y : T | P x y & Q x y}) ->
  {f : forall x : I, T | forall x : I, D x -> P x (f x) & forall x : I, D x -> Q x (f x)}.
Proof.
by move=> /all_sig_cond/[apply]-[f Pf]; exists f => i Di; have [] := Pf i Di.
Qed.

Definition olift aT rT (f : aT -> rT) := Some \o f.

Lemma oapp_comp aT rT sT (f : aT -> rT) (g : rT -> sT) x :
  oapp (g \o f) x =1 (@oapp _ _)^~ x g \o omap f.
Proof. by case. Qed.

Lemma olift_comp aT rT sT (f : aT -> rT) (g : rT -> sT) :
  olift (g \o f) = olift g \o f.
Proof. by []. Qed.

Lemma can_in_pcan [rT aT : Type] (A : {pred aT}) [f : aT -> rT] [g : rT -> aT] :
  {in A, cancel f g} -> {in A, pcancel f (fun y : rT => Some (g y))}.
Proof. by move=> fK x Ax; rewrite fK. Qed.

Lemma pcan_in_inj [rT aT : Type] [A : {pred aT}] [f : aT -> rT] [g : rT -> option aT] :
  {in A, pcancel f g} -> {in A &, injective f}.
Proof. by move=> fK x y Ax Ay /(congr1 g); rewrite !fK// => -[]. Qed.

Definition pred_omap T (D : {pred T}) : pred (option T) :=
  [pred x | oapp (mem D) false x].

Lemma ocan_in_comp [A B C : Type] (D : {pred B}) (D' : {pred C})
    [f : B -> option A] [h : C -> option B]
    [f' : A -> B] [h' : B -> C] :
  {homo h : x / x \in D' >-> x \in pred_omap D} ->
  {in D, ocancel f f'} -> {in D', ocancel h h'} ->
  {in D', ocancel (obind f \o h) (h' \o f')}.
Proof.
move=> hD fK hK c cD /=; rewrite -[RHS]hK/=; case hcE : (h c) => [b|]//=.
have bD : b \in D by have := hD _ cD; rewrite hcE inE.
by rewrite -[b in RHS]fK; case: (f b) => //=; have /hK := cD; rewrite hcE.
Qed.

Lemma pred_omapE {T : Type} (D : {pred T}) :
  pred_omap D = mem (some @` D)%classic.
Proof.
apply/funext=> -[x|]/=; apply/idP/idP; rewrite /pred_omap/= inE //=.
- by move=> xD; exists x.
- by move=> [// + + [<-]].
- by case.
Qed.

Lemma pred_omap_set {T : Type} (D : set T) :
  pred_omap (mem D) = mem (some @` D)%classic.
Proof.
by rewrite pred_omapE; apply/funext => x/=; apply/idP/idP; rewrite ?inE;
   move=> [y/= ]; rewrite ?in_setE; exists y; rewrite ?in_setE.
Qed.

Lemma eqbRL (b1 b2 : bool) : b1 = b2 -> b2 -> b1.
Proof. by move->. Qed.

Definition mul_fun T (R : ringType) (f g : T -> R) x := (f x * g x)%R.
Notation "f \* g" := (mul_fun f g) : ring_scope.
Arguments mul_fun {T R} _ _ _ /.
