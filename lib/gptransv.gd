#############################################################################
##
#W  gptransv.gd			GAP Library		       Gene Cooperman
#W							     and Scott Murray
##
#H  @(#)$Id: gptransv.gd,v 4.8 2010/02/23 15:13:03 gap Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
Revision.gptransv_gd :=
    "@(#)$Id: gptransv.gd,v 4.8 2010/02/23 15:13:03 gap Exp $";

#############################################################################
##
##  1. Introduction
#1
##  This chapter describes the category of transversals of subgroups.
##  This category has the following representations:  
##  `TransvBySchreierTree', `TransvByHomomorphism',
##  `TransvByDirProd', `TransvByTrivSubgrp', `TransvBySiftFunct'.
##

#############################################################################
##
##  2. General operations on transversals
#2
##  Every kind of transversal has the following common operations/attributes:
##  `Size',    `Enumerator',    `Iterator',    `Random',    `TransversalElt',
##  `SiftOneLevel'.
##

##  Requires: hash (for Schreier trees), 
##     quotientgp (for hom images).

DeclareInfoClass( "InfoTransversal" );

#############################################################################
#############################################################################
##
##  General transversals
##
#############################################################################
#############################################################################

#############################################################################
##
#O  TransversalElt( <ss>, <elt> )
##
##  for a transversal <ss> and group element <elt>,
##  returns the representative of the coset containing the element <elt>.
##  The representative is unique, i.e. `TransversalElt' will return the
##  same thing for different elements of the same coset.
##
DeclareOperation( "TransversalElt", [ IsRightTransversal, IsAssociativeElement ] );

#############################################################################
##
#O  SiftOneLevel( <ss>, <g> )
##
##  For a transversal <ss> and group element <g>, the following
##  relationship with `TransversalElt' (see~"TransversalElt") defines
##  `SiftOneLevel':
##
##  \){\kernttindent}SiftOneLevel(<ss>, <g>) = <g> * TransversalElt(<ss>, <g>)
##
##  For some kinds of transversal `TransversalElt' is more efficient,
##  for others `SiftOneLevel' is.
##
DeclareOperation( "SiftOneLevel", [ IsRightTransversal, IsAssociativeElement ] );


#############################################################################
#############################################################################
##
##  3. Transversals by Schreier tree
#3
##  For transversals of stabiliser subgroups, we store  a  Schreier  tree  to
##  allow us to find transversal elements.
##
##  *Note:* `SiftOneLevel' is more efficient that `TransversalElt'.
##
##  Transversals can be extended as more generators are found for the
##  stabiliser.
##  Orbit generators are generators for the original group, stored separately
##  so we can add extra generators to form a shallower tree.
##  Orbits are stored as hash tables.
##


#############################################################################
##
#R  IsTransvBySchreierTree
##
DeclareRepresentation( "IsTransvBySchreierTree",
    IsComponentObjectRep and IsRightTransversal,
    [ "OrbitGenerators", "BasePoint", "Action", "HashTable" ] );
DeclareCategoryCollections( "IsTransvBySchreierTree" );
TransvBySchreierTreeFamily := NewFamily( "ScheierTransvRep", IsTransvBySchreierTree );

#############################################################################
##
#F  SchreierTransversal( <basePoint>, <Action>, <strongGens> )
##
##  creates a transversal by Schreier tree for the subgroup stabilising
##  the point <basePoint> (an object, typically an integer or vector) 
##  inside the group generated by <strongGens> (a list of strong generators
##  for the group).
##  This is the only correct way to create a transversal by Schreier 
##  tree.
##
DeclareGlobalFunction( "SchreierTransversal", [ IsObject, IsFunction, IsList ] );

#############################################################################
##
#O  OrbitGenerators( <ss> )
##
##  The elements used to compute the orbit <ss>.  These will be generators for 
##  the larger group, however there will often be redundancies to keep the 
##  Schreier tree shallow.
##
DeclareOperation( "OrbitGenerators", [ IsTransvBySchreierTree ] );

#############################################################################
##
#O  OrbitGeneratorsInv( <ss> )
##
##  Inverses of the orbit generators of the orbit <ss>.
##
DeclareOperation( "OrbitGeneratorsInv", [ IsTransvBySchreierTree ] );

#############################################################################
##
#O  BasePointOfSchreierTransversal( <ss> )
##
##  The base point of transversal by Schreier tree <ss>, i.e. the point
##  stabilised.
##
DeclareOperation( "BasePointOfSchreierTransversal", [ IsTransvBySchreierTree ] );

#############################################################################
##
#A  One( <ss> )
##
##  The identity of group <ss>.
##
DeclareAttribute( "One", IsTransvBySchreierTree );

##  gdc - These really take arg:  2 or 3 args.  How to declare?
#############################################################################
##
#F  ExtendSchreierTransversal( <st>, <newGens> )
#F  ExtendSchreierTransversal( <st>, <newGens>, <newGensInv> )
##
##  Extend a transversal by Schreier tree <st> with new generators <newGens>.
##
DeclareGlobalFunction( "ExtendSchreierTransversal", 
	[ IsTransvBySchreierTree, IsList ] );

#############################################################################
##
#F  ExtendSchreierTransversalShortCube( <ss>, <newGens> )
#F  ExtendSchreierTransversalShortCube( <ss>, <newGens>, <newGensInv> )
##
##  gdc - Ideally, `ExtendSchreierTransversal' should be a field
##        of the Schreier tree, chosen by `SchreierTransversal()'.
##
##  gdc - This is the new function with the cube control tree.
##
##  EXPERIMENTAL IDEA:  IT WOULD NEED TO BE TUNED.  NOT CURRENTLY
##  COMPETITIVE WITH METHOD BELOW.
##
DeclareGlobalFunction( "ExtendSchreierTransversalShortCube" );

#############################################################################
##
#F  ExtendSchreierTransversalShortTree( <ss>, <newGens> )
#F  ExtendSchreierTransversalShortTree( <ss>, <newGens>, <newGensInv> )
##
##  gdc - This is the original function with the traditional control tree
##
##  BASED ON: \cite{CF94}
##   ``A Random Base Change Algorithm for Permutation Groups'', G.~Cooperman
##   and L.~Finkelstein, J. of Symbolic Computation 17, 1994,
##   pp.~513--528
##
DeclareGlobalFunction( "ExtendSchreierTransversalShortTree" );

#############################################################################
##
##  ExtendTransversalOrbitGenerators(  <ss>, <newGens> )
##  ExtendTransversalOrbitGenerators(  <ss>, <newGens>, <newGensInv> )
##
##  This shouldn't be used.
##
##DeclareGlobalFunction( "ExtendTransversalOrbitGenerators",
##	[ IsTransvBySchreierTree, IsList ] );

#############################################################################
##
#F  CompleteSchreierTransversal( <ss> )
##
##  Complete the transversal.  In order to ensure that the Schreier tree does
##  not become too deep, the `Extend...' functions do not complete the
##  transversal.  Rather they extend it by depth one.
##
DeclareGlobalFunction( "CompleteSchreierTransversal", [IsTransvBySchreierTree] );

#############################################################################
##
#A  PreferredGenerators( <ss> )
##
##  returns the preferred generators of the transversal by Schreier tree <ss>.
##  The preferred generators are always 
##  used first when computing the Schreier tree.
##
DeclareAttribute( "PreferredGenerators", IsTransvBySchreierTree );

#############################################################################
##
#F  SchreierTreeDepth( <ss> )
##
##  The depth of Schreier tree <ss>.
##
DeclareGlobalFunction( "SchreierTreeDepth", [ IsTransvBySchreierTree ] );


#############################################################################
#############################################################################
##
##  4. Transversals by homomorphic images
#4
##  For the transversal of the kernel of a homomorphism,
##  a quotient group for the kernel of a homomorphism is stored.
##  Transversal elements are computed by finding a chain for the image group
##  and doing shadowed stripping.
##
##  *Note:* `TransversalElt' is more efficient that `SiftOneLevel'.
##

#############################################################################
##
#R  IsTransvByHomomorphism
##
DeclareRepresentation( "IsTransvByHomomorphism",
    IsComponentObjectRep and IsAttributeStoringRep and IsRightTransversal,
    [ "Homomorphism", "QuotientGroup" ] );
DeclareCategoryCollections( "IsTransvByHomomorphism" );
TransvByHomomorphismFamily := NewFamily( "TransvByHomomorphism", IsTransvByHomomorphism );

#############################################################################
##
#F  HomTransversal( <h> )
##
##  creates a hom transversal for the homomorphism <h>.
##
DeclareGlobalFunction( "HomTransversal",
    [IsGroupHomomorphism] );

#############################################################################
##
#O  Homomorphism( <homtr> )
##
##  The homomorphism of hom transversal <homtr>.
##
DeclareOperation( "Homomorphism", [IsTransvByHomomorphism] );

#############################################################################
##
#A  QuotientGroup( <homtr> )
##
##  The quotient group of hom transversal <homtr>.
##
DeclareAttribute( "QuotientGroup", IsTransvByHomomorphism );

#############################################################################
##
#O  ImageGroup( <homtr> )
##
##  The image group of hom transversal <homtr>.
##
DeclareOperation( "ImageGroup", [IsTransvByHomomorphism] );


#############################################################################
#############################################################################
##
##  5. Transversals by direct products
#5
##  Stores projection and injection for a direct product.  
##  The chain subgroup is the kernel of the projection.
##


#############################################################################
##
#R  IsTransvByDirProd
##
DeclareRepresentation( "IsTransvByDirProd",
    IsComponentObjectRep and IsRightTransversal,
    [ "Projection", "Injection" ] );
DeclareCategoryCollections( "IsTransvByDirProd" );
TransvByDirProdFamily := NewFamily( "TransvByDirProd", IsTransvByDirProd );

#############################################################################
##
#F  DirProdTransversal( <proj>, <inj> )
##
##  returns a direct product transversal given a projection <proj> and 
##  injection <inj>.
##
DeclareGlobalFunction( "DirProdTransversal",
    [ IsGroupHomomorphism, IsGroupHomomorphism ] );

#############################################################################
##
#O  Projection( <dpt> )
##
##  The projection of the direct product transversal <dpt>.
##
DeclareOperation( "Projection", [IsTransvByDirProd] );
#############################################################################
##
#O  Injection( <dpt> )
##
##  The injection of a direct product transversal <dpt>.
##
DeclareOperation( "Injection", [IsTransvByDirProd] );


#############################################################################
#############################################################################
##
##  6. Transversal by Trivial subgroup
#6
##  For use when our group is small enough to enumerate.
##

#############################################################################
##
#R  IsTransvByTrivSubgrp
##
DeclareRepresentation( "IsTransvByTrivSubgrp",
    IsComponentObjectRep and IsRightTransversal,
    [ "Group" ] );
DeclareCategoryCollections( "IsTransvByTrivSubgrp" );
TransvByTrivSubgrpFamily := NewFamily( "TransvByTrivSubgrp", IsTransvByTrivSubgrp );

#############################################################################
##
#F  TransversalByTrivial( <G> )
##
##  returns a transversal by trivial subgroup for the group <G>.
##
DeclareGlobalFunction( "TransversalByTrivial",
    [ IsGroup ] );

#############################################################################
#############################################################################
##
##  7. Transversal by sift function
#7
##  Given a group, subgroup, and sift function from group to subgroup
##      that is constant on cosets, this defines a transversal.
##  One typically prefers a normalized sift function that is the
##      the identity map on subgroups.
##  For situations when there is a non-group theoretic method for 
##  computing the transversal element, e.g. using row reduction for
##  the stabiliser of an invariant subspace.                                 
##
##  *Note:* `SiftOneLevel' is more efficient than `TransversalElt'.
##

#############################################################################
##
#R  IsTransvBySiftFunct
##
DeclareRepresentation( "IsTransvBySiftFunct",
    IsComponentObjectRep and IsAttributeStoringRep and IsRightTransversal,
    [ "Sift", "ParentGroup", "Subgroup", "Size" ] );
DeclareCategoryCollections( "IsTransvBySiftFunct" );
TransvBySiftFunctFamily := NewFamily( "TransvBySiftFunct", IsTransvBySiftFunct );

#############################################################################
##
#F  TransversalBySiftFunction( <supergroup>, <subgroup>, <sift> )
##
##  returns a transversal by sift function.
##
DeclareGlobalFunction( "TransversalBySiftFunction",
    [ IsFunction, IsGroup ] );

#E
