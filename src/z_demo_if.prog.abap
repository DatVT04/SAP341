*&---------------------------------------------------------------------*
*& Report Z_DEMO_IF
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_DEMO_IF.

PARAMETERS: p_age TYPE i.

DATA: lv_name TYPE string VALUE 'Dat'.

IF p_age IS INITIAL.
  WRITE: 'Please enter your age!'.
  STOP.
ENDIF.

WRITE: 'Name:', lv_name,
       / 'Age:', p_age.

IF p_age >= 18.
  WRITE: / 'Status: Adult'.
ELSE.
  WRITE: / 'Status: Child'.
ENDIF.
