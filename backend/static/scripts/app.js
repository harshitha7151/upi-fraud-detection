document.addEventListener("DOMContentLoaded", () => {

    // ---------------------------
    // PAY PAGE LOGIC
    // ---------------------------
    const payForm = document.getElementById("payForm");

    if (payForm) {
        payForm.addEventListener("submit", function (e) {
            e.preventDefault();

            // SIMPLE PAYLOAD
            const payload = {
                sender: document.getElementById("senderUpi").value,
                receiver: document.getElementById("receiverUpi").value,
                amount: Number(document.getElementById("amount").value),
                country: "India",              // FIXED
                vpn: document.getElementById("simulateVpn").checked,
                velocity: 1,
                hour: new Date().getHours(),
                shared_device: false,
                shared_ip: false
            };

            console.log("SENDING:", payload); // DEBUG

            fetch("http://127.0.0.1:5000/predict", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            })
            .then(res => res.json())
            .then(data => {
                document.getElementById("resultSection").classList.remove("hidden");
                document.getElementById("resultTitle").textContent = data.decision;
                document.getElementById("fraudReason").textContent = data.reason;
            })
            .catch(err => {
                console.error("FETCH ERROR:", err);
                alert("Backend not reachable");
            });
        });
    }

    // ---------------------------
    // HISTORY PAGE LOGIC
    // ---------------------------
    const historyList = document.getElementById("historyList");
    const noHistory = document.getElementById("noHistoryMsg");

    if (historyList) {
        fetch("http://127.0.0.1:5000/history")
            .then(res => res.json())
            .then(data => {
                if (data.length === 0) {
                    noHistory.classList.remove("hidden");
                    return;
                }

                noHistory.classList.add("hidden");

                data.forEach(txn => {
                    const li = document.createElement("li");
                    li.className = "txn-item";
                    li.innerHTML = `
                        <p><b>₹${txn.amount}</b> → ${txn.receiver}</p>
                        <small>${txn.time} | ${txn.decision}</small>
                    `;
                    historyList.appendChild(li);
                });
            })
            .catch(err => console.error(err));
    }

});


