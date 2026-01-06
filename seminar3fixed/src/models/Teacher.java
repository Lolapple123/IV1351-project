package models;

public class Teacher {
    private int id;
    private String firstName;
    private String lastName;
    private String designation;

    public Teacher(int id, String firstName, String lastName, String designation) {
        this.id = id;
        this.firstName = firstName;
        this.lastName = lastName;
        this.designation = designation;
    }

    // ===== Getters =====
    public int getId() { return id; }
    public String getFirstName() { return firstName; }
    public String getLastName() { return lastName; }
    public String getDesignation() { return designation; }

    // Convenience method
    public String getFullName() { return firstName + " " + lastName; }
}
