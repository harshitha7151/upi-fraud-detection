document.addEventListener("DOMContentLoaded", () => {

    /* ===============================
       PAY PAGE LOGIC
    =============================== */

    const payForm = document.getElementById("payForm");

    if (payForm) {

        const loadingSection = document.getElementById("loadingSection");
        const resultSection = document.getElementById("resultSection");
        const resultTitle = document.getElementById("resultTitle");
        const fraudReason = document.getElementById("fraudReason");
        const resultVideo = document.getElementById("resultVideo");

        payForm.addEventListener("submit", function (e) {
            e.preventDefault();

            // Reset UI
            resultSection.classList.add("hidden");
            loadingSection.classList.remove("hidden");

            const amountValue = Number(document.getElementById("amount").value);
            const vpnFlag = document.getElementById("simulateVpn").checked ? 1 : 0;

            // ✅ REALISTIC, DYNAMIC PAYLOAD
            const payload = {
                Amount: amountValue,
                hour: new Date().getHours(),

                velocity: amountValue > 7000 ? 5 : amountValue > 3000 ? 3 : 1,
                shared_device: amountValue > 4000 ? 1 : 0,
                shared_ip: 0,
                vpn: vpnFlag,

                // Temporal sequence for LSTM
                sequence: [
                    Math.random() * 20,
                    Math.random() * 20,
                    Math.random() * 20,
                    Math.random() * 20,
                    amountValue
                ]
            };

            console.log("SENDING:", payload);

            fetch("/predict", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify(payload)
            })
            .then(res => res.json())
            .then(data => {

                // Hide loading
                loadingSection.classList.add("hidden");

                // Show result
                resultSection.classList.remove("hidden");

                resultTitle.textContent = data.decision;
                fraudReason.textContent = "Risk Score: " + data.final_score;

                // Video based on decision
                if (data.decision === "Allow") {
                    resultVideo.src = "/static/assets/success.mp4";
                } else {
                    resultVideo.src = "/static/assets/failure.mp4";
                }

                resultVideo.currentTime = 0;
                resultVideo.play();
            })
            .catch(err => {
                console.error("FETCH ERROR:", err);
                loadingSection.classList.add("hidden");
                alert("Backend not reachable. Is Flask running?");
            });
        });
    }

    /* ===============================
       HISTORY PAGE LOGIC
    =============================== */

    const historyList = document.getElementById("historyList");
    const noHistoryMsg = document.getElementById("noHistoryMsg");

    if (historyList) {
        fetch("/history")
            .then(res => res.json())
            .then(data => {

                if (data.length === 0) {
                    noHistoryMsg.classList.remove("hidden");
                    return;
                }

                noHistoryMsg.classList.add("hidden");

                data.forEach(txn => {
                    const li = document.createElement("li");
                    li.className = "txn-item";

                    li.innerHTML = `
                        <div class="txn-main">
                            <p class="txn-amount">₹${txn.amount}</p>
                            <p class="txn-meta">${txn.time}</p>
                        </div>
                        <div class="${
                            txn.decision === "Allow"
                                ? "txn-status-success"
                                : "txn-status-fraud"
                        }">
                            ${txn.decision}
                        </div>
                    `;

                    historyList.appendChild(li);
                });
            })
            .catch(err => console.error("History fetch error:", err));
    }

});
