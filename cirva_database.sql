-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 07, 2025 at 08:18 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `cirva_database`
--

-- --------------------------------------------------------

--
-- Table structure for table `attendance`
--

CREATE TABLE `attendance` (
  `AttendanceID` int(11) NOT NULL,
  `NumberOfMembers` int(11) NOT NULL,
  `EventTypeID` int(11) NOT NULL,
  `date` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `attendance`
--

INSERT INTO `attendance` (`AttendanceID`, `NumberOfMembers`, `EventTypeID`, `date`) VALUES
(2, 15, 2, '2024-03-02'),
(3, 20, 3, '2024-03-03'),
(6, 25, 6, '2024-03-06'),
(7, 30, 7, '2024-03-07'),
(8, 22, 8, '2024-03-08'),
(9, 16, 9, '2024-03-09'),
(10, 28, 10, '2024-03-10'),
(11, 14, 11, '2024-03-11'),
(12, 19, 12, '2024-03-12'),
(13, 21, 13, '2024-03-13'),
(14, 26, 14, '2024-03-14'),
(16, 17, 16, '2024-03-16'),
(17, 23, 17, '2024-03-17'),
(18, 27, 18, '2024-03-18'),
(19, 29, 19, '2024-03-19'),
(21, 29, 19, '2024-03-19'),
(22, 31, 20, '2024-03-20');

-- --------------------------------------------------------

--
-- Table structure for table `eventtype`
--

CREATE TABLE `eventtype` (
  `EventTypeID` int(11) NOT NULL,
  `EventName` varchar(100) NOT NULL,
  `amount_given` decimal(10,2) DEFAULT NULL,
  `incharge` int(11) DEFAULT NULL,
  `customer_incharge` text NOT NULL,
  `event_date` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `eventtype`
--

INSERT INTO `eventtype` (`EventTypeID`, `EventName`, `amount_given`, `incharge`, `customer_incharge`, `event_date`) VALUES
(2, 'Wedding', 1500.00, 1, 'Jose Rafael Cruz', '2025-06-24'),
(3, 'Corporate Event', 2000.00, 3, 'Juan Miguel Santos', '2025-06-25'),
(6, 'Charity Event', 3500.00, 6, 'Ramon Eliseo Garcia', '2025-06-03'),
(7, 'Music Competition', 4000.00, 7, 'Emmanuel Jose Bautista', '2025-06-05'),
(8, 'School Event', 4500.00, 8, 'Miguel Alfonso Reyes', '2025-06-04'),
(9, 'Religious Event', 5000.00, 9, 'Alon Gabriel Navarro', '2025-06-07'),
(10, 'Private Gathering', 5500.00, 10, 'Bayani Ernesto Salazar', '2025-06-08'),
(11, 'Product Launch', 6000.00, 11, 'Iñigo Tomas Mendoza', '2025-06-09'),
(12, 'Fundraising Event', 6500.00, 12, 'Maria Isabel Flores', '2025-06-10'),
(13, 'Sports Event', 7000.00, 13, 'Rosa Clarita Domingo', '2025-06-11'),
(14, 'Award Ceremony', 7500.00, 14, 'Ligaya Celeste Morales', '2025-06-12'),
(16, 'Anniversary Celebration', 8500.00, 16, 'Mayumi Andrea Torres', '2025-06-14'),
(17, 'Cultural Night', 9000.00, 17, 'Amihan Lucia Vergara', '2025-06-15'),
(18, 'Club Event', 9500.00, 18, 'Dalisay Regina Aquino', '2025-06-16'),
(19, 'Networking Event', 10000.00, 19, 'Luningning Faye Castillo', '2025-06-17'),
(20, 'Community Event', 11000.00, 20, 'Teresa Juliana Manalo', '2025-05-21'),
(37, '3', 3.00, 3, 'Alona Patrice Hidalgo', '2025-06-14'),
(40, '3asd', 332.00, 1, 'Bituin Serena Robles', '2025-06-21'),
(41, '3', 3.00, 1, 'Tala Dominique Cruzado', '2025-06-27'),
(42, '18th Birthday', 18000.00, 1, 'Joyce F', '2025-06-21'),
(43, '3', 3.00, 1, '3', '2025-06-07');

-- --------------------------------------------------------

--
-- Table structure for table `expenses`
--

CREATE TABLE `expenses` (
  `ExpenseID` int(11) NOT NULL,
  `DateEncoded` date NOT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `Amount` decimal(10,2) NOT NULL,
  `DateUsed` date DEFAULT NULL,
  `AmountGiven` decimal(10,2) DEFAULT NULL,
  `DateGiven` date DEFAULT NULL,
  `OfficerID` int(11) DEFAULT NULL,
  `EventTypeID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `expenses`
--

INSERT INTO `expenses` (`ExpenseID`, `DateEncoded`, `Description`, `Amount`, `DateUsed`, `AmountGiven`, `DateGiven`, `OfficerID`, `EventTypeID`) VALUES
(8, '2025-06-07', 'Transpo', 1000.00, '2025-05-20', 1000.00, '2025-05-20', 1, 20),
(11, '2025-06-08', '3', 3.00, '2025-12-01', 23.00, '2025-12-01', 1, 42),
(12, '2025-06-08', '3', 3.00, '2025-12-01', 3.00, '2025-12-01', 1, 41);

-- --------------------------------------------------------

--
-- Table structure for table `incharge`
--

CREATE TABLE `incharge` (
  `InchargeID` int(11) NOT NULL,
  `PersonID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `incharge`
--

INSERT INTO `incharge` (`InchargeID`, `PersonID`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20),
(25, 25),
(26, 26),
(27, 27),
(28, 28);

-- --------------------------------------------------------

--
-- Table structure for table `login`
--

CREATE TABLE `login` (
  `LoginID` int(11) NOT NULL,
  `OfficerID` int(11) DEFAULT NULL,
  `Username` varchar(255) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `Status` varchar(20) NOT NULL DEFAULT 'Active'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `login`
--

INSERT INTO `login` (`LoginID`, `OfficerID`, `Username`, `Password`, `Status`) VALUES
(1, 1, 'user1', '$2b$10$9SFbXBVV1.RL.M0KAknwx.0YIwW847aNuWP3dQ.9JFJDtdU26uqBi', 'Active'),
(2, 2, 'user2', '$2b$10$mDHNGyyLSkokN.rVb3h7a.P7s3FG1fNN0u2cN4.wMFoDAtiYaKJH2', 'Inactive'),
(3, 3, 'user3', '$2b$10$wrF4s.OKu9tctb77DC4p4ebrW1TbOUlGliqx1/isrwocT86BF8EB6', 'Active'),
(6, 6, 'user6', '$2b$10$omuWyHGQorRLO5Wnb3de5epWD7QybhxssNUz0/sVYrrfLkEWpSPv.', 'Active'),
(7, 7, 'user7', '$2b$10$MFf83wasZVk03OK5y6OCh.8WGGuDvooE2OBHB8OaEp/cNDetDpgDG', 'Active'),
(8, 8, 'user8', '$2b$10$mHSZJLtE2UmT/IQe5uUlMeijTucXU/HjnVs5iuVA5jDnFAI6psBFq', 'Active'),
(9, 9, 'user9', '$2b$10$CgLITH0tmF2FjLPaH5QIE.u2p6zY9t2pHHOUPgXDOWNynUZjrNzei', 'Active'),
(10, 10, 'user10', '$2b$10$kyqpJARKDLfPHg3Ob/CJM.tL/JIsA.9.JyEK.TSAY91/7ocBPzlyy', 'Active'),
(11, 11, 'user11', '$2b$10$dzdC0By.gCPEOD9qf31A3e71uGmZLEK/6UBnjBGBIaDLvlLAj6Ori', 'Active'),
(12, 12, 'user12', '$2b$10$4CQ2xvmula5zJtX9UDOb0OmPmO/7yl6oe331FI5nQ.Q7bX1VAPn8.', 'Active'),
(13, 13, 'user13', '$2b$10$Kdfdony4azJA3P0HhGTzZ.XEW0UXS13GEULX/u1jB0MRqXpcCvdfy', 'Active'),
(14, 14, 'user14', '$2b$10$/Uh3f5Vn5rVdse7cT3XDcenpdhacyFnc7bfuOej2zl1IQ2ubtwsym', 'Active'),
(33, 0, '0', '0', 'Active');

-- --------------------------------------------------------

--
-- Table structure for table `login_history`
--

CREATE TABLE `login_history` (
  `id` int(11) NOT NULL,
  `LoginID` int(11) NOT NULL,
  `login_time` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `login_history`
--

INSERT INTO `login_history` (`id`, `LoginID`, `login_time`) VALUES
(12, 1, 'Monday, June 2, 2025 at 03:20:35 AM'),
(37, 1, 'Saturday, June 7, 2025 at 03:28:03 PM'),
(38, 1, 'Saturday, June 7, 2025 at 03:40:03 PM'),
(39, 1, 'Saturday, June 7, 2025 at 03:41:20 PM'),
(40, 1, 'Saturday, June 7, 2025 at 03:41:46 PM'),
(41, 2, 'Saturday, June 7, 2025 at 03:42:10 PM'),
(42, 1, 'Saturday, June 7, 2025 at 03:42:45 PM'),
(49, 1, 'Saturday, June 7, 2025 at 09:13:29 PM'),
(50, 1, 'Saturday, June 7, 2025 at 09:17:18 PM'),
(51, 1, 'Saturday, June 7, 2025 at 09:45:51 PM'),
(52, 1, 'Saturday, June 7, 2025 at 10:06:16 PM'),
(53, 1, 'Saturday, June 7, 2025 at 10:10:51 PM'),
(54, 1, 'Sunday, June 8, 2025 at 12:51:51 AM'),
(55, 1, 'Sunday, June 8, 2025 at 01:49:42 AM'),
(56, 1, 'Sunday, June 8, 2025 at 02:00:32 AM'),
(57, 1, 'Sunday, June 8, 2025 at 02:17:21 AM');

-- --------------------------------------------------------

--
-- Table structure for table `officer`
--

CREATE TABLE `officer` (
  `OfficerID` int(11) NOT NULL,
  `PersonID` int(11) DEFAULT NULL,
  `RoleDescription` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `officer`
--

INSERT INTO `officer` (`OfficerID`, `PersonID`, `RoleDescription`) VALUES
(1, 1, 'Manager'),
(2, 2, 'Assistant'),
(3, 3, 'Coordinator'),
(4, 4, 'Supervisor'),
(6, 6, 'Secretary'),
(7, 7, 'Lead'),
(8, 8, 'Officer'),
(9, 9, 'Director'),
(10, 10, 'Assistant'),
(11, 11, 'Manager'),
(12, 12, 'Coordinator'),
(13, 13, 'Supervisor'),
(14, 14, 'Lead'),
(16, 16, 'Administrator'),
(17, 17, 'Officer'),
(18, 18, 'Director'),
(19, 19, 'Assistant'),
(20, 20, 'Coordinator'),
(25, 25, 'new'),
(26, 26, '3'),
(27, 27, 'gg'),
(28, 28, '3');

-- --------------------------------------------------------

--
-- Table structure for table `payment`
--

CREATE TABLE `payment` (
  `PaymentID` int(11) NOT NULL,
  `RevenueID` int(11) DEFAULT NULL,
  `PaymentDate` date NOT NULL,
  `ModeOfPayment` enum('Cash','Gcash','Bank') NOT NULL,
  `AmountPaid` decimal(10,2) NOT NULL,
  `Remarks` enum('Full','Partial') NOT NULL,
  `Balance` decimal(10,2) DEFAULT NULL,
  `DateReceived` date DEFAULT NULL,
  `OfficerID` int(11) DEFAULT NULL,
  `receipt_src` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `payment`
--

INSERT INTO `payment` (`PaymentID`, `RevenueID`, `PaymentDate`, `ModeOfPayment`, `AmountPaid`, `Remarks`, `Balance`, `DateReceived`, `OfficerID`, `receipt_src`) VALUES
(10, 15, '2025-05-20', 'Cash', 20000.00, 'Full', 0.00, '2025-05-20', 1, 'uploads\\receipt-1749302422285-570666116.JPG'),
(11, 15, '2025-06-20', 'Cash', 3333.00, 'Partial', 0.00, '2025-06-05', 1, 'uploads/receipt-1749304428568-989772494.png'),
(14, 17, '2025-06-21', 'Cash', 3.00, 'Partial', 0.00, '2025-06-21', 1, 'uploads\\receipt-1749318123580-443136621.JPG');

-- --------------------------------------------------------

--
-- Table structure for table `person`
--

CREATE TABLE `person` (
  `PersonID` int(11) NOT NULL,
  `FirstName` varchar(50) NOT NULL,
  `LastName` varchar(50) NOT NULL,
  `ContactNumber` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `person`
--

INSERT INTO `person` (`PersonID`, `FirstName`, `LastName`, `ContactNumber`) VALUES
(1, 'John', 'Doe', '09123456789'),
(2, 'Jane', 'Smith', '09234567890'),
(3, 'Michael', 'Johnson', '09345678901'),
(4, 'Emily', 'Williams', '09456789012'),
(6, 'Sarah', 'Jones', '09678901234'),
(7, 'James', 'Miller', '09789012345'),
(8, 'Laura', 'Davis', '09890123456'),
(9, 'Robert', 'Garcia', '09901234567'),
(10, 'Linda', 'Martinez', '09112345678'),
(11, 'Thomas', 'Rodriguez', '09223456789'),
(12, 'Jessica', 'Wilson', '09334567890'),
(13, 'William', 'Taylor', '09445678901'),
(14, 'Patricia', 'Anderson', '09556789012'),
(16, 'Elizabeth', 'Jackson', '09778901234'),
(17, 'Daniel', 'White', '09889012345'),
(18, 'Helen', 'Harris', '09990123456'),
(19, 'Christopher', 'Martin', '09101234567'),
(20, 'Nancy', 'Lee', '09212345678'),
(25, 'New', 'new', '2'),
(26, '3', '3', '3'),
(27, 'gg', 'gg', '09'),
(28, '3', '3', '3');

-- --------------------------------------------------------

--
-- Table structure for table `recordkeeper`
--

CREATE TABLE `recordkeeper` (
  `KeeperID` int(11) NOT NULL,
  `PersonID` int(11) DEFAULT NULL,
  `OfficerID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `recordkeeper`
--

INSERT INTO `recordkeeper` (`KeeperID`, `PersonID`, `OfficerID`) VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(6, 6, 6),
(7, 7, 7),
(8, 8, 8),
(9, 9, 9),
(10, 10, 10),
(11, 11, 11),
(12, 12, 12),
(13, 13, 13),
(14, 14, 14),
(16, 16, 16),
(17, 17, 17),
(18, 18, 18),
(19, 19, 19),
(20, 20, 20),
(25, 25, 25),
(26, 26, 26),
(27, 27, 27),
(28, 28, 28);

-- --------------------------------------------------------

--
-- Table structure for table `revenues`
--

CREATE TABLE `revenues` (
  `RevenueID` int(11) NOT NULL,
  `EventTypeID` int(11) DEFAULT NULL,
  `Description` varchar(255) DEFAULT NULL,
  `AmountGiven` decimal(10,2) NOT NULL,
  `BandShare` decimal(10,2) DEFAULT NULL,
  `NumberOfMembers` int(11) NOT NULL,
  `MembersTalentFee` decimal(10,2) DEFAULT NULL,
  `KeeperID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `revenues`
--

INSERT INTO `revenues` (`RevenueID`, `EventTypeID`, `Description`, `AmountGiven`, `BandShare`, `NumberOfMembers`, `MembersTalentFee`, `KeeperID`) VALUES
(15, 20, '3', 11000.00, 324.00, 3, 3558.67, 1),
(17, 42, '3', 18000.00, 3.00, 3, 5999.00, 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `attendance`
--
ALTER TABLE `attendance`
  ADD PRIMARY KEY (`AttendanceID`),
  ADD KEY `EventTypeID` (`EventTypeID`);

--
-- Indexes for table `eventtype`
--
ALTER TABLE `eventtype`
  ADD PRIMARY KEY (`EventTypeID`);

--
-- Indexes for table `expenses`
--
ALTER TABLE `expenses`
  ADD PRIMARY KEY (`ExpenseID`),
  ADD KEY `OfficerID` (`OfficerID`),
  ADD KEY `fk_EventType` (`EventTypeID`);

--
-- Indexes for table `incharge`
--
ALTER TABLE `incharge`
  ADD PRIMARY KEY (`InchargeID`),
  ADD KEY `PersonID` (`PersonID`);

--
-- Indexes for table `login`
--
ALTER TABLE `login`
  ADD PRIMARY KEY (`LoginID`),
  ADD KEY `OfficerID` (`OfficerID`);

--
-- Indexes for table `login_history`
--
ALTER TABLE `login_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `LoginID` (`LoginID`);

--
-- Indexes for table `officer`
--
ALTER TABLE `officer`
  ADD PRIMARY KEY (`OfficerID`),
  ADD KEY `PersonID` (`PersonID`);

--
-- Indexes for table `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`PaymentID`),
  ADD KEY `RevenueID` (`RevenueID`),
  ADD KEY `OfficerID` (`OfficerID`);

--
-- Indexes for table `person`
--
ALTER TABLE `person`
  ADD PRIMARY KEY (`PersonID`);

--
-- Indexes for table `recordkeeper`
--
ALTER TABLE `recordkeeper`
  ADD PRIMARY KEY (`KeeperID`),
  ADD KEY `PersonID` (`PersonID`),
  ADD KEY `OfficerID` (`OfficerID`);

--
-- Indexes for table `revenues`
--
ALTER TABLE `revenues`
  ADD PRIMARY KEY (`RevenueID`),
  ADD KEY `EventTypeID` (`EventTypeID`),
  ADD KEY `KeeperID` (`KeeperID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `attendance`
--
ALTER TABLE `attendance`
  MODIFY `AttendanceID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `eventtype`
--
ALTER TABLE `eventtype`
  MODIFY `EventTypeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `ExpenseID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `incharge`
--
ALTER TABLE `incharge`
  MODIFY `InchargeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `login`
--
ALTER TABLE `login`
  MODIFY `LoginID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `login_history`
--
ALTER TABLE `login_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- AUTO_INCREMENT for table `officer`
--
ALTER TABLE `officer`
  MODIFY `OfficerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `payment`
--
ALTER TABLE `payment`
  MODIFY `PaymentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `person`
--
ALTER TABLE `person`
  MODIFY `PersonID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `recordkeeper`
--
ALTER TABLE `recordkeeper`
  MODIFY `KeeperID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `revenues`
--
ALTER TABLE `revenues`
  MODIFY `RevenueID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `attendance`
--
ALTER TABLE `attendance`
  ADD CONSTRAINT `attendance_ibfk_1` FOREIGN KEY (`EventTypeID`) REFERENCES `eventtype` (`EventTypeID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `expenses`
--
ALTER TABLE `expenses`
  ADD CONSTRAINT `expenses_ibfk_3` FOREIGN KEY (`OfficerID`) REFERENCES `officer` (`OfficerID`),
  ADD CONSTRAINT `fk_EventType` FOREIGN KEY (`EventTypeID`) REFERENCES `eventtype` (`EventTypeID`);

--
-- Constraints for table `incharge`
--
ALTER TABLE `incharge`
  ADD CONSTRAINT `incharge_ibfk_1` FOREIGN KEY (`PersonID`) REFERENCES `person` (`PersonID`);

--
-- Constraints for table `login`
--
ALTER TABLE `login`
  ADD CONSTRAINT `login_ibfk_1` FOREIGN KEY (`OfficerID`) REFERENCES `officer` (`OfficerID`);

--
-- Constraints for table `login_history`
--
ALTER TABLE `login_history`
  ADD CONSTRAINT `login_history_ibfk_1` FOREIGN KEY (`LoginID`) REFERENCES `login` (`LoginID`);

--
-- Constraints for table `officer`
--
ALTER TABLE `officer`
  ADD CONSTRAINT `officer_ibfk_1` FOREIGN KEY (`PersonID`) REFERENCES `person` (`PersonID`);

--
-- Constraints for table `payment`
--
ALTER TABLE `payment`
  ADD CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`RevenueID`) REFERENCES `revenues` (`RevenueID`),
  ADD CONSTRAINT `payment_ibfk_2` FOREIGN KEY (`OfficerID`) REFERENCES `officer` (`OfficerID`);

--
-- Constraints for table `recordkeeper`
--
ALTER TABLE `recordkeeper`
  ADD CONSTRAINT `recordkeeper_ibfk_1` FOREIGN KEY (`PersonID`) REFERENCES `person` (`PersonID`),
  ADD CONSTRAINT `recordkeeper_ibfk_2` FOREIGN KEY (`OfficerID`) REFERENCES `officer` (`OfficerID`);

--
-- Constraints for table `revenues`
--
ALTER TABLE `revenues`
  ADD CONSTRAINT `revenues_ibfk_1` FOREIGN KEY (`EventTypeID`) REFERENCES `eventtype` (`EventTypeID`),
  ADD CONSTRAINT `revenues_ibfk_3` FOREIGN KEY (`KeeperID`) REFERENCES `recordkeeper` (`KeeperID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
