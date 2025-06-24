-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 23, 2025 at 03:57 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

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
(11, 14, 11, '2024-03-11'),
(12, 19, 12, '2024-03-12'),
(13, 21, 13, '2024-03-13'),
(14, 26, 14, '2024-03-14'),
(16, 17, 16, '2024-03-16'),
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
(11, 'Product Launch', 6000.00, 11, 'Iñigo Tomas Mendoza', '2025-06-09'),
(12, 'Fundraising Event', 6500.00, 12, 'Maria Isabel Flores', '2025-06-10'),
(13, 'Sports Event', 7000.00, 13, 'Rosa Clarita Domingo', '2025-06-11'),
(14, 'Award Ceremony', 7500.00, 14, 'Ligaya Celeste Morales', '2025-06-12'),
(16, 'Anniversary Celebration', 8500.00, 16, 'Mayumi Andrea Torres', '2025-06-14'),
(19, 'Networking Event', 10000.00, 19, 'Luningning Faye Castillo', '2025-06-17'),
(20, 'Community Event', 11000.00, 20, 'Teresa Juliana Manalo', '2025-05-21'),
(40, '3asd', 332.00, 1, 'Bituin Serena Robles', '2025-06-21'),
(42, '18th Birthday', 18000.00, 1, 'Joyce F', '2025-06-21'),
(45, 'test', 1000.00, 1, 'tester', '2025-06-10');

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
(11, '2025-06-08', '3', 350.00, '2025-06-21', 350.00, '2025-06-21', 1, 42),
(14, '2025-06-10', 'test', 100.00, '2025-06-10', 100.00, '2025-06-10', 1, 45),
(15, '2025-06-10', 'test', 1000.00, '2025-08-10', 1000.00, '2025-08-10', 1, 40),
(16, '2025-06-23', 'Transport', 200.00, '2025-06-30', 200.00, '2025-06-23', 1, 20);

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
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(16, 16),
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
(11, 11, 'user11', '$2b$10$dzdC0By.gCPEOD9qf31A3e71uGmZLEK/6UBnjBGBIaDLvlLAj6Ori', 'Inactive'),
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
(42, 1, 'Saturday, June 7, 2025 at 03:42:45 PM'),
(49, 1, 'Saturday, June 7, 2025 at 09:13:29 PM'),
(50, 1, 'Saturday, June 7, 2025 at 09:17:18 PM'),
(51, 1, 'Saturday, June 7, 2025 at 09:45:51 PM'),
(52, 1, 'Saturday, June 7, 2025 at 10:06:16 PM'),
(53, 1, 'Saturday, June 7, 2025 at 10:10:51 PM'),
(54, 1, 'Sunday, June 8, 2025 at 12:51:51 AM'),
(55, 1, 'Sunday, June 8, 2025 at 01:49:42 AM'),
(56, 1, 'Sunday, June 8, 2025 at 02:00:32 AM'),
(57, 1, 'Sunday, June 8, 2025 at 02:17:21 AM'),
(58, 1, 'Sunday, June 8, 2025 at 03:07:14 AM'),
(59, 1, 'Sunday, June 8, 2025 at 03:08:41 AM'),
(60, 1, 'Sunday, June 8, 2025 at 03:12:47 AM'),
(61, 1, 'Sunday, June 8, 2025 at 03:20:08 AM'),
(62, 1, 'Sunday, June 8, 2025 at 10:59:03 AM'),
(63, 1, 'Sunday, June 8, 2025 at 06:06:03 PM'),
(64, 1, 'Sunday, June 8, 2025 at 07:49:31 PM'),
(65, 1, 'Sunday, June 8, 2025 at 09:58:55 PM'),
(66, 1, 'Sunday, June 8, 2025 at 10:02:17 PM'),
(67, 1, 'Sunday, June 8, 2025 at 10:07:16 PM'),
(68, 1, 'Sunday, June 8, 2025 at 10:10:07 PM'),
(69, 1, 'Sunday, June 8, 2025 at 10:14:25 PM'),
(70, 1, 'Sunday, June 8, 2025 at 10:15:14 PM'),
(71, 1, 'Sunday, June 8, 2025 at 10:17:37 PM'),
(72, 1, 'Sunday, June 8, 2025 at 10:18:56 PM'),
(73, 1, 'Sunday, June 8, 2025 at 10:25:03 PM'),
(74, 1, 'Sunday, June 8, 2025 at 10:29:58 PM'),
(75, 1, 'Sunday, June 8, 2025 at 10:58:15 PM'),
(76, 1, 'Sunday, June 8, 2025 at 10:59:17 PM'),
(77, 1, 'Sunday, June 8, 2025 at 11:06:57 PM'),
(78, 1, 'Sunday, June 8, 2025 at 11:07:25 PM'),
(79, 1, 'Sunday, June 8, 2025 at 11:23:40 PM'),
(80, 1, 'Sunday, June 8, 2025 at 11:28:33 PM'),
(81, 1, 'Sunday, June 8, 2025 at 11:32:08 PM'),
(82, 1, 'Sunday, June 8, 2025 at 11:32:41 PM'),
(83, 1, 'Monday, June 9, 2025 at 04:37:12 PM'),
(84, 1, 'Monday, June 9, 2025 at 06:29:43 PM'),
(85, 1, 'Monday, June 9, 2025 at 11:54:02 PM'),
(86, 1, 'Tuesday, June 10, 2025 at 12:00:42 AM'),
(87, 1, 'Tuesday, June 10, 2025 at 12:02:47 AM'),
(88, 1, 'Tuesday, June 10, 2025 at 11:27:00 AM'),
(89, 1, 'Tuesday, June 10, 2025 at 11:27:12 AM'),
(90, 1, 'Tuesday, June 10, 2025 at 11:45:01 AM'),
(91, 1, 'Tuesday, June 10, 2025 at 09:40:43 PM'),
(92, 1, 'Tuesday, June 10, 2025 at 09:45:03 PM'),
(93, 1, 'Tuesday, June 10, 2025 at 09:58:22 PM'),
(94, 1, 'Tuesday, June 10, 2025 at 10:09:55 PM'),
(95, 1, 'Tuesday, June 10, 2025 at 10:13:52 PM'),
(96, 1, 'Tuesday, June 10, 2025 at 10:44:20 PM'),
(97, 11, 'Tuesday, June 10, 2025 at 10:54:53 PM'),
(98, 1, 'Tuesday, June 10, 2025 at 10:54:59 PM'),
(99, 12, 'Tuesday, June 10, 2025 at 10:56:10 PM'),
(100, 1, 'Tuesday, June 10, 2025 at 11:20:58 PM'),
(101, 1, 'Monday, June 16, 2025 at 08:50:10 PM'),
(102, 1, 'Monday, June 16, 2025 at 08:50:10 PM'),
(103, 1, 'Wednesday, June 18, 2025 at 10:12:45 PM'),
(104, 1, 'Wednesday, June 18, 2025 at 10:14:42 PM'),
(105, 14, 'Wednesday, June 18, 2025 at 10:15:00 PM'),
(106, 1, 'Sunday, June 22, 2025 at 05:39:16 PM'),
(107, 1, 'Monday, June 23, 2025 at 06:34:40 PM');

-- --------------------------------------------------------

--
-- Table structure for table `members`
--

CREATE TABLE `members` (
  `member_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `role` varchar(50) NOT NULL,
  `status` enum('Active','Inactive') NOT NULL DEFAULT 'Active',
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `members`
--

INSERT INTO `members` (`member_id`, `name`, `role`, `status`, `description`, `created_at`, `updated_at`) VALUES
(17, 'sdas', 'rar', 'Active', 'sad', '2025-06-08 05:11:18', '2025-06-08 14:05:19'),
(18, 'zd', 'sd', 'Active', 'DS', '2025-06-08 05:31:06', '2025-06-08 05:31:06'),
(19, 'Kryz Gray', 'Colorguard', 'Inactive', 'available', '2025-06-08 07:01:52', '2025-06-10 14:12:58'),
(20, 'dgd', 'fu', 'Active', 'uygu', '2025-06-10 14:13:04', '2025-06-23 10:44:04'),
(21, 'Allan Dela Cruz', 'Instrumentalist', 'Active', 'Available every weekends', '2025-06-23 10:43:50', '2025-06-23 10:43:50');

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
(11, 11, 'Manager'),
(12, 12, 'Coordinator'),
(13, 13, 'Supervisor'),
(14, 14, 'Lead'),
(16, 16, 'Administrator'),
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
(14, 17, '2025-06-21', 'Cash', 3.00, 'Partial', 0.00, '2025-06-21', 1, 'uploads\\receipt-1749318123580-443136621.JPG'),
(15, 18, '2025-06-08', 'Cash', 10000.00, 'Full', 0.00, '2025-06-08', 1, 'uploads\\receipt-1749465130404-433037694.jpg'),
(16, 19, '2025-06-10', 'Cash', 323.00, 'Full', 0.00, '2025-06-10', 1, 'uploads\\receipt-1749527164671-915268999.jpg'),
(18, 21, '2025-06-10', '', 1000.00, 'Full', 0.00, '2025-06-10', 1, 'uploads\\receipt-1749564682593-54013128.jpg');

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
(11, 'Thomas', 'Rodriguez', '09223456789'),
(12, 'Jessica', 'Wilson', '09334567890'),
(13, 'William', 'Taylor', '09445678901'),
(14, 'Patricia', 'Anderson', '09556789012'),
(16, 'Elizabeth', 'Jackson', '09778901234'),
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
(11, 11, 11),
(12, 12, 12),
(13, 13, 13),
(14, 14, 14),
(16, 16, 16),
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
(17, 42, '3', 18000.00, 3.00, 3, 5999.00, 1),
(18, 19, 'hotel', 10000.00, 3000.00, 20, 350.00, 1),
(19, 40, 'hotel', 332.00, 20.00, 10, 31.20, 1),
(21, 45, 'test', 1000.00, 200.00, 20, 40.00, 1),
(22, 16, 'hotel', 8500.00, 500.00, 20, 400.00, 1);

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
-- Indexes for table `members`
--
ALTER TABLE `members`
  ADD PRIMARY KEY (`member_id`);

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
  MODIFY `EventTypeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=46;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `ExpenseID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=108;

--
-- AUTO_INCREMENT for table `members`
--
ALTER TABLE `members`
  MODIFY `member_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `officer`
--
ALTER TABLE `officer`
  MODIFY `OfficerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `payment`
--
ALTER TABLE `payment`
  MODIFY `PaymentID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

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
  MODIFY `RevenueID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

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
-- Constraints for table `login_history`
--
ALTER TABLE `login_history`
  ADD CONSTRAINT `login_history_ibfk_1` FOREIGN KEY (`LoginID`) REFERENCES `login` (`LoginID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
