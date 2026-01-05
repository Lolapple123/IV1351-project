import dao.*;
import Models.*;
import service.CourseService;

import java.util.List;
import java.util.Scanner;

public class MainCLI {

    private static final CourseDAO courseDAO = new CourseDAO();
    private static final TeachingCostDAO costDAO = new TeachingCostDAO();
    private static final CourseService service = new CourseService();

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);

        while (true) {
            System.out.println("\n=== COURSE PLANNING SYSTEM ===");
            System.out.println("1. Show all course instances");
            System.out.println("2. Show teaching cost for instance (planned + actual)");
            System.out.println("3. Increase students for instance");
            System.out.println("4. Allocate teacher to activity");
            System.out.println("5. Deallocate teacher from instance/activity");
            System.out.println("6. Add new activity 'Exercise' (planned + allocate)");
            System.out.println("0. Exit");
            System.out.print("Choose: ");

            String choice = sc.nextLine().trim();
            switch (choice) {
                case "1":
                    showInstances();
                    break;
                case "2":
                    showCost(sc);
                    break;
                case "3":
                    increaseStudents(sc);
                    break;
                case "4":
                    allocateTeacher(sc);
                    break;
                case "5":
                    deallocateTeacher(sc);
                    break;
                case "6":
                    addExercise(sc);
                    break;
                case "0":
                    System.out.println("Bye!");
                    return;
                default:
                    System.out.println("Invalid choice.");
            }
        }
    }

    private static void showInstances() {
        System.out.println("\nAll course instances:");
        List<CourseInstance> list = courseDAO.getAllInstances();
        for (CourseInstance ci : list) {
            System.out.println(ci.getCourseinstanceId() + " — " + ci.getCourseName() +
                    " (" + ci.getStudyPeriod() + ") students=" + ci.getNumStudents());
        }
    }

    private static void showCost(Scanner sc) {
        try {
            System.out.print("Enter instance ID: ");
            int id = Integer.parseInt(sc.nextLine().trim());
            TeachingCost tc = costDAO.getCostForInstance(id);
            if (tc == null) {
                System.out.println("Instance not found.");
                return;
            }
            System.out.printf("Course %s (instance %d, %s %d)%n",
                    tc.getCourseCode(), tc.getCourseinstanceId(), tc.getStudyPeriod(), tc.getYear());
            System.out.printf("Planned hours: %.2f -> Planned cost: %.2f SEK%n",
                    tc.getPlannedHours(), tc.getPlannedCostSek());
            System.out.printf("Actual  hours: %.2f -> Actual  cost: %.2f SEK%n",
                    tc.getActualHours(), tc.getActualCostSek());
        } catch (NumberFormatException e) {
            System.out.println("Invalid input. Enter a number.");
        }
    }

    private static void increaseStudents(Scanner sc) {
        try {
            System.out.print("Enter instance ID: ");
            int id = Integer.parseInt(sc.nextLine().trim());
            System.out.print("Increase by (e.g., 100): ");
            int delta = Integer.parseInt(sc.nextLine().trim());
            boolean ok = service.increaseStudentsTransactional(id, delta);
            System.out.println(ok ? "Students increased successfully." : "Failed to increase students.");
        } catch (NumberFormatException e) {
            System.out.println("Invalid number input.");
        }
    }

    private static void allocateTeacher(Scanner sc) {
        try {
            System.out.print("Enter employee ID: ");
            int empId = Integer.parseInt(sc.nextLine().trim());
            System.out.print("Enter course instance ID: ");
            int instId = Integer.parseInt(sc.nextLine().trim());
            System.out.print("Enter activity ID: ");
            int actId = Integer.parseInt(sc.nextLine().trim());
            System.out.print("Enter hours to allocate: ");
            double hours = Double.parseDouble(sc.nextLine().trim());

            boolean ok = service.allocateTeacherTransactional(empId, instId, actId, hours);
            System.out.println(ok ? "Teacher allocated successfully." : "Allocation failed.");
        } catch (NumberFormatException e) {
            System.out.println("Invalid input. Numbers required.");
        }
    }

    private static void deallocateTeacher(Scanner sc) {
        try {
            System.out.print("Enter employee ID: ");
            int empId = Integer.parseInt(sc.nextLine().trim());
            System.out.print("Enter course instance ID: ");
            int instId = Integer.parseInt(sc.nextLine().trim());
            System.out.print("Enter activity ID: ");
            int actId = Integer.parseInt(sc.nextLine().trim());

            boolean ok = service.deallocateTeacher(empId, instId, actId);
            System.out.println(ok ? "Teacher deallocated successfully." : "No allocation removed.");
        } catch (NumberFormatException e) {
            System.out.println("Invalid input. Numbers required.");
        }
    }

    private static void addExercise(Scanner sc) {
        try {
            System.out.print("Enter course instance ID: ");
            int instId = Integer.parseInt(sc.nextLine().trim());
            System.out.print("Enter employee ID to allocate: ");
            int empId = Integer.parseInt(sc.nextLine().trim());
            System.out.print("Enter planned hours (e.g., 10): ");
            double plannedHours = Double.parseDouble(sc.nextLine().trim());
            System.out.print("Enter allocated hours (e.g., 5): ");
            double allocHours = Double.parseDouble(sc.nextLine().trim());

            boolean ok = service.addExerciseAndAllocate(instId, empId, plannedHours, allocHours);
            System.out.println(ok ? "Exercise added and allocated." : "Failed to add exercise.");
        } catch (NumberFormatException e) {
            System.out.println("Invalid input. Numbers required.");
        }}}
