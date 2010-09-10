#############################################################################
##
#W  grptbl.gd                   GAP library                     Thomas Breuer
##
#H  @(#)$Id: grptbl.gd,v 4.20 2010/02/23 15:13:08 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the implementation of magmas, monoids, and groups from
##  a multiplication table.
##
Revision.grptbl_gd :=
    "@(#)$Id: grptbl.gd,v 4.20 2010/02/23 15:13:08 gap Exp $";


#############################################################################
##  
#F  MagmaByMultiplicationTableCreator( <A>, <domconst> )
##
##  <ManSection>
##  <Func Name="MagmaByMultiplicationTableCreator" Arg='A, domconst'/>
##
##  <Description>
##  This is a utility for the uniform construction of a magma,
##  a magma-with-one, or a magma-with-inverses from a multiplication table.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "MagmaByMultiplicationTableCreator" );


#############################################################################
##
#F  MagmaByMultiplicationTable( <A> )
##
##  <#GAPDoc Label="MagmaByMultiplicationTable">
##  <ManSection>
##  <Func Name="MagmaByMultiplicationTable" Arg='A'/>
##
##  <Description>
##  For a square matrix <A>A</A> with <M>n</M> rows such that all entries of
##  <A>A</A> are in the range <M>[ 1 .. n ]</M>,
##  <Ref Func="MagmaByMultiplicationTable"/> returns a magma
##  <M>M</M> with multiplication <C>*</C> defined by <A>A</A>.
##  That is, <M>M</M> consists of the elements <M>m_1, m_2, \ldots, m_n</M>,
##  and <M>m_i * m_j = m_k</M>, with <M>k =</M> <A>A</A><M>[i][j]</M>.
##  <P/>
##  The ordering of elements is defined by
##  <M>m_1 &lt; m_2 &lt; \cdots &lt; m_n</M>,
##  so <M>m_i</M> can be accessed as
##  <C>MagmaElement( <A>M</A>, <A>i</A> )</C>,
##  see&nbsp;<Ref Func="MagmaElement"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MagmaByMultiplicationTable" );


#############################################################################
##
#F  MagmaWithOneByMultiplicationTable( <A> )
##
##  <#GAPDoc Label="MagmaWithOneByMultiplicationTable">
##  <ManSection>
##  <Func Name="MagmaWithOneByMultiplicationTable" Arg='A'/>
##
##  <Description>
##  The only differences between <Ref Func="MagmaByMultiplicationTable"/> and
##  <Ref Func="MagmaWithOneByMultiplicationTable"/> are that the latter
##  returns a magma-with-one (see&nbsp;<Ref Func="MagmaWithOne"/>)
##  if the magma described by the matrix <A>A</A> has an identity,
##  and returns <K>fail</K> if not.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MagmaWithOneByMultiplicationTable" );


#############################################################################
##
#F  MagmaWithInversesByMultiplicationTable( <A> )
##
##  <#GAPDoc Label="MagmaWithInversesByMultiplicationTable">
##  <ManSection>
##  <Func Name="MagmaWithInversesByMultiplicationTable" Arg='A'/>
##
##  <Description>
##  <Ref Func="MagmaByMultiplicationTable"/> and
##  <Ref Func="MagmaWithInversesByMultiplicationTable"/>
##  differ only in that the latter returns
##  magma-with-inverses (see&nbsp;<Ref Func="MagmaWithInverses"/>)
##  if each element in the magma described by the matrix <A>A</A>
##  has an inverse,
##  and returns <K>fail</K> if not.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MagmaWithInversesByMultiplicationTable" );


#############################################################################
##
#F  MagmaElement( <M>, <i> ) . . . . . . . . . .  <i>-th element of magma <M>
##
##  <#GAPDoc Label="MagmaElement">
##  <ManSection>
##  <Func Name="MagmaElement" Arg='M, i'/>
##
##  <Description>
##  For a magma <A>M</A> and a positive integer <A>i</A>,
##  <Ref Func="MagmaElement"/> returns the <A>i</A>-th element of <A>M</A>,
##  w.r.t.&nbsp;the ordering <C>&lt;</C>.
##  If <A>M</A> has less than <A>i</A> elements then <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MagmaElement" );


#############################################################################
##
#F  SemigroupByMultiplicationTable( <A> )
##
##  <#GAPDoc Label="SemigroupByMultiplicationTable">
##  <ManSection>
##  <Func Name="SemigroupByMultiplicationTable" Arg='A'/>
##
##  <Description>
##  returns the semigroup whose multiplication is defined by the square
##  matrix <A>A</A> (see&nbsp;<Ref Func="MagmaByMultiplicationTable"/>)
##  if such a semigroup exists.
##  Otherwise <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SemigroupByMultiplicationTable" );


#############################################################################
##
#F  MonoidByMultiplicationTable( <A> )
##
##  <#GAPDoc Label="MonoidByMultiplicationTable">
##  <ManSection>
##  <Func Name="MonoidByMultiplicationTable" Arg='A'/>
##
##  <Description>
##  returns the monoid whose multiplication is defined by the square
##  matrix <A>A</A> (see&nbsp;<Ref Func="MagmaByMultiplicationTable"/>)
##  if such a monoid exists.
##  Otherwise <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MonoidByMultiplicationTable" );


#############################################################################
##
#F  GroupByMultiplicationTable( <A> )
##
##  <ManSection>
##  <Func Name="GroupByMultiplicationTable" Arg='A'/>
##
##  <Description>
##  returns the group whose multiplication is defined by the square
##  matrix <A>A</A> (see&nbsp;<Ref Func="MagmaByMultiplicationTable"/>)
##  if such a group exists.
##  Otherwise <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "GroupByMultiplicationTable" );


#############################################################################
##
#A  MultiplicationTable( <elms> )
#A  MultiplicationTable( <M> )
##
##  <#GAPDoc Label="MultiplicationTable">
##  <ManSection>
##  <Heading>MultiplicationTable</Heading>
##  <Attr Name="MultiplicationTable" Arg='elms'
##   Label="for a list of elements"/>
##  <Attr Name="MultiplicationTable" Arg='M' Label="for a magma"/>
##
##  <Description>
##  For a list <A>elms</A> of elements that form a magma <M>M</M>,
##  <Ref Func="MultiplicationTable" Label="for a list of elements"/> returns
##  a square matrix <M>A</M> of positive integers such that
##  <M>A[i][j] = k</M> holds if and only if
##  <A>elms</A><M>[i] *</M> <A>elms</A><M>[j] =</M> <A>elms</A><M>[k]</M>.
##  This matrix can be used to construct a magma isomorphic to <M>M</M>,
##  using <Ref Func="MagmaByMultiplicationTable"/>.
##  <P/>
##  For a magma <A>M</A>,
##  <Ref Func="MultiplicationTable" Label="for a magma"/> returns
##  the multiplication table w.r.t.&nbsp;the sorted list of elements of
##  <A>M</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> l:= [ (), (1,2)(3,4), (1,3)(2,4), (1,4)(2,3) ];;
##  gap> a:= MultiplicationTable( l );
##  [ [ 1, 2, 3, 4 ], [ 2, 1, 4, 3 ], [ 3, 4, 1, 2 ], [ 4, 3, 2, 1 ] ]
##  gap> m:= MagmaByMultiplicationTable( a );
##  <magma with 4 generators>
##  gap> One( m );
##  m1
##  gap> elm:= MagmaElement( m, 2 );  One( elm );  elm^2;
##  m2
##  m1
##  m1
##  gap> Inverse( elm );
##  m2
##  gap> AsGroup( m );
##  <group of size 4 with 2 generators>
##  gap> a:= [ [ 1, 2 ], [ 2, 2 ] ];
##  [ [ 1, 2 ], [ 2, 2 ] ]
##  gap> m:= MagmaByMultiplicationTable( a );
##  <magma with 2 generators>
##  gap> One( m );  Inverse( MagmaElement( m, 2 ) );
##  m1
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "MultiplicationTable", IsHomogeneousList );
DeclareAttribute( "MultiplicationTable", IsMagma );


#############################################################################
##
#E

