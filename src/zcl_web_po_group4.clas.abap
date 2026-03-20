class ZCL_WEB_PO_GROUP4 definition
  public
  final
  create public .

public section.

  interfaces IF_HTTP_EXTENSION .
  PROTECTED SECTION.
private section.
ENDCLASS.



CLASS ZCL_WEB_PO_GROUP4 IMPLEMENTATION.


METHOD if_http_extension~handle_request.

  DATA lv_ebeln      TYPE ekko-ebeln.
  DATA lv_bukrs      TYPE ekko-bukrs.
  DATA lv_html       TYPE string.
  DATA lv_color      TYPE string.
  DATA lv_total      TYPE ekpo-netpr.

  lv_ebeln = server->request->get_form_field( 'ebeln' ).
  lv_bukrs = server->request->get_form_field( 'bukrs' ).

  IF lv_bukrs IS INITIAL.
    lv_bukrs = 'SC00'.
  ENDIF.

  TYPES: BEGIN OF ty_web_po,
           bukrs TYPE ekko-bukrs,
           butxt TYPE t001-butxt,
           ebeln TYPE ekko-ebeln,
           bedat TYPE ekko-bedat,
           ekorg TYPE ekko-ekorg,
           ekotx TYPE t024e-ekotx,
           ekgrp TYPE ekko-ekgrp,
           eknam TYPE t024-eknam,
           lifnr TYPE ekko-lifnr,
           name1 TYPE lfa1-name1,
           ernam TYPE ekko-ernam,
           waers TYPE ekko-waers,
           ebelp TYPE ekpo-ebelp,
           matnr TYPE ekpo-matnr,
           menge TYPE ekpo-menge,
           meins TYPE ekpo-meins,
           netpr TYPE ekpo-netpr,
         END OF ty_web_po.

  DATA lt_items TYPE TABLE OF ty_web_po.
  DATA ls       TYPE ty_web_po.

  IF lv_ebeln IS NOT INITIAL.
    SELECT ekko~bukrs, t001~butxt,
           ekko~ebeln, ekko~bedat,
           ekko~ekorg, t024e~ekotx,
           ekko~ekgrp, t024~eknam,
           ekko~lifnr, lfa1~name1,
           ekko~ernam, ekko~waers,
           ekpo~ebelp, ekpo~matnr,
           ekpo~menge, ekpo~meins, ekpo~netpr
      FROM ekko
      INNER JOIN ekpo  ON ekpo~ebeln  = ekko~ebeln
      LEFT JOIN t001   ON t001~bukrs  = ekko~bukrs
      LEFT JOIN t024e  ON t024e~ekorg = ekko~ekorg
      LEFT JOIN t024   ON t024~ekgrp  = ekko~ekgrp
      LEFT JOIN lfa1   ON lfa1~lifnr  = ekko~lifnr
      WHERE ekko~ebeln = @lv_ebeln
        AND ekko~bukrs = @lv_bukrs
      INTO CORRESPONDING FIELDS OF TABLE @lt_items.
  ELSE.
    SELECT ekko~bukrs, t001~butxt,
           ekko~ebeln, ekko~bedat,
           ekko~ekorg, t024e~ekotx,
           ekko~ekgrp, t024~eknam,
           ekko~lifnr, lfa1~name1,
           ekko~ernam, ekko~waers,
           ekpo~ebelp, ekpo~matnr,
           ekpo~menge, ekpo~meins, ekpo~netpr
      FROM ekko
      INNER JOIN ekpo  ON ekpo~ebeln  = ekko~ebeln
      LEFT JOIN t001   ON t001~bukrs  = ekko~bukrs
      LEFT JOIN t024e  ON t024e~ekorg = ekko~ekorg
      LEFT JOIN t024   ON t024~ekgrp  = ekko~ekgrp
      LEFT JOIN lfa1   ON lfa1~lifnr  = ekko~lifnr
      WHERE ekko~bukrs = @lv_bukrs
      INTO CORRESPONDING FIELDS OF TABLE @lt_items
      UP TO 100 ROWS.
  ENDIF.

  TYPES: BEGIN OF ty_chart,
           ebeln TYPE ekko-ebeln,
           netpr TYPE ekpo-netpr,
         END OF ty_chart.

  DATA lt_chart        TYPE TABLE OF ty_chart.
  DATA ls_chart        TYPE ty_chart.
  DATA lv_found        TYPE abap_bool.
  DATA lv_high         TYPE i.
  DATA lv_mid          TYPE i.
  DATA lv_low          TYPE i.
  DATA lv_chart_labels TYPE string.
  DATA lv_chart_data   TYPE string.
  DATA lv_high_str     TYPE string.
  DATA lv_mid_str      TYPE string.
  DATA lv_low_str      TYPE string.

  LOOP AT lt_items INTO ls.
    lv_found = abap_false.
    LOOP AT lt_chart INTO ls_chart.
      IF ls_chart-ebeln = ls-ebeln.
        ls_chart-netpr = ls_chart-netpr + ls-netpr.
        MODIFY lt_chart FROM ls_chart.
        lv_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF lv_found = abap_false.
      ls_chart-ebeln = ls-ebeln.
      ls_chart-netpr = ls-netpr.
      APPEND ls_chart TO lt_chart.
    ENDIF.
    lv_total = lv_total + ls-netpr.
    IF ls-netpr >= 10000.
      lv_high = lv_high + 1.
    ELSEIF ls-netpr >= 1000.
      lv_mid = lv_mid + 1.
    ELSE.
      lv_low = lv_low + 1.
    ENDIF.
  ENDLOOP.

  DATA lv_first     TYPE abap_bool.
  DATA lv_netpr_str TYPE string.
  lv_first = abap_true.
  LOOP AT lt_chart INTO ls_chart.
    lv_netpr_str = ls_chart-netpr.
    IF lv_first = abap_true.
      lv_chart_labels = '"' && ls_chart-ebeln && '"'.
      lv_chart_data   = lv_netpr_str.
      lv_first = abap_false.
    ELSE.
      lv_chart_labels = lv_chart_labels && ',"' && ls_chart-ebeln && '"'.
      lv_chart_data   = lv_chart_data   && ',' && lv_netpr_str.
    ENDIF.
  ENDLOOP.

  lv_high_str = lv_high.
  lv_mid_str  = lv_mid.
  lv_low_str  = lv_low.

  DATA lv_total_str TYPE string.
  DATA lv_count_str TYPE string.
  DATA lv_datum     TYPE string.
  DATA lv_count     TYPE i.
  lv_total_str = lv_total.
  lv_datum     = sy-datum.
  DESCRIBE TABLE lt_items LINES lv_count.
  lv_count_str = lv_count.

  lv_html =
    '<!DOCTYPE html>' &&
    '<html lang="en"><head><meta charset="UTF-8">' &&
    '<meta name="viewport" content="width=device-width,initial-scale=1">' &&
    '<title>PO Dashboard - Group 4</title>' &&
    '<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">' &&
    '<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css" rel="stylesheet">' &&
    '<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>' &&
    '<style>' &&
    'body{background:#f0f2f5;font-family:Arial,sans-serif}' &&
    '.stat-card{border-radius:12px;border:none;box-shadow:0 2px 8px rgba(0,0,0,.1)}' &&
    '.stat-card .icon{font-size:2.5rem;opacity:.8}' &&
    '.chart-card,.table-card{border-radius:12px;border:none;box-shadow:0 2px 8px rgba(0,0,0,.1)}' &&
    '.table thead th{background:#004070;color:#fff;border:none;font-size:12px}' &&
    '.table tbody td{font-size:12px;vertical-align:middle}' &&
    '.badge-high{background:#dc3545;color:#fff;padding:4px 8px;border-radius:4px}' &&
    '.badge-mid{background:#ffc107;color:#333;padding:4px 8px;border-radius:4px}' &&
    '.badge-low{background:#198754;color:#fff;padding:4px 8px;border-radius:4px}' &&
    '.search-box{background:#fff;border-radius:12px;padding:20px;box-shadow:0 2px 8px rgba(0,0,0,.1);margin-bottom:20px}' &&
    '</style></head><body>' &&

    '<nav class="navbar navbar-dark" style="background:#004070">' &&
    '<div class="container-fluid">' &&
    '<span class="navbar-brand fw-bold"><i class="bi bi-cart3"></i> PO Dashboard - Group 4</span>' &&
    '<span class="text-white-50 small">Generated by ' && sy-uname && ' | ' && lv_datum && '</span>' &&
    '</div></nav>' &&

    '<div class="container-fluid p-4">' &&

    '<div class="search-box">' &&
    '<form method="GET" class="row g-3 align-items-end">' &&
    '<div class="col-auto"><label class="form-label fw-bold">Company Code</label>' &&
    '<input name="bukrs" class="form-control" value="' && lv_bukrs && '" style="width:100px"/></div>' &&
    '<div class="col-auto"><label class="form-label fw-bold">PO Number</label>' &&
    '<input name="ebeln" class="form-control" value="' && lv_ebeln && '" placeholder="e.g. 1000000001" style="width:180px"/></div>' &&
    '<div class="col-auto"><button type="submit" class="btn btn-primary"><i class="bi bi-search"></i> Search</button></div>' &&
    '<div class="col-auto"><a href="?bukrs=SC00" class="btn btn-outline-secondary"><i class="bi bi-arrow-clockwise"></i> Show All</a></div>' &&
    '</form></div>' &&

    '<div class="row g-3 mb-4">' &&
    '<div class="col-md-3"><div class="card stat-card text-white" style="background:linear-gradient(135deg,#004070,#0066aa)">' &&
    '<div class="card-body d-flex justify-content-between align-items-center">' &&
    '<div><div class="text-white-50 small">Total Records</div><div class="fs-3 fw-bold">' && lv_count_str && '</div></div>' &&
    '<i class="bi bi-file-earmark-text icon"></i></div></div></div>' &&

    '<div class="col-md-3"><div class="card stat-card text-white" style="background:linear-gradient(135deg,#198754,#20c997)">' &&
    '<div class="card-body d-flex justify-content-between align-items-center">' &&
    '<div><div class="text-white-50 small">Total Net Price</div><div class="fs-4 fw-bold">' && lv_total_str && '</div></div>' &&
    '<i class="bi bi-currency-exchange icon"></i></div></div></div>' &&

    '<div class="col-md-3"><div class="card stat-card text-white" style="background:linear-gradient(135deg,#dc3545,#ff6b6b)">' &&
    '<div class="card-body d-flex justify-content-between align-items-center">' &&
    '<div><div class="text-white-50 small">High Price (>=10K)</div><div class="fs-3 fw-bold">' && lv_high_str && '</div></div>' &&
    '<i class="bi bi-arrow-up-circle icon"></i></div></div></div>' &&

    '<div class="col-md-3"><div class="card stat-card text-white" style="background:linear-gradient(135deg,#fd7e14,#ffc107)">' &&
    '<div class="card-body d-flex justify-content-between align-items-center">' &&
    '<div><div class="text-white-50 small">Medium Price (>=1K)</div><div class="fs-3 fw-bold">' && lv_mid_str && '</div></div>' &&
    '<i class="bi bi-dash-circle icon"></i></div></div></div>' &&
    '</div>' &&

    '<div class="row g-3 mb-4">' &&
    '<div class="col-md-8"><div class="card chart-card">' &&
    '<div class="card-header fw-bold" style="background:#f8f9fa">Net Price by PO Number</div>' &&
    '<div class="card-body"><canvas id="barChart" height="100"></canvas></div></div></div>' &&
    '<div class="col-md-4"><div class="card chart-card">' &&
    '<div class="card-header fw-bold" style="background:#f8f9fa">Price Distribution</div>' &&
    '<div class="card-body"><canvas id="doughnutChart"></canvas></div></div></div>' &&
    '</div>' &&

    '<div class="card table-card">' &&
    '<div class="card-header fw-bold d-flex justify-content-between" style="background:#f8f9fa">' &&
    '<span><i class="bi bi-table"></i> Purchase Order Details</span>' &&
    '<span class="badge bg-primary">' && lv_count_str && ' records</span></div>' &&
    '<div class="card-body p-0"><div class="table-responsive">' &&
    '<table class="table table-hover table-striped mb-0"><thead><tr>' &&
    '<th>PO Number</th><th>Date</th><th>Company</th><th>Company Name</th>' &&
    '<th>Purch.Org</th><th>Purch.Org Name</th><th>Purch.Group</th><th>Purch.Group Name</th>' &&
    '<th>Vendor</th><th>Vendor Name</th><th>Created By</th><th>Currency</th>' &&
    '<th>Item</th><th>Material</th><th>Qty</th><th>Unit</th><th>Net Price</th>' &&
    '</tr></thead><tbody>'.

  DATA lv_bedat TYPE string.
  DATA lv_menge TYPE string.
  DATA lv_netpr TYPE string.

  LOOP AT lt_items INTO ls.
    IF ls-netpr >= 10000.
      lv_color = 'badge-high'.
    ELSEIF ls-netpr >= 1000.
      lv_color = 'badge-mid'.
    ELSE.
      lv_color = 'badge-low'.
    ENDIF.
    lv_bedat = ls-bedat.
    lv_menge = ls-menge.
    lv_netpr = ls-netpr.
    lv_html = lv_html &&
      '<tr>' &&
      '<td><strong>' && ls-ebeln && '</strong></td>' &&
      '<td>' && lv_bedat && '</td>' &&
      '<td>' && ls-bukrs && '</td>' &&
      '<td>' && ls-butxt && '</td>' &&
      '<td>' && ls-ekorg && '</td>' &&
      '<td>' && ls-ekotx && '</td>' &&
      '<td>' && ls-ekgrp && '</td>' &&
      '<td>' && ls-eknam && '</td>' &&
      '<td>' && ls-lifnr && '</td>' &&
      '<td>' && ls-name1 && '</td>' &&
      '<td>' && ls-ernam && '</td>' &&
      '<td>' && ls-waers && '</td>' &&
      '<td>' && ls-ebelp && '</td>' &&
      '<td>' && ls-matnr && '</td>' &&
      '<td>' && lv_menge && '</td>' &&
      '<td>' && ls-meins && '</td>' &&
      '<td><span class="' && lv_color && '">' && lv_netpr && '</span></td>' &&
      '</tr>'.
  ENDLOOP.

  lv_html = lv_html &&
    '</tbody>' &&
    '<tfoot><tr class="table-primary fw-bold">' &&
    '<td colspan="16" class="text-end">Total Net Price:</td>' &&
    '<td>' && lv_total_str && '</td>' &&
    '</tr></tfoot>' &&
    '</table></div></div></div>' &&
    '</div>' &&

    '<script>' &&
    'const barCtx=document.getElementById("barChart").getContext("2d");' &&
    'new Chart(barCtx,{type:"bar",data:{labels:[' && lv_chart_labels && '],' &&
    'datasets:[{label:"Net Price",data:[' && lv_chart_data && '],' &&
    'backgroundColor:"rgba(0,64,112,0.7)",borderColor:"#004070",borderWidth:1,borderRadius:4}]},' &&
    'options:{responsive:true,plugins:{legend:{display:false}},' &&
    'scales:{x:{ticks:{font:{size:10},maxRotation:45}},y:{beginAtZero:true}}}});' &&
    'const dCtx=document.getElementById("doughnutChart").getContext("2d");' &&
    'new Chart(dCtx,{type:"doughnut",data:{labels:["High (>=10K)","Medium (>=1K)","Low (<1K)"],' &&
    'datasets:[{data:[' && lv_high_str && ',' && lv_mid_str && ',' && lv_low_str && '],' &&
    'backgroundColor:["#dc3545","#ffc107","#198754"],borderWidth:2}]},' &&
    'options:{responsive:true,plugins:{legend:{position:"bottom"}}}});' &&
    '</script>' &&

    '<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>' &&
    '</body></html>'.

  server->response->set_cdata( data = lv_html ).
  server->response->set_header_field( name  = 'Content-Type'
                                      value = 'text/html; charset=utf-8' ).
  server->response->set_status( code = 200 reason = 'OK' ).

ENDMETHOD.
ENDCLASS.
