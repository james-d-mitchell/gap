/****************************************************************************
**
*W  weakptr.h                   GAP source                       Steve Linton
**
*H  @(#)$Id: weakptr.h,v 4.7 2010/02/23 15:13:50 gap Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions that deal with weak pointer objects
**       it has to interwork somewhat closely with GASMAN.
**
**  A  weak pointer looks like a plain list, except that it does not cause
**  its entries to remain alive through a garbage collection, with the consequent
**  side effect, that its entries may vanish at any time.
**
**
*/
#ifdef  INCLUDE_DECLARATION_PART
const char * Revision_weakptr_h =
   "@(#)$Id: weakptr.h,v 4.7 2010/02/23 15:13:50 gap Exp $";
#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  InitInfoWeakPtr() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoWeakPtr ( void );


/****************************************************************************
**

*E  weakptr.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
