class ZCL_ZGW_LMS_DEV349_DPC_EXT definition
  public
  inheriting from ZCL_ZGW_LMS_DEV349_DPC
  create public .

public section.
protected section.

  methods STUDENTSET_CREATE_ENTITY
    redefinition .
  methods STUDENTSET_GET_ENTITYSET
    redefinition .
  methods STUDENTSET_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZGW_LMS_DEV349_DPC_EXT IMPLEMENTATION.


METHOD studentset_create_entity.

  DATA: ls_student TYPE zstudent_dev349.

  io_data_provider->read_entry_data(
    IMPORTING
      es_data = ls_student ).

  INSERT zstudent_dev349 FROM ls_student.

  er_entity = ls_student.

ENDMETHOD.


METHOD studentset_get_entity.
  DATA: ls_key_tab TYPE /iwbep/s_mgw_name_value_pair,
        lv_id      TYPE zstudent_dev349-student_id,
        ls_db      TYPE zstudent_dev349.

  READ TABLE it_key_tab INTO ls_key_tab WITH KEY name = 'StudentId'.
  IF sy-subrc = 0.
    lv_id = ls_key_tab-value.
  ENDIF.

  SELECT SINGLE student_id, full_name, course
    FROM zstudent_dev349
    INTO CORRESPONDING FIELDS OF @ls_db
    WHERE student_id = @lv_id.

  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
      EXPORTING
        textid      = /iwbep/cx_mgw_busi_exception=>resource_not_found
        entity_type = 'Student'.
  ENDIF.

  " Gán thủ công, KHÔNG gán DOB
  er_entity-student_id = ls_db-student_id.
  er_entity-full_name  = ls_db-full_name.
  er_entity-course     = ls_db-course.

ENDMETHOD.


METHOD studentset_get_entityset.

  DATA: lv_date TYPE d.

  SELECT *
    FROM zstudent_dev349
    INTO CORRESPONDING FIELDS OF TABLE @et_entityset.

  LOOP AT et_entityset ASSIGNING FIELD-SYMBOL(<fs>).

    TRY.
        CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
          EXPORTING
            date_external = <fs>-dob
          IMPORTING
            date_internal = lv_date.

        <fs>-dob = lv_date.

      CATCH cx_root.
        CLEAR <fs>-dob.
    ENDTRY.

  ENDLOOP.

  SORT et_entityset BY student_id.

ENDMETHOD.
ENDCLASS.
