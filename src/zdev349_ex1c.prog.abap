REPORT ZDEV349_EX1C.

START-OF-SELECTION.

  " 1. Khai báo dữ liệu (KIỂU CŨ - KHÔNG inline)
  DATA: lv_fullname TYPE string,
        lv_yob      TYPE string,
        lv_job      TYPE string,
        lv_info     TYPE string.

  DATA: lv_name_out TYPE string,
        lv_yob_out  TYPE string,
        lv_job_out  TYPE string.

  " 2. Gán giá trị
  lv_fullname = 'Vu Tien Dat'.
  lv_yob      = '2004'.
  lv_job      = 'ABAP Developer'.

  " 3. NỐI CHUỖI
  CONCATENATE lv_fullname lv_yob lv_job
    INTO lv_info
    SEPARATED BY ' | '.

  WRITE: / 'Chuoi sau khi noi:'.
  WRITE: / lv_info.

  ULINE.

  " 4. TÁCH CHUỖI
  SPLIT lv_info AT ' | '
    INTO lv_name_out lv_yob_out lv_job_out.

  " 5. In kết quả
  WRITE: / 'Ten:', lv_name_out.
  WRITE: / 'Nam sinh:', lv_yob_out.
  WRITE: / 'Vi tri:', lv_job_out.
