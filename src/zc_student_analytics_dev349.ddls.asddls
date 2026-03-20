@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Analytics: Students per Course'
/* 1. Định nghĩa đây là một Query (Báo cáo phân tích) */
//@Analytics.query: true
define view entity ZC_STUDENT_ANALYTICS_DEV349
as select from zstudent_dev349
{

/* 2. Dimension (Trục hoành - Các chiều phân tích) */
@AnalyticsDetails.query.axis: #FREE
course as Course,
/* 3. Measure (Trục tung - Số liệu tính toán) */
/* Đếm số lượng sinh viên: Count distinct hoặc Count all */
@AnalyticsDetails.query.axis: #ROWS
@DefaultAggregation: #SUM
@EndUserText.label: 'Total Students'
1 as NumberOfStudents
}
/* Group by ngầm định: CDS tự động Group by các cột Dimension (Course) */
