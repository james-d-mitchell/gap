/****************************************************************************
**
*W  bool.h                      GAP source                   Martin Schönert
**
*H  @(#)$Id: bool.h,v 4.12 2010/02/23 15:13:39 gap Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions for the boolean package.
*/
#ifdef INCLUDE_DECLARATION_PART
const char * Revision_bool_h =
   "@(#)$Id: bool.h,v 4.12 2010/02/23 15:13:39 gap Exp $";
#endif


/****************************************************************************
**

*V  True  . . . . . . . . . . . . . . . . . . . . . . . . . . . .  true value
**
**   'True' is the value 'true'.
*/
extern Obj True;


/****************************************************************************
**
*V  False . . . . . . . . . . . . . . . . . . . . . . . . . . . . false value
**
**  'False' is the value 'false'.
*/
extern Obj False;


/****************************************************************************
**
*V  Fail  . . . . . . . . . . . . . . . . . . . . . . . . . . . .  fail value
**
**  'Fail' is the value 'fail'.
*/
extern Obj Fail;

/****************************************************************************
**
*V  SFail  . . . . . . . . . . . . . . . . . . . . . . . . . . superfail value
**
**  'SFail' is an ``superfail'' object which is used to indicate failure if
**  `fail' itself is a sensible response. This is used when having GAP read
**  a file line-by-line via a library function (demo.g)
*/
extern Obj SFail;


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  InitInfoBool()  . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoBool ( void );


/****************************************************************************
**

*E  bool.h  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/




