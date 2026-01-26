*&---------------------------------------------------------------------*
*& Report zdev349_hwk_lab2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdev349_hwk_lab2.

PARAMETERS:
  p_id TYPE i OBLIGATORY.

SELECT-OPTIONS:
  s_date FOR sy-datum.

START-OF-SELECTION.

  LOOP AT s_date INTO DATA(ls_date).
    WRITE: / 'SIGN   :', ls_date-sign,
           / 'OPTION :', ls_date-option,
           / 'LOW    :', ls_date-low,
           / 'HIGH   :', ls_date-high,
           / '-----------------------'.
  ENDLOOP.
