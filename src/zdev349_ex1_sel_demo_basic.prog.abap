*&---------------------------------------------------------------------*
*& Report ZDEV349_EX1_SEL_DEMO_BASIC
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZDEV349_EX1_SEL_DEMO_BASIC.

PARAMETERS: p_id   TYPE i DEFAULT 100 OBLIGATORY,
            p_date TYPE d DEFAULT sy-datum,
            p_text TYPE string OBLIGATORY LOWER CASE.

START-OF-SELECTION.
  WRITE: / |ID={ p_id } DATE={ p_date DATE = ISO } TEXT={ p_text }|.


  PARAMETERS p TYPE i AS LISTBOX VISIBLE LENGTH 10.

AT SELECTION-SCREEN OUTPUT.
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = CONV vrm_id( 'P' )
      values = VALUE vrm_values(
                 FOR i = 1 UNTIL i > 10
                 ( key = i text = |Choose { i }| ) ).
