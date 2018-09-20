#############################################################################
##
##  Custom streams for HPC-GAP
##

#############################################################################
##
#R  IsInputTextCustomRep   (used for custom streams)
##
##  <ManSection>
##  <Filt Name="IsInputTextCustomRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareRepresentation(
    "IsInputTextCustomRep",
    IsComponentObjectRep,
    ["state", "read", "close", "buffer", "endofinput", "pos"] );


#############################################################################
##
#C  IsInputCustomStream( <obj> )  . . . . .  category of input custom streams
##
##  <#GAPDoc Label="IsInputCustomStream">
##  <ManSection>
##  <Filt Name="IsInputCustomStream" Arg='obj' Type='Category'/>
##
##  <Description>
##  All <E>custom</E> input streams lie in this category. They translate
##  new-line
##  characters read.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsInputCustomStream", IsInputStream );


#############################################################################
##
#C  IsOutputCustomStream( <obj> ) . . . . . category of output custom streams
##
##  <#GAPDoc Label="IsOutputCustomStream">
##  <ManSection>
##  <Filt Name="IsOutputCustomStream" Arg='obj' Type='Category'/>
##
##  <Description>
##  All <E>custom</E> output streams lie in this category and translate
##  new-line characters on output.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsOutputCustomStream", IsOutputStream );


#############################################################################
##
#O  InputTextCustom( <state>, <read>, <close> )	. . . . . . create input text
#O                              stream from state, read, and close functions.
##
##  <#GAPDoc Label="InputTextCustom">
##  <ManSection>
##  <Oper Name="InputTextCustom" Arg='state, read, close'/>
##
##  <Description>
##  <C>InputTextString( <A>state</A>, <A>read</A>, <A>close</A> )</C> returns
##  an input stream that
##  delivers the characters generated by the <A>read</A> function. The
##  <A>read</A> function is passed the <A>state</A> parameter as its
##  argument. When the stream is closed, <A>close</A> is called with
##  <A>state</a> as its argument.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "InputTextCustom" );


#############################################################################
##
#O  OutputTextCustom( <state>, <write>, <close> )  . . . . . .  create custom
#O                                                         output text stream
##
##  <#GAPDoc Label="OutputTextCustom">
##  <ManSection>
##  <Oper Name="OutputTextCustom" Arg='state, write, close'/>
##
##  <Description>
##  returns an output stream that sends all received characters to the
##  <A>write</A> function. The <A>write</A> function is called with
##  <A>state</A> as its first parameter and a string containing characters
##  to be output as its second. The <A>close</A> function is called when
##  the stream is closed with <A>state</A> as its only argument.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "OutputTextCustom" );


