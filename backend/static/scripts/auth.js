document.addEventListener("DOMContentLoaded", () => {

    const payForm = document.getElementById("payForm");

    // -------------------------------
    // PAY PAGE
    // -------------------------------
    if (payForm) {
        payForm.addEventListener("submit", e => {
            e.preventDefault();

            fetch("http://127.0.0.1:5000/predict", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    sender: senderUpi.value,
                    receiver: receiverUpi.value,
                    amount: Number(amount.value),
                    country: "India",
                    vpn: simulateVpn.checked,
                    velocity: 2,
                    hour: new Date().getHours(),
                    shared_device: false,
                    shared_ip: false
                })
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

    // -------------------------------
    // HISTORY PAGE
    // -------------------------------
    const historyList = document.getElementById("historyList");
    if (historyList) {
        fetch("http://127.0.0.1:5000/history")
            .then(res => res.json())
            .then(data => {
                if (data.length === 0) {
                    document.getElementById("noHistoryMsg").classList.remove("hidden");
                    return;
                }

                document.getElementById("noHistoryMsg").classList.add("hidden");

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

