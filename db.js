const mysql = require("mysql");

const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "cirva_database",
});

db.connect((err) => {
  if (err) {
    console.error("Database connection failed: " + err.stack);
    return;
  }
  console.log("Connected to MySQL database.");
});

module.exports = db;


// Redirect to dashboard if already logged in
    // if (localStorage.getItem("user")) {
    //     window.location.href = "dashboard.html";
    // }

    //      $("#logoutButton").on("click", function () {
    //     localStorage.removeItem("user");
    //     window.location.href = "login.html";
    // });