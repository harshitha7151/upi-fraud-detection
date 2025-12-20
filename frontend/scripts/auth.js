//-------------------------------------------------------
// USER STORAGE HELPERS
//-------------------------------------------------------
function getUsers() {
    return JSON.parse(localStorage.getItem("tf_users") || "[]");
}

function saveUsers(users) {
    localStorage.setItem("tf_users", JSON.stringify(users));
}

//-------------------------------------------------------
// ON PAGE LOAD
//-------------------------------------------------------
document.addEventListener("DOMContentLoaded", () => {

    const registerForm = document.getElementById("registerForm");
    const loginForm = document.getElementById("loginForm");

    //---------------------------------------------------
    // REGISTER FORM SUBMISSION
    //---------------------------------------------------
    if (registerForm) {
        registerForm.addEventListener("submit", e => {
            e.preventDefault();

            const name = regName.value.trim();
            const account = regAccount.value.trim();
            const pin = regPin.value.trim();

            if (!name || !account || !pin) {
                alert("Please fill all fields.");
                return;
            }

            const users = getUsers();

            // OPTIONAL: Check duplicate account
            if (users.some(u => u.account === account)) {
                alert("Account number already exists.");
                return;
            }

            // SAVE NEW USER
            users.push({ name, account, pin });
            saveUsers(users);

            alert("Demo account created successfully!");
            location.href = "login.html";
        });
    }

    //---------------------------------------------------
    // LOGIN FORM SUBMISSION
    //---------------------------------------------------
    if (loginForm) {
        loginForm.addEventListener("submit", e => {
            e.preventDefault();

            const account = loginAccount.value.trim();
            const pin = loginPin.value.trim();

            const users = getUsers();
            const found = users.find(
                u => u.account === account && u.pin === pin
            );

            if (!found) {
                alert("Invalid fake credentials!");
                return;
            }

            // SAVE CURRENT USER
            localStorage.setItem("tf_current_user", JSON.stringify(found));

            location.href = "index.html";
        });
    }

});
