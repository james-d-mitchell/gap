#############################################################################
##
#W  grplatt.gi                GAP library                   Martin Schönert,
#W                                                          Alexander Hulpke
##
#H  @(#)$Id: grplatt.gi,v 4.89 2010/02/23 15:13:05 gap Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This  file  contains declarations for subgroup latices
##
Revision.grplatt_gi:=
  "@(#)$Id: grplatt.gi,v 4.89 2010/02/23 15:13:05 gap Exp $";

#############################################################################
##
#F  Zuppos(<G>) .  set of generators for cyclic subgroups of prime power size
##
InstallMethod(Zuppos,"group",true,[IsGroup],0,
function (G)
local   zuppos,            # set of zuppos,result
	c,                 # a representative of a class of elements
	o,                 # its order
	N,                 # normalizer of < c >
	t;                 # loop variable

  # compute the zuppos
  zuppos:=[One(G)];
  for c in List(ConjugacyClasses(G),Representative)  do
    o:=Order(c);
    if IsPrimePowerInt(o)  then
      if ForAll([2..o],i -> Gcd(o,i) <> 1 or not c^i in zuppos) then
	N:=Normalizer(G,Subgroup(G,[c]));
	for t in RightTransversal(G,N)  do
	  Add(zuppos,c^t);
	od;
      fi;
    fi;
  od;

  # return the set of zuppos
  Sort(zuppos);
  return zuppos;
end);


#############################################################################
##
#M  ConjugacyClassSubgroups(<G>,<g>)  . . . . . . . . . . . .  constructor
##
InstallMethod(ConjugacyClassSubgroups,IsIdenticalObj,[IsGroup,IsGroup],0,
function(G,U)
local filter,cl;

    if CanComputeSizeAnySubgroup(G) then
      filter:=IsConjugacyClassSubgroupsByStabilizerRep;
    else
      filter:=IsConjugacyClassSubgroupsRep;
    fi;
    cl:=Objectify(NewType(CollectionsFamily(FamilyObj(G)),
      filter),rec());
    SetActingDomain(cl,G);
    SetRepresentative(cl,U);
    SetFunctionAction(cl,OnPoints);
    return cl;
end);

#############################################################################
##
#M  <clasa> = <clasb> . . . . . . . . . . . . . . . . . . by conjugacy test
##
InstallMethod( \=, IsIdenticalObj, [ IsConjugacyClassSubgroupsRep,
  IsConjugacyClassSubgroupsRep ], 0,
function( clasa, clasb )
  if not IsIdenticalObj(ActingDomain(clasa),ActingDomain(clasb))
    then TryNextMethod();
  fi;
  return RepresentativeAction(ActingDomain(clasa),Representative(clasa),
		 Representative(clasb))<>fail;
end);


#############################################################################
##
#M  <G> in <clas> . . . . . . . . . . . . . . . . . . by conjugacy test
##
InstallMethod( \in, IsElmsColls, [ IsGroup,IsConjugacyClassSubgroupsRep], 0,
function( G, clas )
  return RepresentativeAction(ActingDomain(clas),Representative(clas),G)
		 <>fail;
end);

#############################################################################
##
#M  AsList(<cls>)
##
InstallOtherMethod(AsList, "for classes of subgroups",
  true, [ IsConjugacyClassSubgroupsRep],0,
function(c)
local rep;
  rep:=Representative(c);
  if not IsBound(c!.normalizerTransversal) then
    c!.normalizerTransversal:=
      RightTransversal(ActingDomain(c),StabilizerOfExternalSet(c));
  fi;
  if HasParent(rep) and IsSubset(Parent(rep),ActingDomain(c)) then
    return List(c!.normalizerTransversal,i->ConjugateSubgroup(rep,i));
  else
    return List(c!.normalizerTransversal,i->ConjugateGroup(rep,i));
  fi;
end);

#############################################################################
##
#M  ClassElementLattice
##
InstallMethod(ClassElementLattice, "for classes of subgroups",
  true, [ IsConjugacyClassSubgroupsRep, IsPosInt],0,
function(c,nr)
local rep;
  rep:=Representative(c);
  if not IsBound(c!.normalizerTransversal) then
    c!.normalizerTransversal:=
      RightTransversal(ActingDomain(c),StabilizerOfExternalSet(c));
  fi;
  return ConjugateSubgroup(rep,c!.normalizerTransversal[nr]);
end);

InstallOtherMethod( \[\], "for classes of subgroups",
  true, [ IsConjugacyClassSubgroupsRep, IsPosInt],0,ClassElementLattice );

InstallMethod( StabilizerOfExternalSet, true, [ IsConjugacyClassSubgroupsRep ], 
    # override potential pc method
    10,
function(xset)
  return Normalizer(ActingDomain(xset),Representative(xset));
end);

InstallOtherMethod( NormalizerOp, true, [ IsConjugacyClassSubgroupsRep ], 0,
    StabilizerOfExternalSet );


#############################################################################
##
#M  PrintObj(<cl>)  . . . . . . . . . . . . . . . . . . . .  print function
##
InstallMethod(PrintObj,true,[IsConjugacyClassSubgroupsRep],0,
function(cl)
    Print("ConjugacyClassSubgroups(",ActingDomain(cl),",",
           Representative(cl),")");
end);


#############################################################################
##
#M  ConjugacyClassesSubgroups(<G>) . classes of subgroups of a group
##
InstallMethod(ConjugacyClassesSubgroups,"group",true,[IsGroup],0,
function(G)
  return ConjugacyClassesSubgroups(LatticeSubgroups(G));
end);

InstallOtherMethod(ConjugacyClassesSubgroups,"lattice",true,
  [IsLatticeSubgroupsRep],0,
function(L)
  return L!.conjugacyClassesSubgroups;
end);

BindGlobal("LatticeFromClasses",function(G,classes)
local lattice;
  # sort the classes
  Sort(classes,
	function (c,d)
	  return Size(Representative(c)) < Size(Representative(d))
	    or (Size(Representative(c)) = Size(Representative(d))
		and Size(c) < Size(d));
	end);

  # create the lattice
  lattice:=Objectify(NewType(FamilyObj(classes),IsLatticeSubgroupsRep),
    rec(conjugacyClassesSubgroups:=classes,
        group:=G));

  # return the lattice
  return lattice;
end );

#############################################################################
##
#F  LatticeByCyclicExtension(<G>[,<func>[,<noperf>]])  Lattice of subgroups
##
##  computes the lattice of <G> using the cyclic extension algorithm. If the
##  function <func> is given, the algorithm will discard all subgroups not
##  fulfilling <func> (and will also not extend them), returning a partial
##  lattice. This can be useful to compute only subgroups with certain
##  properties. Note however that this will *not* necessarily yield all
##  subgroups that fulfill <func>, but the subgroups whose subgroups used
##  for the construction also fulfill <func> as well.
##

# the following functions are declared only later
SOLVABILITY_IMPLYING_FUNCTIONS:=
  [IsSolvableGroup,IsNilpotentGroup,IsPGroup,IsCyclic];

InstallGlobalFunction( LatticeByCyclicExtension, function(arg)
local   G,		   # group
	func,		   # test function
	noperf,		   # discard perfect groups
        lattice,           # lattice (result)
	factors,           # factorization of <G>'s size
	zuppos,            # generators of prime power order
	zupposPrime,       # corresponding prime
	zupposPower,       # index of power of generator
	ZupposSubgroup,    # function to compute zuppos for subgroup
	zuperms,	   # permutation of zuppos by group
	Gimg,		   # grp image under zuperms
	nrClasses,         # number of classes
	classes,           # list of all classes
	classesZups,       # zuppos blist of classes
	classesExts,       # extend-by blist of classes
	perfect,           # classes of perfect subgroups of <G>
	perfectNew,        # this class of perfect subgroups is new
	perfectZups,       # zuppos blist of perfect subgroups
	layerb,            # begin of previous layer
	layere,            # end of previous layer
	H,                 # representative of a class
	Hzups,             # zuppos blist of <H>
	Hexts,             # extend blist of <H>
	C,                 # class of <I>
	I,                 # new subgroup found
	Ielms,             # elements of <I>
	Izups,             # zuppos blist of <I>
	N,                 # normalizer of <I>
	Nzups,             # zuppos blist of <N>
	Jzups,             # zuppos of a conjugate of <I>
	Kzups,             # zuppos of a representative in <classes>
	reps,              # transversal of <N> in <G>
	ac,
	transv,
	factored,
	mapped,
	expandmem,
	h,i,k,l,ri,rl,r;      # loop variables

    G:=arg[1];
    noperf:=false;
    if Length(arg)>1 and IsFunction(arg[2]) then
      func:=arg[2];
      Info(InfoLattice,1,"lattice discarding function active!");
      if Length(arg)>2 and IsBool(arg[3]) then
	noperf:=arg[3];
      fi;
    else
      func:=false;
    fi;

    expandmem:=ValueOption("Expand")=true;

  # if store is true, an element list will be kept in `Ielms' if possible
  ZupposSubgroup:=function(U,store)
  local elms,zups;
    if Size(U)=Size(G) then
      if store then Ielms:=fail;fi;
      zups:=BlistList([1..Length(zuppos)],[1..Length(zuppos)]);
    elif Size(U)>10^4 then
      # the group is very big - test the zuppos with `in'
      Info(InfoLattice,3,"testing zuppos with `in'");
      if store then Ielms:=fail;fi;
      zups:=List(zuppos,i->i in U);
      IsBlist(zups);
    else
      elms:=AsSSortedListNonstored(U);
      if store then Ielms:=elms;fi;
      zups:=BlistList(zuppos,elms);
    fi;
    return zups;
  end;

    # compute the factorized size of <G>
    factors:=Factors(Size(G));

    # compute a system of generators for the cyclic sgr. of prime power size
    zuppos:=Zuppos(G);

    Info(InfoLattice,1,"<G> has ",Length(zuppos)," zuppos");

    # compute zuppo permutation
    if IsPermGroup(G) then
      zuppos:=List(zuppos,SmallestGeneratorPerm);
      zuppos:=AsSSortedList(zuppos);
      zuperms:=List(GeneratorsOfGroup(G),
		i->Permutation(i,zuppos,function(x,a)
		                          return SmallestGeneratorPerm(x^a);
					end));
      if NrMovedPoints(zuperms)<200*NrMovedPoints(G) then
	zuperms:=GroupHomomorphismByImagesNC(G,Group(zuperms),
		  GeneratorsOfGroup(G),zuperms);
	# force kernel, also enforces injective setting
	Gimg:=Image(zuperms);
	if Size(KernelOfMultiplicativeGeneralMapping(zuperms))=1 then
	  SetSize(Gimg,Size(G));
	fi;
      else
	zuperms:=fail;
      fi;
    else
      zuppos:=AsSSortedList(zuppos);
      zuperms:=fail;
    fi;

    # compute the prime corresponding to each zuppo and the index of power
    zupposPrime:=[];
    zupposPower:=[];
    for r  in zuppos  do
      i:=SmallestRootInt(Order(r));
      Add(zupposPrime,i);
      k:=0;
      while k <> false  do
	k:=k + 1;
	if GcdInt(i,k) = 1  then
	  l:=Position(zuppos,r^(i*k));
	  if l <> fail  then
	    Add(zupposPower,l);
	    k:=false;
	  fi;
	fi;
      od;
    od;
    Info(InfoLattice,1,"powers computed");

    if func<>false and 
      (noperf or func in SOLVABILITY_IMPLYING_FUNCTIONS) then
      Info(InfoLattice,1,"Ignoring perfect subgroups");
      perfect:=[];
    else
      if IsPermGroup(G) then
	# trigger potentially better methods
	IsNaturalSymmetricGroup(G);
	IsNaturalAlternatingGroup(G);
      fi;
      perfect:=RepresentativesPerfectSubgroups(G);
      perfect:=Filtered(perfect,i->Size(i)>1 and Size(i)<Size(G));
      if func<>false then
	perfect:=Filtered(perfect,func);
      fi;
      perfect:=List(perfect,i->AsSubgroup(Parent(G),i));
    fi;

    perfectZups:=[];
    perfectNew :=[];
    for i  in [1..Length(perfect)]  do
        I:=perfect[i];
        #perfectZups[i]:=BlistList(zuppos,AsSSortedListNonstored(I));
        perfectZups[i]:=ZupposSubgroup(I,false);
        perfectNew[i]:=true;
    od;
    Info(InfoLattice,1,"<G> has ",Length(perfect),
                  " representatives of perfect subgroups");

    # initialize the classes list
    nrClasses:=1;
    classes:=ConjugacyClassSubgroups(G,TrivialSubgroup(G));
    SetSize(classes,1);
    classes:=[classes];
    classesZups:=[BlistList(zuppos,[One(G)])];
    classesExts:=[DifferenceBlist(BlistList(zuppos,zuppos),classesZups[1])];
    layerb:=1;
    layere:=1;

    # loop over the layers of group (except the group itself)
    for l  in [1..Length(factors)-1]  do
      Info(InfoLattice,1,"doing layer ",l,",",
		    "previous layer has ",layere-layerb+1," classes");

      # extend representatives of the classes of the previous layer
      for h  in [layerb..layere]  do

	# get the representative,its zuppos blist and extend-by blist
	H:=Representative(classes[h]);
	Hzups:=classesZups[h];
	Hexts:=classesExts[h];
	Info(InfoLattice,2,"extending subgroup ",h,", size = ",Size(H));

	# loop over the zuppos whose <p>-th power lies in <H>
	for i  in [1..Length(zuppos)]  do

	    if Hexts[i] and Hzups[zupposPower[i]]  then

	      # make the new subgroup <I>
	      # NC is safe -- all groups are subgroups of Parent(H)
	      I:=ClosureSubgroupNC(H,zuppos[i]);
	      #Subgroup(Parent(G),Concatenation(GeneratorsOfGroup(H),
	      #			   [zuppos[i]]));
	      if func=false or func(I) then

		SetSize(I,Size(H) * zupposPrime[i]);

		# compute the zuppos blist of <I>
		#Ielms:=AsSSortedListNonstored(I);
		#Izups:=BlistList(zuppos,Ielms);
		if zuperms=fail then
		  Izups:=ZupposSubgroup(I,true);
		else
		  Izups:=ZupposSubgroup(I,false);
		fi;

		# compute the normalizer of <I>
		N:=Normalizer(G,I);
		#AH 'NormalizerInParent' attribute ?
		Info(InfoLattice,2,"found new class ",nrClasses+1,
		      ", size = ",Size(I)," length = ",Size(G)/Size(N));

		# make the new conjugacy class
		C:=ConjugacyClassSubgroups(G,I);
		SetSize(C,Size(G) / Size(N));
		SetStabilizerOfExternalSet(C,N);
		nrClasses:=nrClasses + 1;
		classes[nrClasses]:=C;

		# store the extend by list
		if l < Length(factors)-1  then
		  classesZups[nrClasses]:=Izups;
		  #Nzups:=BlistList(zuppos,AsSSortedListNonstored(N));
		  Nzups:=ZupposSubgroup(N,false);
		  SubtractBlist(Nzups,Izups);
		  classesExts[nrClasses]:=Nzups;
		fi;

		# compute the right transversal
		# (but don't store it in the parent)
		if expandmem and zuperms<>fail then
		  if Index(G,N)>400 then
		    ac:=AscendingChainOp(G,N); # do not store
		    while Length(ac)>2 and Index(ac[3],ac[1])<100 do
		      ac:=Concatenation([ac[1]],ac{[3..Length(ac)]});
		    od;
		    if Length(ac)>2 and
		      Maximum(List([3..Length(ac)],x->Index(ac[x],ac[x-1])))<500
		     then

		      # mapped factorized transversal
		      Info(InfoLattice,3,"factorized transversal ",
		             List([2..Length(ac)],x->Index(ac[x],ac[x-1])));
		      transv:=[];
		      ac[Length(ac)]:=Gimg;
		      for ri in [Length(ac)-1,Length(ac)-2..1] do
			ac[ri]:=Image(zuperms,ac[ri]);
			if ri=1 then
			  transv[ri]:=List(RightTransversalOp(ac[ri+1],ac[ri]),
			                   i->Permuted(Izups,i));
			else
			  transv[ri]:=AsList(RightTransversalOp(ac[ri+1],ac[ri]));
			fi;
		      od;
		      mapped:=true;
		      factored:=true;
		      reps:=Cartesian(transv);
		      Unbind(ac);
		      Unbind(transv);
		    else
		      reps:=RightTransversalOp(Gimg,Image(zuperms,N));
		      mapped:=true;
		      factored:=false;
		    fi;
		  else
		    reps:=RightTransversalOp(G,N);
		    mapped:=false;
		    factored:=false;
		  fi;
		else
		  reps:=RightTransversalOp(G,N);
		  mapped:=false;
		  factored:=false;
		fi;

		# loop over the conjugates of <I>
		for ri in [1..Length(reps)] do
		  CompletionBar(InfoLattice,3,"Coset loop: ",ri/Length(reps));
		  r:=reps[ri];

		  # compute the zuppos blist of the conjugate
		  if zuperms<>fail then
		    # we know the permutation of zuppos by the group
		    if mapped then
		      if factored then
			Jzups:=r[1];
			for rl in [2..Length(r)] do
			  Jzups:=Permuted(Jzups,r[rl]);
			od;
		      else
			Jzups:=Permuted(Izups,r);
		      fi;
		    else
		      if factored then
			Error("factored");
		      else
			Jzups:=Image(zuperms,r);
			Jzups:=Permuted(Izups,Jzups);
		      fi;
		    fi;
		  elif r = One(G)  then
		    Jzups:=Izups;
		  elif Ielms<>fail then
		    Jzups:=BlistList(zuppos,OnTuples(Ielms,r));
		  else
		    Jzups:=ZupposSubgroup(I^r,false);
		  fi;

		  # loop over the already found classes
		  for k  in [h..layere]  do
		    Kzups:=classesZups[k];

		    # test if the <K> is a subgroup of <J>
		    if IsSubsetBlist(Jzups,Kzups)  then
		      # don't extend <K> by the elements of <J>
		      SubtractBlist(classesExts[k],Jzups);
		    fi;

		  od;

		od;
		CompletionBar(InfoLattice,3,"Coset loop: ",false);

		# now we are done with the new class
		Unbind(Ielms);
		Unbind(reps);
		Info(InfoLattice,2,"tested inclusions");

	      else
		Info(InfoLattice,1,"discarded!");
	      fi; # if condition fulfilled

	    fi; # if Hexts[i] and Hzups[zupposPower[i]]  then ...
	  od; # for i  in [1..Length(zuppos)]  do ...

	  # remove the stuff we don't need any more
	  Unbind(classesZups[h]);
	  Unbind(classesExts[h]);
        od; # for h  in [layerb..layere]  do ...

        # add the classes of perfect subgroups
        for i  in [1..Length(perfect)]  do
	  if    perfectNew[i]
	    and IsPerfectGroup(perfect[i])
	    and Length(Factors(Size(perfect[i]))) = l
	  then

	    # make the new subgroup <I>
	    I:=perfect[i];

	    # compute the zuppos blist of <I>
	    #Ielms:=AsSSortedListNonstored(I);
	    #Izups:=BlistList(zuppos,Ielms);
	    if zuperms=fail then
	      Izups:=ZupposSubgroup(I,true);
	    else
	      Izups:=ZupposSubgroup(I,false);
	    fi;

	    # compute the normalizer of <I>
	    N:=Normalizer(G,I);
	    # AH: NormalizerInParent ?
	    Info(InfoLattice,2,"found perfect class ",nrClasses+1,
		  " size = ",Size(I),", length = ",Size(G)/Size(N));

	    # make the new conjugacy class
	    C:=ConjugacyClassSubgroups(G,I);
	    SetSize(C,Size(G)/Size(N));
	    SetStabilizerOfExternalSet(C,N);
	    nrClasses:=nrClasses + 1;
	    classes[nrClasses]:=C;

	    # store the extend by list
	    if l < Length(factors)-1  then
	      classesZups[nrClasses]:=Izups;
	      #Nzups:=BlistList(zuppos,AsSSortedListNonstored(N));
	      Nzups:=ZupposSubgroup(N,false);
	      SubtractBlist(Nzups,Izups);
	      classesExts[nrClasses]:=Nzups;
	    fi;

	    # compute the right transversal
	    # (but don't store it in the parent)
	    reps:=RightTransversalOp(G,N);

	    # loop over the conjugates of <I>
	    for r  in reps  do

	      # compute the zuppos blist of the conjugate
	      if zuperms<>fail then
		# we know the permutation of zuppos by the group
		Jzups:=Image(zuperms,r);
		Jzups:=Permuted(Izups,Jzups);
	      elif r = One(G)  then
		Jzups:=Izups;
	      elif Ielms<>fail then
		Jzups:=BlistList(zuppos,OnTuples(Ielms,r));
	      else
		Jzups:=ZupposSubgroup(I^r,false);
	      fi;

	      # loop over the perfect classes
	      for k  in [i+1..Length(perfect)]  do
		Kzups:=perfectZups[k];

		# throw away classes that appear twice in perfect
		if Jzups = Kzups  then
		  perfectNew[k]:=false;
		  perfectZups[k]:=[];
		fi;

	      od;

	    od;

	    # now we are done with the new class
	    Unbind(Ielms);
	    Unbind(reps);
	    Info(InfoLattice,2,"tested equalities");

	    # unbind the stuff we dont need any more
	    perfectZups[i]:=[];

	  fi; 
	  # if IsPerfectGroup(I) and Length(Factors(Size(I))) = layer the...
        od; # for i  in [1..Length(perfect)]  do

        # on to the next layer
        layerb:=layere+1;
        layere:=nrClasses;

    od; # for l  in [1..Length(factors)-1]  do ...

    # add the whole group to the list of classes
    Info(InfoLattice,1,"doing layer ",Length(factors),",",
                  " previous layer has ",layere-layerb+1," classes");
    if Size(G)>1 and (func=false or func(G)) then
      Info(InfoLattice,2,"found whole group, size = ",Size(G),",","length = 1");
      C:=ConjugacyClassSubgroups(G,G);
      SetSize(C,1);
      nrClasses:=nrClasses + 1;
      classes[nrClasses]:=C;
    fi;

    # return the list of classes
    Info(InfoLattice,1,"<G> has ",nrClasses," classes,",
                  " and ",Sum(classes,Size)," subgroups");

  lattice:=LatticeFromClasses(G,classes);
  if func<>false then
    lattice!.func:=func;
  fi;
  return lattice;
end);

BindGlobal("VectorspaceComplementOrbitsLattice",function(n,a,c,ker)
local s, m, dim, p, field, one, bas, I, l, avoid, li, gens, act, actfun,
      rep, max, baselist, ve, new, lb, newbase, e, orb, stb, tr, di,
      cont, j, img, idx, stabilizer, i, base, d, gn;
  m:=ModuloPcgs(a,ker);
  dim:=Length(m);
  p:=RelativeOrders(m)[1];
  field:=GF(p);
  one:=One(field);
  bas:=List(GeneratorsOfGroup(c),i->ExponentsOfPcElement(m,i)*one);
  TriangulizeMat(bas);
  bas:=Filtered(bas,i->not IsZero(i));
  I := IdentityMat(dim, field);
  l:=BaseSteinitzVectors(I,bas);
  avoid:=Length(l.subspace);
  l:=Concatenation(l.factorspace,l.subspace);
  l:=ImmutableMatrix(field,l);
  li:=l^-1;
  gens:=GeneratorsOfGroup(n);
  act:=LinearActionLayer(n,m);
  act:=List(act,i->l*i*li);
  if p=2 then
    actfun:=OnSubspacesByCanonicalBasisGF2;
  else
    actfun:=OnSubspacesByCanonicalBasis;
  fi;
  rep:=[];
  max:=dim-avoid;
  baselist := [[]];
  ve:=AsList(field);
  for i in [1..dim] do
    Info(InfoLattice,5,"starting dim :",i," bases found :",Length(baselist));
    new := [];
    for base in baselist do

      #subspaces of equal dimension
      lb:=Length(base);
      for d in [0..p^lb-1] do
	if d=0 then
	  # special case for subspace of higher dimension
	  if Length(base) < max and i<=max then
	    newbase:=Concatenation(List(base,ShallowCopy), [I[i]]);
	  else
	    newbase:=[];
	  fi;
	else
	  # possible extension number d
	  newbase := List(base,ShallowCopy);
	  e:=d;
	  for j in [1..lb] do
	    newbase[j][i]:=ve[(e mod p)+1];
	    e:=QuoInt(e,p);
	  od;
	  #for j in [1..Length(vec)] do
	  #  newbase[j][i] := vec[j];
	  #od;
	fi;
	if i<dim and Length(newbase)>0 then
	  # we will need the space for the next level
	  Add(new, newbase);
	fi;

	if Length(newbase)=max then
	  # compute orbit
	  orb:=[newbase];
	  stb:=a;
	  tr:=[One(a)];
	  di:=NewDictionary(newbase,true,
			# fake entry to simulate a ``grassmannian'' object
	                    1);
	  AddDictionary(di,newbase,1);
	  cont:=true;
	  j:=1;
	  while cont and j<=Length(orb) do
	    for gn in [1..Length(gens)] do
	      img:=actfun(orb[j],act[gn]);
	      idx:=LookupDictionary(di,img);
	      if idx=fail then
		if img<newbase then
		  # element is not minimal -- discard
		  cont:=false;
		fi;
		Add(orb,img);
		AddDictionary(di,img,Length(orb));
		Add(tr,tr[j]*gens[gn]);
	      else
		idx:=tr[j]*gens[gn]/tr[idx];
		stb:=ClosureGroup(stb,idx);
	      fi;
	    od;
	    j:=j+1;
	  od;

	  if cont then
	    Info(InfoLattice,5,"orbitlength=",Length(orb));
	    newbase:=List(newbase*l,i->PcElementByExponents(m,i));
	    s:=Group(Concatenation(GeneratorsOfGroup(ker),newbase));
	    SetSize(s,Size(ker)*p^Length(newbase));
	    j:=Size(stb);
	    if IsAbelian(stb) and
	      p^Length(GeneratorsOfGroup(stb))=j then
	      # don't waste too much time
	      stb:=Group(GeneratorsOfGroup(stb),());
	    else
	      stb:=Group(SmallGeneratingSet(stb),());
	    fi;
	    SetSize(stb,j);
	    Add(rep,rec(representative:=s,normalizer:=stb));
	  fi;
	fi;
      od;
    od;

    # book keeping for the next level
    Append(baselist, new);

  od;
  return rep;
end);


#############################################################################
##
#M  LatticeViaRadical(<G>[,<H>])  . . . . . . . . . .  lattice of subgroups
##
InstallGlobalFunction(LatticeViaRadical,function(arg)
  local G,H,HN,HNI,ser, pcgs, u, hom, f, c, nu, nn, nf, a, k, ohom, mpcgs, gf,
  act, nts, orbs, n, ns, nim, fphom, as, p, isn, isns, lmpc, npcgs, ocr, v,
  com, cg, i, j, w, ii,first,cgs,cs,presmpcgs,select,fselect;

  G:=arg[1];
  H:=fail;
  select:=fail;
  if Length(arg)>1 then
    if IsGroup(arg[2]) then
      H:=arg[2];
      if not (IsSubgroup(G,H) and IsNormal(G,H)) then
	Error("H must be normal in G");
      fi;
    elif IsFunction(arg[2]) then
      select:=arg[2];

    fi;
  fi;

  ser:=PermliftSeries(G:limit:=300); # do not form too large spaces as they
                                     # clog up memory
  pcgs:=ser[2];
  ser:=ser[1];
  if Index(G,ser[1])=1 then
    Info(InfoWarning,1,"group is solvable");
    hom:=NaturalHomomorphismByNormalSubgroup(G,G);
    hom:=hom*IsomorphismFpGroup(Image(hom));
    u:=[[G],[G],[hom]];
  elif Size(ser[1])=1 then
    if H<>fail then
      return LatticeByCyclicExtension(G,u->IsSubset(H,u));
    elif select<>fail then
      return LatticeByCyclicExtension(G,select);
    else
      return LatticeByCyclicExtension(G);
    fi;
  else
    hom:=NaturalHomomorphismByNormalSubgroupNC(G,ser[1]);
    f:=Image(hom,G);
    fselect:=fail;
    if H<>fail then
      HN:=Image(hom,H);
      c:=LatticeByCyclicExtension(f,u->IsSubset(HN,u))!.conjugacyClassesSubgroups;
    elif select<>fail and (select=IsPerfectGroup  or select=IsSimpleGroup) then
      c:=ConjugacyClassesPerfectSubgroups(f);
      c:=Filtered(c,x->Size(Representative(x))>1);
      fselect:=U->not IsSolvableGroup(U);
    elif select<>fail then
      c:=LatticeByCyclicExtension(f,select)!.conjugacyClassesSubgroups;
    else
      c:=LatticeByCyclicExtension(f)!.conjugacyClassesSubgroups;
    fi;
    if select<>fail then
      nu:=Filtered(c,i->select(Representative(i)));
      Info(InfoLattice,1,"Selection reduced ",Length(c)," to ",Length(nu));
      c:=nu;
    fi;
    nu:=[];
    nn:=[];
    nf:=[];
    for i in c do
      a:=Representative(i);
      k:=PreImage(hom,a);
      Add(nu,k);
      Add(nn,PreImage(hom,Stabilizer(i)));
      Add(nf,RestrictedMapping(hom,k)*IsomorphismFpGroup(a));
    od;
    u:=[nu,nn,nf];
  fi;
  for i in [2..Length(ser)] do
    Info(InfoLattice,1,"Step ",i," : ",Index(ser[i-1],ser[i]));
    #ohom:=hom;
    #hom:=NaturalHomomorphismByNormalSubgroupNC(G,ser[i]);
    if H<>fail then
      HN:=ClosureGroup(H,ser[i]);
      HNI:=Intersection(ClosureGroup(H,ser[i]),ser[i-1]);
#      if pcgs=false then
	mpcgs:=ModuloPcgs(HNI,ser[i]);
#      else
#	mpcgs:=pcgs[i-1] mod pcgs[i];
#      fi;
      presmpcgs:=ModuloPcgs(ser[i-1],ser[i]);
    else
      if pcgs=false then
	mpcgs:=ModuloPcgs(ser[i-1],ser[i]);
      else
	mpcgs:=pcgs[i-1] mod pcgs[i];
      fi;
      presmpcgs:=mpcgs;
    fi;

    if Length(mpcgs)>0 then
      gf:=GF(RelativeOrders(mpcgs)[1]);
      if select=IsPerfectGroup then
	# the only normal subgroups are those that are normal under any
	# subgroup so far.

	# minimal of the subgroups so far
	nu:=Filtered(u[1],x->not ForAny(u[1],y->Size(y)<Size(x)
                     and IsSubgroup(x,y)));
        nts:=[];
	#T: Use invariant subgroups here
	for j in nu do
	  for k in Filtered(NormalSubgroups(j),y->IsSubset(ser[i-1],y)
	      and IsSubset(y,ser[i])) do
            if not k in nts then Add(nts,k);fi;
	  od;
	od;
	# by setting up `act' as fail, we force a different selection later
	act:=[nts,fail];

      elif select=IsSimpleGroup then
	# simple -> no extensions, only the trivial subgroup is valid.
	act:=[[ser[i]],GroupHomomorphismByImagesNC(G,Group(()),
	    GeneratorsOfGroup(G),
	    List(GeneratorsOfGroup(G),i->()))];
      else
	act:=ActionSubspacesElementaryAbelianGroup(G,mpcgs);
      fi;
    else
      gf:=GF(Factors(Index(ser[i-1],ser[i]))[1]);
      act:=[[ser[i]],GroupHomomorphismByImagesNC(G,Group(()),
           GeneratorsOfGroup(G),
           List(GeneratorsOfGroup(G),i->()))];
    fi;
    nts:=act[1];
    act:=act[2];
    nu:=[];
    nn:=[];
    nf:=[];
    # Determine which ones we need and keep old ones
    orbs:=[];
    for j in [1..Length(u[1])] do
      a:=u[1][j];
#if ForAny(GeneratorsOfGroup(a),i->SIZE_OBJ(i)>maxsz) then Error("1");fi;
      n:=u[2][j];
#if ForAny(GeneratorsOfGroup(n),i->SIZE_OBJ(i)>maxsz) then Error("2");fi;

      # find indices of subgroups normal under a and form orbits under the
      # normalizer
      if act<>fail then
	ns:=Difference([1..Length(nts)],MovedPoints(Image(act,a)));
	nim:=Image(act,n);
	ns:=Orbits(nim,ns);
      else
	nim:=Filtered([1..Length(nts)],x->IsNormal(a,nts[x]));
	ns:=[];
	for k in [1..Length(nim)] do
	  if not ForAny(ns,x->nim[k] in x) then
	    p:=Orbit(n,nts[k]);
	    p:=List(p,x->Position(nts,x));
	    p:=Filtered(p,x->x<>fail and x in nim);
	    Add(ns,p);
	  fi;
	od;
      fi;
      if Size(a)>Size(ser[i-1]) then
	# keep old groups
	if H=fail or IsSubset(HN,a) then
	  Add(nu,a);Add(nn,n);
	  if Size(ser[i])>1 then
	    fphom:=LiftFactorFpHom(u[3][j],a,ser[i-1],ser[i],presmpcgs);
	    Add(nf,fphom);
	  fi;
	fi;
	orbs[j]:=ns;
      else # here a is the trivial subgroup in the factor. (This will never
	   # happen if we look for perfect or simple groups!)
	orbs[j]:=[];
	# previous kernel -- there the orbits are classes of subgroups in G
	for k in ns do
	  Add(nu,nts[k[1]]);
	  Add(nn,PreImage(act,Stabilizer(nim,k[1])));
	  if Size(ser[i])>1 then
	    fphom:=IsomorphismFpGroupByChiefSeriesFactor(nts[k[1]],"x",ser[i]);
	    Add(nf,fphom);
	  fi;
	od;
      fi;
    od;

    # run through nontrivial subspaces (greedy test whether they are needed)
    for j in [1..Length(nts)] do
      if Size(nts[j])<Size(ser[i-1]) then
	as:=[];
	for k in [1..Length(orbs)] do
	  p:=PositionProperty(orbs[k],z->j in z);
	  if p<>fail then
	    # remove orbit
	    orbs[k]:=orbs[k]{Difference([1..Length(orbs[k])],[p])};
	    Add(as,k);
	  fi;
	od;
	if Length(as)>0 then
	  Info(InfoLattice,2,"Normal subgroup ",j,", ",Length(as),
	       " subgroups to consider");
	  # there are subgroups that will complement with this kernel.
	  # Construct the modulo pcgs and the action of the largest subgroup
	  # (which must be the normalizer)
	  isn:=fail;
	  isns:=1;
	  for k in as do
	    if Size(u[1][k])>isns then
	      isns:=Size(u[1][k]);
	      isn:=k;
	    fi;
	  od;

	  if pcgs=false then
	    lmpc:=ModuloPcgs(ser[i-1],nts[j]);
	    npcgs:=ModuloPcgs(nts[j],ser[i]);
	  else
	    if IsTrivial(nts[j]) then
	      lmpc:=pcgs[i-1];
	      npcgs:="not used";
	    else
	      c:=InducedPcgs(pcgs[i-1],nts[j]);
	      lmpc:=pcgs[i-1] mod c;
	      npcgs:=c mod pcgs[i];
	    fi;
	  fi;

	  for k in as do
	    a:=u[1][k];
	    if IsNormal(u[2][k],nts[j]) then
	      n:=u[2][k];
	    else
	      n:=Normalizer(u[2][k],nts[j]);
#if ForAny(GeneratorsOfGroup(n),i->SIZE_OBJ(i)>maxsz) then Error("2a");fi;
	    fi;
	    if Length(GeneratorsOfGroup(n))>3 then
	      w:=Size(n);
	      n:=Group(SmallGeneratingSet(n));
	      SetSize(n,w);
	    fi;
	    ocr:=rec(group:=a,
		    modulePcgs:=lmpc);
	    #fphom:=RestrictedMapping(ohom,a)*IsomorphismFpGroup(Image(ohom,a));
	    #ocr.factorfphom:=fphom;
	    ocr.factorfphom:=u[3][k];
	    OCOneCocycles(ocr,true);
	    if IsBound(ocr.complement) then
#if ForAny(ocr.complementGens,i->SIZE_OBJ(i)>maxsz) then Error("3");fi;
	      v:=BaseSteinitzVectors(
		BasisVectors(Basis(ocr.oneCocycles)),
		BasisVectors(Basis(ocr.oneCoboundaries)));
	      v:=VectorSpace(gf,v.factorspace,Zero(ocr.oneCocycles));
	      com:=[];
	      cgs:=[];
	      first:=false;
	      if Size(v)>100 and Size(ser[i])=1
		 and HasElementaryAbelianFactorGroup(a,nts[j]) then
		com:=VectorspaceComplementOrbitsLattice(n,a,ser[i-1],nts[j]);
		Info(InfoLattice,4,"Subgroup ",Position(as,k),"/",Length(as),
		      ", ",Size(v)," local complements, ",Length(com)," orbits");
		for c in com do
		  if H=fail or IsSubset(HN,c.representative) then
		    Add(nu,c.representative);
		    Add(nn,c.normalizer);
		  fi;
		od;
	      else
		for w in Enumerator(v) do
		  cg:=ocr.cocycleToList(w);
  #if ForAny(cg,i->SIZE_OBJ(i)>maxsz) then Error("3");fi;
		  for ii in [1..Length(cg)] do
		    cg[ii]:=ocr.complementGens[ii]*cg[ii];
		  od;
		  if first then
		    # this is clearly kept -- so calculate a stabchain
		    c:=ClosureSubgroup(nts[j],cg);
		  first:=false;
		  else
		    c:=SubgroupNC(G,Concatenation(SmallGeneratingSet(nts[j]),cg));
		  fi;
		  Assert(1,Size(c)=Index(a,ser[i-1])*Size(nts[j]));
		  if H=fail or IsSubset(HN,c) then
		    SetSize(c,Index(a,ser[i-1])*Size(nts[j]));
		    Add(cgs,cg);
		    #c!.comgens:=cg;
		    Add(com,c);
		  fi;
		od;
		w:=Length(com);
		com:=SubgroupsOrbitsAndNormalizers(n,com,false:savemem:=true);
		Info(InfoLattice,3,"Subgroup ",Position(as,k),"/",Length(as),
		      ", ",w," local complements, ",Length(com)," orbits");
		for w in com do
		  c:=w.representative;
		  if fselect=fail or fselect(c) then
		    Add(nu,c);
		    Add(nn,w.normalizer);
		    if Size(ser[i])>1 then
		      # need to lift presentation
		      fphom:=ComplementFactorFpHom(ocr.factorfphom,
		      a,ser[i-1],nts[j],c,
		      ocr.generators,cgs[w.pos]);

		      Assert(1,KernelOfMultiplicativeGeneralMapping(fphom)=nts[j]);
		      if Size(nts[j])>Size(ser[i]) then
			fphom:=LiftFactorFpHom(fphom,c,nts[j],ser[i],npcgs);
			Assert(1,
			  KernelOfMultiplicativeGeneralMapping(fphom)=ser[i]);
		      fi;
		      Add(nf,fphom);
		    fi;
		  fi;

		od;
	      fi;

	      ocr:=false;
	      cgs:=false;
	      com:=false;
	    fi;
	  od;
	fi;
      fi;
    od;

    u:=[nu,nn,nf];

  od;
  nn:=[];
  for i in [1..Length(u[1])] do
    a:=ConjugacyClassSubgroups(G,u[1][i]);
    n:=u[2][i];
    SetSize(a,Size(G)/Size(n));
    SetStabilizerOfExternalSet(a,n);
    Add(nn,a);
  od;

  # some `select'ions remove the trivial subgroup
  if select<>fail and not ForAny(u[1],x->Size(x)=1) 
    and select(TrivialSubgroup(G)) then
    Add(nn,ConjugacyClassSubgroups(G,TrivialSubgroup(G)));
  fi;
  return LatticeFromClasses(G,nn);
end);


#############################################################################
##
#M  LatticeSubgroups(<G>)  . . . . . . . . . .  lattice of subgroups
##
InstallMethod(LatticeSubgroups,"via radical",true,[IsGroup],0,
  LatticeViaRadical);

#############################################################################
##
#M  Print for lattice
##
InstallMethod(ViewObj,"lattice",true,[IsLatticeSubgroupsRep],0,
function(l)
  Print("<subgroup lattice of ");
  ViewObj(l!.group);
  Print(", ", Length(l!.conjugacyClassesSubgroups)," classes, ",
    Sum(l!.conjugacyClassesSubgroups,Size)," subgroups");
  if IsBound(l!.func) then
    Print(", restricted under further condition l!.func");
  fi;
  Print(">");
end);

InstallMethod(PrintObj,"lattice",true,[IsLatticeSubgroupsRep],0,
function(l)
  Print("LatticeSubgroups(",l!.group);
  if IsBound(l!.func) then
    Print("),# under further condition l!.func\n");
  else
    Print(")");
  fi;
end);

#############################################################################
##
#M  ConjugacyClassesPerfectSubgroups 
##
InstallMethod(ConjugacyClassesPerfectSubgroups,"generic",true,[IsGroup],0,
function(G)
  return
    List(RepresentativesPerfectSubgroups(G),i->ConjugacyClassSubgroups(G,i));
end);

#############################################################################
##
#M  PerfectResiduum
##
InstallMethod(PerfectResiduum,"for groups",true,
  [IsGroup],0,
function(G)
  while not IsPerfectGroup(G) do
    G:=DerivedSubgroup(G);
  od;
  return G;
end);

#############################################################################
##
#M  RepresentativesPerfectSubgroups  solvable
##
InstallMethod(RepresentativesPerfectSubgroups,"solvable",true,
  [IsSolvableGroup],0,
function(G)
  return [TrivialSubgroup(G)];
end);

#############################################################################
##
#M  RepresentativesPerfectSubgroups
##

BindGlobal("RepsPerfSimpSub",function(G,simple)
local badsizes,n,un,cl,r,i,l,u,bw,cnt,gens,go,imgs,bg,bi,emb,nu,k,j,
      D,params,might,bo;
  if IsSolvableGroup(G) then
    return [TrivialSubgroup(G)];
  elif Size(RadicalGroup(G))>1 then
    D:=LatticeViaRadical(G,IsPerfectGroup);
    D:=List(D!.conjugacyClassesSubgroups,Representative);
    if simple then
      D:=Filtered(D,IsSimpleGroup);
    else
      D:=Filtered(D,IsPerfectGroup);
    fi;
    return D;
  else
    PerfGrpLoad(0);
    badsizes := Union(PERFRec.notAvailable,PERFRec.notKnown);
    D:=G;
    D:=PerfectResiduum(D);
    n:=Size(D);
    Info(InfoLattice,1,"The perfect residuum has size ",n);

    # sizes of possible perfect subgroups
    un:=Filtered(DivisorsInt(n),i->i>1
		 # index <=4 would lead to solvable factor
		 and i<n/4);

    # if D is simple, we can limit indices further
    if IsSimpleGroup(D) then
      k:=4;
      l:=120;
      while l<n do
        k:=k+1;
	l:=l*(k+1);
      od;
      # now k is maximal such that k!<Size(D). Thus subgroups of D must have
      # index more than k
      k:=Int(n/k);
      un:=Filtered(un,i->i<=k);
    fi;
    Info(InfoLattice,1,"Searching perfect groups up to size ",Maximum(un));

    if ForAny(un,i->i>10^6) then
      Error("the perfect residuum is too large");
    fi;

    un:=Filtered(un,i->i in PERFRec.sizes);
    if Length(Intersection(badsizes,un))>0 then
      Error(
        "failed due to incomplete information in the Holt/Plesken library");
    fi;
    cl:=Filtered(ConjugacyClasses(G),i->Representative(i) in D);
    Info(InfoLattice,2,Length(cl)," classes of ",
         Length(ConjugacyClasses(G))," to consider");

    r:=[];
    for i in un do

      l:=NumberPerfectGroups(i);
      if l>0 then
	for j in [1..l] do
	  u:=PerfectGroup(IsPermGroup,i,j);
	  Info(InfoLattice,1,"trying group ",i,",",j,": ",u);

	  # test whether there is a chance to embed
	  might:=simple=false or IsSimpleGroup(u);
	  cnt:=0;
	  while might and cnt<20 do
	    bg:=Order(Random(u));
	    might:=ForAny(cl,i->Order(Representative(i))=bg);
	    cnt:=cnt+1;
	  od;

	  if might then
	    # find a suitable generating system
	    bw:=infinity;
	    bo:=[0,0];
	    cnt:=0;
	    repeat
	      if cnt=0 then
		# first the small gen syst.
		gens:=SmallGeneratingSet(u);
	      else
		# then something random
		repeat
		  if Length(gens)>2 and Random([1,2])=1 then
		    # try to get down to 2 gens
		    gens:=List([1,2],i->Random(u));
		  else
		    gens:=List([1..Random([2..Length(SmallGeneratingSet(u))])],
		      i->Random(u));
		  fi;
                  # try to get small orders
		  for k in [1..Length(gens)] do
		    go:=Order(gens[k]);
		    # try a p-element
		    if Random([1..2*Length(gens)])=1 then
		      gens[k]:=gens[k]^(go/(Random(Factors(go))));
		    fi;
		  od;

	        until Index(u,SubgroupNC(u,gens))=1;
	      fi;
	      go:=List(gens,Order);
	      imgs:=List(go,i->Filtered(cl,j->Order(Representative(j))=i));
	      Info(InfoLattice,3,go,":",Product(imgs,i->Sum(i,Size)));
	      if Product(imgs,i->Sum(i,Size))<bw then
		bg:=gens;
		bo:=go;
		bi:=imgs;
		bw:=Product(imgs,i->Sum(i,Size));
	      elif Set(go)=Set(bo) then
		# we hit the orders again -> sign that we can't be
		# completely off track
	        cnt:=cnt+Int(bw/Size(G)*3);
	      fi;
	      cnt:=cnt+1;
	    until bw/Size(G)*6<cnt;

	    if bw>0 then
	      Info(InfoLattice,2,"find ",bw," from ",cnt);
	      # find all embeddings
	      params:=rec(gens:=bg,from:=u);
	      emb:=MorClassLoop(G,bi,params,
		# all injective homs = 1+2+8
	        11); 
	      #emb:=MorClassLoop(G,bi,rec(type:=2,what:=3,gens:=bg,from:=u,
	      #		elms:=false,size:=Size(u)));
	      Info(InfoLattice,2,Length(emb)," embeddings");
	      nu:=[];
	      for k in emb do
		k:=Image(k,u);
		if not ForAny(nu,i->RepresentativeAction(G,i,k)<>fail) then
		  Add(nu,k);
		  k!.perfectType:=[i,j];
		fi;
	      od;
	      Info(InfoLattice,1,Length(nu)," classes");
	      r:=Concatenation(r,nu);
	    fi;
	  else
	    Info(InfoLattice,2,"cannot embed");
	  fi;
	od;
      fi;
    od;
    # add the two obvious ones
    Add(r,D);
    Add(r,TrivialSubgroup(G));
    return r;
  fi;
end);

InstallMethod(RepresentativesPerfectSubgroups,"using Holt/Plesken library",
  true,[IsGroup],0,G->RepsPerfSimpSub(G,false));

InstallMethod(RepresentativesSimpleSubgroups,"using Holt/Plesken library",
  true,[IsGroup],0,G->RepsPerfSimpSub(G,true));

InstallMethod(RepresentativesSimpleSubgroups,"if perfect subs are known",
  true,[IsGroup and HasRepresentativesPerfectSubgroups],0,
  G->Filtered(RepresentativesPerfectSubgroups(G),IsSimpleGroup));

#############################################################################
##
#M  MaximalSubgroupsLattice
##
InstallMethod(MaximalSubgroupsLattice,"cyclic extension",true,
  [IsLatticeSubgroupsRep],0,
function (L)
    local   maximals,          # maximals as pair <class>,<conj> (result)
            maximalsConjs,     # corresponding conjugator element inverses
            cnt,               # count for information messages
            classes,           # list of all classes
            I,                 # representative of a class
            Ielms,             # elements of <I>
            Izups,             # zuppos blist of <I>
            N,                 # normalizer of <I>
            Jgens,             # zuppos of a conjugate of <I>
            Kgroup,             # zuppos of a representative in <classes>
            reps,              # transversal of <N> in <G>
	    grp,	       # the group
	    lcl,	       # length(lcasses);
	    clsz,
	    notinmax,
	    maxsz,
	    mkk,
	    ppow,
	    primes,
	    notperm,
	    dom,
	    orbs,
	    Iorbs,Jorbs,
            i,k,kk,r;         # loop variables

    if IsBound(L!.func) then
      Error("cannot compute maximality inclusions for partial lattice");
    fi;

    grp:=L!.group;
    # relevant prime powers
    primes:=Set(Factors(Size(grp)));
    ppow:=Collected(Factors(Size(grp)));
    ppow:=Union(List(ppow,i->List([1..i[2]],j->i[1]^j)));

    # compute the lattice,fetch the classes,and representatives
    classes:=L!.conjugacyClassesSubgroups;
    lcl:=Length(classes);
    clsz:=List(classes,i->Size(Representative(i)));
    if IsPermGroup(grp) then
      notperm:=false;
      dom:=[1..LargestMovedPoint(grp)];
      orbs:=List(classes,i->Set(List(Orbits(Representative(i),dom),Set)));
      orbs:=List(orbs,i->List([1..Maximum(dom)],p->Length(First(i,j->p in j))));
    else
      notperm:=true;
    fi;

    # compute a system of generators for the cyclic sgr. of prime power size

    # initialize the maximals list
    Info(InfoLattice,1,"computing maximal relationship");
    maximals:=List(classes,c -> []);
    maximalsConjs:=List(classes,c -> []);
    maxsz:=[];
    if IsSolvableGroup(grp) then
      # maxes of grp
      maxsz[lcl]:=Set(List(MaximalSubgroupClassReps(grp),Size));
    else
      maxsz[lcl]:=fail; # don't know about group
    fi;

    # find the minimal supergroups of the whole group
    Info(InfoLattice,2,"testing class ",lcl,", size = ",
         Size(grp),", length = 1, included in 0 minimal subs");

    # loop over all classes
    for i  in [lcl-1,lcl-2..1]  do

        # take the subgroup <I>
        I:=Representative(classes[i]);
	if not notperm then
	  Iorbs:=orbs[i];
	fi;
        Info(InfoLattice,2," testing class ",i);

	if IsSolvableGroup(I) then
	  maxsz[i]:=Set(List(MaximalSubgroupClassReps(I),Size));
	else
	  maxsz[i]:=fail;
	fi;

        # compute the normalizer of <I>
        N:=StabilizerOfExternalSet(classes[i]);

	# compute the right transversal (but don't store it in the parent)
	reps:=RightTransversalOp(grp,N);

        # initialize the counter
        cnt:=0;

        # loop over the conjugates of <I>
        for r  in [1..Length(reps)]  do

            # compute the generators of the conjugate
            if reps[r] = One(grp)  then
                Jgens:=SmallGeneratingSet(I);
		if not notperm then
		  Jorbs:=Iorbs;
		fi;
            else
                Jgens:=OnTuples(SmallGeneratingSet(I),reps[r]);
		if not notperm then
		  Jorbs:=Permuted(Iorbs,reps[r]);
		fi;
            fi;

            # loop over all other (larger) classes
            for k  in [i+1..lcl]  do
	      Kgroup:=Representative(classes[k]);
	      kk:=clsz[k]/clsz[i];
	      if IsInt(kk) and kk>1 and
		# maximal sizes known?
		(maxsz[k]=fail or clsz[i] in maxsz[k]) and
		(notperm or ForAll(dom,x->Jorbs[x]<=orbs[k][x])) then
                # test if the <K> is a minimal supergroup of <J>
                if  ForAll(Jgens,i->i in Kgroup) then
		  # at this point we know all maximals of k of larger order
		  notinmax:=true;
		  kk:=1;
		  while notinmax and kk<=Length(maximals[k]) do
		    mkk:=maximals[k][kk];
		    if IsInt(clsz[mkk[1]]/clsz[i]) # could be in by order
	             and ForAll(Jgens,i->i^maximalsConjs[k][kk] in
				    Representative(classes[mkk[1]])) then
                      notinmax:=false;
		    fi;
                    kk:=kk+1;
		  od;

		  if notinmax then
                    Add(maximals[k],[i,r]);
		    # rep of x-th class ^r is contained in k-th class rep,
		    # so to remove nonmax inclusions we need to test whether
		    # conjugate of putative max by r^-1 is rep of x-th
		    # class.
		    Add(maximalsConjs[k],reps[r]^-1);
                    cnt:=cnt + 1;
		  fi;
                fi;
	      fi;

            od;
        od;

        Unbind(reps);
        # inform about the count
        Info(InfoLattice,2,"size = ",Size(I),", length = ",
	  Size(grp) / Size(N),", included in ",cnt," minimal sups");

    od;

    return maximals;
end);

#############################################################################
##
#M  MinimalSupergroupsLattice
##
InstallMethod(MinimalSupergroupsLattice,"cyclic extension",true,
  [IsLatticeSubgroupsRep],0,
function (L)
    local   minimals,          # minimals as pair <class>,<conj> (result)
            minimalsZups,      # their zuppos blist
            cnt,               # count for information messages
            zuppos,            # generators of prime power order
            classes,           # list of all classes
            classesZups,       # zuppos blist of classes
            I,                 # representative of a class
            Ielms,             # elements of <I>
            Izups,             # zuppos blist of <I>
            N,                 # normalizer of <I>
            Jzups,             # zuppos of a conjugate of <I>
            Kzups,             # zuppos of a representative in <classes>
            reps,              # transversal of <N> in <G>
	    grp,	       # the group
            i,k,r;         # loop variables

    if IsBound(L!.func) then
      Error("cannot compute maximality inclusions for partial lattice");
    fi;

    grp:=L!.group;
    # compute the lattice,fetch the classes,zuppos,and representatives
    classes:=L!.conjugacyClassesSubgroups;
    classesZups:=[];

    # compute a system of generators for the cyclic sgr. of prime power size
    zuppos:=Zuppos(grp);

    # initialize the minimals list
    Info(InfoLattice,1,"computing minimal relationship");
    minimals:=List(classes,c -> []);
    minimalsZups:=List(classes,c -> []);

    # loop over all classes
    for i  in [1..Length(classes)-1]  do

        # take the subgroup <I>
        I:=Representative(classes[i]);

        # compute the zuppos blist of <I>
        Ielms:=AsSSortedListNonstored(I);
        Izups:=BlistList(zuppos,Ielms);
        classesZups[i]:=Izups;

        # compute the normalizer of <I>
        N:=StabilizerOfExternalSet(classes[i]);

        # compute the right transversal (but don't store it in the parent)
        reps:=RightTransversalOp(grp,N);

        # initialize the counter
        cnt:=0;

        # loop over the conjugates of <I>
        for r  in [1..Length(reps)]  do

            # compute the zuppos blist of the conjugate
            if reps[r] = One(grp)  then
                Jzups:=Izups;
            else
                Jzups:=BlistList(zuppos,OnTuples(Ielms,reps[r]));
            fi;

            # loop over all other (smaller classes)
            for k  in [1..i-1]  do
                Kzups:=classesZups[k];

                # test if the <K> is a maximal subgroup of <J>
                if    IsSubsetBlist(Jzups,Kzups)
                  and ForAll(minimalsZups[k],
                              zups -> not IsSubsetBlist(Jzups,zups))
                then
                    Add(minimals[k],[ i,r ]);
                    Add(minimalsZups[k],Jzups);
                    cnt:=cnt + 1;
                fi;

            od;

        od;

        # inform about the count
        Unbind(Ielms);
        Unbind(reps);
        Info(InfoLattice,2,"testing class ",i,", size = ",Size(I),
	     ", length = ",Size(grp) / Size(N),", includes ",cnt,
	     " maximal subs");

    od;

    # find the maximal subgroups of the whole group
    cnt:=0;
    for k  in [1..Length(classes)-1]  do
        if minimals[k] = []  then
            Add(minimals[k],[ Length(classes),1 ]);
            cnt:=cnt + 1;
        fi;
    od;
    Info(InfoLattice,2,"testing class ",Length(classes),", size = ",
        Size(grp),", length = 1, includes ",cnt," maximal subs");

    return minimals;
end);

#############################################################################
##
#F  MaximalSubgroupClassReps(<G>) . . . . reps of conjugacy classes of
#F                                                          maximal subgroups
##
InstallMethod(MaximalSubgroupClassReps,"using lattice",true,[IsGroup],0,
function (G)
    local   maxs,lat;

    #AH special AG treatment
    if not HasIsSolvableGroup(G) and IsSolvableGroup(G) then
      return MaximalSubgroupClassReps(G);
    fi;
    # simply compute all conjugacy classes and take the maximals
    lat:=LatticeSubgroups(G);
    maxs:=MaximalSubgroupsLattice(lat)[Length(lat!.conjugacyClassesSubgroups)];
    maxs:=List(lat!.conjugacyClassesSubgroups{
       Set(maxs{[1..Length(maxs)]}[1])},Representative);
    return maxs;
end);

#############################################################################
##
#F  ConjugacyClassesMaximalSubgroups(<G>)
##
InstallMethod(ConjugacyClassesMaximalSubgroups,
 "use MaximalSubgroupClassReps",true,[IsGroup],0,
function(G)
  return List(MaximalSubgroupClassReps(G),i->ConjugacyClassSubgroups(G,i));
end);

#############################################################################
##
#F  MaximalSubgroups(<G>)
##
InstallMethod(MaximalSubgroups,
 "expand list",true,[IsGroup],0,
function(G)
  return Concatenation(List(ConjugacyClassesMaximalSubgroups(G),AsList));
end);

#############################################################################
##
#F  NormalSubgroupsCalc(<G>[,<onlysimple>]) normal subs for pc or perm groups
##
NormalSubgroupsCalc := function (arg)
local G,	# group
      onlysimple,  # determine only subgroups with simple composition factors
      nt,nnt,	# normal subgroups
      cs,	# comp. series
      M,N,	# nt . in series
      mpcgs,	# modulo pcgs
      p,	# prime
      ocr,	# 1-cohomology record
      l,	# list
      vs,	# vector space
      hom,	# homomorphism
      jg,	# generator images
      auts,	# factor automorphisms
      comp,
      firsts,
      still,
      ab,
      T,S,C,A,ji,orb,orbi,cllen,r,o,c,inv,cnt,
      ii,i,j,k;	# loop

  G:=arg[1];
  onlysimple:=false;
  if Length(arg)>1 and arg[2]=true then
    onlysimple:=true;
  fi;
  if IsElementaryAbelian(G) then
    # we need to do this separately as the inductive process misses its
    # start if the chies series has only one step
    return InvariantSubgroupsElementaryAbelianGroup(G,[]);
  fi;

  cs:=ChiefSeries(G);
  G!.lattfpres:=IsomorphismFpGroupByChiefSeriesFactor(G,"x",G);
  nt:=[G];


  for i in [2..Length(cs)] do
    still:=i<Length(cs);
    # we assume that nt contains all normal subgroups above cs[i-1]
    # we want to lift to G/cs[i]
    M:=cs[i-1];
    N:=cs[i];
    ab:=HasAbelianFactorGroup(M,N);

    # the normal subgroups already known
    if (not onlysimple) or (not ab) then
      nnt:=ShallowCopy(nt);
    else
      nnt:=[];
    fi;
    firsts:=Length(nnt);

    Info(InfoLattice,1,i,":",Index(M,N)," ",ab);
    if ab then
      # the modulo pcgs
      mpcgs:=ModuloPcgs(M,N);

      p:=RelativeOrderOfPcElement(mpcgs,mpcgs[1]);

      for j in Filtered(nt,i->Size(i)>Size(M)) do
	# test centrality
	if ForAll(GeneratorsOfGroup(j),
	          i->ForAll(mpcgs,j->Comm(i,j) in N)) then

	  Info(InfoLattice,2,"factorsize=",Index(j,N),"/",Index(M,N));

	  # reasons not to go complements
	  if (HasAbelianFactorGroup(j,N) and
	    p^(Length(mpcgs)*LogInt(Index(j,M),p))>100)
	    then
            Info(InfoLattice,3,"Set l to fail");
	    l:=fail;  # we will compute the subgroups later
	  else

	    ocr:=rec(
		   group:=j,
		   modulePcgs:=mpcgs
		 );
            if not IsBound(j!.lattfpres) then
	      Info(InfoLattice,2,"Compute new factorfp");
	      j!.lattfpres:=IsomorphismFpGroupByChiefSeriesFactor(j,"x",M);
	    fi;
	    ocr.factorfphom:=j!.lattfpres;
	    Assert(2,KernelOfMultiplicativeGeneralMapping(ocr.factorfphom)=M);

	    # we want only normal complements. Therefore the 1-Coboundaries must
	    # be trivial. We compute these first.
	    if Dimension(OCOneCoboundaries(ocr))=0 then
	      l:=[];
	      OCOneCocycles(ocr,true);
	      if IsBound(ocr.complement) then
		l:=BaseSteinitzVectors(BasisVectors(Basis(ocr.oneCocycles)),
		      BasisVectors(Basis(ocr.oneCoboundaries)));
		vs:=VectorSpace(LeftActingDomain(ocr.oneCocycles),
			 l.factorspace,Zero(ocr.oneCocycles));
		Info(InfoLattice,2,p^Length(l.factorspace)," cocycles");

		# try to catch some solvable cases that look awful
		if Size(vs)>1000 and Length(Set(Factors(Index(j,N))))<=2
		  then
		  l:=fail;
		else
		  l:=[];
		  for k in vs do
		    comp:=ocr.cocycleToList(k);
		    for ii in [1..Length(comp)] do
		      comp[ii]:=ocr.complementGens[ii]*comp[ii];
		    od;
		    k:=ClosureGroup(N,comp);
		    if IsNormal(G,k) then
		      if still then
			# transfer a known presentation
			if not IsPcGroup(k) then
			  k!.lattfpres:=ComplementFactorFpHom(
			    ocr.factorfphom,l,M,N,k,ocr.generators,comp);
	    Assert(1,KernelOfMultiplicativeGeneralMapping(k!.lattfpres)=N);
			fi;
                        k!.obtain:="compl";
		      fi;
		      Add(l,k);
		    fi;
		  od;

		  Info(InfoLattice,2," -> ",Length(l)," normal complements");
		  nnt:=Concatenation(nnt,l);
	        fi;
	      fi;
	    fi;
          fi;
	  Info(InfoLattice,3,"Set l to ",l);

          if l=fail then
	    if onlysimple then
	      # all groups obtained will have a solvable factor
	      l:=[];
	    else
	      Info(InfoLattice,1,"using invariant subgroups");
	      # the factor is abelian, we therefore find this homomorphism
	      # quick.
	      hom:=NaturalHomomorphismByNormalSubgroup(j,N);
	      r:=Image(hom,j);
	      jg:=List(GeneratorsOfGroup(j),i->Image(hom,i));
	      # construct the automorphisms
	      auts:=List(GeneratorsOfGroup(G),
		i->GroupHomomorphismByImagesNC(r,r,jg,
		  List(GeneratorsOfGroup(j),k->Image(hom,k^i))));
	      l:=SubgroupsSolvableGroup(r,rec(
		  actions:=auts,
		  funcnorm:=r,
		  consider:=ExactSizeConsiderFunction(Index(j,M)),
		  normal:=true));
	      Info(InfoLattice,2,"found ",Length(l)," invariant subgroups");
	      C:=Image(hom,M);
	      l:=Filtered(l,i->Size(i)=Index(j,M) and Size(Intersection(i,C))=1);
	      l:=List(l,i->PreImage(hom,i));
	      l:=Filtered(l,i->IsNormal(G,i));
	      Info(InfoLattice,1,Length(l)," of these normal");

	      nnt:=Concatenation(nnt,l);
	    fi;
          fi;

        fi;

      od;
      
    else
      # nonabelian factor.
      if still then
	# fp isom for decomposition
	mpcgs:=IsomorphismFpGroupByChiefSeriesFactor(M,"x",N);
      fi;

      # 1) compute the action for the factor

      # first, we obtain the simple factors T_i/N.
      # we get these as intersections of the conjugates of the subnormal
      # subgroup
      if HasCompositionSeries(M) then
	T:=CompositionSeries(M)[2]; # stored attribute
      else
        T:=false;
      fi;
      if not (T<>false and IsSubgroup(T,N)) then
        # we did not get the right T: must compute
	hom:=NaturalHomomorphismByNormalSubgroup(M,N);
	T:=CompositionSeries(Image(hom))[2];
	T:=PreImage(hom,T);
      fi;

      hom:=NaturalHomomorphismByNormalSubgroup(M,T);
      A:=Image(hom,M);

      Info(InfoLattice,2,"Search involution");

      # find involution in M/T
      repeat
	repeat
	  inv:=Random(M);
	until (Order(inv) mod 2 =0) and not inv in T;
	o:=First([2..Order(inv)],i->inv^i in T);
      until (o mod 2 =0);
      Info(InfoLattice,2,"Element of order ",o);
      inv:=inv^(o/2); # this is an involution in the factor
      Assert(1,inv^2 in T and not inv in T);

      S:=Normalizer(G,T); # stabilize first component

      orb:=[inv]; # class representatives in A by preimages in G
      orbi:=[Image(hom,inv)];
      cllen:=Index(A,Centralizer(A,orbi[1]));
      C:=T; #starting centralizer
      cnt:=1;

      # we have to find at least 1 centralizing element
      repeat

	# find element that centralizes inv modulo T
	repeat
	  r:=Random(S);
	  c:=Comm(inv,r);
	  o:=First([1..Order(c)],i->c^i in T);
	  c:=c^QuoInt(o-1,2);
	  if o mod 2=1 then
	    c:=r*c;
	  else
	    c:=inv^r*c;
	  fi;

	  # take care of potential class fusion
	  if not c in T and c in C then
	    cnt:=cnt+1;
	    if cnt=10 then

	      # if we have 10 true centralizing elements that did not
	      # yield anything new, we assume that classes get fused.
	      # So we have to test, how much fusion takes place.
	      # We do this with an orbit algorithm on classes of A

	      for j in orb do
		for k in SmallGeneratingSet(S) do
		  j:=j^k;
		  ji:=Image(hom,j);
		  if ForAll(orbi,l->RepresentativeAction(A,l,ji)=fail) then
		    Add(orb,j);
		    Add(orbi,ji);
		  fi;
		od;
	      od;

	      # now we have the length
	      cllen:=cllen*Length(orb);
	      Info(InfoLattice,1,Length(orb)," classes fuse");

	    fi;
	  fi;

	until not c in C or Index(S,C)=cllen;

	C:=ClosureGroup(C,c);
	Info(InfoLattice,2,"New centralizing element of order ",o,
			   ", Index=",Index(S,C));

      until Index(S,C)<=cllen;

      C:=Core(G,C); #the true centralizer is the core of the involution
		    # centralizer

      if Size(C)>Size(N) then
	for j in Filtered(nt,i->Size(i)>Size(M)) do
	  j:=Intersection(C,j);
	  if Size(j)>Size(N) and not j in nnt then
	    j!.obtain:="nonab";
	    Add(nnt,j);
	  fi;
	od;
      fi;

    fi; # else nonabelian

    # the kernel itself
    N!.lattfpres:=IsomorphismFpGroupByChiefSeriesFactor(N,"x",N);
    N!.obtain:="kernel";
    Add(nnt,N);
    if onlysimple then
      c:=Length(nnt);
      nnt:=Filtered(nnt,j->Size(ClosureGroup(N,DerivedSubgroup(j)))=Size(j) );
      Info(InfoLattice,2,"removed ",c-Length(nnt)," nonperfect groups");
    fi;

    Info(InfoLattice,1,Length(nnt)-Length(nt),
          " new normal subgroups (",Length(nnt)," total)");
    nt:=nnt;

    # modify hohomorphisms
    if still then
      for i in [1..firsts] do
	l:=nt[i];
	if IsBound(l!.lattfpres) then
	  Assert(1,KernelOfMultiplicativeGeneralMapping(l!.lattfpres)=M);
	  # lift presentation
	  # note: if notabelian mpcgs is an fp hom
	  l!.lattfpres:=LiftFactorFpHom(l!.lattfpres,l,M,N,mpcgs);
	  l!.obtain:="lift";
	fi;
      od;
    fi;

  od;

  # remove partial presentation info
  for i in nt do
    Unbind(i!.lattfpres);
  od;

  return Reversed(nt); # to stay ascending
end;

#############################################################################
##
#M  NormalSubgroups(<G>)
##
InstallMethod(NormalSubgroups,"homomorphism principle pc groups",true,
  [IsPcGroup],0,NormalSubgroupsCalc);

InstallMethod(NormalSubgroups,"homomorphism principle perm groups",true,
  [IsPermGroup],0,NormalSubgroupsCalc);

#############################################################################
##
#M  Socle(<G>)
##
InstallMethod(Socle,"from normal subgroups",true,[IsGroup],0,
function(G)
local n,i,s;
  if Size(G)=1 then return G;fi;
  # this could be a bit shorter, but the groups in question have few normal
  # subgroups
  n:=NormalSubgroups(G);
  n:=Filtered(n,i->2=Number(n,j->IsSubset(i,j)));
  s:=n[1];
  for i in [2..Length(n)] do
    s:=ClosureGroup(s,n[i]);
  od;
  return s;
end);

#############################################################################
##
#M  IntermediateSubgroups(<G>,<U>)
##
InstallMethod(IntermediateSubgroups,"blocks for coset operation",
  IsIdenticalObj, [IsGroup,IsGroup],0,
function(G,U)
local rt,op,a,l,i,j,u,max,subs;
  if Length(GeneratorsOfGroup(G))>2 then
    a:=SmallGeneratingSet(G);
    if Length(a)<Length(GeneratorsOfGroup(G)) then
      G:=Subgroup(Parent(G),a);
    fi;
  fi;
  rt:=RightTransversal(G,U);
  op:=Action(G,rt,OnRight); # use the special trick for right transversals
  a:=ShallowCopy(AllBlocks(op));
  l:=Length(a);

  # compute inclusion information among sets
  Sort(a,function(x,y)return Length(x)<Length(y);end);
  # this is n^2 but I hope will not dominate everything.
  subs:=List([1..l],i->Filtered([1..i-1],j->IsSubset(a[i],a[j])));
      # List the sets we know to be contained in each set

  max:=Set(List(Difference([1..l],Union(subs)), # sets which are
						# contained in no other
      i->[i,l+1]));

  for i in [1..l] do
    #take all subsets
    if Length(subs[i])=0 then
      # is minimal
      AddSet(max,[0,i]);
    else
      u:=ShallowCopy(subs[i]);
      #and remove those which come via other ones
      for j in u do
	u:=Difference(u,subs[j]);
      od;
      for j in u do
	#remainder is maximal
	AddSet(max,[j,i]);
      od;
    fi;
  od;

  return rec(subgroups:=List(a,i->ClosureGroup(U,rt{i})),inclusions:=max);
end);

InstallMethod(IntermediateSubgroups,"normal case",
  IsIdenticalObj, [IsGroup,IsGroup],
  1,# better than the previous method
function(G,N)
local hom,F,cl,cls,lcl,sub,sel,unsel,i,j;
  if not IsNormal(G,N) then
    TryNextMethod();
  fi;
  hom:=NaturalHomomorphismByNormalSubgroup(G,N);
  F:=Image(hom,G);
  unsel:=[1,Size(F)];
  cl:=Filtered(ConjugacyClassesSubgroups(F),
               i->not Size(Representative(i)) in unsel);
  Sort(cl,function(a,b)
            return Size(Representative(a))<Size(Representative(b));
	  end);
  cl:=Concatenation(List(cl,AsList));
  lcl:=Length(cl);
  cls:=List(cl,Size);
  sub:=List(cl,i->[]);
  sub[lcl+1]:=[0..Length(cl)];
  # now build a list of contained maximal subgroups
  for i in [1..lcl] do
    sel:=Filtered([1..i-1],j->IsInt(cls[i]/cls[j]) and cls[j]<cls[i]);
    # now run through the subgroups in reversed order:
    sel:=Reversed(sel);
    unsel:=[];
    for j in sel do
      if not j in unsel then
	if IsSubset(cl[i],cl[j]) then
	  AddSet(sub[i],j);
	  UniteSet(unsel,sub[j]); # these are not maximal
	  RemoveSet(sub[lcl+1],j); # j is not maximal in whole
	fi;
      fi;
    od;
    if Length(sub[i])=0 then
      sub[i]:=[0]; # minimal subgroup
      RemoveSet(sub[lcl+1],0);
    fi;
  od;
  sel:=[];
  for i in [1..Length(sub)] do
    for j in sub[i] do
      Add(sel,[j,i]);
    od;
  od;
  return rec(subgroups:=List(cl,i->PreImage(hom,i)),inclusions:=sel);
end);

#############################################################################
##
#F  DotFileLatticeSubgroups(<L>,<file>)
##
InstallGlobalFunction(DotFileLatticeSubgroups,function(L,file)
local cls, len, sz, max, rep, z, t, i, j, k;
  cls:=ConjugacyClassesSubgroups(L);
  len:=[];
  sz:=[];
  for i in cls do
    Add(len,Size(i));
    AddSet(sz,Size(Representative(i)));
  od;

  PrintTo(file,"digraph lattice {\nsize = \"6,6\";\n");
  # sizes and arrangement
  for i in sz do
    AppendTo(file,"\"s",i,"\" [label=\"",i,"\", color=white];\n");
  od;
  sz:=Reversed(sz);
  for i in [2..Length(sz)] do
    AppendTo(file,"\"s",sz[i-1],"\"->\"s",sz[i],
      "\" [color=white,arrowhead=none];\n");
  od;

  # subgroup nodes, also acccording to size
  for i in [1..Length(cls)] do
    for j in [1..len[i]] do
      if len[i]=1 then
	AppendTo(file,"\"",i,"x",j,"\" [label=\"",i,"\", shape=box];\n");
      else
	AppendTo(file,"\"",i,"x",j,"\" [label=\"",i,"-",j,"\", shape=circle];\n");
      fi;
    od;
    AppendTo(file,"{ rank=same; \"s",Size(Representative(cls[i])),"\"");
    for j in [1..len[i]] do
      AppendTo(file," \"",i,"x",j,"\"");
    od;
    AppendTo(file,";}\n");
  od;

  max:=MaximalSubgroupsLattice(L);
  for i in [1..Length(cls)] do
    for j in max[i] do
      rep:=ClassElementLattice(cls[i],1);
      for k in [1..len[i]] do
	if k=1 then
	  z:=j[2];
	else
	  t:=cls[i]!.normalizerTransversal[k];
	  z:=ClassElementLattice(cls[j[1]],1); # force computation of transv.
	  z:=cls[j[1]]!.normalizerTransversal[j[2]]*t;
	  z:=PositionCanonical(cls[j[1]]!.normalizerTransversal,z);
	fi;
	AppendTo(file,"\"",i,"x",k,"\" -> \"",j[1],"x",z,
	         "\" [arrowhead=none];\n");
      od;
    od;
  od;
  AppendTo(file,"}\n");
end);

#############################################################################
##
#E  grplatt.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

