*&---------------------------------------------------------------------*
*& Report ZDEV349_EXTRA5
*& Description: Selection Screen & Database Read (T001 - Company Codes)
*&---------------------------------------------------------------------*
REPORT zdev349_extra5.

DATA: gv_land1 TYPE t001-land1.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE tit1.
  PARAMETERS:     p_bukrs TYPE bukrs DEFAULT '1000',
                  p_waers TYPE waers OBLIGATORY DEFAULT 'VND'.
  SELECT-OPTIONS: s_land1 FOR gv_land1.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE tit2.
  PARAMETERS: p_maxrow TYPE i DEFAULT 100,
              p_sort   AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b2.

" ✅ KHÔNG khai báo tit1, tit2 trong DATA — SAP tự tạo rồi
DATA: lt_t001  TYPE TABLE OF t001,
      ls_t001  TYPE t001,
      lv_count TYPE i.

INITIALIZATION.
  tit1 = 'Co.Code Select'.
  tit2 = 'Output Opt.'.

START-OF-SELECTION.

  SELECT * FROM t001
    INTO TABLE lt_t001
    WHERE bukrs = p_bukrs
       OR waers = p_waers.

  IF s_land1 IS NOT INITIAL.
    DELETE lt_t001 WHERE NOT ( land1 IN s_land1 ).
  ENDIF.

  IF lines( lt_t001 ) > p_maxrow.
    DELETE lt_t001 FROM p_maxrow + 1.
  ENDIF.

  IF p_sort = 'X'.
    SORT lt_t001 BY bukrs.
  ENDIF.

  lv_count = lines( lt_t001 ).

  IF lv_count = 0.
    MESSAGE 'No records found.' TYPE 'I'.
  ELSE.
    WRITE: / '========================================'.
    WRITE: / 'ZDEV349_EXTRA5: Company Codes (T001)'.
    WRITE: / '========================================'.
    WRITE: / 'BuKrs | Company Name        | Currency | Country'.
    WRITE: / '------+--------------------+----------+--------'.
    LOOP AT lt_t001 INTO ls_t001.
      WRITE: / ls_t001-bukrs, '|',
               ls_t001-butxt(20), '|',
               ls_t001-waers, '|',
               ls_t001-land1.
    ENDLOOP.
    WRITE: / '========================================'.
    WRITE: / 'Total records:', lv_count.
  ENDIF.
