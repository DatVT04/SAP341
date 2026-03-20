*&---------------------------------------------------------------------*
*& Report ZDEV349_BAI1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDEV349_EX1A.

PARAMETERS: p_id   TYPE i OBLIGATORY,
            p_date TYPE d DEFAULT sy-datum,
            p_text TYPE string LOWER CASE.

START-OF-SELECTION.
  WRITE: / |ID     = { p_id }|,
         / |DATE   = { p_date DATE = ISO }|,
         / |TEXT   = { p_text }|.
