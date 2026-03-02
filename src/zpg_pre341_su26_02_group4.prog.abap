REPORT zpg_pre341_su26_02_group4.

TABLES: ekko.

*---------------------------------------------------------------------*
* SELECTION SCREEN
*---------------------------------------------------------------------*
SELECT-OPTIONS:
  s_bukrs FOR ekko-bukrs,
  s_ebeln FOR ekko-ebeln,
  s_bedat FOR ekko-bedat,
  s_ekorg FOR ekko-ekorg,
  s_ekgrp FOR ekko-ekgrp.

*---------------------------------------------------------------------*
* TYPE DECLARATION
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_data,
  bukrs       TYPE ekko-bukrs,
  butxt       TYPE t001-butxt,
  ebeln       TYPE ekko-ebeln,
  bedat       TYPE ekko-bedat,
  ekorg       TYPE ekko-ekorg,
  ekotx       TYPE t024e-ekotx,
  ekgrp       TYPE ekko-ekgrp,
  eknam       TYPE t024-eknam,
  lifnr       TYPE ekko-lifnr,
  name1       TYPE lfa1-name1,
  ernam       TYPE ekko-ernam,
  name_text   TYPE string,
  waers       TYPE ekko-waers,
  ltext       TYPE tcurt-ltext,
  ebelp       TYPE ekpo-ebelp,
  matnr       TYPE ekpo-matnr,
  maktx       TYPE makt-maktx,
  menge       TYPE ekpo-menge,
  meins       TYPE ekpo-meins,
  netpr       TYPE ekpo-netpr,
  unit_price  TYPE p DECIMALS 2,
END OF ty_data.

DATA: gt_data TYPE STANDARD TABLE OF ty_data.

*---------------------------------------------------------------------*
* VALIDATION
*---------------------------------------------------------------------*
AT SELECTION-SCREEN.

  IF s_bukrs IS NOT INITIAL.
    SELECT SINGLE @abap_true
      INTO @DATA(lv_exist1)
      FROM t001
      WHERE bukrs IN @s_bukrs.
    IF sy-subrc <> 0.
      MESSAGE 'Company Code does not exist.' TYPE 'E'.
    ENDIF.
  ENDIF.

  IF s_ebeln IS NOT INITIAL.
    SELECT SINGLE @abap_true
      INTO @DATA(lv_exist2)
      FROM ekko
      WHERE ebeln IN @s_ebeln.
    IF sy-subrc <> 0.
      MESSAGE 'Purchasing Document does not exist.' TYPE 'E'.
    ENDIF.
  ENDIF.

  IF s_ekorg IS NOT INITIAL.
    SELECT SINGLE @abap_true
      INTO @DATA(lv_exist3)
      FROM t024e
      WHERE ekorg IN @s_ekorg.
    IF sy-subrc <> 0.
      MESSAGE 'Purchasing Organization does not exist.' TYPE 'E'.
    ENDIF.
  ENDIF.

  IF s_ekgrp IS NOT INITIAL.
    SELECT SINGLE @abap_true
      INTO @DATA(lv_exist4)
      FROM t024
      WHERE ekgrp IN @s_ekgrp.
    IF sy-subrc <> 0.
      MESSAGE 'Purchasing Group does not exist.' TYPE 'E'.
    ENDIF.
  ENDIF.

*---------------------------------------------------------------------*
* START OF SELECTION
*---------------------------------------------------------------------*
START-OF-SELECTION.

SELECT
  ekko~bukrs,
  t001~butxt,
  ekko~ebeln,
  ekko~bedat,
  ekko~ekorg,
  t024e~ekotx,
  ekko~ekgrp,
  t024~eknam,
  ekko~lifnr,
  lfa1~name1,
  ekko~ernam,
  ekko~waers,
  tcurt~ltext,
  ekpo~ebelp,
  ekpo~matnr,
  makt~maktx,
  ekpo~menge,
  ekpo~meins,
  ekpo~netpr,
  adrp~name_first,
  adrp~name_last

INTO TABLE @DATA(lt_raw)

FROM ekko
INNER JOIN ekpo ON ekko~ebeln = ekpo~ebeln
LEFT JOIN t001 ON ekko~bukrs = t001~bukrs
LEFT JOIN t024e ON ekko~ekorg = t024e~ekorg
LEFT JOIN t024 ON ekko~ekgrp = t024~ekgrp
LEFT JOIN lfa1 ON ekko~lifnr = lfa1~lifnr
LEFT JOIN tcurt ON ekko~waers = tcurt~waers
LEFT JOIN usr21 ON ekko~ernam = usr21~bname
LEFT JOIN adrp ON usr21~persnumber = adrp~persnumber
LEFT JOIN makt ON ekpo~matnr = makt~matnr

WHERE ekko~bukrs IN @s_bukrs
  AND ekko~ebeln IN @s_ebeln
  AND ekko~bedat IN @s_bedat
  AND ekko~ekorg IN @s_ekorg
  AND ekko~ekgrp IN @s_ekgrp.

*---------------------------------------------------------------------*
* PROCESS DATA
*---------------------------------------------------------------------*
LOOP AT lt_raw INTO DATA(ls_raw).

  DATA(ls_data) = VALUE ty_data(
    bukrs = ls_raw-bukrs
    butxt = ls_raw-butxt
    ebeln = ls_raw-ebeln
    bedat = ls_raw-bedat
    ekorg = ls_raw-ekorg
    ekotx = ls_raw-ekotx
    ekgrp = ls_raw-ekgrp
    eknam = ls_raw-eknam
    lifnr = ls_raw-lifnr
    name1 = ls_raw-name1
    ernam = ls_raw-ernam
    name_text = |{ ls_raw-name_first } { ls_raw-name_last }|
    waers = ls_raw-waers
    ltext = ls_raw-ltext
    ebelp = ls_raw-ebelp
    matnr = ls_raw-matnr
    maktx = ls_raw-maktx
    menge = ls_raw-menge
    meins = ls_raw-meins
    netpr = ls_raw-netpr
  ).

  IF ls_raw-menge <> 0.
    ls_data-unit_price = ls_raw-netpr / ls_raw-menge.
  ENDIF.

  APPEND ls_data TO gt_data.

ENDLOOP.

*---------------------------------------------------------------------*
* DISPLAY ALV
*---------------------------------------------------------------------*
DATA: lo_alv TYPE REF TO cl_salv_table.

TRY.
    cl_salv_table=>factory(
      IMPORTING r_salv_table = lo_alv
      CHANGING  t_table      = gt_data ).

    DATA(lo_sorts) = lo_alv->get_sorts( ).
    lo_sorts->add_sort(
      columnname = 'EBELN'
      subtotal   = abap_true ).

    lo_alv->display( ).

  CATCH cx_salv_msg.
    MESSAGE 'SALV Message Error' TYPE 'I'.

  CATCH cx_salv_not_found.
    MESSAGE 'SALV Not Found Error' TYPE 'I'.

  CATCH cx_salv_data_error.
    MESSAGE 'SALV Data Error' TYPE 'I'.

  CATCH cx_salv_existing.
    MESSAGE 'SALV Existing Error' TYPE 'I'.

ENDTRY.
