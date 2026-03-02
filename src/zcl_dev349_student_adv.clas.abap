class ZCL_DEV349_STUDENT_ADV definition
  public
  inheriting from ZCL_DEV349_PERSON
  final
  create public .

public section.

  methods SET_ACADEMIC_INFO
    importing
      !IV_GPA type ZDEC .

  methods GET_INFO
    redefinition .
protected section.
private section.

  data MV_GPA type ZDEC .
ENDCLASS.



CLASS ZCL_DEV349_STUDENT_ADV IMPLEMENTATION.


  METHOD get_info.
*CALL METHOD SUPER->GET_INFO
*  RECEIVING
*    RV_TEXT =
*    .
    " 1. Gọi về lớp cha để lấy chuỗi 'ID - Name' (Tái sử dụng)
    DATA(lv_base) = super->get_info( ).
    " 2. Nối thêm điểm GPA vào
    rv_text = |{ lv_base } - GPA: { me->mv_gpa }|.
  ENDMETHOD.


  method SET_ACADEMIC_INFO.
    me->mv_gpa = iv_gpa.
  endmethod.
ENDCLASS.
