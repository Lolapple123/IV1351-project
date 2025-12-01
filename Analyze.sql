EXPLAIN ANALYZE
SELECT 
    cl.course_code,
    ROUND(SUM(pa.planned_hours * at.factor), 2) AS planned_total,
    ROUND(SUM(COALESCE(a.hours_allocated,0) * at.factor), 2) AS actual_total
FROM CourseInstance ci
JOIN CourseLayout cl ON ci.courselayout_id = cl.course_layout_id
JOIN PlannedActivity pa ON ci.courseinstance_id = pa.courseinstance_id
JOIN ActivityType at ON pa.activitytype_id = at.activitytype_id
LEFT JOIN Allocation a 
       ON ci.courseinstance_id = a.courseinstance_id 
      AND pa.activitytype_id = a.activitytype_id
GROUP BY cl.course_code;
