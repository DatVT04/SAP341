class ZCL_STUDENT_DEV349 definition
  public
  final
  create public .

public section.

  data MV_ID type CHAR8 .
  data MV_NAME type STRING .
  class-data GV_COUNT type I .

  methods SET_GPA
    importing
      !IV_SCORE type P .
  methods DISPLAY_INFO .
  methods CONSTRUCTOR
    importing
      !IV_ID type CHAR8
      !IV_NAME type STRING .
  methods GET_GPA
    returning
      value(RV_RESULT) type DECIMALS .
protected section.
private section.

  data MV_GPA type DECIMALS .
ENDCLASS.



CLASS ZCL_STUDENT_DEV349 IMPLEMENTATION.


  METHOD constructor.
    me->mv_id   = iv_id.
    me->mv_name = iv_name.

    " Tăng biến static
    zcl_student_dev349=>gv_count =
      zcl_student_dev349=>gv_count + 1.
  ENDMETHOD.


  METHOD display_info.
    WRITE: / 'Student Info:', me->mv_name, '(', me->mv_id, ')'.
    WRITE: / 'Current GPA:', me->mv_gpa.
    ULINE.
  ENDMETHOD.


  method GET_GPA.
    rv_result = me->mv_gpa.
  endmethod.


  method SET_GPA.
     me->mv_gpa = iv_score.
  endmethod.
ENDCLASS.
