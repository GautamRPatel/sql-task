use hospital;

CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY IDENTITY,
    DepartmentName VARCHAR(100) NOT NULL UNIQUE,
    HeadDoctorID INT NULL
);

CREATE TABLE Doctors (
    DoctorID INT PRIMARY KEY IDENTITY,
    DoctorName VARCHAR(150) NOT NULL,
    DepartmentID INT NOT NULL,
    Specialisation VARCHAR(100) NOT NULL,
    ConsultationFee DECIMAL(10,2) NOT NULL CHECK (ConsultationFee >= 0),
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Doctor_Department 
        FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

select * from Doctors

CREATE TABLE Patients (
    PatientID INT PRIMARY KEY IDENTITY,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    DOB DATE NOT NULL,
    Phone VARCHAR(20),
    Address VARCHAR(255),
    InsuranceCoveragePercent DECIMAL(5,2) DEFAULT 0 CHECK (InsuranceCoveragePercent BETWEEN 0 AND 100),
    InsuranceYearlyMax DECIMAL(12,2) DEFAULT 0
);

CREATE TABLE Appointments (
    AppointmentID INT PRIMARY KEY IDENTITY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentDate DATE NOT NULL,
    TimeSlot TIME NOT NULL,
    Status VARCHAR(20) NOT NULL 
        CHECK (Status IN ('Scheduled','Completed','Cancelled')),
    CONSTRAINT FK_App_Patient FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
    CONSTRAINT FK_App_Doctor FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

CREATE TABLE MedicalRecords (
    RecordID INT PRIMARY KEY IDENTITY,
    AppointmentID INT UNIQUE,
    Diagnosis VARCHAR(500),
    TreatmentPlan VARCHAR(500),
    RequiresFollowUp BIT DEFAULT 0,
    CONSTRAINT FK_Record_Appointment 
        FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID)
);

CREATE TABLE Medicines (
    MedicineID INT PRIMARY KEY IDENTITY,
    MedicineName VARCHAR(150) NOT NULL UNIQUE,
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0)
);

CREATE TABLE Prescriptions (
    PrescriptionID INT PRIMARY KEY IDENTITY,
    RecordID INT NOT NULL,
    MedicineID INT NOT NULL,
    Dosage VARCHAR(100),
    DurationDays INT,
    Quantity INT CHECK (Quantity > 0),
    CONSTRAINT FK_Presc_Record FOREIGN KEY (RecordID) REFERENCES MedicalRecords(RecordID),
    CONSTRAINT FK_Presc_Med FOREIGN KEY (MedicineID) REFERENCES Medicines(MedicineID)
);

CREATE TABLE LabTests (
    LabTestID INT PRIMARY KEY IDENTITY,
    TestName VARCHAR(150) NOT NULL,
    TestCost DECIMAL(10,2) NOT NULL CHECK (TestCost >= 0)
);

CREATE TABLE LabOrders (
    LabOrderID INT PRIMARY KEY IDENTITY,
    AppointmentID INT NOT NULL,
    LabTestID INT NOT NULL,
    ResultValue VARCHAR(200),
    IsAbnormal BIT DEFAULT 0,
    CONSTRAINT FK_Lab_App FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID),
    CONSTRAINT FK_Lab_Test FOREIGN KEY (LabTestID) REFERENCES LabTests(LabTestID)
);

CREATE TABLE Billing (
    BillID INT PRIMARY KEY IDENTITY,
    AppointmentID INT UNIQUE,
    ConsultationCharge DECIMAL(12,2),
    MedicineCharge DECIMAL(12,2),
    LabCharge DECIMAL(12,2),
    InsuranceDiscount DECIMAL(12,2),
    GSTAmount DECIMAL(12,2),
    FinalAmount DECIMAL(12,2),
    PaymentStatus VARCHAR(20) DEFAULT 'Unpaid',
    CONSTRAINT FK_Bill_App FOREIGN KEY (AppointmentID) REFERENCES Appointments(AppointmentID)
);


INSERT INTO Departments (DepartmentName)
VALUES 
('Cardiology'),
('Orthopaedics'),
('Neurology'),
('Dermatology'),
('Pathology');

INSERT INTO Doctors (DoctorName, DepartmentID, Specialisation, ConsultationFee, IsActive)
VALUES
('Dr. Arjun Mehta',1,'Cardiologist',1000,1),
('Dr. Kavita Rao',1,'Cardiac Surgeon',1500,1),
('Dr. Manish Verma',2,'Orthopaedic',900,1),
('Dr. Ritu Sharma',2,'Spine Specialist',1100,1),
('Dr. Aditya Singh',3,'Neurologist',1300,1),
('Dr. Nidhi Kapoor',3,'Brain Surgeon',1700,1),
('Dr. Sameer Khan',4,'Skin Specialist',800,1),
('Dr. Priya Nair',5,'Pathologist',700,1);
select * from doctors
UPDATE Doctors
SET ConsultationFee = 
CASE 
    WHEN Specialisation LIKE '%Surgeon%' THEN 4000
    WHEN Specialisation LIKE '%Neurologist%' THEN 3500
    WHEN Specialisation LIKE '%Cardiologist%' THEN 3000
    WHEN Specialisation LIKE '%Orthopaedic%' THEN 2500
    ELSE 2000
END;

INSERT INTO Patients 
(FirstName, LastName, DOB, Phone, Address, InsuranceCoveragePercent, InsuranceYearlyMax)
VALUES
('Rahul','Patil','1994-06-12','9000000001','Nagpur',20,100000),
('Sneha','Joshi','1998-03-25','9000000002','Pune',0,0),
('Vikas','Shah','1992-11-10','9000000003','Mumbai',30,150000),
('Anita','Kulkarni','1989-02-05','9000000004','Delhi',15,80000),
('Rohit','Gupta','2000-09-14','9000000005','Indore',0,0),
('Pooja','Singh','1997-12-21','9000000006','Bhopal',25,120000),
('Amit','Jain','1988-01-19','9000000007','Jaipur',10,60000),
('Neha','Patel','1996-07-30','9000000008','Hyderabad',0,0),
('Sanjay','Yadav','1993-04-18','9000000009','Lucknow',35,200000),
('Kiran','Rao','1999-10-09','9000000010','Nashik',5,50000),
('Deepak','Sharma','1991-08-16','9000000011','Nagpur',0,0),
('Meena','Desai','1994-02-27','9000000012','Surat',20,100000),
('Akash','Verma','1987-05-11','9000000013','Pune',15,90000),
('Nisha','Kumar','1996-06-22','9000000014','Delhi',0,0),
('Ramesh','Mishra','1985-03-03','9000000015','Bhopal',40,200000),
('Anjali','Nair','1998-11-17','9000000016','Kochi',10,70000),
('Vivek','Chopra','1990-09-08','9000000017','Mumbai',0,0),
('Simran','Kaur','1997-01-14','9000000018','Chandigarh',30,150000),
('Harsh','Trivedi','1993-12-05','9000000019','Ahmedabad',0,0),
('Priya','Malhotra','1999-04-01','9000000020','Noida',25,100000);

INSERT INTO Medicines (MedicineName, UnitPrice)
VALUES
('Paracetamol',10),
('Ibuprofen',20),
('Amoxicillin',60),
('Pain Relief Gel',120),
('Vitamin D',25),
('Antacid Syrup',45);
select * from medicines
UPDATE Medicines
SET UnitPrice = UnitPrice * 5;

INSERT INTO LabTests (TestName, TestCost)
VALUES
('Blood Test',500),
('X-Ray',800),
('MRI Scan',3500),
('CT Scan',2800),
('ECG',1200);

select * from LabTests
UPDATE LabTests
SET TestCost = 
CASE 
    WHEN TestName = 'MRI Scan' THEN 12000
    WHEN TestName = 'CT Scan' THEN 9000
    WHEN TestName = 'ECG' THEN 2500
    WHEN TestName = 'X-Ray' THEN 2000
    ELSE 1500
END;

INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, TimeSlot, Status)
VALUES
(1,1,'2024-01-05','10:00','Completed'),
(2,2,'2024-01-10','11:00','Scheduled'),
(3,3,'2024-01-15','12:00','Cancelled'),
(4,4,'2024-02-02','10:00','Completed'),
(5,5,'2024-02-08','11:00','Scheduled'),
(6,6,'2024-02-14','12:00','Completed'),
(7,7,'2024-03-01','10:00','Cancelled'),
(8,8,'2024-03-10','11:00','Completed'),
(9,1,'2024-03-18','12:00','Scheduled'),
(10,2,'2024-04-04','10:00','Completed'),
(11,3,'2024-04-12','11:00','Scheduled'),
(12,4,'2024-04-20','12:00','Completed'),
(13,5,'2024-05-03','10:00','Completed'),
(14,6,'2024-05-15','11:00','Cancelled'),
(15,7,'2024-06-01','12:00','Completed'),
(16,8,'2024-06-09','10:00','Scheduled'),
(17,1,'2024-07-07','11:00','Completed'),
(18,2,'2024-07-19','12:00','Scheduled'),
(19,3,'2024-08-02','10:00','Completed'),
(20,4,'2024-08-18','11:00','Cancelled');

INSERT INTO MedicalRecords (AppointmentID, Diagnosis, TreatmentPlan)
SELECT AppointmentID, 'Routine Checkup', 'Medication & Rest'
FROM Appointments
WHERE Status = 'Completed';

INSERT INTO Prescriptions (RecordID, MedicineID, Dosage, DurationDays, Quantity)
SELECT RecordID, 1, 'Twice daily', 5, 10 FROM MedicalRecords
UNION ALL
SELECT RecordID, 3, 'Once daily', 7, 5 FROM MedicalRecords;

INSERT INTO LabOrders (AppointmentID, LabTestID, ResultValue, IsAbnormal)
SELECT AppointmentID, 1, 'Normal', 0 FROM Appointments
UNION ALL
SELECT AppointmentID, 2, 'High', 1 
FROM Appointments
WHERE AppointmentID % 4 = 0;

INSERT INTO LabOrders (AppointmentID, LabTestID, ResultValue, IsAbnormal)
SELECT AppointmentID, 3, 'Critical', 1
FROM Appointments;

INSERT INTO LabOrders (AppointmentID, LabTestID, ResultValue, IsAbnormal)
SELECT AppointmentID, 4, 'Normal', 0
FROM Appointments;
select * from LabOrders
UPDATE Appointments
SET Status = 'Scheduled';

UPDATE Appointments
SET Status = 'Completed'
WHERE AppointmentID IN (1,4,6,8,10,12,13,15,17,19);

select * from Prescriptions
UPDATE Prescriptions
SET Quantity = Quantity * 5;
use hospital

USE hospital;
GO

DROP DATABASE hospital;