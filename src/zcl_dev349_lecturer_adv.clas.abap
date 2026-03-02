class ZCL_DEV349_LECTURER_ADV definition
  public
  inheriting from ZCL_DEV349_PERSON
  final
  create public .

public section.

  methods SET_JOB_INFO
    importing
      !IV_SALARY type ZDEC8_2 .

  methods GET_INFO
    redefinition .
protected section.
private section.

  data MV_SALARY type ZDEC8_2 .
ENDCLASS.



CLASS ZCL_DEV349_LECTURER_ADV IMPLEMENTATION.


  METHOD get_info.
*CALL METHOD SUPER->GET_INFO
*  RECEIVING
*    RV_TEXT =
*    .
    DATA(lv_base) = super->get_info( ). " Giảng viên thì hiển thị Lương
    rv_text = |{ lv_base } - Salary: { me->mv_salary } USD|.
  ENDMETHOD.


  method SET_JOB_INFO.
    me->mv_salary = iv_salary.
  endmethod.
ENDCLASS.
