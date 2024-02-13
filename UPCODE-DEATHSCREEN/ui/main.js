$(function () {
    // Actualizar el progreso y el tiempo antes de que se abra la UI
    updateProgress(100);  // Establecer el progreso inicial (0%)
    updateUITime(0, 0); // Establecer el tiempo inicial (0:00)

    window.addEventListener('message', (event) => {
        var item = event.data;
        if (item.status == true) {
            $(".normal").show();
            updateProgress(item.progress);
            updateUITime(item.time, item.time2);
            $("#reason").text(item.reason);
        } else {
            $(".normal").hide();
        }
    });

    document.addEventListener("keydown", function (event) {
        if (event.key === "x") {
            $.post(`https://${GetParentResourceName()}/press`, JSON.stringify({ action: 'call' }));
        } else if (event.key === "y") {
            $.post(`https://${GetParentResourceName()}/press`, JSON.stringify({ action: 'surrender' }));
        }
    });

    function updateProgress(percent) {
        const circle = document.getElementById("progress-circle");
        const circumference = 2 * Math.PI * circle.getAttribute("r");
        const offset = circumference + (percent / 100) * circumference;

        circle.style.transition = "stroke-dashoffset 0.5s ease";
        
        circle.style.strokeDasharray = `${circumference} ${circumference}`;
        circle.style.strokeDashoffset = offset;
    }

    function updateUITime(minutes, seconds) {
        const formattedMinutes = String(minutes).padStart(2, "0");
        const formattedSeconds = String(seconds).padStart(2, "0");

        document.querySelector(".div").textContent = `${formattedMinutes}:${formattedSeconds}`;
    }
});
