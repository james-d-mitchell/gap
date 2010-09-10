/****************************************************************************
**
*W  streams.h                   GAP source                       Frank Celler
*W                                                  & Burkhard Höfling (MAC)
**
*H  @(#)$Id: streams.h,v 4.12 2010/04/27 09:27:45 sal Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the  various read-eval-print loops and streams related
**  stuff.  The system depend part is in "sysfiles.c".
*/
#ifdef INCLUDE_DECLARATION_PART
const char * Revision_streams_h =
   "@(#)$Id: streams.h,v 4.12 2010/04/27 09:27:45 sal Exp $";
#endif


/****************************************************************************
**

*F * * * * * * * * * streams and files related functions  * * * * * * * * * *
*/


/****************************************************************************
**
*F  READ()  . . . . . . . . . . . . . . . . . . . . . . .  read current input
**
**  Read the current input and close the input stream.
*/
extern Int READ ( void );

/****************************************************************************
**
*F  READ()  . . . . . . . . . . . . . . . . . . . . . . .  read current input
**
**  Read the current input and close the input stream. Disable the normal 
** mechanism which ensures that quitting from a break loop gets you back to a 
** live prompt. This is initially designed for the files read from the command 
** line
*/
extern Int READ_NORECOVERY ( void );


/****************************************************************************
**
*F  READ_AS_FUNC()  . . . . . . . . . . . . .  read current input as function
**
**  Read the current input as function and close the input stream.
*/
extern Obj READ_AS_FUNC ( void );


/****************************************************************************
**
*F  READ_TEST() . . . . . . . . . . . . . . . . .  read current input as test
**
**  Read the current input as test and close the input stream.
*/
extern Int READ_TEST ( void );


/****************************************************************************
**
*F  READ_GAP_ROOT( <filename> ) . . .  read from gap root, dyn-load or static
**
**  'READ_GAP_ROOT' tries to find  a file under  the root directory,  it will
**  search all   directories given   in 'SyGapRootPaths',  check  dynamically
**  loadable modules and statically linked modules.
*/
extern Int READ_GAP_ROOT ( Char * filename );


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  InitInfoStreams() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoStreams ( void );


/****************************************************************************
**

*E  streams.h . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/


