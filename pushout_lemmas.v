Require Import HoTT.

Definition push_fl {A B C : Type} {f : A -> B} {g : A -> C}:
  B -> pushout f g := push o inl.
Definition push_fr {A B C : Type} {f : A -> B} {g : A -> C}:
  C -> pushout f g := push o inr.


Definition pushout_ind' {A B C : Type} (f : A -> B) (g : A -> C)
           (P : pushout f g -> Type)
           (push_fl' : forall b : B, P (push_fl b))
           (push_fr' : forall c : C, P (push_fr c))
           (pp' : forall a : A, transport P (pp a) (push_fl' (f a)) = push_fr' (g a))
  : forall x : pushout f g, P x.
Proof.
  srapply @pushout_ind. intros [b|c]. apply push_fl'. apply push_fr'. apply pp'.
Defined.

Definition pushout_rec' {A B C : Type} (f : A -> B) (g : A -> C)
           (P : Type)
           (push_fl' : B -> P)
           (push_fr' : C -> P)
           (pp' : forall a : A, push_fl' (f a) = push_fr' (g a))
  : pushout f g -> P.
Proof.
  srapply @pushout_rec. intros [b|c]. exact (push_fl' b). exact (push_fr' c). apply pp'.
Defined.
  

Definition pushout_ind_beta_pp' {A B C} {f : A -> B} {g : A -> C}
           (P : pushout f g -> Type)
           (push_fl' : forall b : B, P (push_fl b))
           (push_fr' : forall c : C, P (push_fr c))
           (pp' : forall a : A, transport P (pp a) (push_fl' (f a)) = push_fr' (g a))
           (a : A)
  : apD (pushout_ind' f g P push_fl' push_fr' pp') (pp a) = pp' a.
Proof.
  apply pushout_ind_beta_pp.
Defined.                        (* perhaps not necessary. . . *)


Definition functor_pushout {A1 B1 C1 A2 B2 C2}
           {f1 : A1 -> B1} {g1 : A1 -> C1} {f2 : A2 -> B2} {g2 : A2 -> C2}
           (hA : A1 -> A2) (hB : B1 -> B2) (hC : C1 -> C2) :
  (hB o f1 == f2 o hA) -> (hC o g1 == g2 o hA ) ->  pushout f1 g1 -> pushout f2 g2.
Proof.
  intros nat_f nat_g. srapply @pushout_rec'.
  - exact (fun b => push_fl (hB b)).
  - exact (fun c => push_fr (hC c)).
  - exact (fun a => (ap push_fl (nat_f a) @ pp (hA a)) @ (ap push_fr (nat_g a)^)).
Defined.

Definition functor_pushout_beta_pp {A1 B1 C1 A2 B2 C2}
           {f1 : A1 -> B1} {g1 : A1 -> C1} {f2 : A2 -> B2} {g2 : A2 -> C2}
           (hA : A1 -> A2) (hB : B1 -> B2) (hC : C1 -> C2)
           (nat_f : hB o f1 == f2 o hA) (nat_g : hC o g1 == g2 o hA )
           (a : A1)
  : ap (functor_pushout hA hB hC nat_f nat_g) (pp a) =
    (ap (push_fl) (nat_f a) @ pp (hA a)) @ (ap (push_fr) (nat_g a)^).
Proof.
  unfold functor_pushout. unfold pushout_rec'. refine (pushout_rec_beta_pp (pushout f2 g2) _ _ a ).
Defined.

Definition functor_pushout_compose {A1 B1 C1 A2 B2 C2 A3 B3 C3}
           {f1 : A1 -> B1} {g1 : A1 -> C1} {f2 : A2 -> B2} {g2 : A2 -> C2} {f3 : A3 -> B3} {g3 : A3 -> C3}
           (hA1 : A1 -> A2) (hB1 : B1 -> B2) (hC1 : C1 -> C2)
           (hA2 : A2 -> A3) (hB2 : B2 -> B3) (hC2 : C2 -> C3)
           (nat_f1 : hB1 o f1 == f2 o hA1) (nat_g1 : hC1 o g1 == g2 o hA1 )
           (nat_f2 : hB2 o f2 == f3 o hA2) (nat_g2 : hC2 o g2 == g3 o hA2 )
  : functor_pushout (hA2 o hA1) (hB2 o hB1) (hC2 o hC1)
                    (fun a : A1 => ap (hB2) (nat_f1 a) @ (nat_f2 (hA1 a)))
                    (fun a : A1 => ap (hC2) (nat_g1 a) @ (nat_g2 (hA1 a))) ==
    (functor_pushout hA2 hB2 hC2 nat_f2 nat_g2) o (functor_pushout hA1 hB1 hC1 nat_f1 nat_g1).
Proof.
  srapply @pushout_ind'; try reflexivity.
  intro a. simpl. (* rewrite transport_paths_FlFr. *)
  refine (transport_paths_FlFr
            (f:= functor_pushout (fun x0 : A1 => hA2 (hA1 x0)) (fun x0 : B1 => hB2 (hB1 x0)) (fun x0 : C1 => hC2 (hC1 x0))
                                 (fun a0 : A1 => ap hB2 (nat_f1 a0) @ nat_f2 (hA1 a0)) (fun a0 : A1 => ap hC2 (nat_g1 a0) @ nat_g2 (hA1 a0)))
            (g := fun x => functor_pushout hA2 hB2 hC2 nat_f2 nat_g2 (functor_pushout hA1 hB1 hC1 nat_f1 nat_g1 x))
            (pp a) idpath
            @ _).
  
  apply moveR_Mp. refine (_ @ (concat_p1 _)^).
  refine (_ @ (inv_VV _ idpath)^). refine (_ @ (concat_1p _)^).
  refine (_ @ (functor_pushout_beta_pp (hA2 o hA1) (hB2 o hB1) (hC2 o hC1)
                                       (fun a0 : A1 => ap hB2 (nat_f1 a0) @ nat_f2 (hA1 a0)) (fun a0 : A1 => ap hC2 (nat_g1 a0) @ nat_g2 (hA1 a0)) a)^).
  refine (ap_compose (functor_pushout hA1 hB1 hC1 nat_f1 nat_g1) _ (pp a) @ _).
  refine (ap (ap (functor_pushout hA2 hB2 hC2 nat_f2 nat_g2)) (functor_pushout_beta_pp hA1 hB1 hC1 nat_f1 nat_g1 a) @ _).
  cut (forall (A B : Type) (f : A -> B) (a1 a2 a3 a4 : A) (p1 : a1 = a2) (p2 : a2 = a3) (p3 : a3 = a4),
          ap f (p1 @ p2 @ p3) = (ap f p1) @ (ap f p2) @ (ap f p3)).
  intro ap_ppp. refine (ap_ppp _ _ _ _ _ _ _ _ _ _ @ _). clear ap_ppp.
  transitivity (ap (functor_pushout hA2 hB2 hC2 nat_f2 nat_g2) (ap push_fl (nat_f1 a)) @ (ap (functor_pushout hA2 hB2 hC2 nat_f2 nat_g2) (pp (hA1 a)) @
               ap (functor_pushout hA2 hB2 hC2 nat_f2 nat_g2) (ap push_fr (nat_g1 a)^))).
  { apply concat_pp_p. }  
  rewrite <- !ap_compose. simpl.  
  rewrite functor_pushout_beta_pp.
  repeat rewrite concat_pp_p. rewrite ap_pp.
  (* rewrite <- (ap_compose push_fl (functor_pushout hA2 hB2 hC2 nat_f2 nat_g2)). simpl. *)
  (* rewrite <- (ap_compose push_fr (functor_pushout hA2 hB2 hC2 nat_f2 nat_g2)). simpl. *) rewrite <- !ap_compose.
  repeat rewrite concat_pp_p. repeat apply whiskerL.
  repeat rewrite ap_V. rewrite <- inv_pp. apply (ap inverse).
  rewrite ap_pp. apply whiskerR. rewrite ap_compose. reflexivity.
  by path_induction.
Qed.                            (* that was a mess. . . *)



