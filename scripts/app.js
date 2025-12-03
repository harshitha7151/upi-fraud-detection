//-------------------------------------------------------
// GET CURRENT USER
//-------------------------------------------------------
function getUser() {
    return JSON.parse(localStorage.getItem("tf_current_user") || "null");
}

//-------------------------------------------------------
// APPLY 2-LETTER INITIALS + AVATAR GLOW
//-------------------------------------------------------
function applyUserInitials() {
    const avatar = document.getElementById("avatarCircle");
    const nameEl = document.getElementById("displayUserName");
    const mailEl = document.getElementById("displayUserMail");

    const user = getUser();
    if (!avatar || !user) return;

    const name = user.name.trim();

    // TWO-LETTER INITIALS LOGIC
    const initials = name
        .split(" ")
        .map(w => w.charAt(0).toUpperCase())
        .slice(0, 2)
        .join("");

    avatar.textContent = initials;

    // Show in home/pay page
    if (nameEl) nameEl.textContent = user.name;
    if (mailEl) mailEl.textContent = user.account + "@upi";
}

//-------------------------------------------------------
// LOCATION + FRAUD LOGIC
//-------------------------------------------------------
let realCountry = "Unknown";
let effectiveCountry = "Unknown";

const GEO_API = "https://ipapi.co/json/";

// Detect real IP location
async function detectCountry() {
    try {
        const res = await fetch(GEO_API);
        const data = await res.json();
        realCountry = data.country_name || "Unknown";
    } catch (e) {
        realCountry = "Unknown";
    }
    updateCountryUI();
}

function updateCountryUI() {
    const el = document.getElementById("detectedCountry");
    const vpn = document.getElementById("simulateVpn");

    if (!el) return;

    // If VPN toggle ON → force foreign country
    effectiveCountry = vpn?.checked ? "United States" : realCountry;

    el.textContent = effectiveCountry;
}

//-------------------------------------------------------
// PAYMENT SIMULATION
//-------------------------------------------------------
function simulatePayment(e) {
    e.preventDefault();

    const sender = senderUpi.value.trim();
    const receiver = receiverUpi.value.trim();
    const amt = Number(amount.value.trim());

    if (!sender || !receiver || amt <= 0) {
        alert("Please fill all fields correctly.");
        return;
    }

    updateCountryUI();

    // Show processing
    processingSection.classList.remove("hidden");
    resultSection.classList.add("hidden");

    // Delay for animation (fake processing)
    setTimeout(() => {

        let status = "success";
        let reason = "";

        // FRAUD LOGIC
        if (effectiveCountry !== "India") {
            status = "fraud";
            reason = "Foreign IP / VPN Detected";
        }

        // Hide processing, show result
        processingSection.classList.add("hidden");
        resultSection.classList.remove("hidden");

        const ts = new Date().getTime(); // used to reload GIF

        if (status === "success") {
            resultIcon.src = "../assets/icons/success.gif?" + ts;
            resultTitle.textContent = "TRANSACTION SUCCESSFUL";
            resultMessage.textContent = `₹${amt} sent to ${receiver}`;
            fraudReason.textContent = `Country: ${effectiveCountry}`;
        } else {
            resultIcon.src = "../assets/icons/failure.gif?" + ts;
            resultTitle.textContent = "FRAUD DETECTED";
            resultMessage.textContent = "Transaction blocked.";
            fraudReason.textContent = `Reason: ${reason}`;
            alert("Foreign IP detected — transaction blocked.");
        }

        //----------------------------------------------------
        // SAVE TRANSACTION HISTORY
        //----------------------------------------------------
        const history = JSON.parse(localStorage.getItem("tf_history") || "[]");

        history.push({
            sender,
            receiver,
            amount: amt,
            country: effectiveCountry,
            status,
            reason,
            time: new Date().toISOString()
        });

        localStorage.setItem("tf_history", JSON.stringify(history));

    }, 1500);
}

//-------------------------------------------------------
// RENDER HISTORY PAGE
//-------------------------------------------------------
function renderHistory() {
    const list = document.getElementById("historyList");
    const empty = document.getElementById("noHistoryMsg");

    if (!list) return;

    const history = JSON.parse(localStorage.getItem("tf_history") || "[]").reverse();

    if (history.length === 0) {
        empty.classList.remove("hidden");
        return;
    }

    empty.classList.add("hidden");
    list.innerHTML = "";

    history.forEach(txn => {
        const li = document.createElement("li");
        li.className = "txn-item";

        const icon = document.createElement("img");
        icon.className = "txn-icon";

        icon.src = txn.status === "success" 
            ? "../assets/icons/success.gif"
            : "../assets/icons/failure.gif";

        const main = document.createElement("div");
        main.className = "txn-main";

        const amt = document.createElement("p");
        amt.className = "txn-amount";
        amt.textContent = `₹${txn.amount} → ${txn.receiver}`;

        const meta = document.createElement("p");
        meta.className = "txn-meta";
        meta.textContent = `${new Date(txn.time).toLocaleString()} | ${txn.country}`;

        const status = document.createElement("p");
        status.className = txn.status === "success"
            ? "txn-status-success"
            : "txn-status-fraud";
        status.textContent = txn.status.toUpperCase();

        main.appendChild(amt);
        main.appendChild(meta);

        li.appendChild(icon);
        li.appendChild(main);
        li.appendChild(status);

        list.appendChild(li);
    });
}

//-------------------------------------------------------
// INIT ON PAGE LOAD
//-------------------------------------------------------
document.addEventListener("DOMContentLoaded", () => {

    applyUserInitials();
    detectCountry();

    // If on Pay page
    if (document.getElementById("payForm")) {
        payForm.addEventListener("submit", simulatePayment);
    }

    // If on History page
    if (document.getElementById("historyList")) {
        renderHistory();
    }

    // VPN toggle
    const vpn = document.getElementById("simulateVpn");
    if (vpn) vpn.addEventListener("change", updateCountryUI);
});
