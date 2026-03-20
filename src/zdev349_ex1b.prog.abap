*&---------------------------------------------------------------------*
*& Report ZDEV349_EX1B
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDEV349_EX1B.

SELECT-OPTIONS s_date FOR sy-datum.

START-OF-SELECTION.
  LOOP AT s_date ASSIGNING FIELD-SYMBOL(<fs>).
    WRITE: / <fs>-sign, <fs>-option, <fs>-low, <fs>-high.
  ENDLOOP.
