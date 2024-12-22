-- Create database
CREATE DATABASE IF NOT EXISTS `legal_case`;
USE `legal_case`;

-- Create Clients table
CREATE TABLE IF NOT EXISTS Clients (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    address TEXT
);

-- Create Lawyers table
CREATE TABLE IF NOT EXISTS Lawyers (
    lawyer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100),
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15)
);

-- Create Cases table
CREATE TABLE IF NOT EXISTS Cases (
    case_id INT AUTO_INCREMENT PRIMARY KEY,
    case_name VARCHAR(255) NOT NULL,
    case_description TEXT,
    status ENUM('Open', 'Closed', 'Pending') DEFAULT 'Open',
    client_id INT,
    FOREIGN KEY (client_id) REFERENCES Clients(client_id)
);

-- Create CaseAssignments table
CREATE TABLE IF NOT EXISTS CaseAssignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    case_id INT,
    lawyer_id INT,
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (case_id) REFERENCES Cases(case_id),
    FOREIGN KEY (lawyer_id) REFERENCES Lawyers(lawyer_id)
);

-- Create Payments table
CREATE TABLE IF NOT EXISTS Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    case_id INT,
    amount DECIMAL(10, 2),
    payment_date DATE,
    FOREIGN KEY (case_id) REFERENCES Cases(case_id)
);

-- Insert sample clients
INSERT INTO Clients (name, email, phone, address) VALUES
('Alice Johnson', 'alice.johnson@example.com', '123-456-7890', '123 Maple St, Springfield, IL'),
('Bob Smith', 'bob.smith@example.com', '987-654-3210', '456 Oak St, Springfield, IL'),
('Charlie Brown', 'charlie.brown@example.com', '555-123-4567', '789 Pine St, Springfield, IL'),
('Diana Green', 'diana.green@example.com', '555-987-6543', '321 Birch St, Springfield, IL'),
('Eva White', 'eva.white@example.com', '555-555-5555', '654 Cedar St, Springfield, IL');

-- Insert sample lawyers
INSERT INTO Lawyers (name, specialization, email, phone) VALUES
('John Doe', 'Corporate Law', 'john.doe@lawfirm.com', '312-555-1001'),
('Mary Black', 'Criminal Defense', 'mary.black@lawfirm.com', '312-555-1002'),
('James Red', 'Family Law', 'james.red@lawfirm.com', '312-555-1003'),
('Patricia Blue', 'Intellectual Property', 'patricia.blue@lawfirm.com', '312-555-1004'),
('Michael Grey', 'Real Estate Law', 'michael.grey@lawfirm.com', '312-555-1005');

-- Insert sample cases
INSERT INTO Cases (case_name, case_description, client_id) VALUES
('Case A', 'Corporate merger dispute between two tech companies.', 1),
('Case B', 'Criminal defense for a robbery case.', 2),
('Case C', 'Divorce case involving custody of children.', 3),
('Case D', 'Patent infringement lawsuit regarding software.', 4),
('Case E', 'Real estate dispute over property boundaries.', 5);

-- Insert sample case assignments
INSERT INTO CaseAssignments (case_id, lawyer_id, start_date, end_date) VALUES
(1, 1, '2023-01-15', '2023-06-15'),
(2, 2, '2023-02-01', '2023-07-01'),
(3, 3, '2023-03-10', '2023-09-10'),
(4, 4, '2023-04-05', '2023-08-05'),
(5, 5, '2023-05-20', '2023-11-20');

-- Insert sample payments
INSERT INTO Payments (case_id, amount, payment_date) VALUES
(1, 1500.00, '2023-02-15'),
(1, 2000.00, '2023-04-10'),
(2, 800.00, '2023-03-01'),
(3, 1200.00, '2023-03-20'),
(4, 2500.00, '2023-05-10');

-- Trigger to ensure payment amount is greater than zero
DELIMITER $$

CREATE TRIGGER check_payment_amount
BEFORE INSERT ON Payments
FOR EACH ROW
BEGIN
    IF NEW.amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Payment amount must be greater than zero.';
    END IF;
END $$

DELIMITER ;

-- Trigger to ensure case status is valid
DELIMITER $$

CREATE TRIGGER check_case_status
BEFORE INSERT ON Cases
FOR EACH ROW
BEGIN
    IF NEW.status NOT IN ('Open', 'Closed', 'Pending') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid case status. It must be "Open", "Closed", or "Pending".';
    END IF;
END $$

DELIMITER ;
