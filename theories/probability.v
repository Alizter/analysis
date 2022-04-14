(* -*- company-coq-local-symbols: (("\\int_" . ?∫) ("'d" . ?𝑑) ("\\d_" . ?δ)); -*- *)
(* intersection U+2229; union U+222A, set U+2205, delta U+03B4 *)
(* mathcomp analysis (c) 2017 Inria and AIST. License: CeCILL-C.              *)
From mathcomp Require Import all_ssreflect.
From mathcomp Require Import ssralg ssrnum ssrint interval.
Require Import boolp reals ereal.
From HB Require Import structures.
Require Import classical_sets signed topology normedtype cardinality sequences.
Require Import esum measure lebesgue_measure lebesgue_integral functions numfun.

(******************************************************************************)
(*                             Probability (WIP)                              *)
(*                                                                            *)
(* This file provides a tentative definition of basic notions of probability  *)
(* theory.                                                                    *)
(*                                                                            *)
(*       probability T R == a measure that sums to 1                          *)
(*          {RV P >-> R} == real random variable, a measurable function from  *)
(*                          the measurableType of the probability P to R      *)
(*                  'E X == expectation of of the real random variable X      *)
(*                  'V X == variance of the real random variable X            *)
(*        distribution X == measure image of P by X : {RV P -> R}             *)
(*                                                                            *)
(******************************************************************************)

Reserved Notation "''E' X" (format "''E'  X", at level 5).
Reserved Notation "''V' X" (format "''V'  X", at level 5).

Set Implicit Arguments.
Unset Strict Implicit.
Unset Printing Implicit Defensive.
Import Order.TTheory GRing.Theory Num.Def Num.Theory.
Import numFieldTopology.Exports.

Local Open Scope classical_set_scope.
Local Open Scope ring_scope.

#[global] Hint Extern 0 (measurable_fun _ normr) =>
  solve [exact: measurable_fun_normr] : core.

Notation integrablerM := integrableK.

Section integrable.
Variables (T : measurableType) (R : realType) (mu : {measure set T -> \bar R}).

Lemma integrableMr (D : set T) : measurable D ->
  forall (k : R) (f : T -> \bar R), mu.-integrable D f ->
  mu.-integrable D (f \* cst k%:E)%E.
Proof.
move=> mD k f mf; apply: eq_integrable (integrablerM mD k mf) => //.
by move=> x _; rewrite muleC.
Qed.

Lemma eq_integrable (D : set T) : measurable D -> forall f2 f1 : T -> \bar R,
  {in D, f1 =1 f2} -> mu.-integrable D f1 = mu.-integrable D f2.
Proof.
move=> mD f2 f1 f12.
apply: propext; split; apply: eq_integrable => // x xD.
by rewrite f12.
Qed.

End integrable.
Arguments eq_integrable {T R mu D} _ f2 f1.

From mathcomp.finmap Require Import finmap.

Lemma integralM_indic (T : measurableType) (R : realType)
    (m : {measure set T -> \bar R}) (D : set T) (f : R -> set T) k :
  (k < 0 -> f k = set0) ->
  measurable (f k) ->
  measurable D ->
  (\int[m]_(x in D) (k * \1_(f k) x)%:E =
   k%:E * \int[m]_(x in D) (\1_(f k) x)%:E)%E.
Proof.
move=> fk0 mfk mD; have [k0|k0] := ltP k 0.
  rewrite (eq_integral (cst 0%E)) ?integral0 ?mule0; last first.
    move=> x _.
    by rewrite fk0// indic0 mulr0.
  rewrite (eq_integral (cst 0%E)) ?integral0 ?mule0// => x _.
  by rewrite fk0// indic0.
under eq_integral do rewrite EFinM.
rewrite ge0_integralM//.
- apply/EFin_measurable_fun/(@measurable_funS _ _ setT) => //.
  by rewrite (_ : \1_(f k) = mindic R mfk).
- by move=> y _; rewrite lee_fin.
Qed.

Lemma integralM_indic' (T : measurableType) (R : realType)
    (m : {measure set T -> \bar R}) (D : set T) (f : {nnsfun T >-> R}) k :
  measurable D ->
  (\int[m]_(x in D) (k * \1_(f @^-1` [set k]) x)%:E=
   k%:E * \int[m]_(x in D) (\1_(f @^-1` [set k]) x)%:E)%E.
Proof.
move=> mD.
rewrite (@integralM_indic _ _ _ _ (fun k => f @^-1` [set k]))// => k0.
by rewrite preimage_nnfun0.
Qed.

(* TODO: move to measure.v? *)
Section transfer.
Local Open Scope ereal_scope.
Variables (T1 T2 : measurableType) (phi : T1 -> T2).
Hypothesis mphi : measurable_fun setT phi.
Variables (R : realType) (mu : {measure set T1 -> \bar R}).

Lemma transfer (f : T2 -> \bar R) :
  measurable_fun setT f -> (forall y, 0 <= f y) ->
  \int[pushforward_measure mphi mu]_y f y =
  \int[mu]_x (f \o phi) x.
Proof.
move=> mf f0.
pose pt2 := phi point.
have [f_ [ndf_ f_f]] := approximation measurableT mf (fun t _ => f0 t).
transitivity
    (lim (fun n => \int[pushforward_measure mphi mu]_x (f_ n x)%:E)).
  rewrite -monotone_convergence//.
  - by apply: eq_integral => y _; apply/esym/cvg_lim => //; exact: f_f.
  - by move=> n; exact/EFin_measurable_fun.
  - by move=> n y _; rewrite lee_fin.
  - by move=> y _ m n mn; rewrite lee_fin; apply/lefP/ndf_.
rewrite (_ : (fun _ => _) = (fun n => \int[mu]_x (EFin \o f_ n \o phi) x)).
  rewrite -monotone_convergence//; last 3 first.
    - move=> n /=; apply: measurable_fun_comp; first exact: measurable_fun_EFin.
      by apply: measurable_fun_comp => //; exact: measurable_sfun.
    - by move=> n x _ /=; rewrite lee_fin.
    - by move=> x _ m n mn; rewrite lee_fin; exact/lefP/ndf_.
  by apply: eq_integral => x _ /=; apply/cvg_lim => //; exact: f_f.
rewrite funeqE => n.
have mfnphi : forall r, measurable (f_ n @^-1` [set r] \o phi).
  move=> r.
  rewrite -[_ \o _]/(phi @^-1` (f_ n @^-1` [set r])) -(setTI (_ @^-1` _)).
  exact/mphi.
transitivity (\sum_(k <- fset_set (range (f_ n)))
  \int[mu]_x (k * \1_(((f_ n) @^-1` [set k]) \o phi) x)%:E).
  under eq_integral do rewrite fimfunE -sumEFin.
  rewrite ge0_integral_sum//; last 2 first.
    - move=> y; apply/EFin_measurable_fun; apply: measurable_funM.
        exact: measurable_fun_cst.
      by rewrite (_ : \1_ _ = mindic R (measurable_sfunP (f_ n) y)).
    - by move=> y x _; rewrite muleindic_ge0.
  apply eq_bigr => r _; rewrite integralM_indic'// integral_indic//.
  rewrite /= /pushforward.
  rewrite (@integralM_indic _ _ _ _ (fun r => f_ n @^-1` [set r] \o phi))//.
    by congr (_ * _)%E; rewrite [RHS](@integral_indic).
  by move=> r0; rewrite preimage_nnfun0.
rewrite -ge0_integral_sum//; last 2 first.
  - move=> r; apply/EFin_measurable_fun; apply: measurable_funM.
      exact: measurable_fun_cst.
    by rewrite (_ : \1_ _ = mindic R (mfnphi r)).
  - by move=> r x _; rewrite muleindic_ge0.
by apply eq_integral => x _; rewrite sumEFin -fimfunE.
Qed.

End transfer.

Module Probability.
Section probability.
Variable (T : measurableType) (R : realType).
Record t := mk {
  P : {measure set T -> \bar R} ;
  _ : P setT = 1%E }.
End probability.
Module Exports.
Definition probability (T : measurableType) (R : realType) := (t T R).
Coercion P : t >-> Measure.map.
End Exports.
End Probability.
Export Probability.Exports.

Section probability_lemmas.
Variables (T : measurableType) (R : realType) (P : probability T R).

Lemma probability_setT : P setT = 1%:E.
Proof. by case: P. Qed.

Lemma probability_set0 : P set0 = 0%E.
Proof. exact: measure0. Qed.

Lemma probability_not_empty : [set: T] !=set0.
Proof.
apply/set0P/negP => /eqP setT0; have := probability_set0.
by rewrite -setT0 probability_setT; apply/eqP; rewrite oner_neq0.
Qed.

Lemma probability_le1 (A : set T) : measurable A -> (P A <= 1)%E.
Proof.
move=> mA; rewrite -probability_setT.
by apply: le_measure => //; rewrite ?in_setE.
Qed.

Lemma probability_integrable_cst k : P.-integrable [set: T] (EFin \o cst_mfun k).
Proof.
split; first exact/EFin_measurable_fun/measurable_fun_cst.
have [k0|k0] := leP 0 k.
- rewrite (eq_integral (EFin \o cst_mfun k))//; last first.
    by move=> x _ /=; rewrite ger0_norm.
  by rewrite integral_cst// probability_setT mule1 ltey.
- rewrite (eq_integral (EFin \o cst_mfun (- k)))//; last first.
    by move=> x _ /=; rewrite ltr0_norm.
  by rewrite integral_cst// probability_setT mule1 ltey.
Qed.

End probability_lemmas.

Reserved Notation "f `o X" (at level 50, format "f  `o '/ '  X").
Reserved Notation "X '`^2' " (at level 49).
Reserved Notation "X '`-cst' m" (at level 50).
Reserved Notation "X `+ Y" (at level 50).
Reserved Notation "X `- Y" (at level 50).
Reserved Notation "k `cst* X" (at level 49).

Section mfun.
Variable R : realType.

Definition sqr : R -> R := fun x => x ^+ 2.

Lemma sqr_mfun_subproof : @IsMeasurableFun _ R sqr.
Proof. by split; apply: measurable_fun_sqr; exact: measurable_fun_id. Qed.
HB.instance Definition _ := sqr_mfun_subproof.
Definition sqr_mfun := [the {mfun _ >-> R} of sqr].

Definition subr m : R -> R := fun x => x - m.

Lemma subr_mfun_subproof m : @IsMeasurableFun _ R (subr m).
Proof.
split => _; apply: (measurability (RGenOInfty.measurableE R)) => //.
move=> /= _ [_ [x ->] <-]; apply: measurableI => //.
rewrite (_ : _ @^-1` _ = `](x + m),+oo[)%classic; first exact: measurable_itv.
by apply/seteqP; split => r;
  rewrite preimage_itv in_itv/= in_itv/= !andbT ltr_subr_addr.
Qed.
HB.instance Definition _ m := subr_mfun_subproof m.
Definition subr_mfun m := [the {mfun _ >-> R} of subr m].

End mfun.

Section comp_mfun.
Variables(T : measurableType) (R : realType)
  (f : {mfun Real_sort__canonical__measure_Measurable R >-> R})
  (g : {mfun T >-> R}).

Lemma comp_mfun_subproof : @IsMeasurableFun _ _ (f \o g).
Proof. by split; exact: measurable_fun_comp. Qed.
HB.instance Definition _ := comp_mfun_subproof.
Definition comp_mfun := [the {mfun _ >-> R} of (f \o g)].
End comp_mfun.

(*Reserved Notation "{ 'RV' P >-> R }"
  (at level 0, format "{ 'RV'  P  >->  R }").
Module RandomVariable.
Section random_variable.
Record t (R : realType) (P : probability R) := mk {
  f : {mfun P >-> R} (*;
  _ : P.-integrable [set: P] (EFin \o f)*)
}.
End random_variable.
Module Exports.
Coercion f : t >-> MeasurableFun.type.
Notation "{ 'RV'  P >-> R }" := (@t R P) : form_scope.
End Exports.
End RandomVariable.
Export RandomVariable.Exports.*)

Reserved Notation "'{' 'RV' P >-> R '}'"
  (at level 0, format "'{' 'RV'  P  '>->'  R '}'").
Definition random_variable (T : measurableType) (R : realType) (P : probability T R) :=
  {mfun T >-> R}.
Notation "{ 'RV' P >-> R }" := (@random_variable _ R P) : form_scope.

Section random_variables.
Variables (T : measurableType) (R : realType) (P : probability T R).

Definition comp_RV (f : {mfun _ >-> R}) (X : {RV P >-> R}) : {RV P >-> R} :=
  [the {RV P >-> R} of f \o X].

Local Notation "f `o X" := (comp_RV f X).

Definition sq_RV (X : {RV P >-> R}) : {RV P >-> R} :=
  [the {mfun _ >-> R} of @sqr R] `o X.

Definition RV_sub (X : {RV P >-> R}) m : {RV P >-> R} :=
  [the {mfun _ >-> _} of @subr R m] `o X.

Definition sub_RV (X Y : {RV P >-> R}) : {RV P >-> R} :=
  [the {mfun _ >-> _} of X - Y].

Definition add_RV (X Y : {RV P >-> R}) : {RV P >-> R} :=
  [the {mfun _ >-> _} of X + Y].

Definition scale_RV k (X : {RV P >-> R}) : {RV P >-> R} :=
  [the {mfun _ >-> _} of k \o* X].

End random_variables.
Notation "f `o X" := (comp_RV f X).
Notation "X '`^2' " := (sq_RV X).
Notation "X '`-cst' m" := (RV_sub X m).
Notation "X `- Y" := (sub_RV X Y).
Notation "X `+ Y" := (add_RV X Y).
Notation "k `cst* X" := (scale_RV k X).

Section expectation.
Local Open Scope ereal_scope.
Variables (T : measurableType) (R : realType) (P : probability T R).

Definition expectation (X : {RV P >-> R}) := \int[P]_w (X w)%:E.
End expectation.
Notation "''E' X" := (expectation X).

Section integrable_pred.
Context {T : measurableType} {R : realType} (mu : {measure set T -> \bar R}).
Definition ifun : {pred T -> \bar R} := mem [set f | `[< mu.-integrable setT f >]].
(* NB: avoid Prop to define integrable? *)
Definition ifun_key : pred_key ifun. Proof. exact. Qed.
Canonical ifun_keyed := KeyedPred ifun_key.
End integrable_pred.

Section expectation_lemmas.
Local Open Scope ereal_scope.
Variables (T : measurableType) (R : realType) (P : probability T R).

(* TODO: generalize *)
Lemma expectation1 : 'E (cst_mfun 1 : {RV P >-> R}) = 1.
Proof. by rewrite /expectation integral_cst// probability_setT mule1. Qed.

Lemma expectation_indic (A : set T) (mA : measurable A) :
  'E ((*\1_A*) indic_mfun A mA : {RV P >-> R}) = P A.
Proof. by rewrite /expectation integral_indic// setIT. Qed.

Variables (X : {RV P >-> R}) (iX : P.-integrable setT (EFin \o X)).

Lemma integrable_expectation : `| 'E X | < +oo.
Proof.
move: iX => [? Xoo]; rewrite (le_lt_trans _ Xoo)//.
exact: le_trans (le_abse_integral _ _ _).
Qed.

Lemma expectationM (k : R) : 'E (k `cst* X) = k%:E * 'E X.
Proof.
rewrite /expectation. (*TODO: expectationE lemma*)
under eq_integral do rewrite EFinM.
rewrite -integralM//.
by under eq_integral do rewrite muleC.
Qed.

Lemma expectation_ge0 : (forall x, 0 <= X x)%R -> 0 <= 'E X.
Proof.
by move=> ?; rewrite /expectation integral_ge0// => x _; rewrite lee_fin.
Qed.

Variables (Y : {RV P >-> R}) (iY : P.-integrable setT (EFin \o Y)).

Lemma expectationD : 'E (X `+ Y) = 'E X + 'E Y.
Proof. by rewrite /expectation integralD_EFin. Qed.

Lemma expectationB : 'E (X `- Y) = 'E X - 'E Y.
Proof. by rewrite /expectation integralB_EFin. Qed.

End expectation_lemmas.

Section square_integrable.
Variables (T : measurableType) (R : realType) (mu : {measure set T -> \bar R}).

Definition square_integrable (D : set T) (f : T -> R) :=
  (\int[mu]_(x in D) (`| f x | ^+ 2)%:E < +oo)%E.

Lemma square_integrableP (D : set T) (f : T -> R) :
  measurable D -> measurable_fun D f ->
  square_integrable(*TODO: generalize*) D f <-> mu.-integrable D (EFin \o (fun x => `|f x| ^+ 2)).
Proof.
move=> mD mf; rewrite /square_integrable; split.
  move=> foo; split.
    exact/EFin_measurable_fun/measurable_fun_sqr/measurable_fun_comp.
  apply: le_lt_trans foo; apply ge0_le_integral => //.
  - apply/EFin_measurable_fun => //; apply: measurable_fun_comp => //.
    exact/measurable_fun_sqr/measurable_fun_comp.
  - apply/EFin_measurable_fun => //; apply: measurable_fun_sqr => //.
    exact: measurable_fun_comp.
  - by move=> x Dx /=; rewrite ger0_norm.
move=> [mf' foo].
rewrite (eq_integral (fun x => `|(EFin \o (fun y => (`|f y| ^+ 2)%R)) x|)%E)// => x xD.
by rewrite gee0_abs// lee_fin.
Qed.

End square_integrable.

Section variance.
Local Open Scope ereal_scope.
Variables (T : measurableType) (R : realType) (P : probability T R).

Definition variance (X : {RV P >-> R}) := 'E ((X `-cst fine 'E X) `^2).
Local Notation "''V' X" := (variance X).

Variables (X : {RV P >-> R}) (iX : P.-integrable setT (EFin \o X)).

Lemma varianceE : square_integrable P setT X ->
  'V X = 'E (X `^2) - ('E X) ^+ 2.
Proof.
move=> PX.
rewrite /variance (_ : _ `^2 = X `^2 `- (2 * fine 'E X) `cst* X
    `+ fine ('E X ^+ 2) `cst* cst_mfun 1); last first.
  apply/mfuneqP => x /=; rewrite /sqr /subr/= sqrrB -[RHS]/(_ - _ + _)%R /=.
  congr (_ - _ +  _)%R.
    by rewrite mulr_natl -mulrnAr mulrC.
  rewrite -[RHS]/(_ * _)%R mul1r.
  have [Efin|] := boolP ('E X \is a fin_num); first by rewrite fineM.
  by rewrite fin_numElt -(lte_absl ('E X) +oo) (integrable_expectation iX).
have ? : P.-integrable [set: T] (EFin \o X `^2).
  rewrite (_ : EFin \o X `^2 = (fun x => (`| X x | ^+ 2)%:E)).
    exact/square_integrableP.
  by rewrite funeqE => p /=; rewrite real_normK// num_real.
rewrite expectationD; last 2 first.
  - rewrite (_ : _ \o _ =
      (fun x => (EFin \o (X `^2)) x - (EFin \o (2 * fine 'E X `cst* X)) x)) //.
    apply: integrableB => //.
    rewrite (eq_integrable _ (fun x => (2 * fine 'E X)%:E * (X x)%:E))//.
    exact: integrableK.
    move=> t _ /=.
    by rewrite muleC EFinM.
  - rewrite (eq_integrable _ (fun x => (fine ('E X ^+ 2))%:E * (cst_mfun 1 x)%:E))//.
      by apply: integrableK => //; exact: probability_integrable_cst.
    move=> t _ /=.
    by rewrite mul1r mule1.
rewrite expectationB //; last first.
  rewrite (eq_integrable _ (fun x => (2 * fine 'E X)%:E * (X x)%:E))//.
    exact: integrableK.
  move=> t _ /=.
  by rewrite mulrC EFinM.
rewrite expectationM// expectationM; last exact: probability_integrable_cst.
rewrite expectation1 mule1.
have ? : 'E X \is a fin_num.
  by rewrite fin_numElt -(lte_absl ('E X) +oo) integrable_expectation.
rewrite EFinM fineK// expe2 fineM// EFinM fineK//.
rewrite -muleA mule_natl mule2n oppeD ?fin_numM//.
by rewrite addeA subeK// fin_numM.
Qed.

End variance.
Notation "''V' X" := (variance X).

Section distribution.
Variables (T : measurableType) (R : realType) (P : probability T R) (X : {RV P >-> R}).

Definition distribution : {measure set R -> \bar R} :=
  pushforward_measure (@measurable_funP _ _ X) P.

Lemma distribution_is_probability : distribution [set: R] = 1%:E.
Proof.
by rewrite /distribution /= /pushforward /= preimage_setT probability_setT.
Qed.

Definition probability_of_distribution : probability _ R :=
  Probability.mk distribution_is_probability.

End distribution.

Section transfer_probability.
Local Open Scope ereal_scope.
Variables (T : measurableType) (R : realType) (P : probability T R) (X : {RV P >-> R}).

Lemma transfer_probability (f : R -> \bar R) :
  measurable_fun setT f -> (forall y, 0 <= f y) ->
  \int[distribution X]_y f y = \int[P]_x (f \o X) x.
Proof. by move=> mf f0; rewrite transfer. Qed.

End transfer_probability.

Require Import functions.

Section subadditive_countable.
Variables (T : measurableType) (R : realType) (mu : {measure set T -> \bar R}).

Local Open Scope ereal_scope.

(* PR: in progress *)
Lemma integral_set0 (f : T -> \bar R) : \int[mu]_(x in set0) f x = 0.
Proof.
Admitted.

Lemma restrict_lee {aT} {rT : numFieldType} (D E : set aT) (f : aT -> \bar rT) :
  (forall x, E x -> 0 <= f x) ->
  D `<=` E -> forall x, ((f \_ D) x <= (f \_ E) x)%E.
Proof.
Admitted.

Lemma integral_bigsetU (F : (set T)^nat) (mF : forall n, measurable (F n))
    (f : T -> \bar R) n :
  let D := \big[setU/set0]_(i < n) F i in
  measurable_fun D f ->
  (forall x, D x -> 0 <= f x) ->
  trivIset `I_n F ->
  \int[mu]_(x in D) f x = \sum_(i < n) \int[mu]_(x in F i) f x.
Proof.
Admitted.

Lemma ge0_integral_bigcup (F : (set _)^nat) (f : T -> \bar R) :
  (forall x, 0 <= f x)%E ->
  trivIset setT F ->
  (forall k, measurable (F k)) ->
  mu.-integrable (\bigcup_k F k) f ->
  (\int[mu]_(x in \bigcup_i F i) f x =
   \sum_(i <oo) \int[mu]_(x in F i) f x)%E.
Proof.
Admitted.

Definition summable (R' : realType) (T' : choiceType) (D : set T') (f : T' -> \bar R') :=
  \esum_(x in D) `| f x | < +oo.

Lemma esumB :
forall [R' : realType] [T' : choiceType] [D : set T'] [f g : T' -> \bar R'],
summable D f ->
summable D g ->
(forall i : T', D i -> (0 <= f i)%E) ->
(forall i : T', D i -> (0 <= g i)%E) ->
(\esum_(i in D) (f \- g)^\+ i - \esum_(i in D) (f \- g)^\- i)%E =
(\esum_(i in D) f i - \esum_(i in D) g i)%E.
Admitted.

Lemma summable_ereal_pseries (f : nat -> \bar R) (P : pred nat) :
  summable P f ->
  \sum_(i <oo | P i) (f i) = \sum_(i <oo | P i) f^\+ i - \sum_(i <oo | P i) f^\- i.
Admitted.

Lemma integrable_abse [T' : measurableType] [R' : realType]
    [m : {measure set T' -> \bar R'}] [D : set T'] :
  measurable D -> forall f : T' -> \bar R', m.-integrable D f -> m.-integrable D (abse \o f).
Proof.
Admitted.

Lemma integrable_summable (F : (set T)^nat) (g : T -> \bar R):
  trivIset setT F -> (forall k, measurable (F k)) ->
  mu.-integrable (\bigcup_k F k) g ->
  summable [set: nat] (fun i => \int[mu]_(x in F i) g x).
Proof.
Admitted.

Lemma integral_bigcup (F : (set _)^nat) (g : T -> \bar R) :
  trivIset setT F -> (forall k, measurable (F k)) ->
  mu.-integrable (\bigcup_k F k) g ->
  (\int[mu]_(x in \bigcup_i F i) g x = \sum_(i <oo) \int[mu]_(x in F i) g x)%E.
Proof.
Admitted.
End subadditive_countable.

Lemma preimage10' {T R : Type} {f : T -> R} {x : R} :
  f @^-1` [set x] = set0 -> ~ range f x.
Proof.
rewrite /image /=.
apply: contraPnot => -[t _ <-].
rewrite /preimage/=.
by move/seteqP => -[+ _] => /(_ t) /=.
Qed.
(* /PR in progress *)

(* Convoo? *)
Module Convn.
Record t (R : realType) := {
  f : nat -> R ;
  f0 : forall n, (0 <= f n)%R ;
  f1 : (\sum_(n <oo) (f n)%:E = 1)%E }.
End Convn.
Notation convn := Convn.t.
Coercion Convn.f : convn >-> Funclass.

#[global] Hint Resolve Convn.f0 : core.

Module DiscreteDistribution.
Section discrete_distribution.
Local Open Scope form_scope.
Variables (T : measurableType) (R : realType) (P : probability T R)
          (X : {RV P >-> R}).
(*Record t := mk {
  c : convn R ;
  countableX : countable (range X) ;
  _ : ... a ....

  a : {injfun [set: nat] >-> [set: R]} ;
  XA : forall t, exists n, X t = a n ;


  support : distribution X =1
            (fun A : set R => \sum_(n <oo) (c n)%:E * (\d_ (a n) A))%E
}.*)
Record t := mk {
  c : convn R ;
  a : {injfun [set: nat] >-> [set: R]} ;
  XA : forall t, exists n, X t = a n ;
  support : distribution X =1 (fun A : set R => \sum_(n <oo) (c n)%:E * (\d_ (a n) A))%E
}.

Definition values (d : t) := a d.

Lemma inj_values (d : t) : {injfun [set: nat] >-> [set: R]}.
Proof. by case: d. Qed.

Lemma RV_values (d : t) : forall x, exists n, X x = values d n.
Proof. by case: d. Qed.

Lemma distribution_RV (d : t) :
  distribution X =1
    (fun A => \sum_(n <oo) (c d n)%:E * (\d_ (values d n) A))%E.
Proof. by case: d. Qed.

End discrete_distribution.
Module Exports.
Notation discrete_distribution := t.
End Exports.
End DiscreteDistribution.
Export DiscreteDistribution.Exports.

Section discrete_distribution.
Variables (T : measurableType) (R : realType) (P : probability T R)
  (X : {RV P >-> R}) (d : discrete_distribution X).

Import DiscreteDistribution.

Notation C := (c d).
Notation A := (values d).

Lemma test0 r : P [set x | X x = r] = distribution X [set r].
Proof. by rewrite /distribution /= /pushforward. Qed.

Lemma test1 (n : nat) : distribution X [set A n] = (C n)%:E.
Proof.
rewrite (distribution_RV d) nneseries_esum; last first.
  by move=> m _; rewrite mule_ge0// lee_fin.
rewrite (esumID [set n]); last first.
  by move=> m _; rewrite mule_ge0// lee_fin.
rewrite addeC esum0 ?add0e; last first.
  move=> m [_ /= mn].
  rewrite /dirac indicE memNset ?mule0//=.
  by apply: contra_not mn; exact/injT.
rewrite (_ : _ `&` _ = [set n]); last exact/seteqP.
rewrite esum_set1.
  by rewrite /= /dirac indicE mem_set// mule1.
by rewrite mule_ge0// lee_fin.
Qed.

Lemma discrete_expectation : P.-integrable setT (EFin \o X) ->
  'E X = (\sum_(n <oo) (C n)%:E * (A n)%:E)%E.
Proof.
move=> ix.
rewrite /expectation.
have <- : \bigcup_k X @^-1` [set A k] = setT.
  apply/seteqP; split => // t _.
  rewrite /bigcup /=.
  have [n XAtn] := RV_values d t.
  by exists n.
have tA : trivIset setT (fun k => [set A k]).
  by move=> i j _ _ [/= r []] ->; exact/injT.
have tXA : trivIset setT (fun i : nat => X @^-1` [set A i]).
  apply/trivIsetP => /= i j _ _ ij.
  move/trivIsetP : tA => /(_ i j Logic.I Logic.I ij) Aij.
  by rewrite -preimage_setI Aij preimage_set0.
rewrite integral_bigcup//; last first.
  by apply: (integrableS measurableT) => //; exact: bigcup_measurable.
transitivity (\sum_(i <oo) \int[P]_(x in X @^-1` [set A i]) (A i)%:E)%E.
  by apply eq_nneseries => i _; apply eq_integral => t; rewrite in_setE/= => ->.
transitivity (\sum_(i <oo) (A i)%:E * \int[P]_(x in X @^-1` [set A i]) 1)%E.
  apply eq_nneseries => i _.
  rewrite -integralM//; last first.
    split; first exact: measurable_fun_cst.
    rewrite (eq_integral (cst 1%E)); last by move=> x _; rewrite abse1.
    rewrite integral_cst// mul1e (@le_lt_trans _ _ 1%E) ?ltey//.
    exact: probability_le1.
  by apply eq_integral => y _; rewrite mule1.
apply eq_nneseries => k _.
by rewrite integral_cst//= mul1e test0 test1 muleC.
Qed.

End discrete_distribution.

Module Density.
Section density.
Local Open Scope form_scope.
Variables (R : realType) (P : probability (g_measurableType (@ocitv R)) R)
          (X : {RV P >-> R}).
Record t := mk {
  f : {mfun (g_measurableType (@ocitv R)) >-> R} ;
  f0 : forall r, 0 <= f r ;
  support : distribution X =1 (fun A => \int[lebesgue_measure]_(x in A) (f x)%:E)%E
}.
End density.
End Density.
