<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// The rest of your database connection code...
$conn = new mysqli("localhost", "root", "", "student_db");

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Connection failed"]));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = $_POST['name'] ?? '';
    $roll_number = $_POST['roll_number'] ?? '';
    $email_id = $_POST['email_id'] ?? '';
    $cgpa = $_POST['cgpa'] ?? '';

    if (!empty($name) && !empty($roll_number) && !empty($email_id) && !empty($cgpa)) {
        $stmt = $conn->prepare("INSERT INTO students (name, roll_number, email_id, cgpa) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("sssd", $name, $roll_number, $email_id, $cgpa);

        if ($stmt->execute()) {
            echo json_encode(["status" => "success", "message" => "Student registered successfully"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to insert record"]);
        }
        $stmt->close();
    } else {
        echo json_encode(["status" => "error", "message" => "Incomplete data"]);
    }
}
$conn->close();
?>