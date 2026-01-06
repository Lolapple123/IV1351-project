package service;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import dao.*;
import models.CourseInstance;

public class CourseService {

    private final CourseDAO courseDAO = new CourseDAO();
    private final AllocationDAO allocationDAO = new AllocationDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();

    public boolean increaseStudentsTransactional(int instanceId, int delta) {
        try (Connection c = dao.DATABASEconnect.getConnection()) {
            c.setAutoCommit(false);

            CourseInstance ci = courseDAO.lockAndGetCourseInstance(instanceId);
            if (ci == null) {
                c.rollback();
                return false;
            }

            courseDAO.increaseStudents(instanceId, delta);
            c.commit();
            return true;
        } catch (Exception e) {
            System.out.println("increaseStudents error: " + e.getMessage());
            return false;
        }
    }
    public boolean allocateTeacherTransactional(int empId, int instanceId, int activityId, double hours) {
        try (Connection c = dao.DATABASEconnect.getConnection()) {
            c.setAutoCommit(false);

            CourseInstance ci = courseDAO.lockAndGetCourseInstance(instanceId);
            if (ci == null) {
                c.rollback();
                return false;
            }
            String lockSql = "SELECT a.* FROM Allocation a " +
                             "JOIN CourseInstance ci2 ON a.courseinstance_id = ci2.courseinstance_id " +
                             "WHERE a.employee_id = ? AND ci2.year = ? AND ci2.study_period = ? FOR UPDATE";
            try (PreparedStatement psLock = c.prepareStatement(lockSql)) {
                psLock.setInt(1, empId);
                psLock.setInt(2, ci.getYear());
                psLock.setString(3, ci.getStudy_period());
                psLock.executeQuery();
            }
            int count = allocationDAO.countDistinctInstancesForTeacherInPeriod(empId, ci.getYear(), ci.getStudy_period());
            String existsSql = "SELECT 1 FROM Allocation WHERE employee_id = ? AND courseinstance_id = ? AND activitytype_id = ?";
            boolean alreadyAssigned = false;
            try (PreparedStatement ps = c.prepareStatement(existsSql)) {
                ps.setInt(1, empId);
                ps.setInt(2, instanceId);
                ps.setInt(3, activityId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) alreadyAssigned = true;
                }
            }
            int futureCount = count + (alreadyAssigned ? 0 : 1);
            if (futureCount > 4) {
                c.rollback();
                throw new SQLException("Allocation would exceed 4 courses in period " + ci.getStudy_period());
            }
            allocationDAO.insertAllocation(c, empId, instanceId, activityId, hours);
            c.commit();
            return true;

        } catch (Exception e) {
            System.out.println("Allocation failed: " + e.getMessage());
            return false;
        } }
    public boolean deallocateTeacher(int empId, int instanceId, int activityId) {
        try {
            return allocationDAO.deleteAllocation(empId, instanceId, activityId);
        } catch (Exception e) {
            System.out.println("Deallocate error: " + e.getMessage());
            return false;
        }}
    public boolean addExerciseAndAllocate(int instanceId, int empId, double plannedHours, double allocHours) {
        try (Connection c = dao.DATABASEconnect.getConnection()) {
            c.setAutoCommit(false);

            int activityId = activityDAO.ensureActivity(c, "Exercise", 1.5);
            activityDAO.upsertPlannedActivity(c, instanceId, activityId, plannedHours);
            allocationDAO.insertAllocation(c, empId, instanceId, activityId, allocHours);

            c.commit();
            return true;
        } catch (Exception e) {
            System.out.println("addExercise error: " + e.getMessage());
            return false;
        }}}
