*&---------------------------------------------------------------------*
*& Include MZDEV349_GRADINGTOP                      - Module Pool      SAPMZDEV349_GRADING
*&---------------------------------------------------------------------*
PROGRAM sapmzdev349_grading.



" 1. Khai báo Tables để map trực tiếp với giao diện màn hình
TABLES: zstudent_dev349, zenroll_dev349, zcourse_dev349.
" 2. Biến điều khiển màn hình
DATA: ok_code TYPE sy-ucomm,
      save_ok TYPE sy-ucomm.
DATA: gv_class TYPE zstudent_dev349-course." Ô nhập tên lớp
" 3. Khai báo dữ liệu cho Table Control 1 (Danh sách Sinh viên)
TYPES: BEGIN OF ty_student,
         mark       TYPE c, " Cột Checkbox để chọn dòng
         student_id TYPE zstudent_dev349-student_id,
         full_name  TYPE zstudent_dev349-full_name,
       END OF ty_student.
DATA: it_students TYPE TABLE OF ty_student,
      wa_student  TYPE ty_student.
" 4. Khai báo dữ liệu cho Table Control 2 (Danh sách Điểm)
TYPES: BEGIN OF ty_enroll,
         mark        TYPE c, " Cột Checkbox
         enroll_id   TYPE zenroll_dev349-enroll_id,
         course_id   TYPE zenroll_dev349-course_id,
         course_name TYPE zcourse_dev349-course_name,
         score       TYPE zenroll_dev349-score,
       END OF ty_enroll.
DATA: it_enroll TYPE TABLE OF ty_enroll,
      wa_enroll TYPE ty_enroll.
" 5. Khai báo 2 biến điều khiển Table Control trên màn hình (BẮT BUỘC)
CONTROLS: tc_stu TYPE TABLEVIEW USING SCREEN 100,

          tc_enr TYPE TABLEVIEW USING SCREEN 200.
