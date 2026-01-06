package service;

import dao.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashSet;
import java.util.Set;
import models.CourseInstance;

public class CourseService {

    private final CourseDAO courseDAO = new CourseDAO();
    private final AllocationDAO allocationDAO = new AllocationDAO();
    private final ActivityDAO activityDAO = new ActivityDAO();

    // =============================
    // Increase students for a course instance transactionally
    // =============================
    public boolean increaseStudentsTransactional(int instanceId, int delta) {
        try (Connection c = dao.DATABASEconnect.getConnection()) {
            c.setAutoCommit(false);

            CourseInstance ci = courseDAO.lockAndGetCourseInstance(c, instanceId);
            if (ci == null) {
                c.rollback();
                return false;
            }

            courseDAO.increaseStudents(c, instanceId, delta);
            c.commit();
            return true;
        } catch (Exception e) {
            System.out.println("increaseStudents error: " + e.getMessage());
            return false;
        }
    }

    // =============================
    // Allocate teacher transactionally with 4-course limit
    // =============================
public boolean allocateTeacherTransactional(int empId, int instanceId, int activityId, double hours) {
    try (Connection c = dao.DATABASEconnect.getConnection()) {
        c.setAutoCommit(false);

        // 1. Lock the course instance
        CourseInstance ci = courseDAO.lockAndGetCourseInstance(c, instanceId);
        if (ci == null) {
            c.rollback();
            System.out.println("Debug: Course instance not found.");
            return false;
        }
        System.out.println("Debug: Locked CourseInstance " + ci.getCourseCode() +
                " (" + ci.getStudyPeriod() + " " + ci.getNumStudents() + ")");

        // 2. Get planned_activity_id for this instance/activity
        int plannedActivityId = activityDAO.getPlannedActivityId(c, instanceId, activityId);
        System.out.println("Debug: PlannedActivityId = " + plannedActivityId);

        // 3. Get all distinct course instances this teacher is already allocated to in the same period/year
        String lockSql = """
        SELECT pa.courseinstance_id
        FROM Allocation a
        JOIN PlannedActivity pa ON a.planned_activity_id = pa.planned_activity_id
        JOIN CourseInstance ci2 ON pa.courseinstance_id = ci2.courseinstance_id
        WHERE a.employee_id = ? AND ci2.year = ? AND ci2.study_period = ?
        FOR UPDATE
    """;

        Set<Integer> distinctInstances = new HashSet<>();
        try (PreparedStatement ps = c.prepareStatement(lockSql)) {
            ps.setInt(1, empId);
            ps.setInt(2, ci.getYear());
            ps.setString(3, ci.getStudyPeriod());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                distinctInstances.add(rs.getInt("courseinstance_id"));
            }
        }
    }

        System.out.println("Currently allocated courses: " + distinctInstances);

        // 4. Check if already assigned to this planned activity
        boolean alreadyAssigned = allocationDAO.isTeacherAllocated(c, empId, plannedActivityId);
        System.out.println("Debug: Already assigned to this planned activity? " + alreadyAssigned);

        // 5. Enforce 4-course limit
        int futureCount = distinctInstances.size() + (alreadyAssigned ? 0 : 1);
        System.out.println("Debug: Future course count if allocated = " + futureCount);
        if (futureCount > 4) {
            c.rollback();
            System.out.println("Debug: Allocation blocked — teacher would exceed 4 courses.");
            return false;
        }

        // 6. Insert allocation
        allocationDAO.insertAllocation(c, empId, plannedActivityId, hours);
        System.out.println("Debug: Allocation inserted successfully.");

        c.commit();
        return true;

    } catch (Exception e) {
        System.out.println("Allocation failed: " + e.getMessage());
        return false;
    }
}


    // =============================
    // Deallocate teacher
    // =============================
    public boolean deallocateTeacher(int empId, int instanceId, int activityId) {
        try (Connection c = dao.DATABASEconnect.getConnection()) {
            int plannedActivityId = activityDAO.getPlannedActivityId(c, instanceId, activityId);
            return allocationDAO.deleteAllocation(c, empId, plannedActivityId);
        } catch (Exception e) {
            System.out.println("Deallocate error: " + e.getMessage());
            return false;
        }
    }

    // =============================
    // Add Exercise activity and allocate
    // =============================
 public boolean addExerciseAndAllocate(int instanceId, int empId, double plannedHours, double allocHours) {
    try (Connection c = dao.DATABASEconnect.getConnection()) {
        c.setAutoCommit(false);

        // 1. Ensure 'Exercise' activity exists
        int activityId = activityDAO.ensureActivity(c, "Exercise", 1.5);

        // 2. Add or update planned activity
        activityDAO.upsertPlannedActivity(c, instanceId, activityId, plannedHours);

        // 3. Get planned_activity_id
        int plannedActivityId = activityDAO.getPlannedActivityId(c, instanceId, activityId);

        // 4. Lock the course instance
        CourseInstance ci = courseDAO.lockAndGetCourseInstance(c, instanceId);
        if (ci == null) {
            c.rollback();
            System.out.println("Debug: Course instance not found.");
            return false;
        }
        System.out.println("Debug: Locked CourseInstance " + ci.getCourseCode() +
                " (" + ci.getStudyPeriod() + " " + ci.getNumStudents() + ")");

        // 5. Get all distinct course instances the teacher is allocated to in this period/year
        String sql = """
            SELECT DISTINCT pa.courseinstance_id
            FROM Allocation a
            JOIN PlannedActivity pa ON a.planned_activity_id = pa.planned_activity_id
            JOIN CourseInstance ci2 ON pa.courseinstance_id = ci2.courseinstance_id
            WHERE a.employee_id = ? AND ci2.year = ? AND ci2.study_period = ?
            FOR UPDATE
        """;

        Set<Integer> distinctInstances = new HashSet<>();
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, empId);
            ps.setInt(2, ci.getYear());
            ps.setString(3, ci.getStudyPeriod());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    distinctInstances.add(rs.getInt("COURSEINSTANCE_ID"));
                }
            }
        }

        System.out.println("Debug: Currently allocated courses: " + distinctInstances);

        // 6. Check if already assigned to this planned activity
        boolean alreadyAssigned = allocationDAO.isTeacherAllocated(c, empId, plannedActivityId);
        System.out.println("Debug: Already assigned to this planned activity? " + alreadyAssigned);

        // 7. Enforce 4-course limit
        int futureCount = distinctInstances.size() + (alreadyAssigned ? 0 : 1);
        System.out.println("Debug: Future course count if allocated = " + futureCount);
        if (futureCount > 4) {
            c.rollback();
            System.out.println("Debug: Allocation blocked — teacher would exceed 4 courses.");
            return false;
        }

        // 8. Insert allocation
        allocationDAO.insertAllocation(c, empId, plannedActivityId, allocHours);
        System.out.println("Debug: Allocation inserted successfully.");

        c.commit();
        return true;

    } catch (Exception e) {
        System.out.println("addExercise error: " + e.getMessage());
        return false;
    }
}

}
