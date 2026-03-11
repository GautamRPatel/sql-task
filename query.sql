create database gautam_hospital
use gautam_hospital

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

INSERT INTO Departments (DepartmentName) VALUES
('Cardiology'),
('Neurology'),
('Orthopaedics'),
('Oncology'),
('Nephrology'),
('Pulmonology'),
('Gastroenterology'),
('Dermatology'),
('Urology'),
('Endocrinology');

INSERT INTO Doctors (DoctorName, DepartmentID, Specialisation, ConsultationFee, IsActive) VALUES
('Dr. Arjun Mehra',1,'Cardiac Surgeon',8000,1),
('Dr. Pallavi Rao',1,'Cardiologist',6000,1),
('Dr. Nikhil Sharma',2,'Neurosurgeon',9000,1),
('Dr. Rhea Kapoor',2,'Neuro Physician',6500,1),
('Dr. Manoj Iyer',3,'Joint Replacement Surgeon',7000,1),
('Dr. Ketan Shah',3,'Spine Specialist',6000,1),
('Dr. Tanya Mehta',4,'Onco Surgeon',9500,1),
('Dr. Sameer Jain',4,'Medical Oncologist',8500,1),
('Dr. Danish Qureshi',5,'Kidney Specialist',9000,1),
('Dr. Aditi Nair',5,'Nephrologist',6500,1),
('Dr. Rohit Kulkarni',6,'Pulmonologist',5000,1),
('Dr. Shraddha Patil',6,'Chest Specialist',4800,1),
('Dr. Arjun Verma',7,'Gastro Surgeon',7200,1),
('Dr. Neha Deshmukh',7,'Hepatologist',6800,1),
('Dr. Faizan Khan',8,'Dermatologist',4000,1),
('Dr. Pooja Sinha',8,'Cosmetic Dermatologist',4500,1),
('Dr. Vivek Bansal',9,'Urologist',7500,1),
('Dr. Kiran Reddy',9,'Andrologist',7000,1),
('Dr. Mahima Gupta',10,'Diabetologist',5000,1),
('Dr. Harsh Vaidya',10,'Endocrinologist',7800,1);

INSERT INTO Patients
(FirstName, LastName, DOB, Phone, Address, InsuranceCoveragePercent, InsuranceYearlyMax)
VALUES
('Aarav','Patel','1985-02-10','9500000001','Mumbai',80,1000000),
('Diya','Sharma','1990-05-12','9500000002','Delhi',0,0),
('Kabir','Rao','1978-07-19','9500000003','Pune',60,500000),
('Anaya','Mehta','1993-09-21','9500000004','Hyderabad',75,800000),
('Vivaan','Singh','1988-11-25','9500000005','Nagpur',50,400000),
('Myra','Kapoor','1996-01-30','9500000006','Jaipur',30,200000),
('Reyansh','Jain','1982-03-14','9500000007','Mumbai',85,1200000),
('Sara','Nair','1995-06-18','9500000008','Kochi',20,150000),
('Advik','Desai','1987-08-20','9500000009','Surat',40,300000),
('Ira','Malhotra','1991-10-05','9500000010','Noida',0,0),

('Rudra','Yadav','1984-12-12','9500000011','Indore',70,600000),
('Kiara','Chopra','1997-02-22','9500000012','Chandigarh',0,0),
('Dev','Sinha','1980-04-04','9500000013','Lucknow',65,700000),
('Navya','Gupta','1994-06-16','9500000014','Delhi',90,1500000),
('Aryan','Kulkarni','1986-09-29','9500000015','Pune',0,0),
('Saanvi','Reddy','1992-12-08','9500000016','Hyderabad',50,450000),
('Ishaan','Bhosale','1983-03-03','9500000017','Mumbai',35,250000),
('Aisha','Kaur','1998-05-15','9500000018','Amritsar',0,0),
('Yash','Trivedi','1989-07-27','9500000019','Ahmedabad',75,800000),
('Riya','Mishra','1996-11-19','9500000020','Bhopal',20,100000),

('Krish','Bhatt','1986-11-11','9500000021','Surat',65,500000),
('Anika','Dutta','1994-12-12','9500000022','Kolkata',0,0),
('Ved','Chatterjee','1982-01-15','9500000023','Kolkata',85,1200000),
('Ritika','Pandey','1996-02-18','9500000024','Patna',20,100000),
('Dhruv','Mohan','1989-03-21','9500000025','Chennai',50,450000),
('Pallav','Rastogi','1981-04-24','9500000026','Lucknow',0,0),
('Aanya','Gill','1993-05-27','9500000027','Ludhiana',75,800000),
('Laksh','Kapadia','1984-06-30','9500000028','Mumbai',30,200000),
('Nitya','Rawat','1997-07-07','9500000029','Dehradun',0,0),
('Samar','Thakur','1985-08-08','9500000030','Shimla',60,500000),

('Harshit','Dubey','1983-10-10','9500000031','Indore',90,1500000),
('Tanmay','Gokhale','1986-11-11','9500000032','Pune',40,300000),
('Roshni','Prasad','1995-12-12','9500000033','Ranchi',0,0),
('Adarsh','Naik','1987-01-01','9500000034','Goa',55,450000),
('Prisha','Chawla','1998-02-02','9500000035','Delhi',0,0),
('Tejas','Salvi','1984-03-03','9500000036','Mumbai',70,700000),
('Mitali','Vora','1993-04-04','9500000037','Ahmedabad',15,100000),
('Raghav','Singhania','1982-05-05','9500000038','Jaipur',85,1000000),
('Ishita','Batra','1996-06-06','9500000039','Delhi',0,0),
('Omkar','Joshi','1985-07-07','9500000040','Pune',60,600000);

INSERT INTO Medicines (MedicineName, UnitPrice) VALUES
('Cardiac Stent',50000),
('Neuro Injection',15000),
('Chemotherapy Drug',25000),
('Dialysis Kit',12000),
('Post Surgery Antibiotic',6000),
('Respiratory Therapy Kit',8000),
('Insulin Advanced Pack',5000),
('Pain Management Injection',3500),
('Premium Vitamin Therapy',2000),
('ICU Support Medication',18000);

INSERT INTO LabTests (TestName, TestCost) VALUES
('MRI Brain',18000),
('CT Scan Full Body',15000),
('Angiography',30000),
('Biopsy Advanced',22000),
('Dialysis Session',10000),
('Full Body Checkup',12000),
('Cardiac Panel',16000),
('Liver Advanced Panel',9000),
('Thyroid Comprehensive',6000),
('Cancer Marker Test',25000);


INSERT INTO Appointments (PatientID, DoctorID, AppointmentDate, TimeSlot, Status)
VALUES
(1,1,'2024-01-02','09:00','Scheduled'),
(2,2,'2024-01-03','09:30','Scheduled'),
(3,3,'2024-01-04','10:00','Scheduled'),
(4,4,'2024-01-05','10:30','Scheduled'),
(5,5,'2024-01-06','11:00','Scheduled'),
(6,6,'2024-01-07','11:30','Scheduled'),
(7,7,'2024-01-08','12:00','Scheduled'),
(8,8,'2024-01-09','12:30','Scheduled'),
(9,9,'2024-01-10','13:00','Scheduled'),
(10,10,'2024-01-11','13:30','Scheduled'),

(11,11,'2024-01-12','14:00','Scheduled'),
(12,12,'2024-01-13','14:30','Scheduled'),
(13,13,'2024-01-14','15:00','Scheduled'),
(14,14,'2024-01-15','15:30','Scheduled'),
(15,15,'2024-01-16','16:00','Scheduled'),
(16,16,'2024-01-17','16:30','Scheduled'),
(17,17,'2024-01-18','17:00','Scheduled'),
(18,18,'2024-01-19','09:00','Scheduled'),
(19,19,'2024-01-20','09:30','Scheduled'),
(20,20,'2024-01-21','10:00','Scheduled'),

(21,1,'2024-02-01','10:30','Scheduled'),
(22,2,'2024-02-02','11:00','Scheduled'),
(23,3,'2024-02-03','11:30','Scheduled'),
(24,4,'2024-02-04','12:00','Scheduled'),
(25,5,'2024-02-05','12:30','Scheduled'),
(26,6,'2024-02-06','13:00','Scheduled'),
(27,7,'2024-02-07','13:30','Scheduled'),
(28,8,'2024-02-08','14:00','Scheduled'),
(29,9,'2024-02-09','14:30','Scheduled'),
(30,10,'2024-02-10','15:00','Scheduled'),

(31,11,'2024-02-11','15:30','Scheduled'),
(32,12,'2024-02-12','16:00','Scheduled'),
(33,13,'2024-02-13','16:30','Scheduled'),
(34,14,'2024-02-14','17:00','Scheduled'),
(35,15,'2024-02-15','09:00','Scheduled'),
(36,16,'2024-02-16','09:30','Scheduled'),
(37,17,'2024-02-17','10:00','Scheduled'),
(38,18,'2024-02-18','10:30','Scheduled'),
(39,19,'2024-02-19','11:00','Scheduled'),
(40,20,'2024-02-20','11:30','Scheduled'),

(1,5,'2024-03-01','12:00','Scheduled'),
(2,6,'2024-03-02','12:30','Scheduled'),
(3,7,'2024-03-03','13:00','Scheduled'),
(4,8,'2024-03-04','13:30','Scheduled'),
(5,9,'2024-03-05','14:00','Scheduled'),
(6,10,'2024-03-06','14:30','Scheduled'),
(7,11,'2024-03-07','15:00','Scheduled'),
(8,12,'2024-03-08','15:30','Scheduled'),
(9,13,'2024-03-09','16:00','Scheduled'),
(10,14,'2024-03-10','16:30','Scheduled'),

(11,15,'2024-03-11','17:00','Scheduled'),
(12,16,'2024-03-12','09:00','Scheduled'),
(13,17,'2024-03-13','09:30','Scheduled'),
(14,18,'2024-03-14','10:00','Scheduled'),
(15,19,'2024-03-15','10:30','Scheduled'),
(16,20,'2024-03-16','11:00','Scheduled'),
(17,1,'2024-03-17','11:30','Scheduled'),
(18,2,'2024-03-18','12:00','Scheduled'),
(19,3,'2024-03-19','12:30','Scheduled'),
(20,4,'2024-03-20','13:00','Scheduled');

INSERT INTO MedicalRecords (AppointmentID, Diagnosis, TreatmentPlan)
SELECT AppointmentID, 'Severe Condition', 'Surgery + ICU + Medication'
FROM Appointments;

INSERT INTO Prescriptions (RecordID, MedicineID, Dosage, DurationDays, Quantity)
SELECT RecordID, 1, 'Single Use', 1, 1 FROM MedicalRecords
UNION ALL
SELECT RecordID, 3, 'Weekly', 4, 4 FROM MedicalRecords
UNION ALL
SELECT RecordID, 5, 'Twice Daily', 10, 20 FROM MedicalRecords
UNION ALL
SELECT RecordID, 10, 'Daily', 5, 5 FROM MedicalRecords;

INSERT INTO LabOrders (AppointmentID, LabTestID, ResultValue, IsAbnormal)
SELECT AppointmentID, 1, 'Abnormal', 1 FROM Appointments
UNION ALL
SELECT AppointmentID, 3, 'Critical', 1 FROM Appointments
UNION ALL
SELECT AppointmentID, 6, 'Normal', 0 FROM Appointments
UNION ALL
SELECT AppointmentID, 10, 'High Risk', 1 FROM Appointments;

UPDATE Appointments
SET Status = 'Completed'
WHERE AppointmentID BETWEEN 41 AND 55;

UPDATE Billing
SET PaymentStatus='Paid'
WHERE BillID = 66;

select * from Appointments

use gautam_hospital


SELECT * FROM Billing