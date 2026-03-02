class ZCL_DEV349_PERSON definition
  public
  create public .

public section.

  interfaces ZIF_DEV349_PRINT .

  methods SET_CORE_INFO
    importing
      !IV_ID type CHAR8
      !IV_NAME type STRING .
  methods GET_INFO
    returning
      value(RV_TEXT) type STRING .
protected section.

  data MV_ID type CHAR8 .
  data MV_NAME type STRING .
private section.
ENDCLASS.



CLASS ZCL_DEV349_PERSON IMPLEMENTATION.


  method GET_INFO.
    rv_text = |ID: { me->mv_id } - Name: { me->mv_name }|.
  endmethod.


  method SET_CORE_INFO.
    me->mv_id = iv_id.
me->mv_name = iv_name.
  endmethod.


  METHOD zif_dev349_print~print_log.

    WRITE: / 'LOG:', me->mv_name, 'đã thực hiện hành động vào lúc', sy-uzeit.
  ENDMETHOD.
ENDCLASS.
