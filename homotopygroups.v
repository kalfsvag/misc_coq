(*TODO: Read STYLE.md and put this into HoTT library*)
Require Import HoTT.
Load pType_basics.

Section Precompose_pointed_equivalence.
  
  Definition pointed_precompose {A B C:pType} (f:A->*B) : (B->*C) -> (A->*C)
    := fun g => g o* f.  
  
  Definition pt_precompose_inverse {A B C:pType} (f : A<~>*B) :
    (A->*C) -> (B->*C)
    := pointed_precompose (pequiv_inverse f).

  (*Precomposing with inverse is pointed homotopic to the idmap*)
  Lemma pcompose_inverse {A B:pType} (f : A<~>*B) :
    pequiv_inverse f o* f ==* pmap_idmap A.
  Proof.
    apply issig_phomotopy.
    exists (fun x => eissect _ x).
    hott_simpl. 
    unfold pequiv_inverse; simpl.
    unfold moveR_equiv_V. 
    rewrite <- ap_pp_p.
    hott_simpl.
  Qed.
  
  (*The inverse of the inverse is pointed homotopic to the map itself.*)
  Lemma pequiv_inverse_twice {A B:pType} (f:A<~>*B) : 
    f ==* pequiv_inverse (pequiv_inverse f).
  Proof.
    apply issig_phomotopy.
    exists (ap10 idpath).
    hott_simpl; simpl.
    unfold moveR_equiv_V; simpl.
    rewrite <- (point_eq f).
    rewrite eisadj.
    rewrite <- ap_pp.
    hott_simpl.
  Qed.
  
  (*Precomposing with pointed equivalence results in an equivalence.*)
  (*Should this just follow from isequiv_precompose?*)
  Lemma isequiv_pt_precompose `{Funext} {A B C:pType} (f : A<~>*B)  : 
    IsEquiv (@pointed_precompose A B C f).
  Proof.
    refine (isequiv_adjointify (pointed_precompose f) (pt_precompose_inverse f) _ _).
    -intro g.
     apply equiv_path_pmap.
     pHomotopy_via (g o* ( (pequiv_inverse f) o* f)).
     +apply pmap_compose_assoc.
     +pHomotopy_via (g o* (pmap_idmap A)).
      *apply pmap_postwhisker.
       apply pcompose_inverse.
      *exact (pmap_precompose_idmap g).
    -intro g.
     apply equiv_path_pmap.
     pHomotopy_via (g o* (f o* (pequiv_inverse f))).
     +apply pmap_compose_assoc.
     +pHomotopy_via (g o* (pmap_idmap B)).
      *apply pmap_postwhisker.
       pHomotopy_via 
         ((pequiv_inverse (pequiv_inverse f)) o* pequiv_inverse f ).
       apply pmap_prewhisker.
       apply pequiv_inverse_twice.
       apply pcompose_inverse.
      *apply pmap_precompose_idmap.
  Qed.
End Precompose_pointed_equivalence.

(*In this section we prove that addpoint and the forgetful functor pType->Type are adjoint. This is lemma 6.5.3 in book.*)
Section Addpoint_forgetful_adjointness.
  Definition pMap_to_Map {A:Type } {B:pType} : ( (add_pt A) ->* B  ) -> ( A -> (pointed_type B) ).
    intro f.
    exact (f o inl).
  Defined.
  
  Definition Map_to_pMap {A:Type } {B:pType} : ( A->(pointed_type B) ) -> ( (add_pt A) ->* B  ).
    intro f.
    refine (Build_pMap _ _ _ _).
    -intros [a | [] ].
     *exact (f a). (*What inl a maps to*)
     *exact (point B). (*What the basepoint maps to*)
    -exact idpath.
  Defined.
  (*
  Lemma isequiv_pMap_to_Map {A:Type } {B:pType} `{Funext} : IsEquiv (@pMap_to_Map A B).
  Proof.
    apply (@isequiv_adjointify ( (add_pt A) ->* B  ) (A->B) pMap_to_Map Map_to_pMap).
    -exact (fun _ => idpath).
    -intros [pf pe].
     apply path_pmap.
     apply issig_phomotopy.
     unfold pMap_to_Map; unfold Map_to_pMap; simpl.
     refine (ex_intro _ _ _).
     +intros [a | [] ].
      *exact idpath.
      *exact pe^ .
     +simpl. hott_simpl.
  Qed. 
  *)
  Lemma isequiv_Map_to_pMap {A:Type } {B:pType} `{Funext} : IsEquiv (@Map_to_pMap A B).
  Proof.
    apply (@isequiv_adjointify (A->B) ( (add_pt A) ->* B  ) Map_to_pMap pMap_to_Map).

    -intros [pf pe].
     apply path_pmap.
     apply issig_phomotopy.
     unfold pMap_to_Map; unfold Map_to_pMap; simpl.
     refine (ex_intro _ _ _).
     +intros [a | [] ].
      *exact idpath.
      *exact pe^ .
     +simpl. hott_simpl.
    -exact (fun _ => idpath).
  Qed. 

  (*Lemma 6_5_3 in book:*)
  Lemma addpt_forget_adjoint `{Funext} (A:Type) (B:pType) : 
    ( A -> (pointed_type B) ) <~> ( (add_pt A) ->* B  ).
  Proof.
    exact (BuildEquiv _ _ Map_to_pMap isequiv_Map_to_pMap).
  Qed.
End Addpoint_forgetful_adjointness.


(*Show that my two-pointed types are equivalent*)
Section Two_points.
  Definition two_pts := add_pt Unit. (*TODO: Sphere 0 instead of pBool. . .*)
  
  Definition sph0_to_two_pts : (pSphere 0) ->* two_pts.
    refine (Build_pMap _ _ _ _).
    (*Construct map*)
    -apply (Susp_rec (inr tt) (inl tt)).
     +intros [].
    -exact idpath.
  Defined.
  
  Definition two_pts_to_sph0 : two_pts -> (pSphere 0).
    intros [].
    -exact (Unit_rec (pSphere 0) South).
    -exact (Unit_rec (pSphere 0) North).
  Defined.
  
  Lemma isequiv_sph0_to_two_pts : IsEquiv sph0_to_two_pts.
    refine (isequiv_adjointify _ two_pts_to_sph0  _ _).
    -intros [ [] | [] ] ; exact idpath.
    -refine (Susp_ind _ idpath idpath _).
     intros [].
  Defined.

  Definition equiv_sph0_2 :=
    Build_pEquiv _ _ sph0_to_two_pts isequiv_sph0_to_two_pts.
  
  Definition A_to_twotoA {A:pType} := Map_to_pMap o (Unit_rec A).

  Lemma isequiv_A_to_twotoA `{Funext} {A:pType} : IsEquiv (@A_to_twotoA A).
    refine isequiv_compose.
    exact isequiv_Map_to_pMap.
  Defined.

  Lemma equiv_A_twotoA `{Funext} {A:pType} : Equiv A (two_pts ->*A).
    exact (BuildEquiv _ _ A_to_twotoA isequiv_A_to_twotoA).
  Defined.  
(*
  Lemma equiv_twotoA_A `{Funext} {A:pType} : A <~> (two_pts ->* A).
    equiv_via (Unit->A).
    -exact (BuildEquiv _ _ (Unit_rec A) (isequiv_unit_rec A)).
    -exact ( (addpt_forget_adjoint Unit A)^-1 ).
  Defined.
*)
End Two_points.


Section Loops.

  (*Define Omega n A as pointed maps from the n-sphere*)
  Definition Omega (n:nat) (A:pType) :pType :=
    Build_pType (pMap (pSphere n) A) _.
  
  (*TODO: Use more isEquiv*)

  Definition A_to_Omega0 {A:pType} : A -> Omega 0 A := 
    (pointed_precompose (sph0_to_two_pts) o A_to_twotoA).

  Definition pointed_A_to_Omega0 `{Funext} {A:pType}  : A_to_Omega0 (point A) = point (Omega 0 A).
    apply path_pmap.
    apply issig_phomotopy.
    refine (ex_intro _ _ _).
    refine (Susp_ind _ _ _ _).
    +exact idpath. 
    +exact idpath.
    +intros [].
    +exact idpath.
  Defined.

  Definition pA_to_Omega0 `{Funext} {A:pType} := 
    Build_pMap A (Omega 0 A)  A_to_Omega0 pointed_A_to_Omega0.

  Lemma isequiv_A_to_Omega0 `{Funext} {A:pType} : IsEquiv (@A_to_Omega0 A).
    refine isequiv_compose.
    -exact isequiv_A_to_twotoA.
    -apply (isequiv_pt_precompose equiv_sph0_2).
  Defined.
  
  Definition equiv_A_Omega0 `{Funext} {A:pType} := 
    BuildEquiv _ _ (@A_to_Omega0 A) isequiv_A_to_Omega0.

  Definition iterated_loop_susp_adjoint `{Funext} (n:nat) : 
    forall A:pType, Omega n A -> Omega 0 (iterated_loops n A).
    induction n.
    -intro A. exact idmap.
    -intro A.
     intro l.
     apply (IHn (loops A)).
     apply loop_susp_adjoint.
     exact l.
  Defined.
     

  Definition omega_to_loops `{Funext} (n:nat) : forall A:pType, iterated_loops n A -> Omega n A.
    induction n.
    (*n=0*)
    -exact (@A_to_Omega0).
    (*Induction step*)
    -intro A.
     simpl.
     refine ((equiv_inverse (loop_susp_adjoint _ _)) o (IHn (loops A))).
  Defined.

  Lemma isequiv_omega_to_loops `{Funext} (n:nat) : forall A:pType, IsEquiv (omega_to_loops n A).
   
    induction n.
    -exact (@isequiv_A_to_Omega0 _).
    -intro A.     
     refine isequiv_compose.
     refine (isequiv_adjointify _ _ _ _).
     +
     
    simpl.
     
     
     intro loop.
     refine (pointed_precompose (C:=A) sph0_to_two_pts).
     
     refine compose.
     
     apply iterated_loops_rec.
unfold iterated_loops. simpl.

  (*This should be equivalent to the loop space in the library*)
  Theorem loops_equiv_omega `{Funext} : forall n:nat, forall A:pType,
                                           Omega n A <~> iterated_loops n A.
    induction n.
    -intro A. exact A_Equiv_Omega0.
    -intro A.
     equiv_via (Omega n (loops A)).
     +exact (IHn (loops A)).
     +exact ((loop_susp_adjoint _ _)^-1).
  Defined.
  (*TODO: Show that this equivalence is natural in A.*)
  (*TODO:*)
  Theorem omega_loops_peq `{Funext} :forall n:nat, forall A:pType,
                                       iterated_loops n A <~>* Omega n A. 
    intros n A.
    refine (Build_pEquiv _ _ _ _).
    -refine (Build_pMap _ _ _ _).
     +apply loops_equiv_omega.
     +simpl.
      apply path_pmap.
      apply issig_phomotopy.
      refine (ex_intro _ _ _).
      intro x.
      induction n.
      *change ((point (pSphere 0 ->* A)) x) with (point A). simpl.
       change {| pointed_type := A; ispointed_type := point A |} with A.
       
       unfold iterated_loops.
       unfold point. simpl.
simpl.
       change (const (point A) x) with (point A).
       
unfold addpt_forget_adjoint. hott_simpl.
      *apply path_pmap.
      simpl.
      intro x.
      change (point (iterated_loops n A)) with (@idpath A).
      pointed_reduce.
      unfold point.
      unfold loops_equiv_omega. hott_simpl.
      
  Admitted.

End Loops.

Section homotopy_groups.


  Definition homotopy_group (n:nat) (A:pType) :pType :=
    pTr 0 (Omega n A).

  Notation "'HtGr'" := homotopy_group.

  Definition SphereToOmega_functor {m n:nat} (f:pSphere m ->* pSphere n) (A:pType) :
    Omega n A ->* Omega m A.
    
    refine (Build_pMap _ _ _ _).
    (*Define the map*)
    * intro h. exact (h o* f).
    (*Prove that it is pointed map.*)
    * apply const_comp.
  Defined.

  Definition OmegaToHtGr_functor {m n : nat} {A:pType} (f : Omega n A ->* Omega m A) :
    HtGr n A ->* HtGr m A.
    
    refine (Build_pMap _ _ _ _).
    (*Construct map*)
    *apply Trunc_rec.
     intro loop.
     apply tr.
     exact (f loop).
    (*Show that it is pointed.*)
    *apply (ap tr).
     rewrite (point_eq f).
     reflexivity.
  Defined.

  Definition SphereToHtGr_functor {m n : nat} (f:pSphere m ->* pSphere n) (A:pType) :
    HtGr n A ->* HtGr m A :=
    OmegaToHtGr_functor (SphereToOmega_functor f A).
  
End homotopy_groups.

Section Hopf.
  Definition Hopf : pSphere 3 ->* pSphere 2.
  Admitted. (*TODO*)
  
  Definition Hopf_induced (n:nat){A:pType}: 
    homotopy_group (n+2) A ->* homotopy_group (n+3) A 
    :=
      SphereToHtGr_functor (functor_sphere n Hopf) A.
  
End Hopf.





(*  Lemma equiv_sph0toA_A `{Funext} {A:pType} : A <~> (pSphere 0 ->* A).
        equiv_via (two_pts ->* A).
            -exact equiv_twotoA_A.
            -
            refine (BuildEquiv _ _ _ _).
                +exact (fun g => g o* sph0_to_two_pts).
                +refine (BuildIsEquiv _ _ _ _ _ _ _).
                admit. admit. admit. admit.
                (* 
                apply isequiv_precompose. *)
        Abort.
 *)
