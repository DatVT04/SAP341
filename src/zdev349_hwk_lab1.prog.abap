*&---------------------------------------------------------------------*
*& Report zdev349_hwk_lab1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdev349_hwk_lab1.

PARAMETERS:
  p_id   TYPE i OBLIGATORY,
  p_date TYPE sy-datum DEFAULT sy-datum,
  p_text TYPE string LOWER CASE.

START-OF-SELECTION.
  WRITE: / 'ID    :', p_id,
         / 'DATE  :', p_date,
         / 'TEXT  :', p_text.
