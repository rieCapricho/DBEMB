const express = require("express");
const path = require("path");
const bcrypt = require("bcrypt");
const fs = require('fs');
const db = require("./db");
const multer = require("multer");

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, "public")));

app.use('/uploads', express.static('uploads'));
app.use((req, res, next) => {
    if (req.path.endsWith(".html")) {
        return res.redirect(req.path.replace(".html", ""));
    }
    next();
});



const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, "uploads/");
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1E9);
        const ext = path.extname(file.originalname);
        cb(null, file.fieldname + "-" + uniqueSuffix + ext);
    }
});



const upload = multer({ storage: storage });

app.get("/:page", (req, res, next) => {
    if (req.params.page.includes(".")) return next(); 
    const filePath = path.join(__dirname, "public", `${req.params.page}.html`);
    fs.access(filePath, fs.constants.F_OK, (err) => {
        if (err) {
            return next();
        }
        res.sendFile(filePath, (err) => {
            if (err) {
                res.status(404).send("Page Not Found");
            }
        });
    });
});



// ---------------------- EXPENSES -------------------------------
app.get("/allexpenses", (req, res) => {
   const sql = `
    SELECT e.ExpenseID, e.DateEncoded, e.Description, e.Amount, e.DateUsed, e.AmountGiven, e.DateGiven,
           o.OfficerID, o.RoleDescription,
           ev.EventName, ev.event_date, ev.EventTypeID, ev.customer_incharge
    FROM expenses e
    LEFT JOIN officer o ON e.OfficerID = o.OfficerID
    LEFT JOIN eventtype ev ON e.EventTypeID = ev.EventTypeID
    ORDER BY e.ExpenseID DESC
`;

    
    db.query(sql, (err, results) => {
        if (err) {
            return res.json({ status: "error", message: err.message });
        }
        res.json({ status: "success", data: results });
    });
});

app.post("/addExpense", (req, res) => {
    const { DateEncoded, Description, Amount, DateUsed, AmountGiven, DateGiven, OfficerID, EventID } = req.body;

    if (!DateEncoded || !Description || !Amount || !DateUsed || !AmountGiven || !DateGiven || !OfficerID || !EventID) {
        return res.status(400).json({ success: false, message: "All fields are required." });
    }

    const query = `
        INSERT INTO expenses (DateEncoded, Description, Amount, DateUsed, AmountGiven, DateGiven, OfficerID, EventTypeID) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)`;

    db.query(query, [DateEncoded, Description, Amount, DateUsed, AmountGiven, DateGiven, OfficerID, EventID], (err, result) => {
        if (err) {
            console.error("Error adding expense:", err);
            return res.status(500).json({ success: false, message: "Error adding expense." });
        }

        res.json({ success: true, message: "Expense added successfully!" });
    });
});




app.get('/getmembers', (req, res) => {
  const sql = `
    SELECT 
      p.PersonID,
      CONCAT(p.FirstName, ' ', p.LastName) AS FullName,
      o.RoleDescription AS Role,
      l.Status,
      p.ContactNumber,
      l.Username
    FROM person p
    JOIN officer o ON p.PersonID = o.PersonID
    JOIN login l ON o.OfficerID = l.OfficerID;
  `;

  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});



app.delete('/deletemember/:id', (req, res) => {
  const personId = req.params.id;

  // Step 1: Get OfficerID, KeeperID, and InchargeIDs for the person
  const getIdsSql = `
    SELECT 
      o.OfficerID,
      rk.KeeperID
    FROM person p
    LEFT JOIN officer o ON p.PersonID = o.PersonID
    LEFT JOIN recordkeeper rk ON p.PersonID = rk.PersonID
    WHERE p.PersonID = ?
  `;

  db.query(getIdsSql, [personId], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    if (result.length === 0) return res.status(404).json({ message: 'Member not found' });

    const officerId = result[0].OfficerID;
    const keeperId = result[0].KeeperID;

    // Get all InchargeIDs related to this person
    const getInchargeIdsSql = 'SELECT InchargeID FROM incharge WHERE PersonID = ?';

    db.query(getInchargeIdsSql, [personId], (err, inchargeResults) => {
      if (err) return res.status(500).json({ error: err.message });

      const inchargeIds = inchargeResults.map(r => r.InchargeID);

      // Delete eventtype rows that reference these incharge IDs
      const deleteEventtypes = (callback) => {
        if (inchargeIds.length === 0) return callback();

        const deleteEventtypeSql = 'DELETE FROM eventtype WHERE incharge IN (?)';

        db.query(deleteEventtypeSql, [inchargeIds], (err) => {
          if (err) return res.status(500).json({ error: err.message });
          callback();
        });
      };

      // After eventtype deleted, continue deleting related data
      deleteEventtypes(() => {
        // List of delete queries in order
        const deleteQueries = [
          { sql: 'DELETE FROM login_history WHERE LoginID IN (SELECT LoginID FROM login WHERE OfficerID = ?)', params: [officerId] },
          { sql: 'DELETE FROM login WHERE OfficerID = ?', params: [officerId] },
          { sql: 'DELETE FROM payment WHERE OfficerID = ?', params: [officerId] },
          { sql: 'DELETE FROM expenses WHERE OfficerID = ?', params: [officerId] },
          { sql: 'DELETE FROM revenues WHERE KeeperID = ?', params: [keeperId] },
          { sql: 'DELETE FROM incharge WHERE PersonID = ?', params: [personId] },
          { sql: 'DELETE FROM recordkeeper WHERE PersonID = ?', params: [personId] },
          { sql: 'DELETE FROM recordkeeper WHERE OfficerID = ?', params: [officerId] },
          { sql: 'DELETE FROM recordkeeper WHERE KeeperID = ?', params: [keeperId] },
          { sql: 'DELETE FROM officer WHERE PersonID = ?', params: [personId] },
          { sql: 'DELETE FROM person WHERE PersonID = ?', params: [personId] }
        ];

        // Execute deletes sequentially, skipping if param is null/undefined
        const executeDeletes = (index = 0) => {
          if (index >= deleteQueries.length) {
            return res.json({ message: 'Member deleted successfully.' });
          }

          const { sql, params } = deleteQueries[index];

          if (params.some(p => p === null || p === undefined)) {
            console.log(`Skipping step ${index + 1} due to null param`, sql, params);
            return executeDeletes(index + 1);
          }

          db.query(sql, params, (err) => {
            if (err) {
              console.error(`Error at step ${index + 1}:`, err);
              return res.status(500).json({ error: `Error at step ${index + 1}: ${err.message}` });
            }
            executeDeletes(index + 1);
          });
        };

        executeDeletes();
      });
    });
  });
});




app.get('/expenses-summary/:date', (req, res) => {
  let selectedDate = req.params.date;

  // Sanitize input - remove anything after colon
  selectedDate = selectedDate.split(':')[0];

  if (!/^\d{4}-\d{2}(-\d{2})?$/.test(selectedDate)) {
    return res.status(400).json({ error: 'Invalid date format' });
  }

  const sql = `
    SELECT
      e.DateEncoded,
      et.EventName,
      et.event_date,
      et.customer_incharge,
      e.Description,
      e.Amount,
      e.DateUsed,
      e.AmountGiven,
      e.DateGiven,
      CONCAT(o.RoleDescription, ' ', p.FirstName, ' ', p.LastName) AS OfficerName
    FROM expenses e
    LEFT JOIN eventtype et ON e.EventTypeID = et.EventTypeID
    LEFT JOIN officer o ON e.OfficerID = o.OfficerID
    LEFT JOIN person p ON o.PersonID = p.PersonID
    WHERE et.event_date LIKE ?
    ORDER BY e.DateEncoded DESC
  `;

  db.query(sql, [`${selectedDate}%`], (error, results) => {
    if (error) {
      console.error('DB query error:', error);
      return res.status(500).json({ error: 'Internal server error' });
    }
    res.json(results);
  });
});



app.get('/alleventsforcalendar', (req, res) => {
    const sql = `SELECT EventTypeID, EventName, event_date, incharge, amount_given FROM eventtype`;

    db.query(sql, (err, results) => {
        if (err) {
            console.error('Error fetching events:', err);
            res.status(500).json({ error: 'Database error' });
        } else {
            const events = results.map(row => ({
                EventTypeID: row.EventTypeID,
                EventName: row.EventName,
                EventDate: row.event_date,
                InchargeName: `User ${row.incharge}`, // You can query for user name if needed
                Amount: row.amount_given
            }));
            res.json(events);
        }
    });
});

app.get('/revenues-summary/:date', (req, res) => {
  let selectedDate = req.params.date;

  // Sanitize input - remove anything after colon
  selectedDate = selectedDate.split(':')[0];

  // Simple date format validation: YYYY-MM or YYYY-MM-DD
  if (!/^\d{4}-\d{2}(-\d{2})?$/.test(selectedDate)) {
    return res.status(400).json({ error: 'Invalid date format' });
  }

  const sql = `
    SELECT
      et.EventName,
      et.event_date,
      r.Description,
      r.AmountGiven,
      r.BandShare,
      et.customer_incharge,
      r.MembersTalentFee,
      (r.BandShare + r.MembersTalentFee) AS TotalFee,
      CONCAT(p1.FirstName, ' ', p1.LastName) AS InchargeName,
      CONCAT(p2.FirstName, ' ', p2.LastName) AS KeeperName
    FROM revenues r
    LEFT JOIN eventtype et ON r.EventTypeID = et.EventTypeID
    LEFT JOIN incharge i ON et.incharge = i.InchargeID
    LEFT JOIN person p1 ON i.PersonID = p1.PersonID
    LEFT JOIN recordkeeper rk ON r.KeeperID = rk.KeeperID
    LEFT JOIN person p2 ON rk.PersonID = p2.PersonID
    WHERE et.event_date LIKE ?
  `;

  db.query(sql, [`${selectedDate}%`], (error, results) => {
    if (error) {
      console.error('DB query error:', error);
      return res.status(500).json({ error: 'Internal server error' });
    }

    res.json(results);
  });
});






app.post("/updateExpense", (req, res) => {
    const { ExpenseID, Description, Amount, DateUsed, AmountGiven, DateGiven, OfficerID, EventID } = req.body;

    if (!ExpenseID || !Description || !Amount) {
        return res.status(400).json({ success: false, message: "Expense ID, Description, and Amount are required." });
    }

    const query = `
        UPDATE expenses 
        SET Description = ?, Amount = ?, DateUsed = ?, AmountGiven = ?, DateGiven = ?, OfficerID = ?, EventTypeID = ? 
        WHERE ExpenseID = ?`;

    db.query(query, [Description, Amount, DateUsed, AmountGiven, DateGiven, OfficerID, EventID, ExpenseID], (err, result) => {
        if (err) {
            console.error("Error updating expense:", err);
            return res.status(500).json({ success: false, message: "Error updating expense." });
        }

        res.json({ success: true, message: "Expense updated successfully." });
    });
});

app.delete("/deleteExpense/:expenseId", (req, res) => {
    const expenseId = req.params.expenseId;

    if (!expenseId) {
        return res.status(400).json({ success: false, message: "Expense ID is required." });
    }

    const query = "DELETE FROM expenses WHERE ExpenseID = ?";

    db.query(query, [expenseId], (err, result) => {
        if (err) {
            console.error("Error deleting expense:", err);
            return res.status(500).json({ success: false, message: "Error deleting expense." });
        }

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: "Expense not found." });
        }

        res.json({ success: true, message: "Expense deleted successfully." });
    });
});


// ---------------------- EXPENSES -------------------------------





// ---------------------- USERS -------------------------------
app.get("/allusers", (req, res) => {
    const sql = `
        SELECT p.PersonID, p.FirstName, p.LastName, p.ContactNumber, 
               l.LoginID, l.Username, 
               o.OfficerID, o.RoleDescription
        FROM person p
        LEFT JOIN officer o ON p.PersonID = o.PersonID
        LEFT JOIN login l ON o.OfficerID = l.OfficerID
    `;
    
    db.query(sql, (err, results) => {
        if (err) {
            return res.json({ status: "error", message: err.message });
        }
        res.json({ status: "success", data: results });
    });
});

app.get("/getUser/:id", (req, res) => {
    const userId = req.params.id;

    const query = `
        SELECT p.PersonID, p.FirstName, p.LastName, p.ContactNumber, 
               l.Username, o.RoleDescription
        FROM person p
        LEFT JOIN officer o ON p.PersonID = o.PersonID
        LEFT JOIN login l ON o.OfficerID = l.OfficerID
        WHERE p.PersonID = ?`;

    db.query(query, [userId], (err, results) => {
        if (err) {
            return res.status(500).json({ success: false, message: "Error fetching user data." });
        }

        if (results.length === 0) {
            return res.status(404).json({ success: false, message: "User not found." });
        }

        res.json({ success: true, data: results[0] });
    });
});

app.post("/updateUser", (req, res) => {
    const { PersonID, FirstName, LastName, ContactNumber, RoleDescription, Username } = req.body;

    console.log("📥 Received Update Request:", { PersonID, FirstName, LastName, ContactNumber, RoleDescription, Username }); // Debugging

    if (!PersonID || !FirstName || !LastName || !Username) {
        console.error("❌ Missing required fields:", { PersonID, FirstName, LastName, Username }); // Debugging
        return res.status(400).json({ success: false, message: "All fields are required." });
    }

    const updateUserQuery = `
        UPDATE person p
        JOIN officer o ON p.PersonID = o.PersonID
        JOIN login l ON o.OfficerID = l.OfficerID
        SET p.FirstName = ?, p.LastName = ?, p.ContactNumber = ?, o.RoleDescription = ?, l.Username = ?
        WHERE p.PersonID = ?`;

    db.query(updateUserQuery, [FirstName, LastName, ContactNumber, RoleDescription, Username, PersonID], (err, result) => {
        if (err) {
            console.error("❌ Database Error:", err); // Debugging
            return res.status(500).json({ success: false, message: "Error updating user." });
        }

        console.log("✅ User updated successfully:", result); // Debugging
        res.json({ success: true, message: "User updated successfully." });
    });
});



app.delete("/deleteUser/:id", (req, res) => {
    const userId = req.params.id;

    db.beginTransaction((err) => {
        if (err) {
            return res.status(500).json({ success: false, message: "Transaction error." });
        }

        // Step 1: Delete from login table
        db.query("DELETE FROM login WHERE OfficerID IN (SELECT OfficerID FROM officer WHERE PersonID = ?)", [userId], (err) => {
            if (err) return db.rollback(() => res.status(500).json({ success: false, message: "Error deleting from login." }));

            // Step 2: Delete payments related to the user
            db.query("DELETE FROM payment WHERE OfficerID IN (SELECT OfficerID FROM officer WHERE PersonID = ?)", [userId], (err) => {
                if (err) return db.rollback(() => res.status(500).json({ success: false, message: "Error deleting related payments." }));

                // Step 3: Delete expenses related to the user
                db.query("DELETE FROM expenses WHERE OfficerID IN (SELECT OfficerID FROM officer WHERE PersonID = ?)", [userId], (err) => {
                    if (err) return db.rollback(() => res.status(500).json({ success: false, message: "Error deleting related expenses." }));

                    // Step 4: Delete revenues related to the user
                    db.query("DELETE FROM revenues WHERE InchargeID IN (SELECT OfficerID FROM officer WHERE PersonID = ?)", [userId], (err) => {
                        if (err) return db.rollback(() => res.status(500).json({ success: false, message: "Error deleting related revenues." }));

                        // Step 5: Delete from recordkeeper table
                        db.query("DELETE FROM recordkeeper WHERE PersonID = ?", [userId], (err) => {
                            if (err) return db.rollback(() => res.status(500).json({ success: false, message: "Error deleting from recordkeeper." }));

                            // Step 6: Delete from incharge table
                            db.query("DELETE FROM incharge WHERE PersonID = ?", [userId], (err) => {
                                if (err) return db.rollback(() => res.status(500).json({ success: false, message: "Error deleting from incharge." }));

                                // Step 7: Delete from officer table
                                db.query("DELETE FROM officer WHERE PersonID = ?", [userId], (err) => {
                                    if (err) return db.rollback(() => res.status(500).json({ success: false, message: "Error deleting from officer." }));

                                    // Step 8: Finally, delete from person table
                                    db.query("DELETE FROM person WHERE PersonID = ?", [userId], (err, result) => {
                                        if (err) return db.rollback(() => res.status(500).json({ success: false, message: "Error deleting from person." }));

                                        if (result.affectedRows === 0) {
                                            return db.rollback(() => res.status(404).json({ success: false, message: "User not found." }));
                                        }

                                        db.commit((err) => {
                                            if (err) return db.rollback(() => res.status(500).json({ success: false, message: "Commit error." }));

                                            res.json({ success: true, message: "User deleted successfully." });
                                        });
                                    });
                                });
                            });
                        });
                    });
                });
            });
        });
    });
});

// ---------------------- USERS -------------------------------





// ---------------------- FOR REVENUES AND PAYMENTS -------------------------------
app.post('/updateRevenue', (req, res) => {
    const updatedData = req.body;
    const query = `
        UPDATE revenues 
        SET EventTypeID = ?, Description = ?, AmountGiven = ?, BandShare = ?, MembersTalentFee = ?, KeeperID = ?
        WHERE RevenueID = ?`;
    
    db.query(query, [
        updatedData.EventTypeID,
        updatedData.Description,
        updatedData.AmountGiven,
        updatedData.BandShare,
        updatedData.MembersTalentFee,
        updatedData.KeeperID,
        updatedData.RevenueID
    ], (err, result) => {
        if (err) {
            return res.status(500).json({ success: false, message: "Error updating revenue." });
        }
        res.json({ success: true, message: "Revenue updated successfully." });
    });
});




app.post('/addRevenue', (req, res) => {
    const { eventTypeID, description, amountGiven, bandShare, membersTalentFee, keeperID, new_numofmembers } = req.body;

   

    const query = `
        INSERT INTO revenues (EventTypeID, Description, AmountGiven, BandShare, NumberOfMembers,  MembersTalentFee, KeeperID)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    `;
    
    const values = [ eventTypeID, description, amountGiven, bandShare, new_numofmembers, membersTalentFee, keeperID];

    db.query(query, values, (err, result) => {
        if (err) {
            console.error('Error details:', err); // Log the error for debugging
            return res.status(500).json({ message: 'Error inserting data', error: err.message });
        }

        res.json({ message: 'Revenue data added successfully!' });
    });
});

app.post("/payments/update-payment", (req, res) => {
    const { paymentID, paymentDate, modeOfPayment, amountPaid, remarks, balance, dateReceived, officerID } = req.body;
    
    const sql = `UPDATE payment SET PaymentDate = ?, ModeOfPayment = ?, AmountPaid = ?, Remarks = ?, Balance = ?, DateReceived = ?, OfficerID = ? WHERE PaymentID = ?`;
    const values = [paymentDate, modeOfPayment, amountPaid, remarks, balance, dateReceived, officerID, paymentID];
    
    db.query(sql, values, (err, result) => {
        if (err) {
            return res.json({ status: "error", message: err.message });
        }
        res.json({ status: "success", message: "Payment updated successfully." });
    });
});


app.post('/update-payment', upload.single('receipt'), (req, res) => {
  const {
    paymentID,
    revenueID,
    paymentDate,
    modeOfPayment,
    amountPaid,
    remarks,
    balance,
    dateReceived,
    officerId,
  } = req.body;

  if (!paymentID) {
    return res.status(400).json({ error: 'paymentID is required' });
  }

  // If file uploaded, get filename. Else, keep old receipt_src.
  let receiptFilename = null;
  if (req.file) {
    receiptFilename = 'uploads/' + req.file.filename; // stored file name
  }

  

  // We'll update receipt_src only if file uploaded, else keep old value by ignoring in SQL
  let sql, params;

  if (receiptFilename) {
    sql = `
      UPDATE payment SET
        RevenueID = ?,
        PaymentDate = ?,
        ModeOfPayment = ?,
        AmountPaid = ?,
        Remarks = ?,
        Balance = ?,
        DateReceived = ?,
        OfficerID = ?,
        receipt_src = ?
      WHERE PaymentID = ?
    `;
    params = [
      revenueID || null,
      paymentDate,
      modeOfPayment,
      amountPaid,
      remarks,
      balance || null,
      dateReceived,
      officerId || null,
      receiptFilename,
      paymentID
    ];
  } else {
    // No file uploaded, keep old receipt_src unchanged
    sql = `
      UPDATE payment SET
        RevenueID = ?,
        PaymentDate = ?,
        ModeOfPayment = ?,
        AmountPaid = ?,
        Remarks = ?,
        Balance = ?,
        DateReceived = ?,
        OfficerID = ?
      WHERE PaymentID = ?
    `;
    params = [
      revenueID || null,
      paymentDate,
      modeOfPayment,
      amountPaid,
      remarks,
      balance || null,
      dateReceived,
      officerId || null,
      paymentID
    ];
  }

  db.query(sql, params, (err, result) => {
    if (err) {
      console.error('DB error:', err);
      return res.status(500).json({ error: 'Database error' });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Payment record not found' });
    }

    res.json({ message: 'Payment updated successfully' });
  });
});



app.get("/allrevenues", (req, res) => {
    const query = `
    SELECT 
    r.*, 
    e.EventName, 
    e.event_date,
    e.customer_incharge,
    (r.NumberOfMembers * r.MembersTalentFee) AS TotalFee, -- Calculate TotalFee
    p_keeper.FirstName AS KeeperFirstName,
    p_keeper.LastName AS KeeperLastName,
    p_inc.FirstName AS IncFirstName,
    p_inc.LastName AS IncLastName
FROM revenues r
LEFT JOIN eventtype e ON r.EventTypeID = e.EventTypeID
LEFT JOIN recordkeeper rk ON r.KeeperID = rk.KeeperID
LEFT JOIN incharge inc ON inc.PersonID = e.EventTypeID
LEFT JOIN person p_inc ON p_inc.PersonID = inc.PersonID
LEFT JOIN person p_keeper ON rk.PersonID = p_keeper.PersonID
ORDER BY RevenueID DESC`;



    db.query(query, (err, results) => {
        if (err) {
            console.error("Error fetching revenues:", err);
            return res.status(500).json({ error: "Database error" });
        }
        res.json(results);
    });
});

app.get("/payments/:revenueId", (req, res) => {
    const revenueId = req.params.revenueId;
    const query = `
        SELECT 
            e.*,
            r.*,
            p.*, 
            per.FirstName AS OfficerFirstName, 
            per.LastName AS OfficerLastName
        FROM payment p
        LEFT JOIN officer o ON p.OfficerID = o.OfficerID
        LEFT JOIN person per ON o.PersonID = per.PersonID
        LEFT JOIN revenues r ON r.RevenueID = p.RevenueID
        LEFT JOIN eventtype e ON e.EventTypeID = r.EventTypeID
        WHERE p.RevenueID = ?
        ORDER BY p.PaymentID DESC;
    `;

    db.query(query, [revenueId], (error, results) => {
        if (error) {
            console.error("Error fetching payments:", error);
            return res.status(500).json({ error: "Internal server error" });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: "No payment records found" });
        }

        res.json(results);
    });
});






app.post('/add-payment', upload.single('receipt'), async (req, res) => {
    try {
        const {
            revenueID,
            paymentDate,
            modeOfPayment,
            amountPaid,
            new_remarks,
            balance,
            dateReceived,
            officerId
        } = req.body;

        const receiptFile = req.file;

        if (!receiptFile) {
            return res.status(400).json({ message: 'Proof of payment is required.' });
        }

        const receiptPath = path.join('uploads', receiptFile.filename);
        

        const sql = `
            INSERT INTO payment 
            (RevenueID, PaymentDate, ModeOfPayment, AmountPaid, Remarks, Balance, DateReceived, OfficerID, receipt_src) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;

        const values = [
            revenueID,
            paymentDate,
            modeOfPayment,
            amountPaid,
            new_remarks,
            balance || 0,
            dateReceived,
            officerId,
            receiptPath
        ];

        await db.query(sql, values);

        res.json({ message: 'Payment successfully recorded.' });

    } catch (err) {
        console.error('Error adding payment:', err);
        res.status(500).json({ message: 'Server error adding payment.' });
    }
});





app.get("/get-payment-modes", (req, res) => {
    const query = "SHOW COLUMNS FROM payment LIKE 'ModeOfPayment'";

    db.query(query, (err, results) => {
        if (err) {
            console.error("Error fetching payment modes:", err);
            return res.status(500).json({ error: "Database error" });
        }

        const enumValues = results[0].Type.match(/'([^']+)'/g).map(val => val.replace(/'/g, ""));
        res.json(enumValues);
    });
});

app.get("/get-remarks", (req, res) => {
    const query = "SHOW COLUMNS FROM payment LIKE 'Remarks'";

    db.query(query, (err, results) => {
        if (err) {
            console.error("Error fetching remarks:", err);
            return res.status(500).json({ error: "Database error" });
        }

        const enumValues = results[0].Type.match(/'([^']+)'/g).map(val => val.replace(/'/g, ""));
        res.json(enumValues);
    });
});

app.delete("/delete-payment/:paymentID", (req, res) => {
    const paymentID = req.params.paymentID;
    const query = "DELETE FROM payment WHERE PaymentID = ?";

    db.query(query, [paymentID], (err, result) => {
        if (err) {
            console.error("Error deleting payment:", err);
            return res.status(500).json({ error: "Database error" });
        }

        if (result.affectedRows > 0) {
            res.json({ success: true, message: "Payment deleted successfully" });
        } else {
            res.status(404).json({ error: "Payment not found" });
        }
    });
});
app.get("/allpayments", (req, res) => {
    const query = `
        SELECT 
            e.*,
            r.*,
            p.*, 
            per.FirstName AS OfficerFirstName, 
            per.LastName AS OfficerLastName
        FROM payment p
        LEFT JOIN officer o ON p.OfficerID = o.OfficerID
        LEFT JOIN person per ON o.PersonID = per.PersonID
        LEFT JOIN revenues r ON r.RevenueID = p.RevenueID
        LEFT JOIN eventtype e ON e.EventTypeID = r.EventTypeID
        ORDER BY p.PaymentID DESC;
    `;

    db.query(query, (error, results) => {
        if (error) {
            console.error("Error fetching payments:", error);
            return res.status(500).json({ error: "Internal server error" });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: "No payment records found" });
        }

        res.json(results);
    });
});



app.delete('/deleteRevenue/:revenueId', (req, res) => {
    const revenueId = req.params.revenueId;

    db.beginTransaction((err) => {
        if (err) {
            return res.status(500).json({ success: false, message: "Failed to start transaction." });
        }

        const deletePaymentQuery = 'DELETE FROM payment WHERE RevenueID = ?';
        db.query(deletePaymentQuery, [revenueId], (err, result) => {
            if (err) {
                return db.rollback(() => {
                    res.status(500).json({ success: false, message: "Failed to delete payments." });
                });
            }

            const deleteRevenueQuery = 'DELETE FROM revenues WHERE RevenueID = ?';
            db.query(deleteRevenueQuery, [revenueId], (err, result) => {
                if (err) {
                    return db.rollback(() => {
                        res.status(500).json({ success: false, message: "Failed to delete revenue." });
                    });
                }

                db.commit((err) => {
                    if (err) {
                        return db.rollback(() => {
                            res.status(500).json({ success: false, message: "Failed to commit transaction." });
                        });
                    }

                    res.json({ success: true, message: "Revenue and related payment records deleted successfully." });
                });
            });
        });
    });
});



// ---------------------- FOR REVENUES AND PAYMENTS -------------------------------





// ---------------------- FOR ATTENDANCES -------------------------------
app.get("/allattendances", (req, res) => {
    const sql = `
        SELECT a.AttendanceID, e.EventName, a.NumberOfMembers, a.date 
        FROM attendance a
        JOIN eventtype e ON a.EventTypeID = e.EventTypeID
        ORDER BY a.AttendanceID DESC
    `;
    db.query(sql, (err, results) => {
        if (err) {
            return res.status(500).json({ message: "Error fetching attendance data" });
        }
        res.json(results);
    });
});

app.post("/add_attendance", (req, res) => {
    const { EventTypeID, NumberOfMembers, date } = req.body;

    if (!EventTypeID || !NumberOfMembers || !date) {
        return res.status(400).json({ message: "All fields are required" });
    }

    const checkSql = `
        SELECT a.*, e.EventName 
        FROM attendance a
        JOIN eventtype e ON a.EventTypeID = e.EventTypeID
        WHERE a.EventTypeID = ? AND a.date = ?`;

    db.query(checkSql, [EventTypeID, date], (err, results) => {
        if (err) {
            return res.status(500).json({ message: "Error checking attendance record" });
        }
        if (results.length > 0) {
            return res.status(400).json({ message: `Attendance for '${results[0].EventName}' on ${date} already exists` });
        }

        const insertSql = "INSERT INTO attendance (EventTypeID, NumberOfMembers, date) VALUES (?, ?, ?)";
        db.query(insertSql, [EventTypeID, NumberOfMembers, date], (err, result) => {
            if (err) {
                return res.status(500).json({ message: "Error adding attendance" });
            }
            res.json({ message: "Attendance added successfully", AttendanceID: result.insertId });
        });
    });
});


app.delete("/delete_attendance/:id", (req, res) => {
    const { id } = req.params;

    const checkSql = "SELECT * FROM attendance WHERE AttendanceID = ?";
    db.query(checkSql, [id], (err, results) => {
        if (err) {
            return res.status(500).json({ message: "Error checking attendance record" });
        }
        if (results.length === 0) {
            return res.status(404).json({ message: "Attendance record not found" });
        }

        const deleteSql = "DELETE FROM attendance WHERE AttendanceID = ?";
        db.query(deleteSql, [id], (err, result) => {
            if (err) {
                return res.status(500).json({ message: "Error deleting attendance record" });
            }
            res.json({ message: "Attendance deleted successfully" });
        });
    });
});


// ---------------------- FOR ATTENDANCES -------------------------------




// ---------------------- FOR EVENTS -------------------------------


app.post('/updateEvent', (req, res) => {
    const { eventId, eventName, eventDate, incharge, amount, customer_incharge } = req.body;

    if (!eventId || !eventName || !eventDate || !incharge || amount === undefined) {
        return res.status(400).json({ message: "All fields are required" });
    }

    const sql = `
        UPDATE eventtype SET 
            EventName = ?, 
            event_date = ?, 
            incharge = ?, 
            customer_incharge = ?,
            amount_given = ? 
        WHERE EventTypeID = ?
    `;

    db.query(sql, [eventName, eventDate, incharge, customer_incharge, amount, eventId], (err, results) => {
        if (err) {
            return res.status(500).json({ message: "Error updating event", error: err.message });
        }

        if (results.affectedRows === 0) {
            return res.status(404).json({ message: "Event not found" });
        }

        res.json({ message: "Event updated successfully" });
    });
});



app.get("/allevents", (req, res) => {
    const sql = `
    SELECT
        r.EventTypeID,
        e.EventName,
        r.AmountGiven AS Amount,
        e.customer_incharge
    FROM
        revenues r
    LEFT JOIN
        eventtype e ON r.EventTypeID = e.EventTypeID
    ORDER BY
        e.event_date DESC,
        r.EventTypeID DESC
`;


    db.query(sql, (err, results) => {
        if (err) {
            console.error("SQL Error:", err);
            return res.status(500).json({ message: "Error fetching events", error: err.message });
        }
        res.json(results);
    });
});

app.get('/eventtype/:id', (req, res) => {
  const eventTypeID = req.params.id;
  db.query(
    'SELECT * FROM eventtype WHERE EventTypeID = ?',
    [eventTypeID],
    (err, results) => {
      if (err) return res.status(500).json({ error: 'Database error' });
      if (results.length > 0) {
        res.json({ amount_given: results[0].amount_given });
      } else {
        res.status(404).json({ error: 'Not found' });
      }
    }
  );
});


app.get("/getallevents", (req, res) => {
  const sql = `
    SELECT 
      e.EventTypeID,
      e.EventName,
      e.amount_given,
      e.incharge,
      e.customer_incharge,
      e.event_date,
      CONCAT(p.FirstName, ' ', p.LastName) AS InchargeName
    FROM 
      eventtype e
    LEFT JOIN 
      incharge i ON e.incharge = i.InchargeID
    LEFT JOIN 
      person p ON i.PersonID = p.PersonID
    ORDER BY e.EventTypeID DESC
  `;



  db.query(sql, (err, results) => {
    if (err) {
      console.error("Query Error:", err);
      return res.status(500).json({ error: "Internal server error" });
    }

    res.json(results);
  });
});




app.get("/getallavailableeventinexpenses", (req, res) => {
  const sql = `
    SELECT 
      e.EventTypeID,
      e.EventName,
      e.amount_given,
      e.incharge,
      e.event_date,
      CONCAT(p.FirstName, ' ', p.LastName) AS InchargeName
    FROM 
      eventtype e
    LEFT JOIN 
      incharge i ON e.incharge = i.InchargeID
    LEFT JOIN 
      person p ON i.PersonID = p.PersonID
    WHERE 
      NOT EXISTS (
        SELECT 1 FROM expenses r WHERE r.EventTypeID = e.EventTypeID
      )
    ORDER BY 
      e.EventTypeID DESC
  `;

  db.query(sql, (err, results) => {
    if (err) {
      console.error("Query Error:", err);
      return res.status(500).json({ error: "Internal server error" });
    }

    res.json(results);
  });
});





















app.get("/getallavailableeventinrevenue", (req, res) => {
  const sql = `
    SELECT 
      e.EventTypeID,
      e.EventName,
      e.amount_given,
      e.incharge,
      e.event_date,
      CONCAT(p.FirstName, ' ', p.LastName) AS InchargeName
    FROM 
      eventtype e
    LEFT JOIN 
      incharge i ON e.incharge = i.InchargeID
    LEFT JOIN 
      person p ON i.PersonID = p.PersonID
    WHERE 
      NOT EXISTS (
        SELECT 1 FROM revenues r WHERE r.EventTypeID = e.EventTypeID
      )
    ORDER BY 
      e.EventTypeID DESC
  `;

  db.query(sql, (err, results) => {
    if (err) {
      console.error("Query Error:", err);
      return res.status(500).json({ error: "Internal server error" });
    }

    res.json(results);
  });
});


app.get("/getalleventsinrevenue", (req, res) => {
  const sql = `
    SELECT 
      r.RevenueID,
      e.EventTypeID,
      e.EventName,
      e.amount_given,
      e.incharge,
      e.event_date,
      CONCAT(p.FirstName, ' ', p.LastName) AS InchargeName
    FROM 
      eventtype e
    LEFT JOIN 
      incharge i ON e.incharge = i.InchargeID
    LEFT JOIN 
      person p ON i.PersonID = p.PersonID
    LEFT JOIN
      revenues r ON r.EventTypeID = e.EventTypeID
    WHERE 
     EXISTS (
        SELECT 1 FROM revenues r WHERE r.EventTypeID = e.EventTypeID
      )
    ORDER BY 
      e.EventTypeID DESC
  `;



  db.query(sql, (err, results) => {
    if (err) {
      console.error("Query Error:", err);
      return res.status(500).json({ error: "Internal server error" });
    }

    res.json(results);
  });
});



app.post('/add_events', (req, res) => {
    const { event_date, event_name, incharge, customer_incharge, amount_given } = req.body;

    const query = `
        INSERT INTO eventtype (EventName, amount_given, incharge, customer_incharge, event_date)
        VALUES (?, ?, ?, ?, ?)
    `;

    db.query(query, [event_name, amount_given, incharge, customer_incharge, event_date], (err, results) => {
        if (err) {
            console.error('Insert error:', err);
            return res.status(500).json({ error: 'Database error' });
        }
        res.status(200).json({ message: 'Event inserted', id: results.insertId });
    });
});

app.delete("/delete_event/:id", (req, res) => {
    const eventTypeID = req.params.id;
    const getRevenueIDsQuery = "SELECT RevenueID FROM revenues WHERE EventTypeID = ?";

    db.query(getRevenueIDsQuery, [eventTypeID], (err, revenueResults) => {
        if (err) return res.status(500).json({ message: "Error retrieving related revenue IDs" });

        const revenueIDs = revenueResults.map(row => row.RevenueID);

        if (revenueIDs.length > 0) {
            const deletePaymentsQuery = "DELETE FROM payment WHERE RevenueID IN (?)";
            db.query(deletePaymentsQuery, [revenueIDs], (err) => {
                if (err) return res.status(500).json({ message: "Error deleting related payments" });

                const deleteRevenuesQuery = "DELETE FROM revenues WHERE EventTypeID = ?";
                db.query(deleteRevenuesQuery, [eventTypeID], (err) => {
                    if (err) return res.status(500).json({ message: "Error deleting related revenues" });

                    const deleteExpensesQuery = "DELETE FROM expenses WHERE EventTypeID = ?";
                    db.query(deleteExpensesQuery, [eventTypeID], (err) => {
                        if (err) return res.status(500).json({ message: "Error deleting related expenses" });

                        const deleteEventQuery = "DELETE FROM eventtype WHERE EventTypeID = ?";
                        db.query(deleteEventQuery, [eventTypeID], (err) => {
                            if (err) return res.status(500).json({ message: "Error deleting event" });
                            res.json({ message: "Event deleted successfully" });
                        });
                    });
                });
            });
        } else {
            const deleteExpensesQuery = "DELETE FROM expenses WHERE EventTypeID = ?";
            db.query(deleteExpensesQuery, [eventTypeID], (err) => {
                if (err) return res.status(500).json({ message: "Error deleting related expenses" });

                const deleteEventQuery = "DELETE FROM eventtype WHERE EventTypeID = ?";
                db.query(deleteEventQuery, [eventTypeID], (err) => {
                    if (err) return res.status(500).json({ message: "Error deleting event" });
                    res.json({ message: "Event deleted successfully" });
                });
            });
        }
    });
});

// ---------------------- FOR EVENTS -------------------------------


app.post("/login_process", (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).json({ error: "All fields are required." });
    }

    const sql = `
  SELECT login.*, person.*
  FROM login
  INNER JOIN person ON person.PersonID = login.OfficerID
  WHERE login.Username = ?
`;

    db.query(sql, [username], async (err, results) => {
        if (err) return res.status(500).json({ error: "Database error." });

        if (results.length === 0) {
            return res.status(401).json({ error: "Username or password is incorrect." });
        }

        const user = results[0];

        const match = await bcrypt.compare(password, user.Password);
        if (!match) {
            return res.status(401).json({ error: "Username or password is incorrect." });
        }

        const options = { 
  hour: '2-digit', 
  minute: '2-digit', 
  second: '2-digit',
  year: 'numeric',
  month: 'long',
  day: 'numeric',
  weekday: 'long',
  timeZone: 'Asia/Manila' 
};

const loginTime = new Intl.DateTimeFormat('en-PH', options).format(new Date());

        const insertHistory = "INSERT INTO login_history (LoginID, login_time) VALUES (?, ?)";
        db.query(insertHistory, [user.LoginID, loginTime], (err) => {
            if (err) console.error("Failed to insert login history:", err);
        });

        res.json({
            success: true,
            officerID: user.OfficerID,
            username: user.Username,
            fname: user.FirstName,
            lname: user.LastName,
            Status: user.Status,

        });
    });
});


app.get('/login-history', (req, res) => {
  const sql = `
    SELECT 
      lh.id,
      CONCAT(p.FirstName, ' ', p.LastName) AS fullname,
      o.RoleDescription AS position,
      lh.login_time
    FROM login_history lh
    JOIN login l ON lh.LoginID = l.LoginID
    JOIN officer o ON l.OfficerID = o.OfficerID
    JOIN person p ON o.PersonID = p.PersonID
    ORDER BY lh.id DESC
  `;

  db.query(sql, (err, results) => {
    if (err) {
      console.error('Error fetching login history:', err);
      return res.status(500).send('Server error');
    }
    res.json(results);
  });
});


app.delete('/login-history/:id', (req, res) => {
  const id = req.params.id;
  const sql = 'DELETE FROM login_history WHERE id = ?';

  db.query(sql, [id], (err, result) => {
    if (err) {
      console.error('Error deleting login history:', err);
      return res.status(500).send('Server error');
    }

    if (result.affectedRows === 0) {
      return res.status(404).send('No record found with that ID');
    }

    res.send({ message: 'Deleted successfully', id });
  });
});



app.post("/process_register", async (req, res) => {
    const { firstName, lastName, contactNumber, position, userName, password } = req.body;

    if (!firstName || !lastName || !contactNumber || !position || !userName || !password) {
        return res.status(400).json({ error: "All fields are required." });
    }

    try {
        db.query("SELECT Username FROM login WHERE Username = ?", [userName], async (err, results) => {
            if (err) return res.status(500).json({ error: "Database error." });

            if (results.length > 0) {  
                return res.status(200).json({ success: "Username already exists!" });
            }

            const hashedPassword = await bcrypt.hash(password, 10);

            db.beginTransaction((err) => {
                if (err) return res.status(500).json({ error: "Transaction error." });

                db.query("INSERT INTO person (FirstName, LastName, ContactNumber) VALUES (?, ?, ?)", 
                [firstName, lastName, contactNumber], (err, result) => {
                    if (err) {
                        db.rollback(() => {
                            return res.status(500).json({ error: "Error inserting into person table." });
                        });
                    }
                    
                    const personId = result.insertId;

                    db.query("INSERT INTO officer (PersonID, RoleDescription) VALUES (?, ?)", 
                    [personId, position], (err, result) => {
                        if (err) {
                            db.rollback(() => {
                                return res.status(500).json({ error: "Error inserting into officer table." });
                            });
                        }
                        
                        const officerId = result.insertId;

                        db.query("INSERT INTO login (LoginID, OfficerID, Username, Password) VALUES (?, ?, ?, ?)", 
                        [officerId, officerId, userName, hashedPassword], (err) => {
                            if (err) {
                                db.rollback(() => {
                                    return res.status(500).json({ error: "Error inserting into login table." });
                                });
                            }

                            db.query("INSERT INTO incharge (InchargeID, PersonID) VALUES (?, ?)", [personId, personId], (err) => {
                                if (err) {
                                    db.rollback(() => {
                                        return res.status(500).json({ error: "Error inserting into incharge table." });
                                    });
                                }

                                db.query("INSERT INTO recordkeeper (KeeperID, PersonID, OfficerID) VALUES (?, ?, ?)", [personId, personId, officerId], (err) => {
                                    if (err) {
                                        db.rollback(() => {
                                            return res.status(500).json({ error: "Error inserting into recordkeeper table." });
                                        });
                                    }

                                    db.commit((err) => {
                                        if (err) {
                                            db.rollback(() => {
                                                return res.status(500).json({ error: "Commit error." });
                                            });
                                        }

                                        res.status(200).json({ success: "New Member Added Successfully!" });
                                    });
                                });
                            });
                        });
                    });
                });
            });
        });

    } catch (error) {
        res.status(500).json({ error: "Server error." });
    }
});


app.post("/update_member", async (req, res) => {
    const { personID, firstName, lastName, contactNumber, position, userName, password, NewStatus } = req.body;

    if (!personID || !firstName || !lastName || !contactNumber || !position || !userName) {
        return res.status(400).json({ error: "All fields except password are required." });
    }

    try {
        // Check if username exists (excluding current user's username)
        db.query("SELECT Username FROM login WHERE Username = ? AND OfficerID != (SELECT OfficerID FROM officer WHERE PersonID = ?)", 
        [userName, personID], async (err, results) => {
            if (err) return res.status(500).json({ error: "Database error." });

            if (results.length > 0) {
                return res.status(200).json({ success: "Username already exists!" });
            }

            let hashedPassword = null;
            if (password && password.trim() !== "") {
                hashedPassword = await bcrypt.hash(password, 10);
            }

            db.beginTransaction((err) => {
                if (err) return res.status(500).json({ error: "Transaction error." });

                // Update person table
                db.query("UPDATE person SET FirstName = ?, LastName = ?, ContactNumber = ? WHERE PersonID = ?", 
                [firstName, lastName, contactNumber, personID], (err) => {
                    if (err) {
                        db.rollback(() => res.status(500).json({ error: "Error updating person." }));
                        return;
                    }

                    // Update officer table
                    db.query("UPDATE officer SET RoleDescription = ? WHERE PersonID = ?", 
                    [position, personID], (err) => {
                        if (err) {
                            db.rollback(() => res.status(500).json({ error: "Error updating officer." }));
                            return;
                        }

                        // Update login table (with or without password)
                        let loginQuery, loginParams;
                        if (hashedPassword) {
                            loginQuery = "UPDATE login SET Username = ?, Password = ?, Status = ? WHERE OfficerID = (SELECT OfficerID FROM officer WHERE PersonID = ?)";
                            loginParams = [userName, hashedPassword, NewStatus, personID];
                        } else {
                            loginQuery = "UPDATE login SET Username = ?, Status = ? WHERE OfficerID = (SELECT OfficerID FROM officer WHERE PersonID = ?)";
                            loginParams = [userName, NewStatus, personID];
                        }

                        db.query(loginQuery, loginParams, (err) => {
                            if (err) {
                                db.rollback(() => res.status(500).json({ error: "Error updating login." }));
                                return;
                            }

                            db.commit((err) => {
                                if (err) {
                                    db.rollback(() => res.status(500).json({ error: "Commit error." }));
                                    return;
                                }

                                res.status(200).json({ success: "Member updated successfully!" });
                            });
                        });
                    });
                });
            });
        });

    } catch (error) {
        res.status(500).json({ error: "Server error." });
    }
});




// app.post("/change_pass", async (req, res) => {
//     const { username, newPassword } = req.body;

//     if (!username || !newPassword) {
//         return res.status(400).json({ success: false, message: "Username and new password are required." });
//     }

//     try {
//         // Hash the new password with bcrypt
//         const hashedPassword = await bcrypt.hash(newPassword, 10);

//         const sql = "UPDATE login SET password = ? WHERE username = ?";
//         db.query(sql, [hashedPassword, username], (err, result) => {
//             if (err) {
//                 console.error("Database error:", err);
//                 return res.status(500).json({ success: false, message: "Database error." });
//             }

//             if (result.affectedRows === 0) {
//                 return res.status(404).json({ success: false, message: "Username not found." });
//             }

//             return res.json({ success: true, message: "Password updated successfully." });
//         });
//     } catch (error) {
//         console.error("Error hashing password:", error);
//         res.status(500).json({ success: false, message: "Server error." });
//     }
// });

app.get("/total_balance", (req, res) => {
    
  const sql = `
  SELECT
    (
      (SELECT SUM(BandShare) FROM revenues) -
      (SELECT SUM(AmountGiven) FROM expenses)
    ) AS Balance;
`;


    db.query(sql, (err, results) => {
        if (err) {
            console.error("Database error:", err);
            return res.status(500).json({ success: false, message: "Database error" });
        }

        // Calculate total balance
        let totalBalance = 0;
        results.forEach(row => {
            totalBalance += parseFloat(row.Balance || 0); // handle NULL as 0
        });

        res.json({ success: true, totalBalance, rows: results });
    });
});













app.get("/get-officers", (req, res) => {
    const query = "SELECT PersonID, FirstName, LastName FROM person";

    db.query(query, (err, results) => {
        if (err) {
            console.error("Error fetching officers:", err);
            return res.status(500).json({ error: "Database error" });
        }
        res.json(results);
    });
});

app.listen(3000, () => console.log("Server is running on port 3000"));


// ---------------------- SUMMARY -------------------------------
app.get("/summary/revenues/:month", (req, res) => {
    const selectedMonth = req.params.month; // Format: YYYY-MM

   const query = `
    SELECT 
        r.RevenueID, 
        r.*, 
        e.EventName, 
        r.Description, 
        r.AmountGiven, 
        r.BandShare, 
        r.MembersTalentFee, 
        a.NumberOfMembers, 
        (a.NumberOfMembers * r.MembersTalentFee) AS TotalFee, -- Calculate TotalFee
        p_keeper.FirstName AS KeeperFirstName,
        p_keeper.LastName AS KeeperLastName
    FROM revenues r
    LEFT JOIN eventtype e ON r.EventTypeID = e.EventTypeID
    LEFT JOIN attendance a ON r.EventTypeID = a.EventTypeID AND DATE(e.event_date) = DATE(a.date)
    LEFT JOIN recordkeeper rk ON r.KeeperID = rk.KeeperID
    LEFT JOIN person p_keeper ON rk.PersonID = p_keeper.PersonID
    WHERE DATE_FORMAT(e.event_date, '%Y-%m') = ?`;


    db.query(query, [selectedMonth], (err, results) => {
        if (err) {
            console.error("Error fetching revenues:", err);
            return res.status(500).json({ error: "Database error" });
        }
        res.json(results);
    });
});

app.get("/summary/expenses/:month", (req, res) => {
    const selectedMonth = req.params.month; // Format: YYYY-MM

    const query = `
        SELECT e.ExpenseID, e.DateUsed, e.Description, e.Amount, ev.EventName, ev.event_date, ev.customer_incharge
        FROM expenses e
        LEFT JOIN eventtype ev ON e.EventTypeID = ev.EventTypeID
        WHERE DATE_FORMAT(e.DateUsed, '%Y-%m') = ?`;

    db.query(query, [selectedMonth], (err, results) => {
        if (err) {
            console.error("Error fetching expenses:", err);
            return res.status(500).json({ error: "Database error" });
        }
        res.json(results);
    });
});


// ---------------------- SUMMARY -------------------------------

// ---------------------- MEMBERS -------------------------------
// --- MEMBERS ---
app.get("/allmembers", (req, res) => {
    const sql = "SELECT * FROM members ORDER BY name ASC";
    db.query(sql, (err, results) => {
        if (err) {
            return res.json({ status: "error", message: err.message });
        }
        res.json(results);
    });
});

app.post("/addmember", (req, res) => {
    const { name, role, status, description } = req.body;

    if (!name || !role || !status) {
        return res.status(400).json({ success: false, message: "Name, role, and status are required." });
    }

    const query = "INSERT INTO members (name, role, status, description) VALUES (?, ?, ?, ?)";
    
    db.query(query, [name, role, status, description], (err, result) => {
        if (err) {
            console.error("Error adding member:", err);
            return res.status(500).json({ success: false, message: "Error adding member." });
        }
        res.json({ success: true, message: "Member added successfully!" });
    });
});

app.post("/updatemember/:id", (req, res) => {
    const memberId = req.params.id;
    const { name, role, status, description } = req.body;

    if (!memberId || !name || !role || !status) {
        return res.status(400).json({ success: false, message: "Member ID, name, role, and status are required." });
    }

    const query = "UPDATE members SET name = ?, role = ?, status = ?, description = ? WHERE member_id = ?";
    
    db.query(query, [name, role, status, description, memberId], (err, result) => {
        if (err) {
            console.error("Error updating member:", err);
            return res.status(500).json({ success: false, message: "Error updating member." });
        }
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: "Member not found." });
        }
        
        res.json({ success: true, message: "Member updated successfully!" });
    });
});

app.post("/verify-password", (req, res) => {
    const { password, userId } = req.body;

    if (!password || !userId) {  // Changed from `userId` to `!userId`
        return res.status(400).json({ success: false, error: "Password and user ID are required" });
    }

    const query = "SELECT password FROM users WHERE user_id = ?";
    
    db.query(query, [userId], (err, results) => {
        if (err) {
            console.error("Database error:", err);
            return res.status(500).json({ success: false, error: "Server error" });
        }

        if (results.length === 0) {
            return res.status(404).json({ success: false, error: "User not found" });
        }

        const hashedPassword = results[0].password;

        // Compare passwords (use bcrypt.compare if passwords are hashed)
        if (password === hashedPassword) { // Replace with bcrypt.compare if using hashed passwords
            return res.json({ success: true });
        } else {
            return res.json({ success: false, error: "Incorrect password" });
        }
    });
});

app.delete("/deleteMember/:member_id", (req, res) => {
    const member_id = req.params.member_id;

    if (!member_id) {
        return res.status(400).json({ success: false, message: "Member ID is required." });
    }

    const query = "DELETE FROM members WHERE member_id = ?";

    db.query(query, [member_id], (err, result) => {
        if (err) {
            console.error("Error deleting member:", err);
            return res.status(500).json({ success: false, message: "Error deleting member." });
        }

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: "Member not found." });
        }

        res.json({ success: true, message: "Member deleted successfully." });
    });
});
// --- END MEMBERS ---