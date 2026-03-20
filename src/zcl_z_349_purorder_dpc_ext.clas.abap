CLASS zcl_z_349_purorder_dpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_z_349_purorder_dpc
  CREATE PUBLIC.

  PUBLIC SECTION.
  PROTECTED SECTION.
    METHODS purchaseorderset_get_entityset REDEFINITION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_Z_349_PURORDER_DPC_EXT IMPLEMENTATION.


  METHOD purchaseorderset_get_entityset.
    DATA: lt_ekko   TYPE TABLE OF ekko,
          lt_ekpo   TYPE TABLE OF ekpo,
          ls_ekko   TYPE ekko,
          ls_ekpo   TYPE ekpo,
          ls_entity TYPE zcl_z_349_purorder_mpc=>ts_purchaseorder,
          lv_persnr TYPE adrp-persnumber,
          ls_adrp   TYPE adrp.

    SELECT * FROM ekko INTO TABLE lt_ekko.

    LOOP AT lt_ekko INTO ls_ekko.
      SELECT * FROM ekpo INTO TABLE lt_ekpo
        WHERE ebeln = ls_ekko-ebeln.

      LOOP AT lt_ekpo INTO ls_ekpo.
        CLEAR ls_entity.

        ls_entity-ebeln = ls_ekko-ebeln.
        ls_entity-bukrs = ls_ekko-bukrs.
        ls_entity-bedat = ls_ekko-bedat.
        ls_entity-ekorg = ls_ekko-ekorg.
        ls_entity-ekgrp = ls_ekko-ekgrp.
        ls_entity-lifnr = ls_ekko-lifnr.
        ls_entity-ernam = ls_ekko-ernam.
        ls_entity-waers = ls_ekko-waers.

        SELECT SINGLE butxt FROM t001 INTO ls_entity-butxt
          WHERE bukrs = ls_ekko-bukrs.
        SELECT SINGLE ekotx FROM t024e INTO ls_entity-ekotx
          WHERE ekorg = ls_ekko-ekorg.
        SELECT SINGLE eknam FROM t024 INTO ls_entity-eknam
          WHERE ekgrp = ls_ekko-ekgrp.
        SELECT SINGLE name1 FROM lfa1 INTO ls_entity-name1
          WHERE lifnr = ls_ekko-lifnr.
        SELECT SINGLE ltext FROM tcurt INTO ls_entity-ltext
          WHERE waers = ls_ekko-waers
            AND spras = sy-langu.

        SELECT SINGLE persnumber FROM usr21 INTO lv_persnr
          WHERE bname = ls_ekko-ernam.
        IF sy-subrc = 0.
          SELECT SINGLE name_first name_last FROM adrp
            INTO CORRESPONDING FIELDS OF ls_adrp
            WHERE persnumber = lv_persnr.
          CONCATENATE ls_adrp-name_first ls_adrp-name_last
            INTO ls_entity-name_text SEPARATED BY ' '.
        ENDIF.

        ls_entity-ebelp = ls_ekpo-ebelp.
        ls_entity-matnr = ls_ekpo-matnr.
        ls_entity-menge = ls_ekpo-menge.
        ls_entity-meins = ls_ekpo-meins.
        ls_entity-netpr = ls_ekpo-netpr.

        SELECT SINGLE maktx FROM makt INTO ls_entity-maktx
          WHERE matnr = ls_ekpo-matnr
            AND spras = sy-langu.

        IF ls_ekpo-menge <> 0.
          ls_entity-unit_price = ls_ekpo-netpr / ls_ekpo-menge.
        ENDIF.

        APPEND ls_entity TO et_entityset.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
