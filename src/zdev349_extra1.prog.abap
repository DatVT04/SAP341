*&---------------------------------------------------------------------*
*& Report ZDEV349_EXTRA1
*& Description: String Operations & Text Processing
*&---------------------------------------------------------------------*
REPORT zdev349_extra1.

DATA: lv_text    TYPE string,
      lv_upper   TYPE string,
      lv_lower   TYPE string,
      lv_length  TYPE i,
      lv_sub     TYPE string,
      lv_result  TYPE string.

START-OF-SELECTION.

  lv_text = 'Hello World from SAP ABAP'.

  " Uppercase / Lowercase
  lv_upper = to_upper( lv_text ).
  lv_lower = to_lower( lv_text ).

  " Length
  lv_length = strlen( lv_text ).

  " Substring
  lv_sub = lv_text+6(5).   " 'World'

  " Replace
  lv_result = replace( val = lv_text sub = 'World' with = 'ABAP Developer' ).

  " Concatenate
  CONCATENATE 'SAP' ' ' 'ABAP' ' ' '2024' INTO lv_result.

  WRITE: / '========================================'.
  WRITE: / 'ZDEV349_EXTRA1: String Operations'.
  WRITE: / '========================================'.
  WRITE: / 'Original  :', lv_text.
  WRITE: / 'Uppercase :', lv_upper.
  WRITE: / 'Lowercase :', lv_lower.
  WRITE: / 'Length    :', lv_length.
  WRITE: / 'Substring :', lv_sub.
  WRITE: / 'Replaced  :', lv_result.

  " Split example
  DATA: lt_parts TYPE TABLE OF string,
        lv_part  TYPE string.

  SPLIT lv_text AT ' ' INTO TABLE lt_parts.
  WRITE: / '--- Split by space ---'.
  LOOP AT lt_parts INTO lv_part.
    WRITE: / '  Token:', lv_part.
  ENDLOOP.
