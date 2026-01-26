*&---------------------------------------------------------------------*
*& Report zdev349_hwk_lab3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdev349_hwk_lab3.

PARAMETERS:
  p_id TYPE i OBLIGATORY.

AT SELECTION-SCREEN.
  IF p_id <= 0.
    MESSAGE 'ID phải lớn hơn 0' TYPE 'E'.
  ENDIF.

START-OF-SELECTION.
  WRITE: / 'ID hợp lệ:', p_id.
