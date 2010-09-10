#############################################################################
##
#W  boolean.g                    GAP library                    Thomas Breuer
#W                                                             & Frank Celler
##
#H  @(#)$Id: boolean.g,v 4.10 2010/02/23 15:12:48 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file deals with booleans.
##
Revision.boolean_g :=
    "@(#)$Id: boolean.g,v 4.10 2010/02/23 15:12:48 gap Exp $";


#############################################################################
##
#C  IsBool(<obj>) . . . . . . . . . . . . . . . . . . .  category of booleans
##
##  <#GAPDoc Label="IsBool">
##  <ManSection>
##  <Filt Name="IsBool" Arg='obj' Type='Category'/>
##
##  <Description>
##  tests whether <A>obj</A> is <K>true</K>, <K>false</K> or <K>fail</K>.
##  <Example><![CDATA[
##  gap> IsBool( true );  IsBool( false );  IsBool( 17 );
##  true
##  true
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryKernel( "IsBool", IsObject, IS_BOOL );


#############################################################################
##
#V  BooleanFamily . . . . . . . . . . . . . . . . . . . .  family of booleans
##
##  <ManSection>
##  <Var Name="BooleanFamily"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "BooleanFamily",
    NewFamily(  "BooleanFamily", IS_BOOL ) );


#############################################################################
##
#F  TYPE_BOOL . . . . . . . . . . . . . . . . . . . type of internal booleans
##
##  <ManSection>
##  <Func Name="TYPE_BOOL" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_BOOL",
    NewType( BooleanFamily, IS_BOOL and IsInternalRep ) );


#############################################################################
##
#m  String( <bool> )  . . . . . . . . . . . . . . . . . . . . . for a boolean
##
InstallMethod( String,
    "for a boolean",
    true,
    [ IsBool ], 0,
    function( bool )
    if bool = true then
      return "true";
    elif bool = false  then
      return "false";
    elif bool = fail  then
      return "fail";
    else
      Error( "unknown boolean <bool>" );
    fi;
    end );


#############################################################################
##
#E

