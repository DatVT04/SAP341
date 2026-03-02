CLASS ZCL_WEB_LMS_DEV349 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES IF_HTTP_EXTENSION.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_WEB_LMS_DEV349 IMPLEMENTATION.


METHOD if_http_extension~handle_request.

  DATA: lt_students TYPE TABLE OF zstudent_dev349,
        ls_student  TYPE zstudent_dev349,
        lt_scores   TYPE TABLE OF zenroll_dev349,
        ls_score    TYPE zenroll_dev349,
        lv_html     TYPE string,
        lv_json     TYPE string,
        lv_avg      TYPE p DECIMALS 2,
        lv_count    TYPE i.

  DATA(lv_mode) = server->request->get_form_field( 'mode' ).
  DATA(lv_id)   = server->request->get_form_field( 'id' ).

  IF lv_mode IS INITIAL.
    lv_mode = 'html'.
  ENDIF.

  CASE lv_mode.

  " =====================================================
  " MODE 1: LIST PAGE
  " =====================================================
  WHEN 'html'.

    SELECT * FROM zstudent_dev349 INTO TABLE @lt_students.

    lv_html =
    |<html><head>| &&
    |<meta charset="UTF-8">| &&
    |<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">| &&
    |</head><body class="bg-light p-5"><div class="container">| &&
    |<h1 class="text-center text-warning mb-4">FPT UNIVERSITY - STUDENT LIST</h1>| &&
    |<table class="table table-bordered table-hover shadow bg-white">| &&
    |<thead class="table-dark"><tr><th>ID</th><th>Name</th><th>Course</th></tr></thead><tbody>|.

    LOOP AT lt_students INTO ls_student.

      DATA(lv_id_safe) =
        cl_http_utility=>escape_html( |{ ls_student-student_id }| ).
      DATA(lv_name_safe) =
        cl_http_utility=>escape_html( |{ ls_student-full_name }| ).
      DATA(lv_course_safe) =
        cl_http_utility=>escape_html( |{ ls_student-course }| ).

      lv_html = lv_html &&
        |<tr>| &&
        |<td><a class="text-decoration-none fw-bold text-warning" href="?mode=detail&id={ lv_id_safe }">| &&
        |{ lv_id_safe }</a></td>| &&
        |<td>{ lv_name_safe }</td>| &&
        |<td>{ lv_course_safe }</td>| &&
        |</tr>|.

    ENDLOOP.

    lv_html = lv_html &&
      |</tbody></table>| &&
      |<div class="text-center mt-3">| &&
      |<a class="btn btn-primary" href="?mode=json">View JSON API</a>| &&
      |</div></div></body></html>|.

    server->response->set_header_field(
      name  = 'Content-Type'
      value = 'text/html'
    ).
    server->response->set_cdata( lv_html ).


  " =====================================================
  " MODE 2: DETAIL + SCORE
  " =====================================================
  WHEN 'detail'.

    CLEAR: lv_avg, lv_count.

    SELECT SINGLE *
      FROM zstudent_dev349
      WHERE student_id = @lv_id
      INTO @ls_student.

    IF sy-subrc = 0.

      SELECT *
        FROM zenroll_dev349
        WHERE student_id = @lv_id
        INTO TABLE @lt_scores.

      lv_html =
      |<html><head>| &&
      |<meta charset="UTF-8">| &&
      |<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">| &&
      |</head><body class="bg-light p-5"><div class="container">| &&
      |<h1 class="text-center text-primary mb-4">Student Detail</h1>|.

      DATA(lv_id_safe2) =
        cl_http_utility=>escape_html( |{ ls_student-student_id }| ).
      DATA(lv_name_safe2) =
        cl_http_utility=>escape_html( |{ ls_student-full_name }| ).
      DATA(lv_course_safe2) =
        cl_http_utility=>escape_html( |{ ls_student-course }| ).

      " ===== Student Info =====
      lv_html = lv_html &&
        |<div class="card shadow mx-auto mb-4" style="max-width:500px;">| &&
        |<div class="card-body">| &&
        |<p><b>ID:</b> { lv_id_safe2 }</p>| &&
        |<p><b>Name:</b> { lv_name_safe2 }</p>| &&
        |<p><b>Course:</b> { lv_course_safe2 }</p>| &&
        |</div></div>|.

      " ===== Calculate Average =====
      lv_count = lines( lt_scores ).

      LOOP AT lt_scores INTO ls_score.
        lv_avg = lv_avg + ls_score-score.
      ENDLOOP.

      IF lv_count > 0.
        lv_avg = lv_avg / lv_count.
      ENDIF.

      " ===== Score Table =====
      lv_html = lv_html &&
        |<div class="card shadow mx-auto" style="max-width:500px;">| &&
        |<div class="card-body">| &&
        |<h5 class="mb-3">Score List</h5>| &&
        |<table class="table table-bordered table-striped">| &&
        |<thead class="table-secondary"><tr><th>Course ID</th><th>Score</th></tr></thead><tbody>|.

      LOOP AT lt_scores INTO ls_score.

        DATA(lv_courseid_safe) =
          cl_http_utility=>escape_html( |{ ls_score-course_id }| ).

        lv_html = lv_html &&
          |<tr>| &&
          |<td>{ lv_courseid_safe }</td>| &&
          |<td>{ ls_score-score }</td>| &&
          |</tr>|.

      ENDLOOP.

      lv_html = lv_html &&
        |</tbody></table>| &&
        |<p class="fw-bold text-end text-success">Average Score: { lv_avg }</p>| &&
        |<a class="btn btn-warning w-100 mt-3" href="?mode=html">Back to List</a>| &&
        |</div></div>|.

      lv_html = lv_html && |</div></body></html>|.

    ELSE.

      lv_html =
      |<html><body class="p-5">| &&
      |<div class="alert alert-danger text-center">Student not found!</div>| &&
      |<div class="text-center">| &&
      |<a class="btn btn-secondary" href="?mode=html">Back to List</a>| &&
      |</div></body></html>|.

    ENDIF.

    server->response->set_header_field(
      name  = 'Content-Type'
      value = 'text/html'
    ).
    server->response->set_cdata( lv_html ).


  " =====================================================
  " MODE 3: JSON API
  " =====================================================
  WHEN 'json'.

    SELECT * FROM zstudent_dev349 INTO TABLE @lt_students.

    lv_json = /ui2/cl_json=>serialize(
                data        = lt_students
                pretty_name = /ui2/cl_json=>pretty_mode-low_case ).

    server->response->set_header_field(
      name  = 'Content-Type'
      value = 'application/json'
    ).
    server->response->set_cdata( lv_json ).

  ENDCASE.

  server->response->set_status(
    code   = 200
    reason = 'OK'
  ).

ENDMETHOD.
ENDCLASS.
