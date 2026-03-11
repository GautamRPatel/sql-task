/*
	Create a stored procedure that accepts a month and year as parameters and returns a report
	showing each department, the number of appointments in that period, the number of unique
	patients seen, and the total consultation revenue. Departments with no appointments in that
	period must still appear in the result.
*/
CREATE OR ALTER PROCEDURE sp_MonthlyDepartmentReport
    @Month INT,
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        d.DepartmentName,
        COUNT(a.AppointmentID) AS TotalAppointments,
        COUNT(DISTINCT a.PatientID) AS UniquePatients,
        SUM(CASE 
        WHEN a.AppointmentID IS NOT NULL 
        THEN doc.ConsultationFee 
        ELSE 0 
    END) AS TotalConsultationRevenue
    FROM Departments d
    LEFT JOIN Doctors doc ON d.DepartmentID = doc.DepartmentID
    LEFT JOIN Appointments a 
        ON doc.DoctorID = a.DoctorID
        AND MONTH(a.AppointmentDate) = @Month
        AND YEAR(a.AppointmentDate) = @Year
        AND a.Status = 'Completed'
    GROUP BY d.DepartmentName
    ORDER BY d.DepartmentName;
END;
GO
drop procedure sp_MonthlyDepartmentReport
EXEC sp_MonthlyDepartmentReport 4, 2024;


/*
    Create a stored procedure that accepts a Patient ID and returns a full billing history for that
    patient. For each completed appointment, show the appointment date, doctor name,
    consultation charge, total medicine cost, total lab cost, insurance discount applied, GST charged,
    and final amount payable. Include a grand total row at the end. Raise an error if the Patient ID
    does not exist. 
*/
CREATE OR ALTER PROCEDURE sp_PatientBillingStatement
    @PatientID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT * FROM Patients WHERE PatientID = @PatientID)
        THROW 50001, 'Invalid Patient ID.', 1;

    SELECT 
        a.AppointmentDate,
        d.DoctorName,
        b.ConsultationCharge,
        b.MedicineCharge,
        b.LabCharge,
        b.InsuranceDiscount,
        b.GSTAmount,
        b.FinalAmount
    FROM Billing b
    JOIN Appointments a ON b.AppointmentID = a.AppointmentID
    JOIN Doctors d ON a.DoctorID = d.DoctorID
    WHERE a.PatientID = @PatientID

    UNION ALL

    SELECT 
         NULL,
        'GRAND TOTAL',
         0,0,0,0,0,
        SUM(FinalAmount)
    FROM Billing b
    JOIN Appointments a ON b.AppointmentID = a.AppointmentID
    WHERE a.PatientID = @PatientID;
END;
GO

EXEC sp_PatientBillingStatement 15;
/*
    Create a stored procedure that returns a performance summary for all active doctors. For each
    doctor, show their total appointments, total completed appointments, completion rate as a
    percentage, total revenue generated, and number of unique diagnoses recorded. The procedure
    must accept a minimum appointment count — only doctors who have handled at least that many
    appointments should appear. Order results by revenue, highest first. 
*/
CREATE OR ALTER PROCEDURE sp_DoctorPerformance
    @MinAppointments INT
AS
BEGIN
    SELECT 
        d.DoctorName,
        COUNT(a.AppointmentID) AS TotalAppointments,
        SUM(CASE WHEN a.Status='Completed' THEN 1 ELSE 0 END) AS CompletedAppointments,
        CAST(
            100.0 * SUM(CASE WHEN a.Status='Completed' THEN 1 ELSE 0 END)
            / NULLIF(COUNT(a.AppointmentID),0)
        AS DECIMAL(5,2)) AS CompletionRate,
        SUM(b.FinalAmount) AS Revenue,
        COUNT(DISTINCT mr.Diagnosis) AS UniqueDiagnoses
    FROM Doctors d
    LEFT JOIN Appointments a ON d.DoctorID = a.DoctorID
    LEFT JOIN MedicalRecords mr ON a.AppointmentID = mr.AppointmentID
    LEFT JOIN Billing b ON a.AppointmentID = b.AppointmentID
    WHERE d.IsActive = 1
    GROUP BY d.DoctorName
    HAVING COUNT(a.AppointmentID) >= @MinAppointments
    ORDER BY Revenue DESC;
END;
GO

EXEC sp_DoctorPerformance 2;
/*
    Create a stored procedure that returns all medicines that have never appeared in any
    prescription. Solve this in two different ways within the same procedure: once using a subquery
    approach, and once using a SET operation. Both must return the same result. Label each
    approach clearly with a comment. 
*/
CREATE OR ALTER PROCEDURE sp_MedicinesNeverPrescribed
AS
BEGIN
    -- Approach 1: Subquery
    SELECT MedicineID, MedicineName, UnitPrice FROM Medicines
    WHERE MedicineID NOT IN (SELECT MedicineID FROM Prescriptions);

    -- Approach 2: EXCEPT (SET operation)
    SELECT MedicineID, MedicineName, UnitPrice FROM Medicines
    EXCEPT
    SELECT m.MedicineID, m.MedicineName, m.UnitPrice
    FROM Medicines m
    JOIN Prescriptions p ON m.MedicineID = p.MedicineID;
END;
GO

EXEC sp_MedicinesNeverPrescribed
/*
    The hospital's monthly revenue target is Rs. 5,00,000. Create a stored procedure that returns
    one row per calendar month showing: the month and year, total revenue collected, whether the
    target was met (Yes or No), and the surplus or deficit amount. Also include a final summary
    showing how many months met the target and how many did not. 
*/
CREATE OR ALTER PROCEDURE sp_MonthlyRevenueTarget
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH MonthlyRevenue AS
    (
        SELECT 
            DATEFROMPARTS(YEAR(a.AppointmentDate),
                          MONTH(a.AppointmentDate),1) AS MonthStart,
            SUM(b.FinalAmount) AS Revenue
        FROM Billing b
        JOIN Appointments a 
            ON b.AppointmentID = a.AppointmentID
        GROUP BY YEAR(a.AppointmentDate),
                 MONTH(a.AppointmentDate)
    )

    SELECT 
        FORMAT(MonthStart,'MMM yyyy') AS MonthYear,
        Revenue,
        CASE 
            WHEN Revenue >= 2000 THEN 'Yes'
            ELSE 'No'
        END AS TargetMet,
        Revenue - 2000 AS SurplusOrDeficit
    FROM MonthlyRevenue

    UNION ALL

    SELECT
        'SUMMARY',
        NULL,
        'Met: ' + CAST(SUM(CASE WHEN Revenue >= 2000 THEN 1 ELSE 0 END) AS VARCHAR(10))
        + ' | Not Met: ' +
        CAST(SUM(CASE WHEN Revenue < 2000 THEN 1 ELSE 0 END) AS VARCHAR(10)),
        NULL
    FROM MonthlyRevenue;
END;
GO
EXEC sp_MonthlyRevenueTarget

/* Trigger */

/*
    Create a trigger on the Appointments table that fires when a new appointment is inserted. If the
    doctor already has a Scheduled or Completed appointment at the same date and time, the trigger
    must roll back the insert and raise a clear error message identifying the doctor and the
    conflicting time slot. 
*/
CREATE OR ALTER TRIGGER trg_PreventDoubleBooking
ON Appointments
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Appointments a
        JOIN inserted i 
            ON a.DoctorID = i.DoctorID
            AND a.AppointmentDate = i.AppointmentDate
            AND a.TimeSlot = i.TimeSlot
            AND a.AppointmentID <> i.AppointmentID
            AND a.Status IN ('Scheduled','Completed')
    )
    BEGIN
        ROLLBACK;
        THROW 50002, 'Doctor already booked at this time.', 1;
    END
END;
GO

/*
    Create a trigger on the Appointments table that fires when a row is updated. When the status is
    changed to Completed, the trigger must automatically insert a fully calculated bill into the Billing
    table. The bill must include the consultation fee, total medicine charges, total lab charges, the
    correct insurance discount (if any), GST at the appropriate rates for each charge type, and the
    final payable amount. Raise an error if a bill already exists for that appointment. 

*/

CREATE OR ALTER TRIGGER trg_AutoGenerateBill
ON Appointments
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Only proceed if Status changed to Completed
    IF NOT EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d 
            ON i.AppointmentID = d.AppointmentID
        WHERE i.Status = 'Completed'
          AND d.Status <> 'Completed'
    )
        RETURN;

    IF EXISTS (SELECT 1 FROM inserted WHERE Status = 'Completed')
    BEGIN

        -- Prevent duplicate
        IF EXISTS (
            SELECT 1
            FROM Billing b
            JOIN inserted i ON b.AppointmentID = i.AppointmentID
        )
        BEGIN
            THROW 50010, 'Bill already exists for this appointment.', 1;
        END

        INSERT INTO Billing
        (
            AppointmentID,
            ConsultationCharge,
            MedicineCharge,
            LabCharge,
            InsuranceDiscount,
            GSTAmount,
            FinalAmount,
            PaymentStatus
        )
        SELECT
            i.AppointmentID,
            d.ConsultationFee,

            med.MedicineTotal,
            lab.LabTotal,

            -- Insurance discount
            (med.MedicineTotal + lab.LabTotal)
                * (pat.InsuranceCoveragePercent / 100.0),

            -- GST AFTER insurance
            (
                (med.MedicineTotal 
                 - (med.MedicineTotal * pat.InsuranceCoveragePercent / 100.0)) * 0.05
                +
                (lab.LabTotal 
                 - (lab.LabTotal * pat.InsuranceCoveragePercent / 100.0)) * 0.12
            ),

            -- Final Amount
            (
                d.ConsultationFee
                +
                (med.MedicineTotal + lab.LabTotal)
                - ((med.MedicineTotal + lab.LabTotal)
                   * (pat.InsuranceCoveragePercent / 100.0))
                +
                (
                    (med.MedicineTotal 
                     - (med.MedicineTotal * pat.InsuranceCoveragePercent / 100.0)) * 0.05
                    +
                    (lab.LabTotal 
                     - (lab.LabTotal * pat.InsuranceCoveragePercent / 100.0)) * 0.12
                )
            ),

            'Unpaid'

        FROM inserted i
        JOIN Appointments a ON i.AppointmentID = a.AppointmentID
        JOIN Doctors d ON a.DoctorID = d.DoctorID
        JOIN Patients pat ON a.PatientID = pat.PatientID

        OUTER APPLY (
            SELECT ISNULL(SUM(m.UnitPrice * p.Quantity),0) AS MedicineTotal
            FROM MedicalRecords mr
            JOIN Prescriptions p ON mr.RecordID = p.RecordID
            JOIN Medicines m ON p.MedicineID = m.MedicineID
            WHERE mr.AppointmentID = i.AppointmentID
        ) med

        OUTER APPLY (
            SELECT ISNULL(SUM(lt.TestCost),0) AS LabTotal
            FROM LabOrders lo
            JOIN LabTests lt ON lo.LabTestID = lt.LabTestID
            WHERE lo.AppointmentID = i.AppointmentID
        ) lab

        WHERE i.Status = 'Completed';


        -- Check unpaid limit ONLY for affected patient
        IF EXISTS (
            SELECT 1
            FROM Billing b
            JOIN Appointments a ON b.AppointmentID = a.AppointmentID
            JOIN inserted i ON a.PatientID = i.PatientID
            WHERE b.PaymentStatus = 'Unpaid'
            GROUP BY a.PatientID
            HAVING SUM(b.FinalAmount) > 200000
        )
        BEGIN
            ROLLBACK;
            THROW 50011, 'Patient unpaid bills exceed Rs. 2,00,000 limit.', 1;
        END
    END
END;
GO

/*
    Create a trigger on the lab orders table that fires on both INSERT and UPDATE. When a result is
    marked as abnormal, the trigger must automatically update the linked medical record to require
    a follow-up. If no medical record exists yet for that appointment, the trigger should raise a
    warning message but must not roll back — the lab order must still be saved. 
*/
CREATE OR ALTER TRIGGER trg_LabAbnormal
ON LabOrders
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE mr
    SET RequiresFollowUp = 1
    FROM MedicalRecords mr
    JOIN inserted i ON mr.AppointmentID = i.AppointmentID
    WHERE i.IsAbnormal = 1;

    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE i.IsAbnormal = 1
        AND NOT EXISTS (
            SELECT 1 FROM MedicalRecords 
            WHERE AppointmentID = i.AppointmentID
        )
    )
    BEGIN
        PRINT 'Warning: Abnormal result but no medical record exists.';
    END
END;
GO
/* User defined functions 

Create a scalar function called fn_GetPatientAge that accepts a Patient ID and returns the
patient's current age in completed years as an integer. Return NULL if the Patient ID does not
exist. Demonstrate its use in a SELECT query that lists all patients with their calculated age.

*/

CREATE OR ALTER FUNCTION fn_GetPatientAge (@PatientID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Age INT;

    SELECT @Age =
        DATEDIFF(YEAR, DOB, GETDATE())
        - CASE 
            WHEN FORMAT(GETDATE(), 'MMdd') < FORMAT(DOB, 'MMdd')
            THEN 1
            ELSE 0
          END
    FROM Patients
    WHERE PatientID = @PatientID;

    RETURN @Age;
END;
GO
SELECT dbo.fn_GetPatientAge(2) AS Age;
/*
    Create a scalar function called fn_CalculateNetBill that accepts a consultation charge,
    medicine charge, lab charge, and insurance coverage percentage (pass 0 if no insurance applies)
    and returns the final payable amount after applying the insurance discount and the correct GST
    rates. Demonstrate its use by calling it in a SELECT on your billing data and verifying the result
    matches your stored totals. 
*/

CREATE OR ALTER FUNCTION fn_CalculateNetBill
(
    @Consult DECIMAL(12,2),
    @Med DECIMAL(12,2),
    @Lab DECIMAL(12,2),
    @InsurancePercent DECIMAL(5,2)
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @MedDiscount DECIMAL(12,2);
    DECLARE @LabDiscount DECIMAL(12,2);
    DECLARE @GST DECIMAL(12,2);

    -- Insurance applies only on Med + Lab (proportionally)
    SET @MedDiscount = @Med * (@InsurancePercent / 100.0);
    SET @LabDiscount = @Lab * (@InsurancePercent / 100.0);

    -- GST after insurance
    SET @GST = (@Med - @MedDiscount) * 0.05
             + (@Lab - @LabDiscount) * 0.12;

    RETURN
        @Consult
        + (@Med - @MedDiscount)
        + (@Lab - @LabDiscount)
        + @GST;
END;
GO

SELECT dbo.fn_CalculateNetBill(1000, 5000, 3000, 20) AS Bill;

SELECT 
    BillID,
    FinalAmount AS StoredAmount,
    dbo.fn_CalculateNetBill(
        ConsultationCharge,
        MedicineCharge,
        LabCharge,
        (SELECT InsuranceCoveragePercent 
         FROM Patients p
         JOIN Appointments a ON p.PatientID = a.PatientID
         WHERE a.AppointmentID = b.AppointmentID)
    ) AS CalculatedAmount
FROM Billing b;


/*
    Write a query that returns the top 3 revenue-generating doctors within each department. Show
    the department name, doctor name, total revenue, and their rank within the department.
    Doctors with no completed appointments must not appear
*/

-- D1 Top 3 Doctors per Department by Revenue

WITH DoctorRevenue AS 
(
    SELECT 
        dep.DepartmentName,
        d.DoctorName,
        SUM(b.FinalAmount) AS Revenue,
        RANK() OVER (
            PARTITION BY dep.DepartmentName
            ORDER BY SUM(b.FinalAmount) DESC
        ) AS RankInDept
    FROM Billing b
    JOIN Appointments a 
        ON b.AppointmentID = a.AppointmentID
    JOIN Doctors d 
        ON a.DoctorID = d.DoctorID
    JOIN Departments dep 
        ON d.DepartmentID = dep.DepartmentID
    WHERE a.Status = 'Completed'
    GROUP BY dep.DepartmentName, d.DoctorName
)

SELECT 
    DepartmentName,
    DoctorName,
    Revenue,
    RankInDept
FROM DoctorRevenue
WHERE RankInDept <= 3
ORDER BY DepartmentName, RankInDept;


/*
    Write a query that shows, for each calendar month, the total revenue collected and a running
    cumulative total from the earliest month in the data up to that month. Order the results
    chronologically and display the month in a readable format — for example, Jan 2024. 
*/
-- D2 Running Monthly Revenue Total

-- D2 Running Monthly Revenue Total

WITH MonthlyRevenue AS
(
    SELECT 
        DATEFROMPARTS(YEAR(a.AppointmentDate),
                      MONTH(a.AppointmentDate), 1) AS MonthStart,
        SUM(b.FinalAmount) AS Revenue
    FROM Billing b
    JOIN Appointments a 
        ON b.AppointmentID = a.AppointmentID
    GROUP BY DATEFROMPARTS(YEAR(a.AppointmentDate),
                           MONTH(a.AppointmentDate), 1)
)

SELECT 
    FORMAT(MonthStart, 'MMM yyyy') AS Month,
    Revenue,
    SUM(Revenue) OVER (ORDER BY MonthStart) AS RunningTotal
FROM MonthlyRevenue
ORDER BY MonthStart;


/*
    Create the following database roles and assign permissions using GRANT, DENY, and REVOKE. No
    role should have broader access than what is listed. Where a role needs patient information but should
    not see all columns, create a View that exposes only the required fields — grant access to the View, not
    the base table. 
*/

CREATE ROLE db_receptionist;
CREATE ROLE db_doctor;
CREATE ROLE db_lab_tech;
CREATE ROLE db_billing;
CREATE ROLE db_admin;
GO
-- Example permissions
GRANT SELECT, INSERT ON Patients TO db_receptionist;
GRANT SELECT, INSERT ON Appointments TO db_receptionist;

DENY SELECT ON Billing TO db_receptionist;

-- Admin
GRANT CONTROL ON DATABASE::hospital_hrishi TO db_admin;

use hospital_hrishi;
GO