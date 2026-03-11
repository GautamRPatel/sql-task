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
USE hospital_hrishi;
GO

-- Departments
USE hospital_hrishi;
GO

-- Departments
INSERT INTO Departments (DepartmentName)
VALUES 
('Gastroenterology'),
('Oncology'),
('Pediatrics'),
('ENT'),
('Psychiatry');


-- Doctors
INSERT INTO Doctors (DoctorName, DepartmentID, Specialisation, ConsultationFee, IsActive)
VALUES
('Dr. Rohan Deshmukh',1,'Gastro Specialist',1200,1),
('Dr. Isha Menon',1,'Liver Surgeon',1800,1),
('Dr. Arvind Pillai',2,'Cancer Specialist',2000,1),
('Dr. Meera Iyer',2,'Radiation Oncologist',2200,1),
('Dr. Saurabh Kulkarni',3,'Child Specialist',900,1),
('Dr. Tanvi Bhatia',3,'Neonatologist',1500,1),
('Dr. Kunal Reddy',4,'ENT Surgeon',1100,1),
('Dr. Farah Ali',5,'Psychiatrist',1300,1);


-- Patients
INSERT INTO Patients 
(FirstName, LastName, DOB, Phone, Address, InsuranceCoveragePercent, InsuranceYearlyMax)
VALUES
('Arjun','More','1995-05-14','9111111111','Nagpur',15,80000),
('Kavya','Shinde','1999-02-10','9222222222','Pune',0,0),
('Ritesh','Agarwal','1991-07-19','9333333333','Mumbai',25,120000),
('Sonal','Chavan','1988-11-23','9444444444','Delhi',10,50000),
('Nikhil','Patankar','1997-09-09','9555555555','Indore',0,0),
('Mitali','Jadhav','1996-12-01','9666666666','Bhopal',30,140000),
('Varun','Bhatt','1990-03-18','9777777777','Jaipur',20,90000),
('Ishita','Kapadia','1998-06-22','9888888888','Hyderabad',0,0),
('Pratik','Sawant','1992-01-30','9999999991','Lucknow',35,200000),
('Ankita','Dube','1994-04-17','9999999992','Nashik',5,40000),
('Tejas','Shetty','1993-08-28','9999999993','Nagpur',0,0),
('Riya','Thomas','1995-10-05','9999999994','Surat',20,100000),
('Manav','Gandhi','1989-05-11','9999999995','Pune',10,60000),
('Snehal','Kulshrestha','1996-07-07','9999999996','Delhi',0,0),
('Yogesh','Naik','1987-02-15','9999999997','Bhopal',40,180000),
('Divya','Raman','1998-03-29','9999999998','Kochi',15,75000),
('Aditya','Malik','1990-12-12','9999999999','Mumbai',0,0),
('Pallavi','Singhania','1997-09-03','9000000011','Chandigarh',30,150000),
('Rohini','Trivedi','1993-11-25','9000000012','Ahmedabad',0,0),
('Siddharth','Kapoor','1999-01-08','9000000013','Noida',25,110000);


-- Medicines
INSERT INTO Medicines (MedicineName, UnitPrice)
VALUES
('Cefixime',55),
('Azithromycin',75),
('Pantoprazole',30),
('Calcium Tablets',40),
('Cough Syrup',65),
('Antidepressant',150);


-- Lab Tests
INSERT INTO LabTests (TestName, TestCost)
VALUES
('Liver Function Test',900),
('Thyroid Profile',1200),
('Ultrasound Abdomen',2500),
('EEG',1800),
('Hearing Test',700);


-- Appointments
INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, TimeSlot, Status)
VALUES
(1,1,'2024-01-03','09:00','Completed'),
(2,2,'2024-01-12','10:00','Scheduled'),
(3,3,'2024-01-20','11:00','Cancelled'),
(4,4,'2024-02-04','09:30','Completed'),
(5,5,'2024-02-11','10:30','Scheduled'),
(6,6,'2024-02-18','11:30','Completed'),
(7,7,'2024-03-02','09:00','Cancelled'),
(8,8,'2024-03-14','10:00','Completed'),
(9,1,'2024-03-25','11:00','Scheduled'),
(10,2,'2024-04-06','09:30','Completed'),
(11,3,'2024-04-16','10:30','Scheduled'),
(12,4,'2024-04-28','11:30','Completed'),
(13,5,'2024-05-05','09:00','Completed'),
(14,6,'2024-05-19','10:00','Cancelled'),
(15,7,'2024-06-03','11:00','Completed'),
(16,8,'2024-06-17','09:30','Scheduled'),
(17,1,'2024-07-08','10:30','Completed'),
(18,2,'2024-07-22','11:30','Scheduled'),
(19,3,'2024-08-05','09:00','Completed'),
(20,4,'2024-08-21','10:00','Cancelled');


-- Medical Records
INSERT INTO MedicalRecords (AppointmentID, Diagnosis, TreatmentPlan)
SELECT AppointmentID, 'General Illness', 'Prescription & Rest'
FROM Appointments
WHERE Status = 'Completed';


-- Prescriptions
INSERT INTO Prescriptions (RecordID, MedicineID, Dosage, DurationDays, Quantity)
SELECT RecordID, 2, 'Twice daily', 5, 10 FROM MedicalRecords
UNION ALL
SELECT RecordID, 4, 'Once daily', 7, 5 FROM MedicalRecords;


-- Lab Orders
INSERT INTO LabOrders (AppointmentID, LabTestID, ResultValue, IsAbnormal)
SELECT AppointmentID, 1, 'Normal', 0 FROM Appointments
UNION ALL
SELECT AppointmentID, 3, 'High', 1 
FROM Appointments
WHERE AppointmentID % 3 = 0;


-- Test Procedures
EXEC sp_MonthlyDepartmentReport 1, 2024;
EXEC sp_DoctorPerformance 2;
EXEC sp_MonthlyRevenueTarget;


-- Status Changes
UPDATE Appointments
SET Status = 'Scheduled';

UPDATE Appointments
SET Status = 'Completed'
WHERE AppointmentID IN (1,4,6,8,10,12,13,15,17,19);
USE hospital_hrishi;
GO

