CLASS zcl_lms_mailer_dev349 DEFINITION
PUBLIC
FINAL
CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_LMS_MAILER_DEV349 IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    TRY.
        " 1. Tạo Send Request
        DATA(lo_send_request) = cl_bcs=>create_persistent( ).
        " 2. Tạo nội dung HTML
        DATA: lt_body TYPE bcsy_text.
        APPEND '<html><body>' TO lt_body.
        APPEND '<h2 style="color:blue">LMS Weekly Report</h2>' TO lt_body.
        APPEND '<p>He thong LMS dang hoat dong tot tren S/4HANA.</p>' TO lt_body.
        APPEND '</body></html>' TO lt_body.
        DATA(lo_document) = cl_document_bcs=>create_document(
        i_type = 'HTM'
        i_text = lt_body

        i_subject = 'FPT LMS Notification (Test from Eclipse)' ).
        lo_send_request->set_document( lo_document ).
        " 3. Thêm người nhận (Thay bằng email thật của bạn nếu server cấu hình)
        DATA(lo_recipient) = cl_cam_address_bcs=>create_internet_address(
        'vtdat271204@gmail.com' ).
        lo_send_request->add_recipient( lo_recipient ).
        " 4. Gửi
        DATA(lv_sent) = lo_send_request->send( ).
        IF lv_sent = abap_true.
          COMMIT WORK. " Quan trọng
          out->write( 'Email sent successfully!' ). " In ra Console Eclipse
        ELSE.
          out->write( 'Error sending email.' ).
        ENDIF.
      CATCH cx_bcs INTO DATA(lx_bcs).
        out->write( |Exception: { lx_bcs->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
