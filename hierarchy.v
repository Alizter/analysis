Require Import Reals.
From Coq Require Import ssreflect ssrfun ssrbool.
Require Import Rcomplements Rbar Markov Iter Lub.
From mathcomp Require Import ssrnat eqtype choice ssralg ssrnum.
From SsrReals Require Import boolp reals.
Require Import Rstruct.

(** ADD HEADER HERE !! *)

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.
Import GRing.Theory Num.Def Num.Theory.

Delimit Scope R_scope with coqR.
Delimit Scope real_scope with real.
Local Close Scope R_scope.
Local Open Scope ring_scope.
Local Open Scope real_scope.

(* :TODO: move to boolp *)
Lemma propT (P : Prop) : P -> P = True.
Proof. by move=> p; rewrite propeqE; tauto. Qed.

(* :TODO: move to boolp *)
Lemma propF (P : Prop) : ~ P -> P = False.
Proof. by move=> p; rewrite propeqE; tauto. Qed.

(* Enrico's trick for tc resolution in have *)
Notation "!! x" := (ltac:(refine x)) (at level 100, only parsing).
Class infer (P : Prop) := Infer : P.
Hint Mode infer ! : typeclass_instances.

Hint Resolve cond_pos.
Definition PosReal (x : R) (p : 0 < x) := mkposreal x (RltP _ _ p).

Section PosReal.
Implicit Types x y : posreal.

Lemma posreal_gt0 x : x > 0 :> R. Proof. by apply/RltP. Qed.
Hint Resolve posreal_gt0.
Lemma posreal_ge0 x : x >= 0 :> R. Proof. by apply: ltrW. Qed.
Hint Resolve posreal_ge0.
Lemma posreal_eq0 x : (x == 0 :> R) = false. Proof. by rewrite gtr_eqF. Qed.
Lemma posreal_neq0 x : (x != 0 :> R). Proof. by rewrite gtr_eqF. Qed.
Hint Resolve posreal_neq0.
Lemma posreal_le0 x : (x <= 0 :> R) = false.
Proof. by rewrite lerNgt posreal_gt0. Qed.
Lemma posreal_lt0 x : (x < 0 :> R) = false.
Proof. by rewrite ltrNge posreal_ge0. Qed.

Lemma min_pos_gt0 x y : 0 < minr (x : R) (y : R).
Proof. by rewrite ltr_minr !posreal_gt0. Qed.
Canonical minr_posreal x y := PosReal (@min_pos_gt0 x y).

Lemma add_pos_gt0 x y : 0 < (x : R) + (y : R).
Proof. by rewrite addr_gt0. Qed.
Canonical addr_posreal x y := PosReal (add_pos_gt0 x y).

Lemma mul_pos_posreal x y : 0 < (x : R) * (y : R).
Proof. by rewrite mulr_gt0. Qed.
Canonical mulr_posreal x y := PosReal (mul_pos_posreal x y).

Lemma muln_pos_posreal x n : 0 < (x : R) *+ n.+1.
Proof. by rewrite pmulrn_lgt0. Qed.
Canonical mulrn_posreal x n := PosReal (muln_pos_posreal x n).

Lemma inv_pos_gt0 x : 0 < (x : R)^-1. Proof. by rewrite invr_gt0. Qed.
Canonical invr_posreal x := PosReal (inv_pos_gt0 x).

Lemma one_pos_gt0 : 0 < 1 :> R. Proof. by rewrite ltr01. Qed.
Canonical oner_posreal := PosReal (@ltr01 _).

Definition posreal_of (x : R) y of x = y := y.
End PosReal.

Hint Resolve posreal_gt0.
Hint Resolve posreal_ge0.
Hint Resolve posreal_neq0.
Notation "[ 'posreal' 'of' x ]" := (@posreal_of x _ erefl)
  (format "[ 'posreal'  'of'  x ]") : ring_scope.

Definition dep_arrow_eq (T : eqType) (T' : T -> eqType)
   (f g : forall x : T, T' x) := `[<f = g>].
Lemma dep_arrow_eqP (T : eqType) (T' : T -> eqType) : Equality.axiom (@dep_arrow_eq T T').
Proof.
by move=> f g; apply: (iffP idP) => [/asboolP|->]; last by apply/asboolP.
Qed.

Definition dep_arrow_eqMixin (T : eqType) (T' : T -> eqType) := EqMixin (@dep_arrow_eqP T T').
Definition dep_arrow_eqType  (T : eqType) (T' : T -> eqType) :=
  EqType (forall x : T, T' x) (@dep_arrow_eqMixin T T').
Canonical arrow_eqType (T : eqType) (T' : eqType) :=
  EqType (T -> T') (@dep_arrow_eqMixin T _).

Axiom arrow_choiceMixin : forall T T' : Type, Choice.mixin_of (T -> T').
Canonical arrow_choiceType (T : choiceType) (T' : choiceType) :=
  ChoiceType (T -> T') (@arrow_choiceMixin T T').

Reserved Notation "A `&` B"  (at level 48, left associativity).
Reserved Notation "A `*` B"  (at level 46, left associativity).
Reserved Notation "A `+` B"  (at level 54, left associativity).
Reserved Notation "A +` B"  (at level 54, left associativity).
Reserved Notation "A `|` B" (at level 52, left associativity).
Reserved Notation "a |` A" (at level 52, left associativity).
Reserved Notation "A `\` B" (at level 50, left associativity).
Reserved Notation "A `\ b" (at level 50, left associativity).

Definition set A := A -> Prop.
Definition in_set T (P : set T) : pred T := [pred x | `[<P x>]].
Canonical set_predType T := @mkPredType T (set T) (@in_set T).

Lemma in_setE T (P : set T) x : x \in P = P x :> Prop.
Proof. by rewrite propeqE; split => [] /asboolP. Qed.

Bind Scope classical_set_scope with set.
Local Open Scope classical_set_scope.

Notation "[ 'set' x : T | P ]" := ((fun x => P) : set T)
  (at level 0, x at level 99, only parsing) : classical_set_scope.
Notation "[ 'set' x | P ]" := [set x : _ | P]
  (at level 0, x, P at level 99, format "[ 'set'  x  |  P ]") : classical_set_scope.

Notation "[ 'set' E | x 'in' A ]" := [set y | exists2 x, A x & E = y]
  (at level 0, E, x at level 99,
   format "[ '[hv' 'set'  E '/ '  |  x  'in'  A ] ']'") : classical_set_scope.

Definition image {A B} (f : A -> B) (X : set A) : set B :=
  [set f a | a in X].

Definition preimage {A B} (f : A -> B) (X : set B) : set A := [set a | X (f a)].
Arguments preimage A B f X / a.

Definition setT {A} := [set _ : A | True].
Definition set0 {A} := [set _ : A | False].
Definition set1 {A} (x : A) := [set a : A | a = x].
Definition setI {A} (X Y : set A) := [set a | X a /\ Y a].
Definition setU {A} (X Y : set A) := [set a | X a \/ Y a].
Definition nonempty {A} (X : set A) := exists x, X x.
Definition setC {A} (X : set A) := [set a | ~ X a].
Definition setD {A} (X Y : set A) := [set a | X a /\ ~ Y a].

Notation "[ 'set' a ]" := (set1 a)
  (at level 0, a at level 99, format "[ 'set'  a ]") : classical_set_scope.
Notation "[ 'set' a : T ]" := [set (a : T)]
  (at level 0, a at level 99, format "[ 'set'  a   :  T ]") : classical_set_scope.
Notation "A `|` B" := (setU A B) : classical_set_scope.
Notation "a |` A" := ([set a] `|` A) : classical_set_scope.
Notation "[ 'set' a1 ; a2 ; .. ; an ]" := (setU .. (a1 |` [set a2]) .. [set an])
  (at level 0, a1 at level 99,
   format "[ 'set'  a1 ;  a2 ;  .. ;  an ]") : classical_set_scope.
Notation "A `&` B" := (setI A B) : classical_set_scope.
Notation "~` A" := (setC A) (at level 35, right associativity) : classical_set_scope.
Notation "[ 'set' ~ a ]" := (~` [set a])
  (at level 0, format "[ 'set' ~  a ]") : classical_set_scope.
Notation "A `\` B" := (setD A B) : classical_set_scope.
Notation "A `\ a" := (A `\` [set a]) : classical_set_scope.

Definition bigsetI A I (P : set I) (X : I -> set A) :=
  [set a | forall i, P i -> X i a].
Definition bigsetU A I (P : set I) (X : I -> set A) :=
  [set a | exists2 i, P i & X i a].

Notation "\bigcup_ ( i 'in' P ) F" :=
  (bigsetU P (fun i => F))
  (at level 41, F at level 41, i, P at level 50,
           format "'[' \bigcup_ ( i  'in'  P ) '/  '  F ']'")
 : classical_set_scope.
Notation "\bigcup_ ( i : T ) F" :=
  (\bigcup_(i in @setT T) F)
  (at level 41, F at level 41, i at level 50,
           format "'[' \bigcup_ ( i  :  T ) '/  '  F ']'")
 : classical_set_scope.
Notation "\bigcup_ i F" :=
  (\bigcup_(i : _) F)
  (at level 41, F at level 41, i at level 0,
           format "'[' \bigcup_ i '/  '  F ']'")
 : classical_set_scope.

Notation "\bigcap_ ( i 'in' P ) F" :=
  (bigsetI P (fun i => F))
  (at level 41, F at level 41, i, P at level 50,
           format "'[' \bigcap_ ( i  'in'  P ) '/  '  F ']'")
 : classical_set_scope.
Notation "\bigcap_ ( i : T ) F" :=
  (\bigcap_(i in @setT T) F)
  (at level 41, F at level 41, i at level 50,
           format "'[' \bigcap_ ( i  :  T ) '/  '  F ']'")
 : classical_set_scope.
Notation "\bigcap_ i F" :=
  (\bigcap_(i : _) F)
  (at level 41, F at level 41, i at level 0,
           format "'[' \bigcap_ i '/  '  F ']'")
 : classical_set_scope.

Definition subset {A} (X Y : set A) := forall a, X a -> Y a.

Notation "A `<=` B" := (subset A B) (at level 70, no associativity)
 : classical_set_scope.
Notation "f @^-1` A" := (preimage f A) (at level 24) : classical_set_scope.
Notation "f @` A" := (image f A) (at level 24) : classical_set_scope.
Notation "A !=set0" := (nonempty A) (at level 80) : classical_set_scope.

Lemma imageP {A B} (f : A -> B) (X : set A) a : X a -> (f @` X) (f a).
Proof. by exists a. Qed.

Lemma sub_image_setI {A B} (f : A -> B) (X Y : set A) :
  f @` (X `&` Y) `<=` f @` X `&` f @` Y.
Proof. by move=> b [x [Xa Ya <-]]; split; apply: imageP. Qed.
Arguments sub_image_setI {A B f X Y} a _.

Lemma nonempty_image {A B} (f : A -> B) (X : set A) :
  f @` X !=set0 -> X !=set0.
Proof. by case=> b [a]; exists a. Qed.

Lemma nonempty_preimage {A B} (f : A -> B) (X : set B) :
  f @^-1` X !=set0 -> X !=set0.
Proof. by case=> [a ?]; exists (f a). Qed.

Lemma subset_empty {A} (X Y : set A) : X `<=` Y -> X !=set0 -> Y !=set0.
Proof. by move=> sXY [x Xx]; exists x; apply: sXY. Qed.

Lemma subset_trans {A} (Y X Z : set A) : X `<=` Y -> Y `<=` Z -> X `<=` Z.
Proof. by move=> sXY sYZ ? ?; apply/sYZ/sXY. Qed.

Lemma nonempty_preimage_setI {A B} (f : A -> B) (X Y : set B) :
  (f @^-1` (X `&` Y)) !=set0 <-> (f @^-1` X `&` f @^-1` Y) !=set0.
Proof. by split; case=> x ?; exists x. Qed.

Lemma subsetC {A} (X Y : set A) : X `<=` Y -> ~` Y `<=` ~` X.
Proof. by move=> sXY ? nYa ?; apply/nYa/sXY. Qed.

Lemma subsetU {A} (X Y Z : set A) : X `<=` Z -> Y `<=` Z -> X `|` Y `<=` Z.
Proof. by move=> sXZ sYZ a; apply: or_ind; [apply: sXZ|apply: sYZ]. Qed.

Lemma setDE {A} (X Y : set A) : X `\` Y = X `&` ~` Y.
Proof. by []. Qed.

Definition is_prop {A} (X : set A) := forall x y, X x -> X y -> x = y.
Definition is_fun {A B} (f : A -> B -> Prop) := all (is_prop \o f).
Definition is_total {A B} (f : A -> B -> Prop) := all (nonempty \o f).
Definition is_totalfun {A B} (f : A -> B -> Prop) :=
  forall x, nonempty (f x) /\ is_prop (f x).

Definition xget {T : choiceType} x0 (P : set T) : T :=
  if pselect (exists x : T, `[<P x>]) isn't left exP then x0
  else projT1 (sigW exP).

Lemma xgetPex {T : choiceType} x0 (P : set T) : (exists x, P x) -> P (xget x0 P).
Proof.
rewrite /xget; case: pselect => [|nexP [x Px]]; last first.
  by exfalso; apply: nexP; exists x; apply/asboolP.
by move=> p; case: sigW=> {p} /= x /asboolP.
Qed.

Lemma xgetP {T : choiceType} x0 (P : set T) (x : T): P x -> P (xget x0 P).
Proof. by move=> Px; apply: xgetPex; exists x. Qed.

Lemma xget_prop {T : choiceType} x0 (P : set T) (x : T) :
  P x -> is_prop P -> xget x0 P = x.
Proof. by move=> Px /(_ _ _ (xgetP x0 Px) Px). Qed.

Lemma xget_unique  {T : choiceType} x0 (P : set T) (x : T) :
  P x -> (forall y, P y -> y = x) -> xget x0 P = x.
Proof. by move=> /xget_prop gPx eqx; apply: gPx=> y z /eqx-> /eqx. Qed.

Lemma xgetPN {T : choiceType} x0 (P : set T) : (forall x, ~ P x) -> xget x0 P = x0.
Proof.
rewrite /xget; case: pselect => //= - [x p /(_ x)].
by have /asboolP q := p => /(_ q).
Qed.

Definition fun_of_rel {A} {B : choiceType} (f0 : A -> B) (f : A -> B -> Prop) :=
  fun x => xget (f0 x) (f x).

Lemma fun_of_relP {A} {B : choiceType} (f : A -> B -> Prop) (f0 : A -> B) a :
  nonempty (f a) ->  f a (fun_of_rel f0 f a).
Proof. by move=> [b fab]; rewrite /fun_of_rel; apply: xgetP fab. Qed.

Lemma fun_of_rel_uniq {A} {B : choiceType} (f : A -> B -> Prop) (f0 : A -> B) a :
  is_prop (f a) -> forall b, f a b ->  fun_of_rel f0 f a = b.
Proof. by move=> fa_prop b /xget_prop xgeteq; rewrite /fun_of_rel xgeteq. Qed.

(* Index the filter (2nd proj) on a term (1st proj) *)
Structure canonical_filter_on X Y := CanonicalFilterOn {
  canonical_filter_term : X;
  _ : set (set Y)
}.
(* Defining the 2nd proj, not named before to prevent Warnings *)
(* when adding a canonical instance of canonical_filter_on *)
Definition canonical_term_filter {X Y} (F : canonical_filter_on X Y) :=
  let: CanonicalFilterOn x f := F in f.
(* Coercion canonical_term_filter : canonical_filter_on >-> set. *)
(* Identity Coercion set >-> Funclass. *)

(* Index a family of filters on a type, one for each element of the type *)
Structure canonical_filter Y := CanonicalFilter {
  canonical_filter_type :> Type;
  _ : canonical_filter_type -> set (set Y)
}.
(* Naming the second proj *)
Definition canonical_type_filter {Y} {F : canonical_filter Y} :
  F -> set (set Y) :=
  let: CanonicalFilter X f := F in f.

(* The default filter for an arbitrary element is the one obtained *)
(* from its type *)
Canonical default_filter_term Y (X : canonical_filter Y) (x : X) :=
  @CanonicalFilterOn X Y x (canonical_type_filter x).

(* filter on arrow sources *)
Structure canonical_filter_source Z Y := CanonicalFilterSource {
  canonical_filter_source_type :> Type;
  _ : (canonical_filter_source_type -> Z) -> set (set Y)
}.
Definition canonical_source_filter Z Y (F : canonical_filter_source Z Y) :
  (F -> Z) -> set (set Y) :=
  let: CanonicalFilterSource X f := F in f.

Canonical default_arrow_filter Y Z (X : canonical_filter_source Z Y) :=
  @CanonicalFilter _ (X -> Z) (@canonical_source_filter _ _ X).

Canonical source_filter_filter Y :=
  @CanonicalFilterSource Prop _ (_ -> Prop) (fun x : (set (set Y)) => x).
Canonical source_filter_filter' Y :=
  @CanonicalFilterSource Prop _ (set _) (fun x : (set (set Y)) => x).

Definition filter_of X Y (F : canonical_filter_on X Y)
  (x : X) (_ : x = canonical_filter_term F) :=
  canonical_term_filter F.

Notation "[ 'filter' 'of' x ]" := (@filter_of _ _ _ x erefl)
  (format "[ 'filter'  'of'  x ]").
Arguments filter_of _ _ _ _ _ _ /.

Lemma filter_of_filterE T (F : set (set T)) : [filter of F] = F.
Proof. by []. Qed.

Lemma filter_of_genericE X T (F : canonical_filter_on X T) :
  [filter of canonical_filter_term F] = canonical_term_filter F.
Proof. by []. Qed.

Definition filter_ofE := (filter_of_filterE, filter_of_genericE).

Section Near.

Local Notation "{ 'all1' P }" := (forall x, P x : Prop) (at level 0).
Local Notation "{ 'all2' P }" := (forall x y, P x y : Prop) (at level 0).
Local Notation "{ 'all3' P }" := (forall x y z, P x y z: Prop) (at level 0).
Local Notation ph := (phantom _).

Definition prop_near1 {X Y} (F : canonical_filter_on X Y) (x : X)
  (_ : x = canonical_filter_term F) P & ph {all1 P} :=
  (canonical_term_filter F) P.

Definition prop_near2 {X X' Y Y'} :=
 fun (F : canonical_filter_on X Y) (x : X) of x = canonical_filter_term F =>
 fun (F' : canonical_filter_on X' Y') (x' : X')
     of x' = canonical_filter_term F' =>
  fun P of ph {all2 P} =>
  (canonical_term_filter F) (fun x => canonical_term_filter F' (P x)).

End Near.

Notation "{ 'near' x , P }" :=
  (@prop_near1 _ _ _ x erefl _ (inPhantom P))
  (at level 0, format "{ 'near'  x ,  P }") : type_scope.
Notation "{ 'near' x & y , P }" :=
  (@prop_near2 _ _ _ _ _ x erefl _ y erefl _ (inPhantom P))
  (at level 0, format "{ 'near'  x  &  y ,  P }") : type_scope.

(** * Filters *)

(** ** Definitions *)

Class Filter {T : Type} (F : set (set T)) := {
  filter_true : F setT ;
  filter_and : forall P Q : set T, F P -> F Q -> F (P `&` Q) ;
  filter_imp : forall P Q : set T, P `<=` Q -> F P -> F Q
}.
Global Hint Mode Filter - ! : typeclass_instances.

Class ProperFilter' {T : Type} (F : set (set T)) := {
  filter_not_empty : not (F (fun _ => False)) ;
  filter_filter' :> Filter F
}.
Global Hint Mode ProperFilter' - ! : typeclass_instances.
Arguments filter_not_empty {T} F {_}.

Notation ProperFilter := ProperFilter'.

Lemma filter_not_empty_ex {T : Type} (F : set (set T)) :
    (forall P, F P -> exists x, P x) -> ~ F set0.
Proof. by move=> /(_ set0) ex /ex []. Qed.

Definition Build_ProperFilter {T : Type} (F : set (set T))
  (filter_ex : forall P, F P -> exists x, P x)
  (filter_filter : Filter F) :=
  Build_ProperFilter' (filter_not_empty_ex filter_ex) (filter_filter).

Lemma filter_ex_subproof {T : Type} (F : set (set T)) :
     ~ F set0 -> (forall P, F P -> exists x, P x).
Proof.
move=> NFset0 P FP; apply: contrapNT NFset0 => nex; suff <- : P = set0 by [].
by rewrite funeqE => x; rewrite propeqE; split=> // Px; apply: nex; exists x.
Qed.

Definition filter_ex {T : Type} (F : set (set T)) {FF : ProperFilter F} :=
  filter_ex_subproof (filter_not_empty F).
Arguments filter_ex {T F FF _}.

Lemma filterP T (F : set (set T)) {FF : Filter F} (P : set T) :
  (exists2 Q : set T, F Q & forall x : T, Q x -> P x) <-> F P.
Proof.
split; last by exists P.
by move=> [Q FQ QP]; apply: (filter_imp QP).
Qed.

Definition extensible_property T (x : T) (P : Prop) := P.
Lemma extensible_propertyI T (x : T) (P : Prop) :
  P -> extensible_property x P.
Proof. by []. Qed.

Fact near_lock : unit. Proof. exact: tt. Qed.
Definition near {T} (F : set (set T)) (x : T) := locked_with near_lock True.
Lemma solve_near {T} F (x : T) : near F x.
Proof. by rewrite /near; case: near_lock. Qed.

Ltac near x :=
  let T := fresh "filter_type" in
  let F := fresh "filter_near" in
  let R := fresh "arround" in
  let FR := fresh "arroundP" in
  let Hx := fresh "Hx" in
  evar (T : Type);
  evar (F : set (set T));
  apply/(@filterP _ F);
  match goal with |- exists2 Q : set ?T, ?F Q & _ =>
                  evar (R : set T); evar (FR : F R);
                  exists R; [exact: FR|];
  move=> x /(extensible_propertyI x) ?; suff ? : near F x
  end.

Ltac have_near x FP :=
  match goal with _ : near ?F x |- _ =>
  match goal with U : F ?R  |- _ =>
  match goal with Rx : extensible_property x _  |- _ =>
    instantiate (1 := filter_and _ FP) in (Value of U);
    case: Rx => [/(extensible_propertyI x) Rx]
  end end end.

Ltac end_near :=
  match goal with |- @near _ ?F ?x =>
  match goal with U : F ?R  |- _ =>
   match goal with Rx : extensible_property x _ |- _ =>
    instantiate (1 := filter_true) in (Value of U);
    exact: solve_near
  end
  end
  end.

Lemma filter_forall {T : Type} {F} {FF: @Filter T F} (P : T -> Prop) :
  (forall x, P x) -> F P.
Proof. by move=> ?; apply/filterP; exists setT => //; apply: filter_true. Qed.

Lemma filter_bind (T : Type) (F : set (set T)) :
  Filter F -> forall P Q : set T, {near F, P `<=` Q} -> F P -> F Q.
Proof.
move=> FF P Q subPQ FP; near x.
  by have_near x subPQ; apply; have_near x FP.
by end_near.
Qed.

Lemma filter_bind2 (T : Type) (F : set (set T)) :
  Filter F -> forall P Q R : set T, {near F, forall x, P x -> Q x -> R x} ->
  F P -> F Q -> F R.
Proof. by move=> ???? PQR FP; apply: filter_bind; apply: filter_bind FP. Qed.

Lemma filter_const {T : Type} {F} {FF: @ProperFilter T F} (P : Prop) :
  F (fun=> P) -> P.
Proof. by move=> FP; case: (filter_ex FP). Qed.

Definition filter_from {I T : Type} (B : I -> set T) : set (set T) :=
  [set P | exists i, B i `<=` P].

Lemma in_filter_from {I T : Type} (B : I -> set T) (i : I) : 
   filter_from B (B i).
Proof. by exists i. Qed.

Definition flim {T : Type} (F G : set (set T)) := G `<=` F.
Definition filter_le {T} := @flim T. (*compat*)
Notation "F `=>` G" := (flim F G)
  (at level 70, format "F  `=>`  G") : classical_set_scope.

Lemma flim_refl T (F : set (set T)) : F `=>` F.
Proof. exact. Qed.

Lemma flim_trans T (F G H : set (set T)) :
  (F `=>` G) -> (G `=>` H) -> (F `=>` H).
Proof. by move=> FG GH P /GH /FG. Qed.

Lemma filter_fromP {I T : Type} (B : I -> set T) (F : set (set T)) :
  Filter F ->
  F `=>` filter_from B <-> forall i, F (B i).
Proof.
split; first by move=> FB i; apply/FB/in_filter_from.
by move=> FB P [i BjP]; apply: (filter_imp BjP).
Qed.

Lemma filter_from_filter  {I T : Type} (B : I -> set T) :
  (exists _ : I, True) -> (forall i j, exists k, B k `<=` B i `&` B j) ->
  Filter (filter_from B).
Proof.
move=> [i0 _] Binter; constructor.
- by exists i0.
- move=> P Q [i BiP] [j BjQ]; have [k BkPQ]:= Binter i j.
  by exists k => x /BkPQ [/BiP ? /BjQ].
- by move=> P Q subPQ [i BiP]; exists i; apply: subset_trans subPQ.
Qed.

(** ** Limits expressed with filters *)

Notation "F --> G" := (flim [filter of F] [filter of G])
  (at level 70, format "F  -->  G") : classical_set_scope.

Lemma filter_le_refl T (F : set (set T)) : F --> F. (*compat*)
Proof. exact. Qed.

Lemma filter_le_trans T (F G H : set (set T)) : (*compat*)
  (F --> G) -> (G --> H) -> (F --> H).
Proof. exact: flim_trans. Qed.

Definition filtermap {T U : Type} (f : T -> U) (F : set (set T)) :=
  [set P | F (f @^-1` P)].
Arguments filtermap _ _ _ _ _ /.

Lemma filtermapE {U V : Type} (f : U -> V)
  (F : set (set U)) (P : set V) : filtermap f F P = F (f @^-1` P).
Proof. by []. Qed.

Notation "E @[ x --> F ]" := (filtermap (fun x => E) [filter of F])
  (at level 60, x ident, format "E  @[ x  -->  F ]") : classical_set_scope.
Notation "f @ F" := (filtermap f [filter of F])
  (at level 60, format "f  @  F") : classical_set_scope.

Global Instance filtermap_filter T U (f : T -> U) (F : set (set T)) :
  Filter F -> Filter (f @ F).
Proof.
move=> FF; constructor => [|P Q|P Q PQ]; rewrite ?filtermapE ?filter_ofE //=.
- exact: filter_true.
- exact: filter_and.
- by apply: filter_imp=> ?/PQ.
Qed.

Global Instance filtermap_proper_filter T U (f : T -> U) (F : set (set T)) :
  ProperFilter F -> ProperFilter (f @ F).
Proof.
move=> FF; apply: Build_ProperFilter';
by rewrite filtermapE; apply: filter_not_empty.
Qed.
Definition filtermap_proper_filter' := filtermap_proper_filter.

Definition filtermapi {T U : Type} (f : T -> set U) (F : set (set T)) :=
  [set P | {near F, forall x, exists y, f x y /\ P y}].

Notation "E `@[ x --> F ]" := (filtermapi (fun x => E) [filter of F])
  (at level 60, x ident, format "E  `@[ x  -->  F ]") : classical_set_scope.
Notation "f `@ F" := (filtermapi f [filter of F])
  (at level 60, format "f  `@  F") : classical_set_scope.

Lemma filtermapiE {U V : Type} (f : U -> set V)
  (F : set (set U)) (P : set V) :
  filtermapi f F P = {near F, forall x, exists y, f x y /\ P y}.
Proof. by []. Qed.

Global Instance filtermapi_filter T U (f : T -> U -> Prop) (F : set (set T)) :
  infer {near F, is_totalfun f} -> Filter F -> Filter (f `@ F).
Proof.
move=> f_totalfun FF; rewrite /filtermapi; apply: Build_Filter. (* bug *)
- by apply: filter_imp f_totalfun => x [[y Hy] H]; exists y.
- move=> P Q FP FQ; near x.
    have_near x FP => -[y [fxy Py]].
    have_near x FQ => -[z [fxz Qy]].
    have_near x f_totalfun => -[_ fx_prop].
    by exists y; split => //; split => //; rewrite [y](fx_prop _ z).
  end_near.
- move=> P Q subPQ FP; near x.
    by have_near x FP => -[y [fxy /subPQ]]; exists y.
  by end_near.
Qed.

Global Instance filtermapi_proper_filter
  T U (f : T -> U -> Prop) (F : set (set T)) :
  infer {near F, is_totalfun f} ->
  ProperFilter F -> ProperFilter (f `@ F).
Proof.
move=> f_totalfun FF; apply: Build_ProperFilter.
by move=> P; rewrite /filtermapi => /filter_ex [x [y [??]]]; exists y.
Qed.
Definition filter_map_proper_filter' := filtermapi_proper_filter.

Lemma flim_id T (F : set (set T)) : x @[x --> F] --> F.
Proof. exact. Qed.
Lemma filterlim_id T (F : set (set T)) : x @[x --> F] --> F. (*compat*)
Proof. exact. Qed.

Lemma appfilter U V (f : U -> V) (F : set (set U)) :
  f @ F = [set P : _ -> Prop | {near F, forall x, P (f x)}].
Proof. by []. Qed.

Lemma flim_app U V (F G : set (set U)) (f : U -> V) :
  F --> G -> f @ F --> f @ G.
Proof. by move=> FG P /=; exact: FG. Qed.
Lemma filterlim_app U V (F G : set (set U)) (f : U -> V) : (*compat*)
  F --> G -> f @ F --> f @ G.
Proof. by move=> FG P /=; exact: FG. Qed.

Lemma filter_comp T U V (f : T -> U) (g : U -> V) (F : set (set T)) : (*compat*)
  g \o f @ F = g @ (f @ F).
Proof. by []. Qed.

Lemma flim_comp T U V (f : T -> U) (g : U -> V)
  (F : set (set T)) (G : set (set U)) (H : set (set V)) :
  f @ F `=>` G -> g @ G `=>` H -> g \o f @ F `=>` H.
Proof.
move=> fFG gGH; apply: filter_le_trans gGH.
by rewrite filter_comp; apply: filterlim_app.
Qed.

Lemma filterlim_comp T U V (f : T -> U) (g : U -> V)
  (F : set (set T)) (G : set (set U)) (H : set (set V)) : (*compat*)
  f @ F `=>` G -> g @ G `=>` H -> g \o f @ F `=>` H.
Proof. exact: flim_comp. Qed.

Lemma flim_eq_loc {T U} {F : set (set T)}
  {FF : Filter F} (f g : T -> U) :
  {near F, f =1 g} -> g @ F `=>` f @ F.
Proof.
move=> eq_fg P /= FP.
  near x; first by have_near x eq_fg => <-; have_near x FP => Pgx.
by end_near.
Qed.
Lemma filterlim_eq_loc {T U} {F : set (set T)}
  {FF : Filter F} (f g : T -> U) : (*compat*)
  {near F, f =1 g} -> g @ F `=>` f @ F.
Proof. exact: flim_eq_loc. Qed.

Lemma filterlim_ext_loc {T U} {F : set (set T)} {G : set (set U)}
  {FF : Filter F} (f g : T -> U) : (*compat*)
  {near F, f =1 g} -> f @ F `=>` G -> g @ F `=>` G.
Proof.
by move=> eq_fg; apply: filter_le_trans; apply: filterlim_eq_loc.
Qed.

Lemma filterlim_ext {T U} {F : set (set T)} {G : set (set U)}
  {FF : Filter F} (f g : T -> U) : (*compat*)
  (forall x, f x = g x) -> f @ F --> G -> g @ F --> G.
Proof. by move=> /(@filter_forall _ F) => eq_fg; apply: filterlim_ext_loc. Qed.

Lemma filterlim_trans {T} {F G H : set (set T)} : F --> G -> G --> H -> F --> H.
Proof. exact: flim_trans. Qed.

Lemma filterlim_filter_le_1 {T U} {F G : set (set T)} {H : set (set U)}
  (f : T -> U) : G --> F -> f @ F --> H -> f @ G --> H. (*compat*)
Proof. by move=> /filterlim_app /filter_le_trans; apply. Qed.

Lemma filterlim_filter_le_2 {T U} {F : set (set T)} {G H : set (set U)}
  (f : T -> U) : G --> H -> f @ F --> G -> f @ F --> H. (*compat*)
Proof. by move=> GH ?; apply: filter_le_trans GH. Qed.

Lemma filterlimi_comp T U V (f : T -> U) (g : U -> set V)
  (F : set (set T)) (G : set (set U)) (H : set (set V)) :
  f @ F --> G -> g `@ G --> H -> g (f x) `@[x --> F] --> H. (*compat*)
Proof.
intros FG GH P HP.
apply (FG (fun x => exists y, g x y /\ P y)).
now apply GH.
Qed.

Lemma filterlimi_ext_loc {T U} {F : set (set T)} {G : set (set U)}
  {FF : Filter F} (f g : T -> set U) :
  {near F, forall x y, f x y <-> g x y} ->
  f `@ F --> G -> g `@ F --> G.
Proof.
intros Efg Lf P GP.
specialize (Lf P GP).
generalize (filter_and Efg Lf).
apply: filter_imp.
intros x [H [y [Hy1 Hy2]]].
exists y.
apply: conj Hy2.
now apply H.
Qed.

Lemma filterlimi_ext  {T U} {F : set (set T)} {G : set (set U)}
  {FF : Filter F} (f g : T -> set U) :
  (forall x y, f x y <-> g x y) ->
  f `@ F --> G -> g `@ F --> G.
Proof.
intros Efg.
apply filterlimi_ext_loc.
exact: filter_forall.
Qed.

Lemma filterlimi_filter_le_1 {T U} {F G : set (set T)} {H : set (set U)}
  (f : T -> set U) : G --> F -> f `@ F --> H -> f `@ G --> H.
Proof.
intros K Hf P HP.
apply K.
now apply Hf.
Qed.

Lemma filterlimi_filter_le_2  {T U} {F : set (set T)} {G H : set (set U)}
  (f : T -> set U) : G --> H -> f `@ F --> G -> f `@ F --> H.
Proof.
intros K Hf P HP.
apply Hf.
now apply K.
Qed.

(** ** Specific filters *)

(** Filters for pairs *)

Definition filter_prod {T U : Type} (F : set (set T)) (G : set (set U)) :
   set (set (T * U)) :=
  [set P : set (T * U) | {near F & G, forall x y, P (x, y)}].
Arguments filter_prod /.
(* Inductive filter_prod {T U : Type} (F G : _ -> Prop) (P : T * U -> Prop) : Prop := *)
(*   Filter_prod (Q : T -> Prop) (R : U -> Prop) : *)
(*     F Q -> G R -> (forall x y, Q x -> R y -> P (x, y)) -> filter_prod F G P. *)

Definition apply_filter_prod {X1 X2 Y1 Y2} (f : Y1 -> set (set X1))
  (g : Y2 -> set (set X2)) (y1 : Y1) (y2 : Y2) : set (set (X1 * X2)) :=
  filter_prod (f y1) (g y2).
Arguments apply_filter_prod /.

Canonical canonical_filter_prod X1 X2 (Z1 : canonical_filter X1)
  (Z2 : canonical_filter X2) : canonical_filter (X1 * X2) :=
  @CanonicalFilter _ _ (fun x => apply_filter_prod
  (@canonical_type_filter _ Z1) (@canonical_type_filter _ Z2) x.1 x.2).

Global Instance filter_prod_filter  T U (F : set (set T)) (G : set (set U)) :
  Filter F -> Filter G -> Filter (filter_prod F G).
Proof.
rewrite /filter_prod => FF FG; constructor.
- by near x; [near y; [|end_near]|end_near].
- move=> P Q; apply: filter_bind2; apply: filter_forall => /= x.
  by apply: filter_bind2; apply: filter_forall.
- by move=> P Q subPQ; apply: filter_imp => x; apply: filter_imp => y /subPQ.
Qed.

Global Instance filter_prod_proper {T1 T2 : Type}
  {F : (T1 -> Prop) -> Prop} {G : (T2 -> Prop) -> Prop}
  {FF : ProperFilter F} {FG : ProperFilter G} :
  ProperFilter (filter_prod F G).
Proof.
apply: Build_ProperFilter'; rewrite /filter_prod=> FGN0.
apply: (filter_not_empty F); apply: filter_imp FGN0 => x.
exact: filter_not_empty.
Qed.
Definition filter_prod_proper' := @filter_prod_proper.

Lemma filterlim_fst {T U F G} {FF : Filter F} {FG : Filter G} :
  (@fst T U) @ filter_prod F G --> F.
Proof.
by move=> P /= FP; apply: filter_imp FP => x /= Px; apply: filter_forall.
Qed.

Lemma filterlim_snd {T U F G} {FF : Filter F} :
  (@snd T U) @ filter_prod F G --> G.
Proof. by move=> P /= FP; apply: filter_forall. Qed.

Lemma filterlim_pair {T U V F} {G : set (set U)} {H : set (set V)}
  {FF : Filter F} {FG : Filter G} {FH : Filter H} (f : T -> U) (g : T -> V) :
  f @ F --> G -> g @ F --> H ->
  (f x, g x) @[x --> F] --> (G, H).
Proof.
move=> fFG gFH P /= GHP.
have /= := fFG _ GHP; apply: filter_imp => /= x HP.
have /= := gFH _ HP. apply: filter_imp.
  

intros Cf Cg P [A B GA HB HP].
unfold filtermap.
apply: (@filter_imp _ _ _ (fun x => A (f x) /\ B (g x))).
intros x [Af Bg].
now apply HP.
apply filter_and.
now apply Cf.
now apply Cg.
Qed.

Lemma filterlim_comp_2 {T U V W}
  {F : set (set T)} {G : set (set U)} {H : set (set V)} {I : set (set W)}
  {FF : Filter F}
  (f : T -> U) (g : T -> V) (h : U -> V -> W) :
  f @ F --> G -> g @ F --> H ->
  h (fst x) (snd x) @[x --> (G, H)] --> I ->
  h (f x) (g x) @[x --> F] --> I.
Proof.
intros Cf Cg Ch.
change (fun x => h (f x) (g x)) with (fun x => h (fst (f x, g x)) (snd (f x, g x))).
apply: filterlim_comp Ch.
now apply filterlim_pair.
Qed.

Lemma filterlimi_comp_2 {T U V W}
  {F : set (set T)} {G : set (set U)} {H : set (set V)} {I : set (set W)}
  {FF : Filter F}
  (f : T -> U) (g : T -> V) (h : U -> V -> set W) :
  f @ F --> G -> g @ F --> H ->
  h (fst x) (snd x) `@[x --> (G, H)] --> I ->
  h (f x) (g x) `@[x --> F] --> I.
Proof.
intros Cf Cg Ch.
change (fun x => h (f x) (g x)) with (fun x => h (fst (f x, g x)) (snd (f x, g x))).
apply: filterlimi_comp Ch.
now apply filterlim_pair.
Qed.

(** Restriction of a filter to a domain *)

Definition within {T : Type} (D : set T) (F : set (set T)) (P : set T) :=
  {near F, D `<=` P}.

Global Instance within_filter T D F : Filter F -> Filter (@within T D F).
Proof.
move=> FF; rewrite /within; constructor.
- by apply: filter_forall.
- move=> P Q FP; apply: filter_bind; apply: filter_bind FP.
  by apply: filter_forall => x DP DQ Dx; split; [apply: DP|apply: DQ].
- move=> P Q subPQ; apply: filter_bind; apply: filter_forall.
  by move=> x DP /DP /subPQ.
Qed.

Lemma filter_le_within {T} {F : set (set T)} {FF : Filter F} D :
  within D F --> F.
Proof. by move=> P; apply: filter_imp. Qed.

Lemma filterlim_within_ext {T U F} {G : set (set U)}
  {FF : Filter F} (D : set T) (f g : T -> U) :
  (forall x, D x -> f x = g x) ->
  f @ within D F --> G ->
  g @ within D F --> G.
Proof.
move=> eq_fg; apply: filter_le_trans; apply: filterlim_eq_loc.
by rewrite /within /=; apply: filter_forall.
Qed.

Definition subset_filter {T} (F : set (set T))
  (dom : T -> Prop) (P : {x|dom x} -> Prop) : Prop :=
  F [set x | forall H : dom x, P (exist _ x H)].
Arguments subset_filter {T} F dom _.

Global Instance subset_filter_filter T F (dom : T -> Prop) :
  Filter F -> Filter (subset_filter F dom).
Proof.
move=> FF.
constructor ; unfold subset_filter.
- now apply filter_imp with (2 := filter_true).
- intros P Q HP HQ.
  generalize (filter_and HP HQ).
  apply filter_imp.
  intros x [H1 H2] H.
  now split.
- intros P Q H.
  apply filter_imp.
  intros x H' H0.
  now apply H.
Qed.

Lemma subset_filter_proper {T F} {FF : Filter F} (dom : T -> Prop) :
  (forall P, F P -> ~ ~ exists x, dom x /\ P x) ->
  ProperFilter (subset_filter F dom).
Proof.
move=> domAP; apply: Build_ProperFilter'; rewrite /subset_filter => subF_dom.
by have /(_ subF_dom) := domAP (~` dom); apply => -[x [dx /(_ dx)]].
Qed.
Definition subset_filter_proper' := @subset_filter_proper.

(** * Uniform spaces defined using balls *)

Module Uniform.

Record mixin_of (M : Type) := Mixin {
  point : M ;
  ball : M -> R -> M -> Prop ;
  ax1 : forall x (e : posreal), ball x e x ;
  ax2 : forall x y (e : R), ball x e y -> ball y e x ;
  ax3 : forall x y z e1 e2, ball x e1 y -> ball y e2 z -> ball x (e1 + e2) z
}.

Record class_of (M : Type) := Class {
  base : Choice.class_of M;
  mixin : mixin_of M
}.

Section ClassDef.

Structure type := Pack { sort; _ : class_of sort ; _ : Type }.
Local Coercion sort : type >-> Sortclass.
Variables (T : Type) (cT : type).
Definition class := let: Pack _ c _ := cT return class_of cT in c.

Definition clone c of phant_id class c := @Pack T c T.
Let xT := let: Pack T _ _ := cT in T.
Notation xclass := (class : class_of xT).
Local Coercion base : class_of >-> Choice.class_of.
Local Coercion mixin : class_of >-> mixin_of.

Definition pack m :=
  fun bT b of phant_id (Choice.class bT) b => @Pack T (Class b m) T.

Definition eqType := @Equality.Pack cT xclass xT.
Definition choiceType := @Choice.Pack cT xclass xT.

End ClassDef.

Module Exports.

Coercion sort : type >-> Sortclass.
Coercion base : class_of >-> Choice.class_of.
Coercion mixin : class_of >-> mixin_of.
Coercion eqType : type >-> Equality.type.
Canonical eqType.
Coercion choiceType : type >-> Choice.type.
Canonical choiceType.
Notation uniformType := type.
Notation UniformType T m := (@pack T m _ _ idfun).
Notation UniformMixin := Mixin.
Notation "[ 'uniformType' 'of' T 'for' cT ]" :=  (@clone T cT _ idfun)
  (at level 0, format "[ 'uniformType'  'of'  T  'for'  cT ]") : form_scope.
Notation "[ 'uniformType' 'of' T ]" := (@clone T _ _ id)
  (at level 0, format "[ 'uniformType'  'of'  T ]") : form_scope.

End Exports.

End Uniform.

Export Uniform.Exports.

Definition point {M : uniformType} := Uniform.point (Uniform.class M).
Definition ball {M : uniformType} := Uniform.ball (Uniform.class M).
Definition locally {M : uniformType} (x : M) : set (set M) :=
  @filter_from posreal _ (ball x).
Definition uniformType_is_canonical_filter {M : uniformType} :=
   @CanonicalFilter M M locally.
Coercion uniformType_is_canonical_filter : uniformType >-> canonical_filter.
Canonical uniformType_is_canonical_filter.

Section UniformGet.

Context {T : uniformType}.
(* move to boolP *)
Definition get : set T -> T := xget point.

Lemma getPex (P : set T) : (exists x, P x) -> P (get P).
Proof. exact: (xgetPex point). Qed.

Lemma getP (P : set T) (x : T): P x -> P (get P).
Proof. exact: (xgetP point). Qed.

Lemma get_prop (P : set T) (x : T) : P x -> is_prop P -> get P = x.
Proof. exact: (xget_prop point). Qed.

Lemma get_unique (P : set T) (x : T) :
   P x -> (forall y, P y -> y = x) -> get P = x.
Proof. exact: (xget_unique point). Qed.
Definition iota_unique := @get_unique.

Lemma getPN (P : set T) : (forall x, ~ P x) -> get P = point.
Proof. exact: (xgetPN point). Qed.

Definition lim (F : set (set T)) : T := get [set x | F --> x].

(* Definition lim_in {M : uniformType} (F : set (set M)) T : T := *)
(*    get (fun x : T => F --> x). *)
(* Notation "[ 'lim' F 'in' T ]" := (lim_in F T). *)
(* Definition type_of_filter {M : uniformType} (F : set (set M)) := M. *)
(* Notation lim F := [lim F in type_of_filter F]. *)

End UniformGet.

(* Unique Choice for compatilibility reasons *)
Notation iota := get.

Section uniformType1.
Context {M : uniformType}.

Lemma ball_center (x : M) (e : posreal) : ball x e x.
Proof. exact: Uniform.ax1. Qed.
Hint Resolve ball_center.

Lemma ballxx (x : M) (e : R) : (0 < e)%R -> ball x e x.
Proof. by move=> e_gt0; apply: ball_center (PosReal e_gt0). Qed.

Lemma ball_sym (x y : M) (e : R) : ball x e y -> ball y e x.
Proof. exact: Uniform.ax2. Qed.

Lemma ball_triangle (x y z : M) (e1 e2 : R) :
  ball x e1 y -> ball y e2 z -> ball x (e1 + e2) z.
Proof. exact: Uniform.ax3. Qed.

Lemma ball_split (z x y : M) (e : R) :
  ball x (e / 2) z -> ball z (e / 2) y -> ball x e y.
Proof. by move=> /ball_triangle h /h; rewrite -double_var. Qed.

Lemma ball_splitr (z x y : M) (e : R) :
  ball z (e / 2) x -> ball z (e / 2) y -> ball x e y.
Proof. by move=> /ball_sym /ball_split; apply. Qed.

Lemma ball_splitl (z x y : M) (e : R) :
  ball x (e / 2) z -> ball y (e / 2) z -> ball x e y.
Proof. by move=> bxz /ball_sym /(ball_split bxz). Qed.

Lemma ball_ler (x : M) (e1 e2 : R) : e1 <= e2 -> ball x e1 `<=` ball x e2.
Proof.
move=> le12 y; case: ltrgtP le12 => [//|lte12 _|->//].
by rewrite -[e2](subrK e1); apply/ball_triangle/ballxx; rewrite subr_gt0.
Qed.

Lemma ball_le (x : M) (e1 e2 : R) :
  (e1 <= e2)%coqR -> ball x e1 `<=` ball x e2.
Proof. by move=> /RleP/ball_ler. Qed.

Definition close (x y : M) : Prop := forall eps : posreal, ball x eps y.

Lemma close_refl (x : M) : close x x. Proof. by []. Qed.

Lemma close_sym (x y : M) : close x y -> close y x.
Proof. by move=> ??; apply: ball_sym. Qed.

Lemma close_trans (x y z : M) : close x y -> close y z -> close x z.
Proof. by move=> ?? eps; apply: ball_split. Qed.

Lemma close_limxx (x y : M) : close x y -> x --> y.
Proof.
move=> cxy P /= [eps epsP]; exists [posreal of eps / 2] => z bxz.
by apply: epsP; apply: ball_splitr (cxy _) bxz.
Qed.

End uniformType1.

Hint Resolve ball_center.
Hint Resolve close_refl.

(** ** Specific uniform spaces *)

(** Rings with absolute value *)


Section prod_Uniform.

Context {U V : uniformType}.
Implicit Types (x y : U * V).

Definition prod_point : U * V := (point, point).

Definition prod_ball x (eps : R) y :=
  ball (fst x) eps (fst y) /\ ball (snd x) eps (snd y).

Lemma prod_ball_center x (eps : posreal) : prod_ball x eps x.
Proof. by split. Qed.

Lemma prod_ball_sym x y (eps : R) : prod_ball x eps y -> prod_ball y eps x.
Proof. by move=> [bxy1 bxy2]; split; apply: ball_sym. Qed.

Lemma prod_ball_triangle x y z (e1 e2 : R) :
  prod_ball x e1 y -> prod_ball y e2 z -> prod_ball x (e1 + e2) z.
Proof.
by move=> [bxy1 bxy2] [byz1 byz2]; split; eapply ball_triangle; eassumption.
Qed.

End prod_Uniform.

Definition prod_uniformType_mixin (U V : uniformType) :=
  @Uniform.Mixin (U * V) prod_point _ prod_ball_center prod_ball_sym prod_ball_triangle.

Canonical prod_uniformType (U V : uniformType) :=
  UniformType (U * V) (prod_uniformType_mixin U V).

(** Functional metric spaces *)

Section fct_Uniform.

Variable (T : choiceType) (U : uniformType).

Definition fct_point : T -> U := fun=> point.

Definition fct_ball (x : T -> U) (eps : R) (y : T -> U) :=
  forall t : T, ball (x t) eps (y t).

Lemma fct_ball_center :
  forall (x : T -> U) (e : posreal),
  fct_ball x e x.
Proof.
  intros x e t.
  exact: ball_center.
Qed.

Lemma fct_ball_sym :
  forall (x y : T -> U) (e : R),
  fct_ball x e y -> fct_ball y e x.
Proof.
  intros x y e H t.
  exact: ball_sym.
Qed.

Lemma fct_ball_triangle :
  forall (x y z : T -> U) (e1 e2 : R),
  fct_ball x e1 y -> fct_ball y e2 z -> fct_ball x (e1 + e2) z.
Proof.
  intros x y z e1 e2 H1 H2 t.
  now apply ball_triangle with (y t).
Qed.

Definition fct_uniformType_mixin :=
  @Uniform.Mixin _ fct_point _ fct_ball_center fct_ball_sym fct_ball_triangle.

Canonical fct_uniformType := UniformType (T -> U) fct_uniformType_mixin.
Canonical generic_source_filter := @CanonicalFilterSource _ _ _ locally.

End fct_Uniform.

(** ** Local predicates *)
(** locally_dist *)

Definition locally_dist {T : Type} (d : T -> R) :=
  filter_from (fun delta : posreal => [set y | (d y < delta)%R]).

Global Instance locally_dist_filter T (d : T -> R) : Filter (locally_dist d).
Proof.
apply: filter_from_filter; first by exists [posreal of 1].
move=> e1 e2; exists [posreal of minr (e1 : R) (e2 : R)].
by move=> P /=; rewrite ltr_minr => /andP [dPe1 dPe2].
Qed.

(** locally *)

(*Require Import FunctionalExtensionality.
Notation funext := functional_extensionality.*)

Section LocallyDef.

Context {T : uniformType}.
Implicit Types x y : T.

Global Instance locally_filter (x : T) : ProperFilter (locally x).
Proof.
constructor => [[eps /(_ _ (ball_center _ _))] //|].
apply: filter_from_filter; first by exists [posreal of 1].
move=> e1 e2; exists [posreal of minr (e1 : R) (e2 : R)].
by move=> P /= xP; split; apply: ball_ler xP; rewrite ler_minl lerr ?orbT.
Qed.

End LocallyDef.

(*compat*)
Lemma ProperFilter_ext {T} (F G : set (set T)) : (forall P, F P <-> G P) ->
  ProperFilter F -> ProperFilter G.
Proof.
move=> FG; suff <- : F = G by [].
by rewrite funeqE => P; rewrite propeqE.
Qed.

Section Locally.
Context {T : uniformType}.

Typeclasses Transparent filter_of.

Lemma locally_locally (x : T) (P : T -> Prop) :
  locally x P -> locally x (locally^~ P).
Proof.
move=> [dp Hp].
exists [posreal of dp / 2] => y xy.
exists [posreal of dp / 2] => z yz.
by apply: Hp; apply: ball_split yz.
Qed.

Lemma locally_singleton (x : T) (P : T -> Prop) : locally x P -> P x.
Proof. move=> [dp H]; by apply/H/ball_center. Qed.

Lemma locally_ball (x : T) (eps : posreal) : locally x (ball x eps).
Proof. by exists eps. Qed.

Lemma locally_not' : (* useless *)
  forall (x : T) (P : T -> Prop),
  not (forall eps : posreal, not (forall y, ball x eps y -> not (P y))) ->
  {d : posreal | forall y, ball x d y -> not (P y)}.
Proof.
intros x P H.
set (Q := fun z => (z <= 1)%coqR /\ forall y, ball x z y -> not (P y)).
destruct (completeness Q) as [d [H1 H2]].
- exists 1.
  now intros y [Hy _].
- exists 0.
  split.
  apply Rle_0_1.
  intros y Hy Py.
  apply H.
  intros eps He.
  apply He with (2 := Py).
  apply ball_le with (2 := Hy).
  apply Rlt_le, eps.
assert (Zd : (0 < d)%coqR).
  apply Rnot_le_lt.
  intros Hd.
  apply H.
  intros eps He.
  apply (Rlt_irrefl (Rmin 1 eps)).
  apply Rle_lt_trans with d.
  apply H1.
  split.
  apply Rmin_l.
  intros y By.
  apply He.
  apply ball_le with (2 := By).
  apply Rmin_r.
  apply Rle_lt_trans with (1 := Hd).
  apply Rmin_case.
  apply Rlt_0_1.
  apply cond_pos.
exists [posreal of mkposreal _ Zd / 2].
simpl.
intros y Hy HP.
apply (Rlt_not_le _ _ (Rlt_eps2_eps _ Zd)).
apply H2.
intros z Hz.
apply Rnot_lt_le.
contradict HP.
apply Hz.
apply ball_le with (2 := Hy).
now apply Rlt_le.
Qed.

Lemma locally_not (x : T) (P : T -> Prop) :
  not (forall eps : posreal, not (forall y, ball x eps y -> not (P y))) ->
  locally x (fun y => not (P y)).
Proof.
move=> H.
case: (locally_not' H) => eps He; by exists eps.
Qed.

Lemma locally_ex_not (x : T) (P : T -> Prop) :
  locally x (fun y => not (P y)) ->
  {d : posreal | forall y, ball x d y -> not (P y)}.
Proof.
move=> H.
apply locally_not'.
case: H => eps He.
by move/(_ eps).
Qed.

Lemma locally_ex_dec (x : T) (P : T -> Prop) :
  (forall x, P x \/ ~ P x) ->
  locally x P ->
  {d : posreal | forall y, ball x d y -> P y}.
Proof.
move=> P_dec H; have [|d Hd] := @locally_ex_not x (fun y => not (P y)).
  by apply: filter_imp H => y Py /(_ Py).
by exists d => y Hy; have [|/(Hd y)] := P_dec y.
Qed.

Lemma is_filter_lim_close {F} {FF : ProperFilter F} (x y : T) :
  F --> x -> F --> y -> close x y.
Proof.
intros Fx Fy eps.
specialize (Fy _ (locally_ball y [posreal of eps / 2])).
specialize (Fx _ (locally_ball x [posreal of eps / 2])).
generalize (filter_and Fx Fy) => {Fx Fy} Fxy.
have [z [Fxz Fyz]] := filter_ex Fxy.
exact: ball_splitl Fyz.
Qed.

Lemma is_filter_lim_locally_close (x y : T) : x --> y -> close x y.
Proof. exact: is_filter_lim_close. Qed.

End Locally.

Definition cvg (U : Type) (T : canonical_filter U) :=
  fun (T' : Type) & canonical_filter_type T = T' =>
  fun F : set (set U) => exists l : T, F --> l.

Notation "[ 'cvg' F 'in' T ]" :=
  (@cvg _ _ T erefl [filter of F])
  (format "[ 'cvg'  F  'in'  T ]") : classical_set_scope.
Notation continuous f := (forall x, f%function @ locally x --> f%function x).

Lemma flim_const {T} {U : uniformType} {F : set (set T)}
   {FF : Filter F} (a : U) : a @[_ --> F] --> a.
Proof.
move=> P [eps HP]; rewrite appfilter /=.
by apply: filter_forall=> ?; apply/HP/ball_center.
Qed.

Lemma filterlim_const {T} {U : uniformType} {F : set (set T)} (*compat*)
   {FF : Filter F} (a : U) : a @[_ --> F] --> a.
Proof. exact: flim_const. Qed.

Section Cvg.

Context {U : uniformType}.

Lemma cvgE (F : set (set U)) : [cvg F in U] = (F --> lim F).
Proof. by rewrite propeqE; split => [/getPex//|]; exists (lim F). Qed.

Lemma limP (F : set (set U)) : [cvg F in U] <-> (F --> lim F).
Proof. by rewrite cvgE. Qed.

Lemma dvgP (F : set (set U)) : ~ [cvg F in U] -> lim F = point.
Proof.
by move=> dvg; rewrite [lim _]getPN // => x Fx; apply: dvg; exists x.
Qed.

CoInductive cvg_spec (F : set (set U)) : U -> Prop -> Type :=
| HasLim (l : U) of F --> l : cvg_spec F l True
| HasNoLim of ~ [cvg F in U] : cvg_spec F point False.

Lemma cvgP (F : set (set U)) : cvg_spec F (lim F) [cvg F in U].
Proof.
have [cvg|dvg] := pselect [cvg F in U].
  by rewrite (propT cvg); apply: HasLim; rewrite -cvgE.
by rewrite (propF dvg) (dvgP _) //; apply: HasNoLim.
Qed.

Lemma cvgI (F : set (set U)) (l : U) : F --> l -> [cvg F in U].
Proof. by exists l. Qed.

Lemma close_lim (F1 F2 : set (set U)) {FF2 : ProperFilter F2} :
  F1 --> F2 -> F2 --> F1 -> close (lim F1) (lim F2).
Proof.
have [l F1l _|dvgF1]:= cvgP F1.
  move=> /filter_le_trans /(_ F1l) F2l.
  apply: (@is_filter_lim_close _ F2) => //.
  by rewrite -cvgE; exists l.
have [l F2l|//]:= cvgP F2.
move=> /filter_le_trans /(_ F2l) F1l _.
by have := dvgF1 (ex_intro _ l F1l).
Qed.

Lemma filterlim_closeP (F : set (set U)) (l : U) :
  ProperFilter F ->
  F --> l <-> ([cvg F in U] /\ close (lim F) l).
Proof.
rewrite cvgE; split=> [Fl|[FlF cl]].
  have FlF: F --> lim F by rewrite -cvgE; exists l.
  by split=> //; apply: is_filter_lim_close.
by apply: filter_le_trans (close_limxx cl).
Qed.

End Cvg.
Arguments close_lim {U} F1 F2 {FF2} _.

Section Locally_fct.

Context {T : Type} {U : uniformType}.

Lemma filterlim_locally {F} {FF : Filter F} (y : U) :
  F --> y <-> forall eps : posreal, F [set x | ball y eps x].
Proof.
split.
- move=> Cf eps.
  apply: (Cf (fun x => ball y eps x)).
  by exists eps.
- move=> Cf P [eps He].
  apply: filter_imp (Cf eps) => t.
  exact: He.
Qed.

Lemma app_filterlim_locally {F} {FF : Filter F} (f : T -> U) y :
  f @ F --> y <-> forall eps : posreal, F [set x | ball y eps (f x)].
Proof. exact: filterlim_locally. Qed.

Lemma filterlimi_locally {F} {FF : Filter F} (f : T -> U -> Prop) y :
  f `@ F --> y <->
  forall eps : posreal, F [set x | exists z, f x z /\ ball y eps z].
Proof.

split.
- intros Cf eps.
  apply (Cf (ball y eps)).
  by exists eps.
- move=> Cf P [eps He].
  rewrite /filtermapi /filter_of /=.
  apply: filter_imp (Cf eps).
  intros t [z [Hz1 Hz2]].
  exists z.
  apply (conj Hz1).
  now apply He.
Qed.

(* :TODO: remove *)
Lemma filterlim_locally_close {F} {FF: ProperFilter F} (f : T -> U) (l l' : U) :
  f @ F --> l -> f @ F --> l' -> close l l'.
Proof. exact: is_filter_lim_close. Qed.

(* :TODO: refactor *)
Lemma filterlimi_locally_close
  {F} {FF: ProperFilter F} (f : T -> U -> Prop) (l l' : U) :
  F [set x | is_prop (f x)] ->
  f `@ F --> l ->  f `@ F --> l' -> close l l'.
Proof.
(* move=> Fmem; suff fFp : ProperFilter (f `@ F) by exact: @is_filter_lim_close. *)
(* apply: filtermapi_proper_filter. *)
(* apply: filter_imp Fmem. *)
intros Hf Hl Hl' eps.
(* have half_l := Hl (ball l ([posreal of eps / 2])) (locally_ball _ _). *)
(* have half_l' := Hl' (ball l' ([posreal of eps / 2])) (locally_ball _ _). *)
(* have := (filter_and _ _ half_l half_l'). *)
(* move=> /filter_ex [fx [fxl /ball_sym fxl']]. *)
(* by rewrite (double_var eps); eapply (ball_triangle _ fx). *)
have H := locally_ball l [posreal of eps / 2].
specialize (Hl (ball l [posreal of eps / 2]) H).
have H' := locally_ball l' [posreal of eps / 2].
specialize (Hl' (ball l' [posreal of eps / 2]) H').
unfold filtermapi in Hl, Hl'.
rewrite /filter_of /= in Hl Hl'.
generalize (filter_and Hf (filter_and Hl Hl')) => {H H' Hl Hl' Hf} H.
apply filter_ex in H.
case: H => [x [Hf [[y [H1 H1']] [y' [H2 H2']]]]].
apply/(ball_splitl H1').
by rewrite (Hf _ _ H1 H2).
Qed.

End Locally_fct.

Lemma is_filter_lim_filtermap {T: uniformType} {U : uniformType}
  (F : set (set T)) x (f : T -> U) :
   {for x, continuous f} -> F --> x -> f @ F --> f x.
Proof. by move=> cf fx P /cf /fx. Qed.

(** locally' *)

Definition locally' {T : uniformType} (x : T) :=
  within (fun y => y <> x) (locally x).

Global Instance locally'_filter :
  forall {T : uniformType} (x : T), Filter (locally' x).
Proof.
intros T x.
apply within_filter.
apply locally_filter.
Qed.

Section at_point.

Context {T : uniformType}.

Definition at_point (a : T) (P : T -> Prop) : Prop := P a.

Global Instance at_point_filter (a : T) : ProperFilter (at_point a).
Proof. by constructor => //; constructor => // P Q subPQ /subPQ. Qed.

End at_point.

(** ** Open sets in uniform spaces *)

Section Open.

Context {T : uniformType}.

Definition open (D : T -> Prop) := forall x, D x -> locally x D.

Lemma locally_open (D E : T -> Prop) (OD : open D) :
  (forall x : T, D x -> E x) ->
  forall x : T, D x ->
  locally x E.
Proof.
intros H x Dx.
apply filter_imp with (1 := H).
now apply OD.
Qed.

Lemma open_ext (D E : T -> Prop) : (forall x, D x <-> E x) ->
  open D -> open E.
Proof.
intros H OD x Ex.
move: (OD x (proj2 (H x) Ex)).
apply filter_imp => y.
by apply H.
Qed.

Lemma open_and (D E : T -> Prop) : open D -> open E ->
  open (fun x => D x /\ E x).
Proof.
intros OD OE x [Dx Ex].
apply filter_and.
now apply OD.
now apply OE.
Qed.

Lemma open_or (D E : T -> Prop) : open D -> open E ->
  open (fun x => D x \/ E x).
Proof.
move=> OD OE x [Dx|Ex].
- move/filter_imp : (OD x Dx); apply; by left.
- move/filter_imp : (OE x Ex); apply; by right.
Qed.

Lemma open_true : open (fun x : T => True).
Proof. intros x _; by apply filter_true. Qed.

Lemma open_false : open (fun x : T => False).
Proof. by []. Qed.

End Open.

Lemma open_comp :
  forall {T U : uniformType} (f : T -> U) (D : U -> Prop),
  (forall x, D (f x) -> {for x, continuous f}) ->
  open D -> open (fun x : T => D (f x)).
Proof.
intros T U f D Cf OD x Dfx.
apply Cf.
exact Dfx.
now apply OD.
Qed.

(** ** Closed sets in uniform spaces *)

Section Closed.

Context {T : uniformType}.

Definition closed (D : T -> Prop) :=
  forall x, not ((locally x) (fun x : T => not (D x))) -> D x.

Lemma open_not (D : T -> Prop) : closed D -> open (fun x => not (D x)).
Proof.
intros CD x Dx.
apply locally_not.
intros H.
apply Dx, CD.
move=> [eps He].
by apply (H eps).
Qed.

Lemma closed_not (D : T -> Prop) : open D -> closed (fun x => not (D x)).
Proof.
intros OD x Lx Dx.
apply Lx.
apply: filter_imp (OD _ Dx).
intros t Dt nDt.
now apply nDt.
Qed.

Lemma closed_ext (D E : T -> Prop) : (forall x, D x <-> E x) ->
  closed D -> closed E.
Proof.
intros DE CD x Hx.
apply DE, CD.
contradict Hx.
apply: filter_imp Hx.
move => {x} x Dx Ex.
now apply Dx, DE.
Qed.

Lemma closed_and (D E : T -> Prop) : closed D -> closed E ->
  closed (fun x => D x /\ E x).
Proof.
intros CD CE x Hx; split.
- apply CD.
  contradict Hx.
  apply: filter_imp Hx.
  move => {x} x nDx [Dx _].
  now apply nDx.
- apply CE.
  contradict Hx.
  apply: filter_imp Hx.
  move => {x} x nEx [_ Ex].
  now apply nEx.
Qed.

(*
Lemma closed_or :
  forall D E : T -> Prop,
  closed D -> closed E ->
  closed (fun x => D x \/ E x).
Proof.
intros D E CD CE x Hx.
generalize (open_and _ _ CD CE).
apply open_ext.
clear ; intuition.
Qed.
*)

Lemma closed_true : closed (fun x : T => True).
Proof. by []. Qed.

Lemma closed_false : closed (fun x : T => False).
Proof.
intros x Hx.
apply: Hx.
now exists [posreal of 1].
Qed.

End Closed.

Lemma closed_comp :
  forall {T U : uniformType} (f : T -> U) (D : U -> Prop),
  continuous f ->
  closed D -> closed (fun x : T => D (f x)).
Proof.
intros T U f D Cf CD x Dfx.
apply CD.
contradict Dfx.
exact: Cf Dfx.
Qed.

Lemma closed_filterlim_loc :
  forall {T} {U : uniformType} {F} {FF : ProperFilter F} (f : T -> U) (D : U -> Prop),
  forall y, f @ F --> y ->
  F (fun x => D (f x)) ->
  closed D -> D y.
Proof.
intros T U F FF f D y Ffy Df CD.
apply CD.
intros LD.
apply: filter_not_empty.
specialize (Ffy _ LD).
unfold filtermap in Ffy.
set P := [set x | D (f x) /\ ~ D (f x)].
suff : F P by apply filter_imp => x [].
by apply: filter_and.
Qed.

Lemma closed_filterlim :
  forall {T} {U : uniformType} {F} {FF : ProperFilter F} (f : T -> U) (D : U -> Prop),
  forall y, f @ F --> y ->
  (forall x, D (f x)) ->
  closed D -> D y.
Proof.
intros T U F FF f D y Ffy Df.
apply: closed_filterlim_loc Ffy _.
now apply filter_forall.
Qed.

(** ** Complete uniform spaces *)

Definition cauchy {T : uniformType} (F : set (set T)) :=
  forall eps : posreal, exists x, F (ball x eps).

Module Complete.

Definition axiom (T : uniformType) :=
  forall (F : set (set T)), ProperFilter F -> cauchy F -> F --> lim F.

Section ClassDef.

Record class_of (T : Type) := Class {
  base : Uniform.class_of T ;
  mixin : axiom (Uniform.Pack base T)
}.
Local Coercion base : class_of >-> Uniform.class_of.
Local Coercion mixin : class_of >-> Complete.axiom.

Structure type := Pack { sort; _ : class_of sort ; _ : Type }.
Local Coercion sort : type >-> Sortclass.

Variables (T : Type) (cT : type).

Definition class := let: Pack _ c _ := cT return class_of cT in c.

Definition clone c of phant_id class c := @Pack T c T.
Let xT := let: Pack T _ _ := cT in T.
Notation xclass := (class : class_of xT).

Definition pack b0 (m0 : axiom (@Uniform.Pack T b0 T)) :=
  fun bT b of phant_id (Uniform.class bT) b =>
  fun m of phant_id m m0 => @Pack T (@Class T b m) T.

Definition eqType := @Equality.Pack cT xclass xT.
Definition choiceType := @Choice.Pack cT xclass xT.
Definition uniformType := @Uniform.Pack cT xclass xT.

End ClassDef.

Module Exports.

Coercion base : class_of >-> Uniform.class_of.
Coercion mixin : class_of >-> axiom.
Coercion sort : type >-> Sortclass.
Coercion eqType : type >-> Equality.type.
Canonical eqType.
Coercion choiceType : type >-> Choice.type.
Canonical choiceType.
Coercion uniformType : type >-> Uniform.type.
Canonical uniformType.
Definition type_canonical_filter (T : type):= @CanonicalFilter T T locally.
Coercion type_canonical_filter : type >-> canonical_filter.
Canonical type_canonical_filter.
Notation completeType := type.
Notation "[ 'completeType' 'of' T 'for' cT ]" :=  (@clone T cT _ idfun)
  (at level 0, format "[ 'completeType'  'of'  T  'for'  cT ]") : form_scope.
Notation "[ 'completeType' 'of' T ]" := (@clone T _ _ id)
  (at level 0, format "[ 'completeType'  'of'  T ]") : form_scope.
Notation CompleteType T m := (@pack T _ m _ _ idfun _ idfun).

End Exports.

End Complete.

Export Complete.Exports.

Section completeType1.

Context {T : completeType}.

Lemma complete_cauchy (F : set (set T)) (FF : ProperFilter F) :
  cauchy F -> F --> lim F.
Proof. by case: T F FF => [? [?]]. Qed.

Lemma iota_correct_weak (P : T -> Prop) :
  (forall x y, P x -> P y -> close x y) ->
  forall x, P x -> close (iota P) x.
Proof. by move=> HP x Hx eps; apply: HP=> //; apply: getP Hx. Qed.

Lemma close_iota (P Q : T -> Prop) : (forall x, P x <-> Q x) ->
  close (iota P) (iota Q).
Proof. by move=> ?; rewrite (_ : P = Q) // funeqE => x; rewrite propeqE. Qed.

End completeType1.
Arguments complete_cauchy {T} F {FF} _.

Lemma cauchy_distance  {T : uniformType} {F} {FF : ProperFilter F} :
  (forall eps : posreal, exists x, F (ball x eps)) <->
  (forall eps : posreal, exists P, F P /\ forall u v : T, P u -> P v -> ball u eps v).
Proof.
split.
- intros H eps.
  case: (H [posreal of eps / 2]) => {H} x Hx.
  exists (ball x [posreal of eps / 2]).
  split.
  by [].
  move => u v Hu Hv.
  exact: ball_splitr Hv.
- intros H eps.
  case: (H eps) => {H} P [HP H].
  destruct (filter_ex HP) as [x Hx].
  exists x.
  move: (fun v => H x v Hx) => {H} H.
  apply filter_imp with (1 := H).
  by [].
Qed.

Section fct_Complete.

Context {T : choiceType} {U : completeType}.

Lemma filterlim_locally_cauchy :
  forall {F} {FF : ProperFilter F} (f : T -> U),
  (forall eps : posreal, exists P, F P /\ forall u v : T, P u -> P v -> ball (f u) eps (f v)) <->
  exists y : U, f @ F --> y.
Proof.
intros F FF f.
split.
- intros H.
  exists (lim (f @ F)).
  move=> P [eps HP] /=.
  refine (_ (complete_cauchy (f @ F) _ _)).
  + by apply => /=; exists eps.
  + clear eps P HP.
    intros eps.
    destruct (H eps) as [P [FP H']].
    destruct (filter_ex FP) as [x Hx].
    exists (f x).
    unfold filtermap.
    generalize FP.
    apply filter_imp.
    intros x' Hx'.
    now apply H'.
- intros [y Hy] eps.
  exists (fun x => ball y [posreal of eps / 2] (f x)).
  split.
  apply Hy.
  now exists [posreal of eps / 2].
- intros u v Hu Hv.
  exact: ball_splitr Hv.
Qed.

Lemma filterlimi_locally_cauchy :
  forall {F} {FF : ProperFilter F} (f : T -> set U),
  F (fun x => (exists y, f x y) /\
    (forall y1 y2, f x y1 -> f x y2 -> y1 = y2)) ->
  ((forall eps : posreal, exists P, F P /\
   forall u v : T, P u -> P v -> forall u' v': U, f u u' -> f v v' -> ball u' eps v') <->
  exists y : U, f `@ F --> y).
Proof.
intros F FF f Hf.
assert (FF': ProperFilter (filtermapi f F)).
  apply filtermapi_proper_filter.
  exact: filter_imp Hf.
  exact FF.
split.
- intros H.
  exists (lim (f `@ F)) => P [eps HP].
  refine (_ (complete_cauchy (filtermapi f F) _ _)).
  + by apply; exists eps.
  + clear eps P HP.
    intros eps.
    case: (H eps) => {H} [P [FP H]].
    assert (FfP := filter_and Hf FP).
    destruct (filter_ex FfP) as [x [[[fx Hfx] _] Px]].
    exists fx.
    unfold filtermapi.
    apply: filter_imp FfP.
    intros x' [[[fx' Hfx'] _] Px'].
    exists fx'.
    apply (conj Hfx').
    exact: H Hfx Hfx'.
- intros [y Hy] eps.
  exists (fun x => forall fx, f x fx -> ball y [posreal of eps / 2] fx).
  split.
    have Hb := locally_ball y [posreal of eps / 2].
    assert (H := filter_and Hf (Hy _ Hb)).
    apply: filter_imp H.
    intros x [[_ H] [fx2 [Hfx2 H']]] fx Hfx.
    now rewrite <- (H fx2).
  intros u v Hu Hv fu fv Hfu Hfv.
  by apply: ball_splitr; [exact: Hu|exact: Hv].
Qed.

Lemma complete_cauchy_fct :
  forall (F : ((T -> U) -> Prop) -> Prop),
  ProperFilter F -> cauchy F -> F --> lim F.
Proof.
move=> F FF Fc.
set Fr := fun (t : T) (P : U -> Prop) => F (fun g => P (g t)).
have FFr t : ProperFilter (Fr t).
  by apply: Build_ProperFilter'; apply: filter_not_empty.
have Frc t : cauchy (Fr t).
  move=> e; have [f Ffe] := Fc e; exists (f t).
  by rewrite /Fr; apply: filter_imp Ffe.
apply/limP; exists (fun t => lim (Fr t)).
apply/filterlim_locally => e.
have /cauchy_distance /(_ [posreal of e / 2]) [A [FA diamA_he]] := Fc.
apply: (filter_imp _ FA) => f Af t.
have [g [Ag limFte_gt]] :
  exists g, A g /\ ball (lim (Fr t)) [posreal of e / 2] (g t).
  apply/filter_ex/filter_and => //; apply: complete_cauchy => //.
  exact: locally_ball.
by apply: ball_split limFte_gt _; apply: diamA_he.
Qed.

Canonical fct_completeType := CompleteType (T -> U) complete_cauchy_fct.

End fct_Complete.

(** ** Limit switching *)

Section Filterlim_switch.

Context {T1 T2 : choiceType}.

(* :TODO: Use bigenough reasonning here *)
Lemma filterlim_switch_1 {U : uniformType}
  F1 (FF1 : ProperFilter F1) F2 (FF2 : Filter F2) (f : T1 -> T2 -> U) (g : T2 -> U) (h : T1 -> U) (l : U) :
  f @ F1 --> g ->
  (forall x, f x @ F2 --> h x) ->
  h @ F1 --> l ->
  g @ F2 --> l.
Proof.
  move=> Hfg Hfh Hhl P.
  have HF1 := !! @filter_ex _ F1 _.

  apply filterlim_locally.
  move => eps.

  have {Hfg}Hfg : [filter of (F1, F2)] [set x | ball (g x.2) (eps / 2 / 2) (f x.1 x.2)].
    exists [set x | ball g (eps / 2 / 2) (f x)] setT => //=; last first.
      exact: filter_true.
      exact: (proj1 (@app_filterlim_locally _ _ F1 _ f g) _).

  have {Hhl} Hhl : [filter of (F1, F2)] [set x | ball l (eps / 2) (h x.1)].
    exists [set x | ball l (eps / 2) (h x)] setT => //=; last first.
      exact: filter_true.
    exact: (proj1 (@app_filterlim_locally _ _ F1 _ h l) _).

  have [Q R /= F1Q F2R Hfghl] := filter_and Hhl Hfg.

  move: (fun x => proj1 (@app_filterlim_locally _ _ F2 FF2 (f x) (h x)) (Hfh x) ([posreal of eps / 2 / 2])) => {Hfh} /= Hfh.
  have [x Qx] := HF1 Q F1Q.

  have {Hfh} := !! filter_and (Hfh x) F2R.
  rewrite appfilter.
  apply: filter_imp => y Hy.
  apply: (@ball_split _ (h x)).
     apply (Hfghl x y) => //.
     by apply Hy.
  apply: (@ball_splitl _ (f x y)).
    by apply Hy.
  apply Hfghl.
    by [].
  by apply Hy.
Qed.

(* :TODO: Use bigenough reasonning here *)
Lemma filterlim_switch_2 {U : completeType}
  F1 (FF1 : ProperFilter F1) F2 (FF2 : ProperFilter F2) (f : T1 -> T2 -> U) (g : T2 -> U) (h : T1 -> U) :
  f @ F1 --> g ->
  (forall x, f x @ F2 --> h x) ->
  [cvg h @ F1 in U].

Proof.
  move => Hfg Hfh.
  case : (proj1 (filterlim_locally_cauchy h)).
  move => eps.
  generalize (proj2 (filterlim_locally_cauchy f)) => Hf.
  assert (exists y : T2 -> U, f @ F1 --> y).
    exists g => P Hp.
    apply Hfg.
    case: Hp => d Hp.
    exists d => y Hy.
    apply: Hp.
    by apply Hy.

  move: H => {Hfg} Hfg.
  move: (Hf Hfg [posreal of eps / 2]) => {Hf Hfg} /= Hf.

  have HF2 := !! @filter_ex _ F2 _.
  generalize (fun x => proj1 (app_filterlim_locally (f x) (h x)) (Hfh x) ([posreal of eps / 2 / 2]))
    => {Hfh} Hfh.

  case: Hf => P [Hp Hf].
  exists P ; split.
  by [].
  move => u v Hu Hv.
  move: (Hfh u) => /= Hu'.
  move: (Hfh v) => /= Hv'.
  move: (!! (@filter_and _ F2 _ _ _ Hu' Hv')) => {Hu' Hv' Hfh} Hfh.
  case: (HF2 _ Hfh) => {Hfh} y Hy.
  replace (pos eps) with (eps / 2 / 2 + (eps / 2 + eps / 2 / 2))%coqR by field.
  apply ball_triangle with (f u y).
  by apply Hy.
  apply ball_triangle with (f v y).
  by apply Hf.
    apply ball_sym.
    by apply Hy.
  move => l Hl.
  by exists l.
Qed.

(* Alternative version *)
(* Lemma filterlim_switch {U : completeType} *)
(*   F1 (FF1 : ProperFilter F1) F2 (FF2 : ProperFilter F2) (f : T1 -> T2 -> U) (g : T2 -> U) (h : T1 -> U) : *)
(*   [cvg f @ F1 in T2 -> U] -> (forall x, [cvg f x @ F2 in U]) -> *)
(*   [/\ [cvg [lim f @ F1] @ F2 in U], [cvg (fun x => [lim f x @ F2]) @ F1 in U] *)
(*   & [lim [lim f @ F1] @ F2] = [lim (fun x => [lim f x @ F2]) @ F1]]. *)
Lemma filterlim_switch {U : completeType}
  F1 (FF1 : ProperFilter F1) F2 (FF2 : ProperFilter F2) (f : T1 -> T2 -> U) (g : T2 -> U) (h : T1 -> U) :
  f @ F1 --> g ->
  (forall x, f x @ F2 --> h x) ->
  exists l : U, h @ F1 --> l /\ g @ F2 --> l.
Proof.
  move => Hfg Hfh.
  destruct (filterlim_switch_2 FF1 FF2 Hfg Hfh) as [l Hhl].
  exists l ; split.
  exact Hhl.
  case: FF2 => HF2 FF2.
  now apply (@filterlim_switch_1 _ F1 FF1 F2 FF2 f g h l).
Qed.

End Filterlim_switch.

(* TODO: fix this later by instanciating a choicetype on sig *)
(* Lemma filterlim_switch_dom {T1 T2 : choiceType} {U : completeType} *)
(*   F1 (FF1 : ProperFilter F1) F2 (FF2 : Filter F2) *)
(*   (dom : T2 -> Prop) (HF2 : forall P, F2 P -> exists x, dom x /\ P x) *)
(*   (f : T1 -> T2 -> U) (g : T2 -> U) (h : T1 -> U) : *)
(*   (fun x (y : {z : T2 | dom z}) => f x (proj1_sig y)) @ F1 *)
(*      --> (fun y : {z : T2 | dom z} => g (proj1_sig y)) -> *)
(*   (forall x, (f x) @ (within dom F2) --> h x) -> *)
(*   exists l : U, h @ F1 --> l /\ g @ within dom F2 --> l. *)
(* Proof. *)
(* set (T2' := { y : T2 | dom y }). *)
(* set (f' := fun x (y : T2') => f x (proj1_sig y)). *)
(* set (F2' := fun P : T2' -> Prop => F2 (fun x => forall (H:dom x), P (exist _ x H))). *)
(* set (g' := fun y : T2' => g (proj1_sig y)). *)
(* intros Hfg Hfh. *)
(* refine (filterlim_switch F1 FF1 F2' _ f' g' h _ _). *)
(* now apply subset_filter_proper. *)
(* intros H P. *)
(* now apply Hfg. *)
(* intros x P HP. *)
(* now apply Hfh. *)
(* Qed. *)

(** ** Modules with a norm *)

Module AbsRing.

Record mixin_of (D : ringType) := Mixin {
  abs : D -> R;
  ax1 : abs 0 = 0 ;
  ax2 : abs (- 1) = 1 ;
  ax3 : forall x y : D, abs (x + y) <= abs x + abs y ;
  ax4 : forall x y : D, abs (x * y) <= abs x * abs y ;
  ax5 : forall x : D, abs x = 0 -> x = 0
}.

Section ClassDef.

Record class_of (K : Type) := Class {
  base : Num.NumDomain.class_of K ;
  mixin : mixin_of (Num.NumDomain.Pack base K)
}.
Local Coercion base : class_of >-> Num.NumDomain.class_of.
Local Coercion mixin : class_of >-> mixin_of.

Structure type := Pack { sort; _ : class_of sort ; _ : Type }.
Local Coercion sort : type >-> Sortclass.

Variables (T : Type) (cT : type).
Definition class := let: Pack _ c _ := cT return class_of cT in c.
Let xT := let: Pack T _ _ := cT in T.
Notation xclass := (class : class_of xT).
Definition clone c of phant_id class c := @Pack T c T.
Definition pack b0 (m0 : mixin_of (@Num.NumDomain.Pack T b0 T)) :=
  fun bT b & phant_id (Num.NumDomain.class bT) b =>
  fun    m & phant_id m0 m => Pack (@Class T b m) T.

Definition eqType := @Equality.Pack cT xclass xT.
Definition choiceType := @Choice.Pack cT xclass xT.
Definition zmodType := @GRing.Zmodule.Pack cT xclass xT.
Definition ringType := @GRing.Ring.Pack cT xclass xT.
Definition comRingType := @GRing.ComRing.Pack cT xclass xT.
Definition unitRingType := @GRing.UnitRing.Pack cT xclass xT.
Definition comUnitRingType := @GRing.ComUnitRing.Pack cT xclass xT.
Definition idomainType := @GRing.IntegralDomain.Pack cT xclass xT.
Definition numDomainType := @Num.NumDomain.Pack cT xclass xT.

End ClassDef.

Module Exports.

Coercion base : class_of >-> Num.NumDomain.class_of.
Coercion mixin : class_of >-> mixin_of.
Coercion sort : type >-> Sortclass.
Coercion eqType : type >-> Equality.type.
Canonical eqType.
Coercion choiceType : type >-> Choice.type.
Canonical choiceType.
Coercion zmodType : type >-> GRing.Zmodule.type.
Canonical zmodType.
Coercion ringType : type >-> GRing.Ring.type.
Canonical ringType.
Coercion comRingType : type >-> GRing.ComRing.type.
Canonical comRingType.
Coercion unitRingType : type >-> GRing.UnitRing.type.
Canonical unitRingType.
Coercion comUnitRingType : type >-> GRing.ComUnitRing.type.
Canonical comUnitRingType.
Coercion idomainType : type >-> GRing.IntegralDomain.type.
Canonical idomainType.
Coercion numDomainType : type >-> Num.NumDomain.type.
Canonical numDomainType.
Notation AbsRingMixin := Mixin.
Notation AbsRingType T m := (@pack T _ m _ _ id _ id).
Notation "[ 'absRingType' 'of' T 'for' cT ]" := (@clone T cT _ idfun)
  (at level 0, format "[ 'absRingType'  'of'  T  'for'  cT ]") : form_scope.
Notation "[ 'absRingType' 'of' T ]" := (@clone T _ _ id)
  (at level 0, format "[ 'absRingType'  'of'  T ]") : form_scope.
Notation absRingType := type.

End Exports.

End AbsRing.

Export AbsRing.Exports.

Definition abs {K : absRingType} : K -> R := @AbsRing.abs _ (AbsRing.class K).
Notation "`| x |" := (abs x%R) : R_scope.
Notation "`| x |" := (abs x%R) : real_scope.

Section AbsRing1.

Context {K : absRingType}.
Implicit Types x : K.

Lemma absr0 : `|0 : K| = 0. Proof. exact: AbsRing.ax1. Qed.

Lemma absrN1: `|- 1 : K| = 1.
Proof. exact: AbsRing.ax2. Qed.

Lemma ler_abs_add (x y : K) :  `|x + y| <= `|x|%real + `|y|%real.
Proof. exact: AbsRing.ax3. Qed.

Lemma absrM (x y : K) : `|x * y| <= `|x|%real * `|y|%real.
Proof. exact: AbsRing.ax4. Qed.

Lemma absr0_eq0 (x : K) : `|x| = 0 -> x = 0.
Proof. exact: AbsRing.ax5. Qed.

Lemma absrN x : `|- x| = `|x|.
Proof.
gen have le_absN1 : x / `|- x| <= `|x|.
  by rewrite -mulN1r (ler_trans (absrM _ _)) //= absrN1 mul1r.
by apply/eqP; rewrite eqr_le le_absN1 /= -{1}[x]opprK le_absN1.
Qed.

Lemma absrB (x y : K) : `|x - y| = `|y - x|.
Proof. by rewrite -absrN opprB. Qed.

Lemma absr1 : `|1 : K| = 1. Proof. by rewrite -absrN absrN1. Qed.

Lemma absr_ge0 x : 0 <= `|x|.
Proof.
rewrite -(@pmulr_rge0 _ 2%:R) // mulr2n mulrDl !mul1r.
by rewrite -{2}absrN (ler_trans _ (ler_abs_add _ _)) // subrr absr0.
Qed.

Lemma absrX x n : `|x ^+ n| <= `|x|%real ^+ n.
Proof.
elim: n => [|n IH]; first  by rewrite !expr0 absr1.
by rewrite !exprS (ler_trans (absrM _ _)) // ler_pmul // absr_ge0.
Qed.

End AbsRing1.
Hint Resolve absr_ge0.

Section AbsRing_UniformSpace.

Context (K : absRingType).

Definition AbsRing_ball (x : K) (eps : R) (y : K) := `|x - y| < eps.

Lemma AbsRing_ball_center (x : K) (e : posreal) : AbsRing_ball x e x.
Proof. by rewrite /AbsRing_ball subrr absr0. Qed.

Lemma AbsRing_ball_sym (x y : K) (e : R) :
  AbsRing_ball x e y -> AbsRing_ball y e x.
Proof. by rewrite /AbsRing_ball absrB. Qed.

(* :TODO: to math-comp *)
Lemma subr_trans (M : zmodType) (z x y : M) : x - y = (x - z) + (z - y).
Proof. by rewrite addrA addrNK. Qed.

Lemma AbsRing_ball_triangle (x y z : K) (e1 e2 : R) :
  AbsRing_ball x e1 y -> AbsRing_ball y e2 z -> AbsRing_ball x (e1 + e2) z.
Proof.
rewrite /AbsRing_ball => xy yz.
by rewrite (subr_trans y) (ler_lt_trans (ler_abs_add _ _)) ?ltr_add.
Qed.

Definition AbsRingUniformMixin :=
  UniformMixin 0 AbsRing_ball_center AbsRing_ball_sym AbsRing_ball_triangle.

(* :TODO: DANGEROUS ! Must change this to include uniform type inside absring *)
Canonical absRing_UniformType := UniformType K AbsRingUniformMixin.
Canonical AbsRingcanonical_filter := @CanonicalFilter K K locally.

End AbsRing_UniformSpace.

Reserved Notation  "`|[ x ]|" (at level 0, x at level 99, format "`|[ x ]|").

Module NormedModule.

Record mixin_of (K : absRingType) (V : lmodType K) (m : Uniform.mixin_of V) := Mixin {
  norm : V -> R ;
  norm_factor : R ;
  ax1 : forall (x y : V), norm (x + y) <= norm x + norm y ;
  ax2 : forall (l : K) (x : V), norm (l *: x) <= abs l * norm x;
  ax3 : forall (x y : V) (eps : posreal), norm (x - y) < eps -> Uniform.ball m x eps y ;
  ax4 : forall (x y : V) (eps : posreal), Uniform.ball m x eps y ->
    norm (x - y) < norm_factor * eps ;
  ax5 : forall x : V, norm x = 0 -> x = 0
}.

Section ClassDef.

Variable K : absRingType.

Record class_of (T : Type) := Class {
  base : GRing.Lmodule.class_of K T ;
  uniform_mixin : Uniform.mixin_of T ;
  mixin : @mixin_of _ (@GRing.Lmodule.Pack K (Phant K) T base T) uniform_mixin
}.
Local Coercion base : class_of >-> GRing.Lmodule.class_of.
Definition base2 T (c : class_of T) :=
  Uniform.Class (@base T c) (@uniform_mixin T c).
Local Coercion base2 : class_of >-> Uniform.class_of.
Local Coercion mixin : class_of >-> mixin_of.

Structure type (phK : phant K) :=
  Pack { sort; _ : class_of sort ; _ : Type }.
Local Coercion sort : type >-> Sortclass.

Variables (phK : phant K) (T : Type) (cT : type phK).

Definition class := let: Pack _ c _ := cT return class_of cT in c.
Definition clone c of phant_id class c := @Pack phK T c T.
Let xT := let: Pack T _ _ := cT in T.
Notation xclass := (class : class_of xT).

Definition pack b0 um0 (m0 : @mixin_of _ (@GRing.Lmodule.Pack K (Phant K) T b0 T) um0) :=
  fun bT b & phant_id (@GRing.Lmodule.class K phK bT) b =>
  fun ubT (ub : Uniform.class_of _) & phant_id (@Uniform.class ubT) ub =>
  fun   m & phant_id m0 m => Pack phK (@Class T b ub m) T.

Definition eqType := @Equality.Pack cT xclass xT.
Definition choiceType := @Choice.Pack cT xclass xT.
Definition zmodType := @GRing.Zmodule.Pack cT xclass xT.
Definition lmodType := @GRing.Lmodule.Pack K phK cT xclass xT.
Definition uniformType := @Uniform.Pack cT xclass xT.
Definition join_zmodType := @GRing.Zmodule.Pack uniformType xclass xT.
Definition join_lmodType := @GRing.Lmodule.Pack K phK uniformType xclass xT.
End ClassDef.

Module Exports.

Coercion base : class_of >-> GRing.Lmodule.class_of.
Coercion base2 : class_of >-> Uniform.class_of.
Coercion mixin : class_of >-> mixin_of.
Coercion sort : type >-> Sortclass.
Coercion eqType : type >-> Equality.type.
Canonical eqType.
Coercion choiceType : type >-> Choice.type.
Canonical choiceType.
Coercion zmodType : type >-> GRing.Zmodule.type.
Canonical zmodType.
Coercion lmodType : type >-> GRing.Lmodule.type.
Canonical lmodType.
Coercion uniformType : type >-> Uniform.type.
Canonical uniformType.
Canonical join_zmodType.
Canonical join_lmodType.
Definition type_canonical_filter
   (K : absRingType) (phK : phant K) (T : type phK) :=
  @CanonicalFilter T T locally.
Coercion type_canonical_filter : type >-> canonical_filter.
Canonical type_canonical_filter.

Notation normedModType K := (type (Phant K)).
Notation NormedModType K T m := (@pack _ (Phant K) T _ _ m _ _ id _ _ id _ id).
Notation NormedModMixin := Mixin.
Notation "[ 'normedModType' K 'of' T 'for' cT ]" := (@clone _ (Phant K) T cT _ idfun)
  (at level 0, format "[ 'normedModType'  K  'of'  T  'for'  cT ]") : form_scope.
Notation "[ 'normedModType' K 'of' T ]" := (@clone _ (Phant K) T _ _ id)
  (at level 0, format "[ 'normedModType'  K  'of'  T ]") : form_scope.

End Exports.

End NormedModule.

Export NormedModule.Exports.

Program Definition R_AbsRingMixin :=
 @AbsRing.Mixin _ normr (normr0 _) (normrN1 _) (@ler_norm_add _) _ (@normr0_eq0 _).
Next Obligation. by rewrite normrM. Qed.
Canonical R_absRingType := AbsRingType R R_AbsRingMixin.

Definition R_UniformSpace_mixin := @AbsRingUniformMixin R_absRingType.
Canonical R_UniformSpace := UniformType R R_UniformSpace_mixin.
Canonical R_canonical_filter := @CanonicalFilter R R locally.
Canonical Ro_UniformSpace := UniformType R^o R_UniformSpace_mixin.
Canonical Ro_canonical_filter := @CanonicalFilter R R^o locally.

Definition norm {K : absRingType} {V : normedModType K} : V -> R :=
  NormedModule.norm (NormedModule.class _).
Definition norm_factor {K : absRingType} (V : normedModType K) : R :=
 @NormedModule.norm_factor _ _ _ (@NormedModule.class _ _ V).
Notation "`|[ x ]|" := (norm x) : ring_scope.

Section NormedModule1.
Context {K : absRingType} {V : normedModType K}.
Implicit Types (l : K) (x y : V) (eps : posreal).

Lemma ler_normm_add x y : `|[x + y]| <= `|[x]| + `|[y]|.
Proof. exact: NormedModule.ax1. Qed.
Definition norm_triangle := ler_normm_add. (*compat*)

Lemma ler_normmZ l x : `|[l *: x]| <= `|l|%real * `|[x]|.
Proof. exact: NormedModule.ax2. Qed.
Definition norm_scal := ler_normmZ. (*compat*)

Definition ball_norm x (eps : R) y := `|[x - y]| < eps.
Arguments ball_norm x eps%R y /.

Lemma sub_norm_ball_pos (x : V) (eps : posreal) : ball_norm x eps `<=` ball x eps.
Proof. move=> y; exact: NormedModule.ax3. Qed.
Definition norm_compat1 := sub_norm_ball_pos.

Lemma sub_ball_norm_pos (x : V) (eps : posreal) : ball x eps `<=` ball_norm x (norm_factor V * eps).
Proof. move=> y; exact: NormedModule.ax4. Qed.
Definition norm_compat2 := sub_ball_norm_pos.

Lemma normm0_eq0 x : `|[x]| = 0 -> x = 0.
Proof. exact: NormedModule.ax5. Qed.
Definition norm_eq_zero := normm0_eq0.

Lemma normmN x : `|[- x]| = `|[x]|.
Proof.
gen have le_absN1 : x / `|[- x]| <= `|[x]|.
  by rewrite -scaleN1r (ler_trans (ler_normmZ _ _)) //= absrN1 mul1r.
by apply/eqP; rewrite eqr_le le_absN1 /= -{1}[x]opprK le_absN1.
Qed.

Lemma normmB x y : `|[x - y]| = `|[y - x]|.
Proof. by rewrite -normmN opprB. Qed.

Lemma normm0 : `|[0 : V]| = 0.
Proof.
apply/eqP; rewrite eqr_le; apply/andP; split.
  by rewrite -{1}(scale0r 0) (ler_trans (ler_normmZ _ _)) ?absr0 ?mul0r.
by rewrite -(ler_add2r `|[0 : V]|) add0r -{1}[0 : V]add0r ler_normm_add.
Qed.
Definition norm_zero := normm0.
Hint Resolve normm0.

Lemma normm_eq0 x : (`|[x]| == 0) = (x == 0).
Proof. by apply/eqP/eqP=> [/normm0_eq0|->//]. Qed.

Lemma normm_ge0 x : 0 <= `|[x]|.
Proof.
rewrite -(@pmulr_rge0 _ 2%:R) // mulr2n mulrDl !mul1r.
by rewrite -{2}normmN (ler_trans _ (ler_normm_add _ _)) // subrr normm0.
Qed.

Lemma normm_gt0 x : (0 < `|[x]|) = (x != 0).
Proof. by rewrite ltr_def normm_eq0 normm_ge0 andbT. Qed.

Lemma normm_lt0 x : (`|[x]| < 0) = false.
Proof. by rewrite ltrNge normm_ge0. Qed.

Lemma norm_factor_gt_0 : 0 < norm_factor V.
Proof.
have /= := @sub_ball_norm_pos 0 [posreal of (1 : R)].
by move=> /(_ 0 (ball_center _ _)) /=; rewrite subrr normm0 mulr1.
Qed.
Canonical norm_factor_posreal := PosReal norm_factor_gt_0.

Lemma absRE (x : R) : `|x|%real = `|x|%R.
Proof. by []. Qed.

Lemma ler_distm_dist x y : `| `|[x]| - `|[y]| | <= `|[x - y]|.
Proof.
wlog gt_xy : x y / `|[x]| >= `|[y]| => [hw|].
  by have [/hw//|/ltrW/hw] := lerP `|[y]| `|[x]|; rewrite absRE distrC normmB.
rewrite absRE ger0_norm ?subr_ge0 // ler_subl_addr.
by rewrite -{1}[x](addrNK y) ler_normm_add.
Qed.
Definition norm_triangle_inv := ler_distm_dist.

Lemma sub_norm_ball (x : V) (eps : R) : ball_norm x eps `<=` ball x eps.
Proof.
move=> y /=; have [/ltr_le_trans lt /lt|eps_gt0] := ler0P eps.
  by rewrite normm_lt0.
by apply: (@sub_norm_ball_pos _ (PosReal eps_gt0)).
Qed.

Lemma sub_ball_norm_rev (x : V) (eps : posreal) :
  ball x ((norm_factor V)^-1 * eps) `<=` ball_norm x eps.
Proof. by move=> y /sub_ball_norm_pos /=; rewrite mulVKf. Qed.

Lemma closeE x y : close x y = (x = y).
Proof.
rewrite propeqE; split => [cl_xy|->//]; have [//|neq_xy] := eqVneq x y.
have dxy_gt0 : `|[x - y]| > 0 by rewrite normm_gt0 subr_eq0.
have dxy_ge0 := ltrW dxy_gt0.
have /sub_ball_norm_pos/= := cl_xy
  [posreal of ((norm_factor V)^-1 * (((PosReal dxy_gt0) : R) / 2%:R))%R].
rewrite mulVKf // -subr_lt0 ler_gtF //.
rewrite -[X in X - _]mulr1 -mulrBr mulr_ge0 //.
by rewrite subr_ge0 -(@ler_pmul2r _ 2%:R) // mulVf // mul1r ler1n.
Qed.
Lemma eq_close x y : close x y -> x = y. by rewrite closeE. Qed.

Definition locally_norm (x : V) (P : V -> Prop) :=
  exists eps : posreal, forall y, ball_norm x eps y -> P y.

Lemma locally_le_locally_norm x : filter_le (locally x) (locally_norm x).
Proof. by move=> P [e H]; eexists=> y Py; apply/H/sub_ball_norm_rev/Py. Qed.

Lemma locally_norm_le_locally x : filter_le (locally_norm x) (locally x).
Proof. by move=> P [e Pxe]; exists e => y /sub_norm_ball /Pxe. Qed.

(* NB: this lemmas was not here before *)
Lemma locally_locally_norm : locally_norm = locally.
Proof.
rewrite funeqE => x; rewrite funeqE => s; rewrite propeqE; split;
by [apply locally_le_locally_norm | apply locally_norm_le_locally].
Qed.

Lemma locally_norm_ball_norm x (e : posreal) : locally_norm x (ball_norm x e).
Proof. by exists e. Qed.

Lemma locally_norm_ball x (eps : posreal) : locally_norm x (ball x eps).
Proof. rewrite locally_locally_norm; by apply: locally_ball. Qed.

Lemma locally_ball_norm (x : V) (eps : posreal) : locally x (ball_norm x eps).
Proof. rewrite -locally_locally_norm; apply locally_norm_ball_norm. Qed.

Lemma ball_norm_triangle (x y z : V) (e1 e2 : R) :
  ball_norm x e1 y -> ball_norm y e2 z -> ball_norm x (e1 + e2) z.
Proof.
rewrite /ball_norm => H1 H2; rewrite (subr_trans y).
by rewrite (ler_lt_trans (ler_normm_add _ _)) ?ltr_add.
Qed.

Lemma ball_norm_center (x : V) (e : posreal) : ball_norm x e x.
Proof. apply/RltbP; rewrite subrr normm0; exact: cond_pos. Qed.

Lemma ball_norm_dec x y (e : R) : {ball_norm x e y} + {~ ball_norm x e y}.
Proof. exact: pselect. Qed.

Lemma ball_norm_sym x y (e : R) : ball_norm x e y -> ball_norm y e x.
Proof. by rewrite /ball_norm -opprB normmN. Qed.

Lemma ball_norm_le x (e1 e2 : R) :
  e1 <= e2 -> ball_norm x e1 `<=` ball_norm x e2.
Proof. by move=> e1e2 y /ltr_le_trans; apply. Qed.

Lemma norm_close x y : close x y = (forall eps : posreal, ball_norm x eps y).
Proof.
rewrite propeqE; split=> [cxy eps|cxy eps]; last exact: sub_norm_ball.
exact/sub_ball_norm_rev/cxy.
Qed.

Lemma ball_norm_eq x y : (forall eps : posreal, ball_norm x eps y) -> x = y.
Proof. by rewrite -norm_close closeE. Qed.

Lemma is_filter_lim_unique {F} {FF : ProperFilter F} :
  is_prop [set x : V | F --> x].
Proof. by move=> Fx Fy; rewrite -closeE; apply: is_filter_lim_close. Qed.

Lemma is_filter_lim_locally_unique (x y : V) : x --> y -> x = y.
Proof. move=> H; rewrite -closeE; by apply/is_filter_lim_locally_close. Qed.

End NormedModule1.

Section NormedModule2.

Context {T : Type} {K : absRingType} {V : normedModType K}.

Lemma filterlim_locally_unique {F} {FF : ProperFilter F} (f : T -> V) :
  is_prop [set x : V | f @ F --> x].
Proof. exact: is_filter_lim_unique. Qed.

Lemma filterlimi_locally_unique {F} {FF : ProperFilter F} (f : T -> V -> Prop) :
  F (fun x => is_prop (f x)) -> is_prop [set x : V | f `@ F --> x].
Proof.
move=> ffun fx fy; rewrite -closeE.
exact: (@filterlimi_locally_close _ _ _ _ f).
Qed.

End NormedModule2.
Hint Resolve normm_ge0.

(** Rings with absolute values are normed modules *)

Section AbsRing_NormedModule.

Variable (K : absRingType).
Implicit Types (x y : K) (eps : posreal).

Lemma sub_abs_ball x y eps : `|x - y| < eps -> ball x eps y.
Proof. by []. Qed.

Lemma sub_ball_abs x y eps : ball x eps y -> `|x - y| < 1 * pos eps.
Proof. by rewrite mul1r. Qed.

Definition AbsRing_NormedModMixin := @NormedModule.Mixin K _ _
  (abs : K^o -> R) 1 ler_abs_add absrM sub_abs_ball sub_ball_abs absr0_eq0.

Canonical AbsRing_NormedModType := NormedModType K K^o AbsRing_NormedModMixin.

End AbsRing_NormedModule.

(* Quick fix for non inferred instances *)
(* This does not fix everything, see below *)
Instance NormedModule_locally_filter (K : absRingType) (V : normedModType K)
  (p : V) :
  @ProperFilter (@NormedModule.sort K (Phant K) V)
  (@locally (@NormedModule.uniformType K (Phant K) V) p).
Proof. exact: locally_filter. Qed.

(** Normed vector spaces have some continuous functions *)

Section NVS_continuity.

Context {K : absRingType} {V : normedModType K}.

Lemma filterlim_locally_norm
  {F : set (set V)} {FF : Filter F} (y : V) :
  F --> y <-> forall eps : posreal, F (ball_norm y eps).
Proof.
rewrite /filter_of /= -locally_locally_norm.
split => [Fy eps|Fy P [e yP]]; first by apply: Fy; exists eps.
exact: filter_imp (Fy e).
Qed.

Lemma filterlim_locally_norm'
  {F : set (set V)} {FF : Filter F} (y : V) :
  F --> y -> forall eps : posreal, F (ball_norm y eps).
Proof.
rewrite /filter_of /= -locally_locally_norm.
by move=> Fy eps; apply: Fy; exists eps.
Qed.

(* :TODO: put again filter inside uniform type and prove this instead: *)
(* Lemma filterlim_plus (x y : V) : continuous (fun z : V * V => z.1 + z.2). *)
Lemma filterlim_plus (x y : V) : z.1 + z.2 @[z --> (x, y)] --> x + y.
Proof.
apply/filterlim_locally_norm=> e; rewrite /ball_norm appfilter /=.
near z.
rewrite opprD addrACA (double_var e) (ler_lt_trans (ler_normm_add _ _)) //.
rewrite ltr_add //.
rewrite -/(ball_norm _ _ _).
apply: filterlim_locally_norm'.
have_near (@filterlim_fst _ _ _ _ _).
have /filterlim_locally_norm /(_ [posreal of e / 2]%coqR) :=
   !! @filterlim_fst _ _ (locally x) (locally y) _.
  move=> H.
  have_near x H.
move=> /filterP [Q1].
rewrite appfilter /= => A.
apply.
admit.
have /filterlim_locally_norm /(_ [posreal of e / 2]%coqR) :=
   !! @filterlim_snd _ _ (locally x) (locally y) _.
move=> /filterP [Q2].
rewrite appfilter /= => B.
apply.
Admitted.

(* apply (filterlim_filter_le_1 (F := filter_prod (locally_norm x) (locally_norm y))). *)
(*   intros P [Q R LQ LR H]. *)
(*   exists Q R. *)
(*   now apply locally_le_locally_norm. *)
(*   now apply locally_le_locally_norm. *)
(*   exact H. *)
(* apply (filterlim_filter_le_2 (G := locally_norm (x + y))). *)
(*   apply locally_norm_le_locally. *)
(* intros P [eps HP]. *)
(* exists (ball_norm x [posreal of eps / 2]) (ball_norm y [posreal of eps / 2]). *)
(* by apply locally_norm_ball_norm. *)
(* by apply locally_norm_ball_norm. *)
(* intros u v Hu Hv. *)
(* apply HP. *)
(* rewrite /ball_norm /= (double_var eps). *)
(* by rewrite opprD addrACA (ler_lt_trans (ler_normm_add _ _)) ?ltr_add. *)
(* Qed. *)

Lemma filterlim_scal (k : K) (x : V) : z.1 *: z.2 @[z --> (k, x)] --> k *: x.
Proof.
apply/filterlim_locally_norm=> /= eps; rewrite appfilter /=.
near => z ?; rewrite /ball_norm /= (@subr_trans _ (k *: z.2)).
rewrite (double_var eps) (ler_lt_trans (ler_normm_add _ _)) //.
rewrite ltr_add // -?(scalerBr, scalerBl).
  rewrite (ler_lt_trans (ler_normmZ _ _)) //.
  rewrite (ler_lt_trans (ler_pmul _ _ (_ : _ <= `|k|%real + 1)  (lerr _))) //.
    by rewrite ler_addl.
  rewrite -ltr_pdivl_mull // ?(ltr_le_trans ltr01) ?ler_addr //.
  rewrite -/(ball_norm _ _ _).
  have_near x
  instantiate (FQ := filter_and _ _).
  exact: proj1 Qz.
rewrite (ler_lt_trans (ler_normmZ _ _)) //.
rewrite (ler_lt_trans (ler_pmul _ _ (lerr _) (_ : _ <= `|[x]| + 1))) //.
  admit.
rewrite -ltr_pdivl_mulr // ?(ltr_le_trans ltr01) ?ler_addr //.
rewrite -/(ball_norm (k : K^o) _ z.1).
apply: proj2 Qz.
Unshelve.
  by rewrite /F; typeclasses eauto.


Admitted.



pose Q :=

apply/filterlim_locally => /= eps.
set P := (fun u : K * V => (abs (u.1 - k) < pos eps / 2 / (norm x + 1) /\
           abs (u.1 - k) < 1) /\
         (norm (u.2 - x) < pos eps / 2 / (abs k + 1))).
apply: (@filter_imp _ _ _ P).
- move => /= u Hu.
  rewrite (double_var eps).
  apply (@ball_triangle _ _ (u.1 *: x)).
  + apply norm_compat1.
    rewrite /ball_norm -scalerBl.
    apply: ler_lt_trans; first by apply norm_scal.
    apply (@ler_lt_trans _ (`|k - u.1|%real * (`|[x]| + 1))).
    by rewrite ler_pmul // ?absr_ge0 // ?normm_ge0 // ler_addl.
    rewrite -ltr_pdivl_mulr; last by rewrite ltr_paddl // normm_ge0.
    move: (proj1 (proj1 Hu)).
    by rewrite absrB /= RdivE.
  + apply norm_compat1.
    rewrite /ball_norm -scalerBr.
    apply: ler_lt_trans; first by apply norm_scal.
    apply (@ler_lt_trans _ ((`|k|%real + 1) * `|[x - u.2]|)).
      rewrite ler_pmul // ?absr_ge0 // ?normm_ge0 //.
      rewrite (_ : `|u.1| = `|k + ((u.1) - k)|); last by rewrite addrCA subrr addr0.
      apply: (@ler_trans _ _); first by apply ler_abs_add.
      rewrite ler_add // ltrW //; exact: (proj2 (proj1 Hu)).
    rewrite mulrC -ltr_pdivl_mulr; last by rewrite ltr_paddl // absr_ge0.
    by rewrite /= RdivE // normmB; exact: (proj2 Hu).
- have x1 : `|[x]| + 1 != 0 by rewrite lt0r_neq0 // ltr_paddl // normm_ge0.
  have k1 : `|k|%real + 1 != 0 by rewrite lt0r_neq0 // ltr_paddl // absr_ge0.
  repeat apply filter_and.
  + have Hd : (0 < pos eps / 2 / (norm x + 1))%coqR.
      apply/RltP; rewrite RdivE RplusE //.
      by rewrite divr_gt0 // ltr_paddl // normm_ge0.
    eexists => /=.
    * exact: (@locally_ball_norm _ (AbsRing_NormedModType K) _ (mkposreal _ Hd)).
    * by apply: filter_true.
    * move=> x0 y /= x0y _; move: x0y.
      by rewrite /ball_norm -RplusE absrB RdivE // RdivE.
  + eexists => /=.
    * exact (@locally_ball_norm _ (AbsRing_NormedModType K) _ [posreal of 1]).
    * by apply: filter_true.
    * move=> x0 y /=; by rewrite /ball_norm -absrB.
  + have Hd : (0 < eps / 2 / (abs k + 1))%coqR.
      apply/RltP.
      rewrite RdivE; last by rewrite lt0r_neq0 // RplusE // ltr_paddl // absr_ge0.
      by rewrite divr_gt0 // ltr_paddl // absr_ge0.
    eexists.
    * by apply: filter_true.
    * by apply (locally_ball_norm _ (mkposreal _ Hd)).
    * move=> x0 y /= _; by rewrite /ball_norm RplusE RdivE // RdivE // normmB.
Qed.

Lemma filterlim_scal_r (k : K) (x : V) : k *: z @[z --> x] --> k *: x.
Proof.
eapply filterlim_comp_2.
by apply filterlim_const.
by apply filterlim_id.
by apply filterlim_scal.
Qed.

Lemma filterlim_scal_l (l : K) (x : V) : k *: x @[k --> l] --> l *: x.
Proof.
eapply filterlim_comp_2.
by apply filterlim_id.
by apply filterlim_const.
by apply filterlim_scal.
Qed.

Lemma filterlim_opp (x : V) : (@GRing.opp V) @ x --> - x.
Proof.
rewrite -scaleN1r.
apply filterlim_ext with (2 := @filterlim_scal_r _ _) => /= x0.
by rewrite scaleN1r.
Qed.

End NVS_continuity.

Lemma filterlim_mult {K : absRingType} (x y : K) :
   z.1 * z.2 @[z --> (x, y)] --> x * y.
Proof. exact: (@filterlim_scal _ (AbsRing_NormedModType K)). Qed.


Lemma filterlim_locally_ball_norm {K : absRingType} {T} {U : normedModType K}
  {F : set (set T)} {FF : Filter F} (f : T -> U) (y : U) :
  f @ F --> y <-> forall eps : posreal, F (fun x => ball_norm y eps (f x)).
Proof.
(* use locally = locally_norm *)
split.
- intros Cf eps.
  apply (Cf (fun x => ball_norm y eps x)).
  by apply/locally_le_locally_norm/locally_norm_ball_norm.
- intros Cf.
  apply: filterlim_filter_le_2; first by apply: locally_norm_le_locally.
  move=> P [eps He].
  apply: filter_imp (Cf eps) => t; by apply He.
Qed.

(** ** Complete Normed Modules *)

Module CompleteNormedModule.

Section ClassDef.

Variable K : absRingType.

Record class_of (T : Type) := Class {
  base : NormedModule.class_of K T ;
  mixin : Complete.axiom (Uniform.Pack base T)
}.
Local Coercion base : class_of >-> NormedModule.class_of.
Definition base2 T (cT : class_of T) : Complete.class_of T :=
  @Complete.Class _ (@base T cT) (@mixin T cT).
Local Coercion base2 : class_of >-> Complete.class_of.

Structure type (phK : phant K) := Pack { sort; _ : class_of sort ; _ : Type }.
Local Coercion sort : type >-> Sortclass.

Variables (phK : phant K) (cT : type phK) (T : Type).

Definition class := let: Pack _ c _ := cT return class_of cT in c.

Definition pack :=
  fun bT b & phant_id (@NormedModule.class K phK bT) (b : NormedModule.class_of K T) =>
  fun mT m & phant_id (@Complete.class mT) (@Complete.Class T b m) =>
    Pack phK (@Class T b m) T.
Let xT := let: Pack T _ _ := cT in T.
Notation xclass := (class : class_of xT).

Definition eqType := @Equality.Pack cT xclass xT.
Definition choiceType := @Choice.Pack cT xclass xT.
Definition zmodType := @GRing.Zmodule.Pack cT xclass xT.
Definition lmodType := @GRing.Lmodule.Pack K phK cT xclass xT.
Definition uniformType := @Uniform.Pack cT xclass xT.
Definition join_zmodType := @GRing.Zmodule.Pack uniformType xclass xT.
Definition join_lmodType := @GRing.Lmodule.Pack K phK uniformType xclass xT.
Definition normedModType := @NormedModule.Pack K phK cT xclass xT.
Definition join_uniformType := @Uniform.Pack normedModType xclass xT.
End ClassDef.

Module Exports.

Coercion base : class_of >-> NormedModule.class_of.
Coercion base2 : class_of >-> Complete.class_of.
Coercion sort : type >-> Sortclass.
Coercion eqType : type >-> Equality.type.
Canonical eqType.
Coercion choiceType : type >-> Choice.type.
Canonical choiceType.
Coercion zmodType : type >-> GRing.Zmodule.type.
Canonical zmodType.
Coercion lmodType : type >-> GRing.Lmodule.type.
Canonical lmodType.
Coercion uniformType : type >-> Uniform.type.
Canonical uniformType.
Canonical join_zmodType.
Canonical join_lmodType.
Coercion normedModType : type >-> NormedModule.type.
Canonical normedModType.
Canonical join_uniformType.
Definition type_canonical_filter
   (K : absRingType) (phK : phant K) (T : type phK) :=
  @CanonicalFilter T T locally.
Coercion type_canonical_filter : type >-> canonical_filter.
Canonical type_canonical_filter.
Notation completeNormedModType K := (type (Phant K)).
Notation "[ 'completeNormedModType' K 'of' T ]" := (@pack _ (Phant K) T _ _ id _ _ id)
  (at level 0, format "[ 'completeNormedModType'  K  'of'  T ]") : form_scope.

End Exports.

End CompleteNormedModule.

Export CompleteNormedModule.Exports.

Section CompleteNormedModule1.

Context {K : absRingType} {V : completeNormedModType K}.

Lemma get_correct (P : V -> Prop) :
  (exists! x : V, P x) -> P (get P).
Proof. by move=> [x [Px _]]; exact: getP Px. Qed.
Definition iota_correct := get_correct.

Lemma get_is_filter_lim {F} {FF : ProperFilter F} (l : V) :
  F --> l -> lim F = l.
Proof.
move=> Fl; have FlF : F --> lim F by rewrite -cvgE; exists l.
by apply: is_filter_lim_unique.
Qed.

Context {T : Type}.

Lemma get_filterlim_locally {F} {FF : ProperFilter F} (f : T -> V) l :
  f @ F --> l -> lim (f @ F) = l.
Proof. exact: get_is_filter_lim. Qed.

Lemma get_filterlimi_locally {F} {FF : ProperFilter F} (f : T -> V -> Prop) l :
  F (fun x => is_prop (f x)) ->
  f `@ F --> l -> lim (f `@ F) = l.
Proof.
move=> f_prop f_l; apply: get_unique => // l' f_l'.
exact: filterlimi_locally_unique _ f_l' f_l.
Qed.

End CompleteNormedModule1.

(** * Extended Types *)

(** ** Pairs *)

(* TODO a prouver dans Rstruct pour prouver norm_compat1 and norm_compat2 *)
Lemma sqrt_plus_sqr (x y : R) :
  maxr `|x| `|y| <= Num.sqrt (x^+2 + y^+2) <= Num.sqrt 2%:R * maxr `|x| `|y|.
Proof.
rewrite -(@ler_pexpn2r _ 2) ?nnegrE ?sqrtr_ge0 ?ler_maxr ?normr_ge0 // andbC.
rewrite -(@ler_pexpn2r _ 2) ?nnegrE ?mulr_ge0 ?sqrtr_ge0 ?ler_maxr ?normr_ge0 //.
rewrite sqr_sqrtr ?addr_ge0 // ?sqr_ge0 //.
wlog : x y / `|x| <= `|y| => H.
  case: (lerP `|x| `|y|) => yx; first by rewrite H.
  by rewrite maxrC addrC H // ltrW.
rewrite maxr_r ?real_normK ?num_real ?ler_addr ?sqr_ge0 // andbT.
rewrite exprMn_comm ?sqr_sqrtr //; last by rewrite /GRing.comm mulrC.
rewrite -(@real_normK _ x) ?num_real // -{1}(@real_normK _ y) ?num_real //.
by rewrite mulr_natl mulr2n ler_add // ler_pexpn2r // ?num_real ?nnegrE.
Qed.

Section prod_NormedModule.

Context {K : absRingType} {U V : normedModType K}.

Definition prod_norm (x : U * V) := Num.sqrt (`|[x.1]| ^+ 2 + `|[x.2]| ^+ 2).

Lemma prod_norm_triangle : forall x y : U * V, prod_norm (x + y) <= prod_norm x + prod_norm y.
Proof.
intros [xu xv] [yu yv].
rewrite /prod_norm /=.
apply (@ler_trans _ (Num.sqrt ((`|[xu]| + `|[yu]|)^+2 + (`|[xv]| + `|[yv]|)^+2))).
  by rewrite ler_wsqrtr // ler_add // ler_pexpn2r //
     ?nnegrE ?addr_ge0 // ?normm_ge0 // ?norm_triangle.
set a := `|[xu]|. set b := `|[yu]|. set c := `|[xv]|. set d := `|[yv]|.
rewrite -(@ler_pexpn2r _ 2) // ?nnegrE ?ler_add ?addr_ge0 // ?sqrtr_ge0 //.
rewrite sqr_sqrtr ?addr_ge0 // ?sqr_ge0 // [in X in _ <= X]sqrrD.
rewrite !sqr_sqrtr // ?addr_ge0 // ?sqr_ge0 //.
rewrite 2!sqrrD -!addrA ler_add //.
rewrite (addrCA _ (c^+2)) 2!addrCA ler_add //.
rewrite 2!addrCA 2!(addrCA _ (b^+2)) ler_add //.
rewrite !addrA ler_add //.
rewrite -mulr2n -addrA -mulr2n -mulr2n -mulrnDl ler_muln2r /=.
rewrite -sqrtrM ?addr_ge0 // ?sqr_ge0 //.
rewrite -(@ler_pexpn2r _ 2) // ?nnegrE ?sqrtr_ge0 ?addr_ge0 ?mulr_ge0 ?normm_ge0 //.
rewrite sqr_sqrtr ?mulr_ge0 ?addr_ge0 ?sqr_ge0 //.
rewrite sqrrD [in X in _ <= X]mulrDr 2![in X in _ <= X]mulrDl.
rewrite -exprMn_comm ?/GRing.comm; last by rewrite mulrC.
rewrite -!addrA ler_add //.
rewrite -(@exprMn_comm _ c d) ?/GRing.comm; last by rewrite mulrC.
rewrite !addrA ler_add // -mulr2n.
rewrite -(@exprMn_comm _ c b) ?/GRing.comm; last by rewrite mulrC.
rewrite -(@exprMn_comm _ a d) ?/GRing.comm; last by rewrite mulrC.
rewrite -subr_ge0 addrAC.
by rewrite mulrCA (mulrC a b) -mulrA mulrA -sqrrB ?sqr_ge0.
Qed.

Lemma prod_norm_scal (l : K) : forall (x : U * V), prod_norm (l *: x) <= abs l * prod_norm x.
Proof.
case=> xu xv; rewrite /prod_norm /=.
rewrite -(@ler_pexpn2r _ 2) // ?nnegrE ?mulr_ge0 ?sqrtr_ge0 ?absr_ge0 //.
rewrite sqr_sqrtr ?addr_ge0 ?sqr_ge0 //.
rewrite exprMn_comm ?/GRing.comm; last by rewrite mulrC.
rewrite sqr_sqrtr ?addr_ge0 // ?sqr_ge0 // mulrDr.
rewrite -exprMn_comm ?/GRing.comm; last by rewrite mulrC.
rewrite -exprMn_comm ?/GRing.comm; last by rewrite mulrC.
by rewrite ler_add // ler_pexpn2r // ?nnegrE ?mulr_ge0 ?absr_ge0 ?normm_ge0 // ?ler_normmZ.
Qed.

Lemma prod_norm_compat1 : forall (x y : U * V) (eps : R),
  prod_norm (x - y) < eps -> ball x eps y.
Proof.
move=> [xu xv] [yu yv] eps H.
set x := `|[yu - xu]|. set y := `|[yv - xv]|.
rewrite /prod_norm normmB (normmB xv) in H.
case/andP: (sqrt_plus_sqr x y) => /ler_lt_trans/(_ H) => H1.
have /RltbP He : 0 < eps by apply: (ler_lt_trans _ H); rewrite sqrtr_ge0.
rewrite (_ : eps = mkposreal _ He) // => H2.
split; apply: norm_compat1; apply: (ler_lt_trans _ H1).
by rewrite ler_maxr /x normmB real_ler_norm // ger0_real // normm_ge0.
by rewrite ler_maxr orbC /y normmB real_ler_norm // ger0_real // normm_ge0.
Qed.

Definition prod_norm_factor :=
  Num.sqrt 2%:R * maxr (@norm_factor K U) (@norm_factor K V).

Lemma prod_norm_compat2 : forall (x y : U * V) (eps : posreal),
  ball x eps y -> (prod_norm (x - y) < prod_norm_factor * eps).
Proof.
move=> [xu xv] [yu yv] eps [Bu Bv].
set x := `|[xu - yu]|. set y := `|[xv - yv]|.
case/andP: (sqrt_plus_sqr x y) => H1 H2; apply: (ler_lt_trans H2).
rewrite /prod_norm_factor -mulrA.
rewrite -subr_gt0 -mulrBr pmulr_rgt0 // ?sqrtr_gt0 // subr_gt0 maxr_pmull //.
case: (lerP `|y| `|x|) => yx.
  rewrite [in X in X < _]maxr_l //.
  rewrite (@ltr_le_trans _ (norm_factor U * eps)) ?ler_maxr ?lerr //.
  rewrite ger0_norm ?normm_ge0 //; exact: norm_compat2.
rewrite (@maxr_r _ _ `|y|%R); last by rewrite ltrW.
rewrite (@ltr_le_trans _ (norm_factor V * eps)) // ?ler_maxr ?lerr ?orbT //.
rewrite ger0_norm ?normm_ge0 //; exact: norm_compat2.
Qed.

Lemma prod_norm_eq_zero : forall x : U * V, prod_norm x = 0 -> x = 0.
Proof.
move=> [xu xv] /eqP H.
rewrite sqrtr_eq0 ler_eqVlt ltrNge addr_ge0  ?sqr_ge0 // orbF in H.
rewrite paddr_eq0 ?sqr_ge0 // 2!sqrf_eq0 /= 2!normm_eq0 in H.
by case/andP : H => /eqP -> /eqP ->.
Qed.

End prod_NormedModule.

Definition prod_NormedModule_mixin (K : absRingType) (U V : normedModType K) :=
  @NormedModMixin K _ _ (@prod_norm K U V) prod_norm_factor prod_norm_triangle
  prod_norm_scal prod_norm_compat1 prod_norm_compat2 prod_norm_eq_zero.

Canonical prod_NormedModule (K : absRingType) (U V : normedModType K) :=
  NormedModType K (U * V) (@prod_NormedModule_mixin K U V).

Lemma norm_prod {K : absRingType} {U : normedModType K} {V : normedModType K}
  (x : U) (y : V) :
  maxr `|[ x ]| `|[ y ]| <= `|[(x, y)]| <= Num.sqrt 2%:R * maxr `|[x]| `|[y]|.
Proof.
rewrite -(Rabs_pos_eq (norm x)); last by apply/RlebP/normm_ge0.
rewrite -(Rabs_pos_eq (norm y)); last by apply/RlebP/normm_ge0.
by apply sqrt_plus_sqr.
Qed.

(** ** Iterated Products *)

Fixpoint Tn (n : nat) (T : Type) : Type :=
  match n with
  | O => unit
  | S n => prod T (Tn n T)
  end.

Notation "[ x1 , .. , xn ]" := (pair x1 .. (pair xn tt) .. ).

Fixpoint mk_Tn {T} (n : nat) (u : nat -> T) : Tn n T :=
  match n with
    | O => (tt : Tn O T)
    | S n => (u O, mk_Tn n (fun n => u (S n)))
  end.
Fixpoint coeff_Tn {T} {n : nat} (x0 : T) : (Tn n T) -> nat -> T :=
  match n with
  | O => fun (_ : Tn O T) (_ : nat) => x0
  | S n' => fun (v : Tn (S n') T) (i : nat) => match i with
           | O => fst v
           | S i => coeff_Tn x0 (snd v) i
           end
  end.
Lemma mk_Tn_bij {T} {n : nat} (x0 : T) (v : Tn n T) :
  mk_Tn n (coeff_Tn x0 v) = v.
Proof.
  induction n ; simpl.
  now apply unit_ind.
  rewrite IHn ; by destruct v.
Qed.
Lemma coeff_Tn_bij {T} {n : nat} (x0 : T) (u : nat -> T) :
  forall i, (i < n)%coq_nat -> coeff_Tn x0 (mk_Tn n u) i = u i.
Proof.
  revert u ; induction n => /= u i Hi.
  by apply lt_n_O in Hi.
  destruct i.
  by [].
  now apply (IHn (fun n => u (S n))), lt_S_n.
Qed.
Lemma coeff_Tn_ext {T} {n : nat} (x1 x2 : T) (v1 v2 : Tn n T) :
  v1 = v2 <-> forall i, (i < n)%coq_nat -> coeff_Tn x1 v1 i = coeff_Tn x2 v2 i.
Proof.
  split.
  + move => -> {v1}.
    induction n => i Hi.
    by apply lt_n_O in Hi.
    destruct i ; simpl.
    by [].
    by apply IHn, lt_S_n.
  + induction n => H.
    apply unit_ind ; move: (v1) ; now apply unit_ind.
    apply injective_projections.
    by apply (H O), lt_O_Sn.
    apply IHn => i Hi.
    by apply (H (S i)), lt_n_S.
Qed.
Lemma mk_Tn_ext {T} (n : nat) (u1 u2 : nat -> T) :
  (forall i, (i < n)%coq_nat -> (u1 i) = (u2 i))
    <-> (mk_Tn n u1) = (mk_Tn n u2).
Proof.
  move: u1 u2 ; induction n ; simpl ; split ; intros.
  by [].
  by apply lt_n_O in H0.
  apply f_equal2.
  by apply H, lt_O_Sn.
  apply IHn => i Hi.
  by apply H, lt_n_S.
  destruct i.
  by apply (f_equal (@fst _ _)) in H.
  move: i {H0} (lt_S_n _ _ H0).
  apply IHn.
  by apply (f_equal (@snd _ _)) in H.
Qed.

(*
Global Instance AbelianGroup_Tn {T} :
  AbelianGroup T -> forall n, AbelianGroup (Tn n T) | 10.
Proof.
  intro GT.
  elim => /= [ | n IH].
  - apply Build_AbelianGroup with (fun _ _ => tt) (fun _ => tt) tt ; auto.
    by apply unit_ind.
  - by apply AbelianGroup_prod.
Defined.

Global Instance MetricBall_Tn :
  forall T, MetricBall T -> forall n, MetricBall (Tn n T) | 10.
Proof.
intros T MT n.
elim: n => [ | n MTn].
by apply Build_MetricBall with (fun _ _ _ => True).
by apply MetricBall_prod.
Defined.

Global Instance VectorSpace_mixin_Tn {T} {K} {FK : Ring K} :
  forall GT : AbelianGroup T,
  VectorSpace_mixin T K GT ->
  forall n, VectorSpace_mixin (Tn n T) K (AbelianGroup_Tn GT n) | 10.
Proof.
  intros GT VV.
  elim => [ | n VVn].
  apply Build_VectorSpace_mixin with (fun _ _ => tt) ; by apply unit_ind.
  by apply VectorSpace_mixin_prod.
Defined.

Global Instance VectorSpace_Tn {T} {K} {FK : Ring K} :
  VectorSpace T K -> forall n, VectorSpace (Tn n T) K | 10.
Proof.
  intros VV n.
  apply Build_VectorSpace with (AbelianGroup_Tn _ n).
  now apply VectorSpace_mixin_Tn, VV.
Defined.

Global Instance NormedVectorSpace_Tn {T} {K} {FK : absRingType K} :
  NormedVectorSpace T K ->
  forall n, NormedVectorSpace (Tn n T) K | 10.
Proof.
  move => VT.
  elim => [ | n NVTn].
  - econstructor.
    apply Build_NormedVectorSpace_mixin with (fun _ => 0).
    move => _ _.
    rewrite Rplus_0_l ; by apply Rle_refl.
    move => l _ ; rewrite Rmult_0_r ; by apply Rle_refl.
    easy.
    exists [posreal of 1].
    intros x y eps _.
    rewrite Rmult_1_l.
    apply cond_pos.
  - by apply NormedVectorSpace_prod.
Defined.
*)

(** *)

Fixpoint Fn (n : nat) (T U : Type) : Type :=
  match n with
  | O => U
  | S n => T -> Fn n T U
  end.

(*
Global Instance MetricBall_Fn {T M} (n : nat) :
  MetricBall M -> MetricBall (Fn n T M) | 10.
Proof.
  intros MM.
  elim: n => /= [ | n IHn].
  exact MM.
  exact (MetricBall_fct IHn).
Defined.
*)

(** * The topology on natural numbers *)

Definition eventually (P : nat -> Prop) :=
  exists N : nat, forall n, (N <= n)%coq_nat -> P n.

Notation "'\oo'" := eventually : classical_set_scope.

Global Instance eventually_filter : ProperFilter eventually.
Proof.
constructor.
  by case => n; apply; apply le_refl.
constructor.
- by exists O.
- move=> P Q [NP HP] [NQ HQ].
  exists (max NP NQ) => n Hn; split.
  by apply/HP/(le_trans _ _ _ _ Hn)/Max.le_max_l.
  by apply/HQ/(le_trans _ _ _ _ Hn)/Max.le_max_r.
- by move=> P Q H [NP HP]; exists NP => n Hn; apply/H/HP.
Qed.

(** * The topology on real numbers *)

Definition R_AbsRing_mixin :=
  @AbsRingMixin [ringType of R] _ absr0 absrN1 ler_abs_add absrM absr0_eq0.

Canonical R_AbsRing := @AbsRingType R R_AbsRing_mixin.

Definition R_uniformType_mixin := AbsRingUniformMixin R_AbsRing.

Canonical R_uniformType := UniformType R R_uniformType_mixin.
(*NB: already exists Canonical R_canonical_filter := @CanonicalFilter R R locally.*)

(* TODO: Remove R_complete_lim and use lim instead *)
Definition R_complete_lim (F : (R -> Prop) -> Prop) : R :=
  real (Lub_Rbar (fun x : R => F (ball (x + 1) [posreal of 1]))).

Lemma R_complete_ax1 (F : set (set R)) : ProperFilter F ->
  (forall eps : posreal, exists x : R, F (ball x eps)) ->
  forall eps : posreal, F (ball (R_complete_lim F) eps).
Proof.
move=> FF HF eps.
rewrite /R_complete_lim.
move: (Lub_Rbar_correct (fun x : R => F (ball (x + 1) [posreal of 1]))).
move Hl : (Lub_Rbar _) => l{Hl}; move: l => [x| |] [Hx1 Hx2].
- case: (HF [posreal of Rmin 2 eps / 2]) => z Hz.
  have H1 : z - Num.min 2 eps / 2 + 1 <= x + 1.
    rewrite ler_add //; apply/RlebP/Hx1.
    apply: filter_imp Hz.
    rewrite /ball /= => u /RltbP.
    rewrite absrB absRE => /(Rabs_lt_between' u z) => Bu.
    apply/RltbP; rewrite absrB; apply/Rabs_lt_between'.
    case: Bu => {Hx1 Hx2 FF HF x F} Bu1 Bu2.
    have H := Rmin_l 2 eps.
    rewrite !(RminE,RplusE,RoppE,RdivE,RminusE) //= in Bu1 Bu2 H *.
    move/RltP in Bu2. move/RleP in H. move/RltP in Bu1.
    rewrite addrK -addrA; split; apply/RltP => //.
    move/(ltr_le_trans) : Bu2; apply.
    rewrite addrAC ler_subr_addl addrA addrCA -addrA.
    by rewrite ler_add // ler_add // ler_pdivr_mulr // ?mul1r.
  have H2 : x + 1 <= z + Rmin 2 eps / 2 + 1.
    rewrite ler_add //; apply/RlebP/(Hx2 (Finite _)) => v Hv.
    apply Rbar_not_lt_le => Hlt.
    apply: filter_not_empty.
    apply: filter_imp (filter_and Hz Hv).
    rewrite /ball /= => w [/RltbP Hw1 /RltbP Hw2].
    move: Hw1; rewrite absrB absRE => /(Rabs_lt_between' w z) => -[_ Hw1].
    move: Hw2; rewrite absrB => /(Rabs_lt_between' w (v + 1)) => -[Hw2 _].
    rewrite {F FF HF Hx1 Hx2 Hz Hv H1 x}.
    rewrite !(RplusE,RminusE,RdivE) //= in Hw2 Hw1 Hlt.
    rewrite addrK in Hw2.
    move/RltP in Hw1. move/RltP in Hlt. move/RltP in Hw2.
    move: (ltr_trans (ltr_trans Hw1 Hlt) Hw2); by rewrite ltrr.
  apply: filter_imp Hz.
  rewrite /ball /= => u.
  move/RltbP; rewrite absrB absRE => /(Rabs_lt_between' u z) => Hu.
  apply/RltbP/Rabs_lt_between'.
  case: Hu {Hx1 Hx2 F FF HF} => H H0.
  rewrite !(RminusE,RplusE).
  move/RltP in H0.
  have /RleP := Rmin_r 2 eps. rewrite RminE => H4.
  split; apply/RltP.
  - move: H1; rewrite -ler_subr_addr addrK ler_subl_addr => H1.
    rewrite ltr_subl_addr // (ltr_le_trans H0) //.
    rewrite !(RplusE,RdivE,RminE) // -ler_subr_addr (ler_trans H1) //.
    rewrite -ler_subr_addl -!addrA (addrC x) !addrA subrK.
    rewrite ler_subr_addr -mulrDl ler_pdivr_mulr //.
    by rewrite -mulr2n -mulr_natl mulrC ler_pmul.
  - move: H2; rewrite -ler_subr_addr addrK.
    move/ler_lt_trans; apply.
    move/RltP : H; rewrite !(RminusE,RdivE,RminE) // ltr_subl_addr => H.
    rewrite -ltr_subr_addr (ltr_le_trans H) //.
    rewrite addrC -ler_subr_addr -!addrA (addrC u) !addrA subrK.
    rewrite -ler_subl_addr opprK -mulrDl ler_pdivr_mulr // -mulr2n -mulr_natl.
    by rewrite mulrC ler_pmul.
- case (HF [posreal of 1]) => y Fy.
  case: (Hx2 (y + 1)) => x Fx.
  apply Rbar_not_lt_le => Hlt.
  apply: filter_not_empty.
  apply: filter_imp (filter_and Fy Fx) => z [Hz1 Hz2].
  apply: Rbar_le_not_lt Hlt.
  apply Rplus_le_reg_r with (-(y - 1)).
  rewrite opprB 2!RplusE (addrC (y + 1)) !addrA subrK.
  apply Rabs_le_between.
  apply/RleP.
  rewrite ltrW //.
  move: (@ball_triangle _ y z (x + 1) 1 1).
  rewrite {3}/ball /Uniform.ball /= /AbsRing_ball absrB; apply.
  + by apply Hz1.
  + move/ball_sym: Hz2; by apply.
- case: (HF [posreal of 1]) => y Fy.
  case: (Hx1 (y - 1)); by rewrite addrAC addrK.
Qed.

Lemma R_complete (F : (R -> Prop) -> Prop) :
  ProperFilter F -> cauchy F -> F --> lim F.
Proof.
move=> FF F_cauchy; rewrite -cvgE.
exists (R_complete_lim F).
apply/filterlim_locally => /=.
exact: R_complete_ax1.
Qed.

Canonical R_completeType := CompleteType R R_complete.

Canonical R_NormedModule := [normedModType R of R^o].
Canonical R_CompleteNormedModule := [completeNormedModType R of R^o].

Definition at_left x := within (fun u : R => Rlt u x) (locally x).
Definition at_right x := within (fun u : R => Rlt x u) (locally x).

Global Instance at_right_proper_filter : forall (x : R),
  ProperFilter (at_right x).
Proof.
move=> x.
constructor; last by apply within_filter, locally_filter.
case=> d /(_ (x + pos d / 2)).
apply; last by apply/RltP; rewrite ltr_addl.
apply sub_abs_ball.
rewrite opprD !addrA subrr add0r absrN.
rewrite absRE normf_div !ger0_norm //.
rewrite ltr_pdivr_mulr // ltr_pmulr //.
by rewrite (_ : 2 = 2%:R) // (_ : 1 = 1%:R) // ltr_nat.
Qed.

Global Instance at_left_proper_filter : forall (x : R),
  ProperFilter (at_left x).
move=> x.
constructor; last by apply within_filter, locally_filter.
case=> d /(_ (x - pos d / 2)).
apply; last by apply/RltP; rewrite ltr_subl_addl ltr_addr.
apply sub_abs_ball.
rewrite opprD !addrA subrr add0r opprK.
rewrite absRE normf_div !ger0_norm //.
rewrite ltr_pdivr_mulr // ltr_pmulr //.
by rewrite (_ : 2 = 2%:R) // (_ : 1 = 1%:R) // ltr_nat.
Qed.

(** Continuity of norm *)

Lemma filterlim_norm {K : absRingType} {V : normedModType K} :
  forall (x : V), norm @ x --> (norm x).
Proof.
intros x.
apply (@filterlim_filter_le_1 _ _ _ _ _ _ (@locally_le_locally_norm _ _ x)).
eapply (proj2 (@filterlim_locally _ _ _ _)) => eps /=.
exists eps => /= y Hy.
by apply/sub_abs_ball/(ler_lt_trans (norm_triangle_inv _ _)).
Unshelve.
apply filtermap_filter.
rewrite locally_locally_norm.
typeclasses eauto.
Qed.

(* TODO: yet, not used anywhere?! *)
Lemma filterlim_norm_zero {U} {K : absRingType} {V : normedModType K}
  {F : set (set U)} {FF : Filter F} (f : U -> V) :
  (fun x => `|[f x]|) @ F --> (0 : R)
  -> f @ F --> (0 : V).
Proof.
  (* intros Hf. *)
  (* apply filterlim_locally_ball_norm => eps. *)
  (* generalize (proj1 (filterlim_locally_ball_norm _ _) Hf eps) ; *)
  (* unfold ball_norm ; simpl. *)
  (* apply filter_imp => /= x. *)
  (* rewrite !minus_zero_r {1}/norm /= /abs /= Rabs_pos_eq //. *)
  (* by apply norm_ge_0. *)
(*Qed.*)
Admitted.

Canonical eventually_filter_source X :=
  @CanonicalFilterSource X _ nat (fun f => f @ \oo).

Lemma filterlim_bounded {K : absRingType} {V : normedModType K} (a : nat -> V) :
  (exists x : V, a --> x)
 -> {M : R | forall n, norm (a n) <= M}.
Proof.
move=> Ha.
have {Ha}H : exists x : R, (fun n => `|[a n]|) --> x.
  case: Ha => [l Hl].
  exists `|[ l ]|; exact: (filterlim_comp Hl (@filterlim_norm _ _ _)).
case: (LPO_ub_dec (fun n => norm (a n))) => [[M HM] | HM].
exists M => n; by apply/RleP.
exfalso.
case: H => l Hl.
have {Hl} := proj1 (@filterlim_locally _ _ _ l) Hl [posreal of 1].
rewrite /= /ball /= /AbsRing_ball => -[N HN].
move: (HM (seq.foldr Rmax (1 + l) (seq.map (fun n => `|[a n]|) (seq.iota 0 N)))) => {HM}.
case => [n].
apply Rle_not_lt.
elim: N a n HN => /=[ |N IH] a n HN.
  rewrite addrC.
  apply Rlt_le, Rabs_lt_between'.
  apply/RltP/(ler_lt_trans _ (HN _ _)).
  - rewrite absrB; by apply lerr.
  - by apply/leP.
case: n => [ | n]; first by apply Rmax_l.
apply: (Rle_trans _ _ _ _ (Rmax_r _ _)).
eapply Rle_trans.
  apply (IH (fun n => a n.+1)) => k Hk; by apply/HN/le_n_S.
rewrite {HN n IH}.
apply Req_le.
elim: N 0%nat => /=[// |N IH] n0.
congr Rmax; by apply IH.
Qed.

(** Some open sets of [R] *)

Lemma open_lt (y : R) : open (fun u : R => u < y).
Proof.
move=> x; rewrite -subr_gt0 => /RltP xy.
exists (mkposreal _ xy) => z Bz.
rewrite (_ : y = x + (y - x)); last by rewrite addrCA subrr addr0.
apply/RltP. apply Rabs_lt_between'. apply/RltP.
move/sub_ball_abs : Bz; by rewrite /= mul1r RminusE absrB.
Qed.

Lemma open_gt (y : R) : open (fun u : R => y < u).
Proof.
move=> x; rewrite -subr_gt0 => /RltP xy.
exists (mkposreal _ xy) => z Bz.
rewrite (_ : y = x - (x - y)); last by rewrite opprB addrCA subrr addr0.
apply/RltP. apply Rabs_lt_between'. apply/RltP.
move/sub_ball_abs : Bz; by rewrite mul1r /= RminusE absrB.
Qed.

Lemma open_neq (y : R) : open (fun u : R => u <> y).
Proof.
apply (@open_ext _ (fun u : R => u < y \/ y < u)).
  move=> u; split.
  by move/orP; rewrite -neqr_lt => /eqP.
  by move/eqP; rewrite neqr_lt => /orP.
apply open_or; by [apply open_lt | apply open_gt].
Qed.

(** Some closed sets of [R] *)

Lemma closed_le (y : R) : closed (fun u : R => u <= y).
Proof.
apply (@closed_ext _ (fun u => not (y < u))) => x.
  by rewrite lerNgt; split => /negP.
apply: closed_not; exact: open_gt.
Qed.

Lemma closed_ge (y : R) : closed (fun u : R => y <= u).
Proof.
apply (@closed_ext _ (fun u : R => not (u < y))) => x.
  by rewrite lerNgt; split => /negP.
apply: closed_not; exact: open_lt.
Qed.

Lemma closed_eq (y : R) : closed (fun u : R => u = y).
Proof.
apply (@closed_ext _ (fun u => not (u <> y))) => x.
  destruct (Req_dec x y); by tauto.
apply: closed_not; exact: open_neq.
Qed.

(** Local properties in [R] *)

Lemma locally_interval (P : R -> Prop) (x : R) (a b : Rbar) :
  Rbar_lt a x -> Rbar_lt x b ->
  (forall (y : R), Rbar_lt a y -> Rbar_lt y b -> P y) ->
  locally x P.
Proof.
move => Hax Hxb Hp.
case: (Rbar_lt_locally _ _ _ Hax Hxb) => d Hd.
exists d => y Hy.
apply Hp ; apply Hd; apply/RltP => //; move/sub_ball_abs : Hy;
  by rewrite mul1r absrB.
Qed.

(** * Topology on [R]² *)

(* ALTERNATIVE: *)
Definition locally_2d (x y : R) (P : R -> R -> Prop) := locally (x, y) (fun z => P z.1 z.2).

(*Definition locally_2d (P : R -> R -> Prop) x y :=
  exists delta : posreal, forall u v, Rabs (u - x) < delta -> Rabs (v - y) < delta -> P u v.*)

Lemma locally_2d_locally P x y :
  locally_2d x y P <-> locally (x,y) (fun z => P (fst z) (snd z)).
Proof. split; move=> [d H]; exists d; exact H. Qed.

Lemma locally_2d_impl_strong (P Q : R -> R -> Prop) x y :
  locally_2d x y (fun u v => locally_2d u v P -> Q u v) ->
  locally_2d x y P -> locally_2d x y Q.
Proof.
move=> /locally_2d_locally Li /locally_2d_locally/locally_locally LP.
apply locally_2d_locally.
apply: filter_imp (filter_and Li LP) => uv -[H1 H2].
by apply/H1/locally_2d_locally.
Qed.

Lemma locally_2d_singleton (P : R -> R -> Prop) x y : locally_2d x y P -> P x y.
Proof. by move/locally_2d_locally => /locally_singleton. Qed.

Lemma locally_2d_impl (P Q : R -> R -> Prop) x y :
  locally_2d x y (fun u v => P u v -> Q u v) ->
  locally_2d x y P -> locally_2d x y Q.
Proof.
move=> H.
apply locally_2d_impl_strong.
case : H => d Hd.
exists d => /= z Hz HP.
by apply/(Hd _ Hz); apply locally_2d_singleton.
Qed.

Lemma locally_2d_forall (P : R -> R -> Prop) x y :
  (forall u v, P u v) -> locally_2d x y P.
Proof. move=> Hp; by exists [posreal of 1]. Qed.

Lemma locally_2d_and (P Q : R -> R -> Prop) x y :
  locally_2d x y P -> locally_2d x y Q -> locally_2d x y (fun u v => P u v /\ Q u v).
Proof.
intros H.
apply: locally_2d_impl.
apply: locally_2d_impl H.
apply locally_2d_forall.
now split.
Qed.

Lemma locally_2d_align :
  forall (P Q : R -> R -> Prop) x y,
  ( forall eps : posreal, (forall uv, ball (x, y) eps uv -> P uv.1 uv.2) ->
    forall uv, ball (x, y) eps uv -> Q uv.1 uv.2 ) ->
  locally_2d x y P -> locally_2d x y Q.
Proof.
intros P Q x y K (d,H).
exists d => uv Huv.
by apply (K d) => //.
Qed.

Lemma locally_2d_1d_const_x :
  forall (P : R -> R -> Prop) x y,
  locally_2d x y P ->
  locally y (fun t => P x t).
Proof.
intros P x y (d,Hd).
exists d; intros z Hz.
by apply (Hd (x, z)).
Qed.

Lemma locally_2d_1d_const_y :
  forall (P : R -> R -> Prop) x y,
  locally_2d x y P ->
  locally x (fun t => P t y).
Proof.
intros P x y (d,Hd).
exists d; intros z Hz.
by apply (Hd (z, y)).
Qed.

Lemma locally_2d_1d_strong :
  forall (P : R -> R -> Prop) x y,
  locally_2d x y P ->
  locally_2d x y (fun u v => forall (t : R), 0 <= t <= 1 ->
    locally t (fun z => locally_2d (x + z * (u - x)) (y + z * (v - y)) P)).
Proof.
move=> P x y.
apply locally_2d_align => eps HP uv Huv t Ht.
set u := uv.1. set v := uv.2.
have Zm : 0 <= Num.max `|u - x| `|v - y| by rewrite ler_maxr 2!normr_ge0.
rewrite ler_eqVlt in Zm.
case/orP : Zm => Zm.
- apply filter_forall => z.
  exists eps => pq.
  rewrite !(RminusE,RmultE,RplusE).
  move: (Zm).
  have : Num.max `|u - x| `|v - y| <= 0 by rewrite -(eqP Zm).
  rewrite ler_maxl => /andP[H1 H2] _.
  rewrite (_ : u - x = 0); last by apply/eqP; rewrite -normr_le0.
  rewrite (_ : v - y = 0); last by apply/eqP; rewrite -normr_le0.
  rewrite !(mulr0,addr0); by apply HP.
- have H1: Num.max (`|u - x|) (`|v - y|) < eps.
    rewrite ltr_maxl; apply/andP; split.
    - case: Huv => /sub_ball_abs /=; by rewrite mul1r absrB.
    - case: Huv => _ /sub_ball_abs /=; by rewrite mul1r absrB.
  rewrite -subr_gt0 in H1.
  move/RltP in H1.
  set (d1 := mkposreal _ H1).
  have H2 : 0 < pos d1 / 2 / Num.max `|u - x| `|v - y| by rewrite mulr_gt0 // invr_gt0.
  move/RltP in H2.
  set (d2 := mkposreal _ H2).
  exists d2 => z Hz.
  exists [posreal of d1 / 2] => /= pq Hpq.
  apply HP.
  set p := pq.1.
  set q := pq.2.
  split.
  + apply/sub_abs_ball => /=.
    rewrite absrB.
    rewrite (_ : p - x = p - (x + z * (u - x)) + (z - t + t) * (u - x)); last first.
      by rewrite subrK opprD addrA subrK.
    apply: (ler_lt_trans (ler_abs_add _ _)).
    rewrite (_ : pos eps = pos d1 / 2 + (pos eps - pos d1 / 2)); last first.
      by rewrite addrCA subrr addr0.
    rewrite (_ : pos eps - _ = d1) // in Hpq.
    case: Hpq => /sub_ball_abs Hp /sub_ball_abs Hq.
    rewrite mul1r /= (_ : pos eps - _ = d1) // !(RminusE,RplusE,RmultE,RdivE) // in Hp, Hq.
    rewrite absrB in Hp.
    rewrite absrB in Hq.
    rewrite (ltr_le_add Hp) //.
    apply: (ler_trans (absrM _ _)).
    apply (@ler_trans _ ((pos d2 + 1) * Num.max `|u - x| `|v - y|)).
    apply ler_pmul => //.
    by rewrite normr_ge0.
    by rewrite normr_ge0.
    apply: (ler_trans (ler_abs_add _ _)).
    rewrite ler_add //.
    move/sub_ball_abs : Hz; rewrite mul1r => tzd2; by rewrite absrB ltrW.
    rewrite absRE ger0_norm //; by case/andP: Ht.
    by rewrite ler_maxr lerr.
    rewrite /d2 /d1 /=.
    set n := Num.max _ _.
    rewrite mulrDl mul1r -mulrA mulVr ?unitfE ?lt0r_neq0 // mulr1.
    rewrite ler_sub_addr addrAC -mulrDl -mulr2n -mulr_natr.
    by rewrite (_ : 2 = 2%:R) // -mulrA mulrV ?mulr1 ?unitfE // subrK.
  + apply/sub_abs_ball => /=.
    rewrite absrB.
    rewrite (_ : (q - y) = (q - (y + z * (v - y)) + (z - t + t) * (v - y))); last first.
      by rewrite subrK opprD addrA subrK.
    apply: (ler_lt_trans (ler_abs_add _ _)).
    rewrite (_ : pos eps = pos d1 / 2 + (pos eps - pos d1 / 2)); last first.
      by rewrite addrCA subrr addr0.
    rewrite (_ : pos eps - _ = d1) // in Hpq.
    case: Hpq => /sub_ball_abs Hp /sub_ball_abs Hq.
    rewrite mul1r /= (_ : pos eps - _ = d1) // !(RminusE,RplusE,RmultE,RdivE) // in Hp, Hq.
    rewrite absrB in Hp.
    rewrite absrB in Hq.
    rewrite (ltr_le_add Hq) //.
    apply: (ler_trans (absrM _ _)).
    apply (@ler_trans _ ((pos d2 + 1) * Num.max `|u - x| `|v - y|)).
    apply ler_pmul => //.
    by rewrite normr_ge0.
    by rewrite normr_ge0.
    apply: (ler_trans (ler_abs_add _ _)).
    rewrite ler_add //.
    move/sub_ball_abs : Hz; rewrite mul1r => tzd2; by rewrite absrB ltrW.
    rewrite absRE ger0_norm //; by case/andP: Ht.
    by rewrite ler_maxr lerr orbT.
    rewrite /d2 /d1 /=.
    set n := Num.max _ _.
    rewrite mulrDl mul1r -mulrA mulVr ?unitfE ?lt0r_neq0 // mulr1.
    rewrite ler_sub_addr addrAC -mulrDl -mulr2n -mulr_natr.
    by rewrite (_ : 2 = 2%:R) // -mulrA mulrV ?mulr1 ?unitfE // subrK.
Qed.

(* COMPILES UNTIL HERE *)

Lemma locally_2d_1d (P : R -> R -> Prop) x y :
  locally_2d P x y ->
  locally_2d (fun u v => forall t, 0 <= t <= 1 -> locally_2d P (x + t * (u - x)) (y + t * (v - y))) x y.
Proof.
move/locally_2d_1d_strong.
apply: locally_2d_impl.
apply locally_2d_forall => u v H t Ht.
specialize (H t Ht).
have : locally t (fun z => locally_2d P (x + z * (u - x)) (y + z * (v - y))) by [].
by apply: locally_singleton.
Qed.

Lemma locally_2d_ex_dec :
  forall P x y,
  (forall x y, P x y \/ ~P x y) ->
  locally_2d P x y ->
  {d : posreal | forall u v, Rabs (u-x) < d -> Rabs (v-y) < d -> P u v}.
Proof.
(* intros P x y P_dec H. *)
(* destruct (locally_ex_dec (x, y) (fun z => P (fst z) (snd z))) as [d Hd]. *)
(* - now intros [u v]. *)
(* - destruct H as [e H]. *)
(*   exists e. *)
(*   intros [u v] Huv. *)
(*   apply H. *)
(*   apply Huv. *)
(*   apply Huv. *)
(* exists d. *)
(* intros u v Hu Hv. *)
(* apply (Hd (u, v)). *)
(* simpl. *)
(* now split. *)
(* Qed. *)
Admitted.

(** * Some Topology on [Rbar] *)

Definition Rbar_locally' (a : Rbar) (P : R -> Prop) :=
  match a with
    | Finite a => locally' a P
    | +oo => exists M : R, forall x, M < x -> P x
    | -oo => exists M : R, forall x, x < M -> P x
  end.
Definition Rbar_locally (a : Rbar) (P : R -> Prop) :=
  match a with
    | Finite a => locally a P
    | +oo => exists M : R, forall x, M < x -> P x
    | -oo => exists M : R, forall x, x < M -> P x
  end.

Canonical Rbar_canonical_filter := @CanonicalFilter R Rbar (Rbar_locally).

Global Instance Rbar_locally'_filter :
  forall x, ProperFilter (Rbar_locally' x).
Proof.
(* intros [x| |] ; (constructor ; [idtac | constructor]). *)
(* - intros P [eps HP]. *)
(*   exists (x + eps / 2). *)
(*   apply HP. *)
(*     rewrite /ball /= /AbsRing_ball /abs /minus /plus /opp /=. *)
(*     ring_simplify (x + eps / 2 + - x). *)
(*     rewrite Rabs_pos_eq. *)
(*       apply Rminus_lt_0. *)
(*       by rewrite (_ : _ - _ = eps / 2)//; field. *)
(*     exact: Rlt_le. *)
(*   apply Rgt_not_eq, Rminus_lt_0 ; ring_simplify => //. *)
(* - now exists [posreal of 1]. *)
(* - intros P Q [dP HP] [dQ HQ]. *)
(*   exists [posreal of Rmin dP dQ]. *)
(*   simpl. *)
(*   intros y Hy H. *)
(*   split. *)
(*   apply HP with (2 := H). *)
(*   apply Rlt_le_trans with (1 := Hy). *)
(*   apply Rmin_l. *)
(*   apply HQ with (2 := H). *)
(*   apply Rlt_le_trans with (1 := Hy). *)
(*   apply Rmin_r. *)
(* - intros P Q H [dP HP]. *)
(*   exists dP. *)
(*   intros y Hy H'. *)
(*   apply H. *)
(*   now apply HP. *)
(* - intros P [N HP]. *)
(*   exists (N + 1). *)
(*   apply HP. *)
(*   apply Rlt_plus_1. *)
(* - now exists 0. *)
(* - intros P Q [MP HP] [MQ HQ]. *)
(*   exists (Rmax MP MQ). *)
(*   intros y Hy. *)
(*   split. *)
(*   apply HP. *)
(*   apply Rle_lt_trans with (2 := Hy). *)
(*   apply Rmax_l. *)
(*   apply HQ. *)
(*   apply Rle_lt_trans with (2 := Hy). *)
(*   apply Rmax_r. *)
(* - intros P Q H [dP HP]. *)
(*   exists dP. *)
(*   intros y Hy. *)
(*   apply H. *)
(*   now apply HP. *)
(* - intros P [N HP]. *)
(*   exists (N - 1). *)
(*   apply HP. *)
(*   apply Rlt_minus_l, Rlt_plus_1. *)
(* - now exists 0. *)
(* - intros P Q [MP HP] [MQ HQ]. *)
(*   exists (Rmin MP MQ). *)
(*   intros y Hy. *)
(*   split. *)
(*   apply HP. *)
(*   apply Rlt_le_trans with (1 := Hy). *)
(*   apply Rmin_l. *)
(*   apply HQ. *)
(*   apply Rlt_le_trans with (1 := Hy). *)
(*   apply Rmin_r. *)
(* - intros P Q H [dP HP]. *)
(*   exists dP. *)
(*   intros y Hy. *)
(*   apply H. *)
(*   now apply HP. *)
(* Qed. *)
Admitted.

Global Instance Rbar_locally_filter :
  forall x, ProperFilter (Rbar_locally x).
Proof.
intros [x| |].
- apply locally_filter.
- exact (Rbar_locally'_filter +oo).
- exact (Rbar_locally'_filter -oo).
Qed.

(** Open sets in [Rbar] *)

Lemma open_Rbar_lt :
  forall y, open (fun u : R => Rbar_lt u y).
Proof.
(* intros [y| |]. *)
(* - apply open_lt. *)
(* - apply open_true. *)
(* - apply open_false. *)
(* Qed. *)
Admitted.

Lemma open_Rbar_gt :
  forall y, open (fun u : R => Rbar_lt y u).
Proof.
(* intros [y| |]. *)
(* - apply open_gt. *)
(* - apply open_false. *)
(* - apply open_true. *)
(* Qed. *)
Admitted.

Lemma open_Rbar_lt' :
  forall x y, Rbar_lt x y -> Rbar_locally x (fun u => Rbar_lt u y).
Proof.
(* intros [x| |] y Hxy. *)
(* - now apply open_Rbar_lt. *)
(* - easy. *)
(* - destruct y as [y| |]. *)
(*   now exists y. *)
(*   now apply filter_forall. *)
(*   easy. *)
(* Qed. *)
Admitted.

Lemma open_Rbar_gt' :
  forall x y, Rbar_lt y x -> Rbar_locally x (fun u => Rbar_lt y u).
Proof.
(* intros [x| |] y Hxy. *)
(* - now apply open_Rbar_gt. *)
(* - destruct y as [y| |]. *)
(*   now exists y. *)
(*   easy. *)
(*   now apply filter_forall. *)
(* - now destruct y as [y| |]. *)
(* Qed. *)
Admitted.

Lemma Rbar_locally'_le x : Rbar_locally' x --> Rbar_locally x.
Proof. by move: x; move=> [x| | ] P [eps HP]; exists eps => *; apply: HP. Qed.

Lemma Rbar_locally'_le_finite (x : R) : Rbar_locally' x --> locally x.
Proof. by move=> P [eps HP]; exists eps => *; apply: HP. Qed.

(** * Some limits on real functions *)

Definition Rbar_loc_seq (x : Rbar) (n : nat) := match x with
    | Finite x => x + / (INR n + 1)
    | +oo => INR n
    | -oo => - INR n
  end.

Lemma filterlim_Rbar_loc_seq  x : Rbar_loc_seq x --> Rbar_locally' x.
Proof.
(*   intros P. *)
(*   unfold Rbar_loc_seq. *)
(*   case: x => /= [x | | ] [delta Hp]. *)
(* (* x \in R *) *)
(*   case: (nfloor_ex (/delta)) => [ | N [_ HN]]. *)
(*   by apply Rlt_le, Rinv_0_lt_compat, delta. *)
(*   exists N => n Hn. *)
(*   apply Hp ; simpl. *)
(*   rewrite /ball /= /AbsRing_ball /abs /minus /plus /opp /=. *)
(*   ring_simplify (x + / (INR n + 1) + - x). *)
(*   rewrite Rabs_pos_eq. *)
(*   rewrite -(Rinv_involutive delta). *)
(*   apply Rinv_lt_contravar. *)
(*   apply Rmult_lt_0_compat. *)
(*   apply Rinv_0_lt_compat. *)
(*   by apply delta. *)
(*   exact: INRp1_pos. *)
(*   apply Rlt_le_trans with (1 := HN). *)
(*   by apply Rplus_le_compat_r, le_INR. *)
(*   by apply Rgt_not_eq, delta. *)
(*   by apply Rlt_le, RinvN_pos. *)
(*   apply Rgt_not_eq, Rminus_lt_0. *)
(*   ring_simplify. *)
(*   by apply RinvN_pos. *)
(* (* x = +oo *) *)
(*   case: (nfloor_ex (Rmax 0 delta)) => [ | N [_ HN]]. *)
(*   by apply Rmax_l. *)
(*   exists (S N) => n Hn. *)
(*   apply Hp. *)
(*   apply Rle_lt_trans with (1 := Rmax_r 0 _). *)
(*   apply Rlt_le_trans with (1 := HN). *)
(*   rewrite -S_INR ; by apply le_INR. *)
(* (* x = -oo *) *)
(*   case: (nfloor_ex (Rmax 0 (-delta))) => [ | N [_ HN]]. *)
(*   by apply Rmax_l. *)
(*   exists (S N) => n Hn. *)
(*   apply Hp. *)
(*   rewrite -(Ropp_involutive delta). *)
(*   apply Ropp_lt_contravar. *)
(*   apply Rle_lt_trans with (1 := Rmax_r 0 _). *)
(*   apply Rlt_le_trans with (1 := HN). *)
(*   rewrite -S_INR ; by apply le_INR. *)
(* Qed. *)
Admitted.


Lemma continuity_pt_locally f x :
  continuity_pt f x <->
  forall eps : posreal, locally x (fun u => Rabs (f u - f x) < eps).
Proof.
(* split. *)
(* intros H eps. *)
(* move: (H eps (cond_pos eps)) => {H} [d [H1 H2]]. *)
(* rewrite /= /R_dist /D_x /no_cond in H2. *)
(* exists (mkposreal d H1) => y H. *)
(* destruct (Req_dec x y) as [<-|Hxy]. *)
(* rewrite /Rminus Rplus_opp_r Rabs_R0. *)
(* apply cond_pos. *)
(* by apply H2. *)
(* intros H eps He. *)
(* move: (H (mkposreal _ He)) => {H} [d H]. *)
(* exists d. *)
(* split. *)
(* apply cond_pos. *)
(* intros h [Zh Hh]. *)
(* exact: H. *)
(* Qed. *)
Admitted.

Lemma continuity_pt_filterlim (f : R -> R) (x : R) :
  continuity_pt f x <-> f @ x --> f x.
Proof.
(* eapply iff_trans. *)
(* apply continuity_pt_locally. *)
(* apply iff_sym. *)
(* exact (filterlim_locally f (f x)). *)
(* Qed. *)
Admitted.

Lemma continuity_ptE (f : R -> R) (x : R) :
 continuity_pt f x <-> {for x, continuous f}.
Proof. exact: continuity_pt_filterlim. Qed.

Lemma continuous_withinNx {U V : uniformType} (Ueqdec : forall x y : U, x = y \/ x <> y)
  (f : U -> V) x :
  {for x, continuous f} <-> f @ locally' x --> f x.
Proof.
split=> - cfx P /= fxP.
  by rewrite appfilter; apply filter_le_within; apply/cfx.
 (* :BUG: ssr apply: does not work,
    because the type of the filter is not infered *)
have /= := cfx P fxP; rewrite !appfilter => /filterP[//= Q Qx QP].
apply/filterP; exists (fun y => y <> x -> Q y) => // y Qy.
by have [->|/Qy /QP //] := Ueqdec y x; apply: locally_singleton.
Qed.

Lemma continuity_pt_filterlim' f x :
   continuity_pt f x <-> f @ locally' x --> f x.
Proof. by rewrite continuity_ptE continuous_withinNx //; exact: Req_dec. Qed.


Lemma continuity_pt_locally' f x :
  continuity_pt f x <->
  forall eps : posreal, locally' x (fun u => `|f u - f x| < eps)%R.
Proof.
(* rewrite continuity_ptE continuous_withinNx; last exact: Req_dec. *)
(* exact: filterlim_locally. *)
(* Qed. *)
Admitted.

Lemma locally_pt_comp (P : R -> Prop) (f : R -> R) (x : R) :
  locally (f x) P -> continuity_pt f x ->
  locally x (fun x => P (f x)).
Proof.
intros Lf Cf.
apply continuity_pt_filterlim in Cf.
now apply Cf.
Qed.

