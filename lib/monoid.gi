#############################################################################
##
#W  monoid.gi                   GAP library                     Thomas Breuer
##
#H  @(#)$Id: monoid.gi,v 4.30 2010/02/23 15:13:18 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains generic methods for monoids.
##
Revision.monoid_gi :=
    "@(#)$Id: monoid.gi,v 4.30 2010/02/23 15:13:18 gap Exp $";


#############################################################################
##
#M  PrintObj( <M> ) . . . . . . . . . . . . . . . . . . . . .  print a monoid
##
InstallMethod( PrintObj,
    "for monoid",
    true,
    [ IsMonoid ], 0,
    function( M )
    Print( "Monoid( ... )" );
    end );

InstallMethod( PrintObj,
    "for monoid with known generators",
    true,
    [ IsMonoid and HasGeneratorsOfMonoid ], 0,
    function( M )
    Print( "Monoid( ", GeneratorsOfMagmaWithOne( M ), ", ... )" );
    end );


#############################################################################
##
#M  ViewObj( <M> )  . . . . . . . . . . . . . . . . . . . . . . view a monoid
##
InstallMethod( ViewObj,
    "for a monoid",
    true,
    [ IsMonoid ], 0,
    function( M )
    Print( "<monoid>" );
    end );

InstallMethod( ViewObj,
    "for a monoid with generators",
    true,
    [ IsMonoid and HasGeneratorsOfMagmaWithOne ], 0,
    function( M )
    if IsEmpty( GeneratorsOfMagmaWithOne( M ) ) then
      Print( "<trivial monoid>" );
    elif Length(GeneratorsOfMagmaWithOne(M)) = 1 then
      Print( "<monoid with ", Length( GeneratorsOfMagmaWithOne( M ) ),
             " generator>" );
	else
      Print( "<monoid with ", Length( GeneratorsOfMagmaWithOne( M ) ),
             " generators>" );
    fi;
    end );


#############################################################################
##
#M  MonoidByGenerators( <gens> )  . . . . . . . .  monoid generated by <gens>
##
InstallOtherMethod( MonoidByGenerators,
    "for a collection",
    true,
    [ IsCollection ] , 0,
    function( gens )
    local M;
    M:= Objectify( NewType( FamilyObj( gens ),
                            IsMonoid and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfMagmaWithOne( M, AsList( gens ) );
    return M;
    end );

InstallOtherMethod( MonoidByGenerators,
    "for collection and identity",
    IsCollsElms,
    [ IsCollection, IsMultiplicativeElementWithOne ], 0,
    function( gens, id )
    local M;
    M:= Objectify( NewType( FamilyObj( gens ),
                            IsMonoid and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfMagmaWithOne( M, AsList( gens ) );
    SetOne( M, Immutable( id ) );
    return M;
    end );

InstallOtherMethod( MonoidByGenerators,
    "for empty collection and identity",
    true,
    [ IsEmpty, IsMultiplicativeElementWithOne ], 0,
    function( gens, id )
    local M;
    M:= Objectify( NewType( CollectionsFamily( FamilyObj( id ) ),
                                IsMonoid
                            and IsTrivial
                            and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfMagmaWithOne( M, AsList( gens ) );
    SetOne( M, Immutable( id ) );
    return M;
    end );

InstallImmediateMethod( GeneratorsOfSemigroup,
    IsMonoid and HasGeneratorsOfMonoid and IsAttributeStoringRep, 0,
    M->Concatenation([One(M)],GeneratorsOfMonoid(M)));


#############################################################################
##
#M  AsMonoid( <D> ) . . . . . . . . . . . . . .  domain <D>, viewed as monoid
##
InstallMethod( AsMonoid,
    "for a monoid",
    true,
    [ IsMonoid ], 100,
    IdFunc );

InstallMethod( AsMonoid,
    "generic method for a collection",
    true,
    [ IsCollection ], 0,
    function ( D )
    local   M,  L;

    D := AsSSortedList( D );
    L := ShallowCopy( D );
    M := TrivialSubmagmaWithOne( MonoidByGenerators( D ) );
    SubtractSet( L, AsSSortedList( M ) );
    while not IsEmpty(L)  do
        M := ClosureMagmaDefault( M, L[1] );
        SubtractSet( L, AsSSortedList( M ) );
    od;
    if Length( AsSSortedList( M ) ) <> Length( D )  then
        return fail;
    fi;
    M := MonoidByGenerators( GeneratorsOfMonoid( M ), One( D[1] ) );
    SetAsSSortedList( M, D );
    SetIsFinite( M, true );
    SetSize( M, Length( D ) );

    # return the monoid
    return M;
    end );


#############################################################################
##
#M  AsSubmonoid( <G>, <U> )
##
InstallMethod( AsSubmonoid,
    "generic method for a domain and a collection",
    IsIdenticalObj,
    [ IsDomain, IsCollection ], 0,
    function( G, U )
    local S;
    if not IsSubset( G, U ) then
      return fail;
    fi;
    if IsMagmaWithOne( U ) then
      if not IsAssociative( U ) then
        return fail;
      fi;
      S:= SubmonoidNC( G, GeneratorsOfMagmaWithOne( U ) );
    else
      S:= SubmagmaWithOneNC( G, AsList( U ) );
      if not IsAssociative( S ) then
        return fail;
      fi;
    fi;
    UseIsomorphismRelation( U, S );
    UseSubsetRelation( U, S );
    return S;
    end );


#############################################################################
##
#M  IsCommutative( <M> ) . . . . . . . . . .  test if a monoid is commutative
##
InstallMethod( IsCommutative,
    "for associative magma-with-one",
    true,
    [ IsMagmaWithOne and IsAssociative ], 0,
    IsCommutativeFromGenerators( GeneratorsOfMagmaWithOne ) );


#############################################################################
##
#F  Monoid( <gen>, ... )
#F  Monoid( <obj> )
#F  Monoid( <gens>, <id> )
##
InstallGlobalFunction( Monoid, function( arg )

    # special case for matrices, because they may look like lists
    if Length( arg ) = 1 and IsMatrix( arg[1] ) then
      return MonoidByGenerators( [ arg[1] ] );

    # special case for matrices, because they look like lists
    elif Length( arg ) = 2 and IsMatrix( arg[1] ) then
      return MonoidByGenerators( arg );

    # list of generators
    elif Length( arg ) = 1 and IsList( arg[1] ) and 0 < Length( arg[1] ) then
      return MonoidByGenerators( arg[1] );

    # list of generators plus identity
    elif Length( arg ) = 2 and IsList( arg[1] ) then
      return MonoidByGenerators( arg[1], arg[2] );

    # generators
    elif 0 < Length( arg ) then
      return MonoidByGenerators( arg );

    # no argument given, error
    else
      Error("usage: Monoid(<gen>,...), Monoid(<gens>), Monoid(<D>)");
    fi;
end );


#############################################################################
##
#E

