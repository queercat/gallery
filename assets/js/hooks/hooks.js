let Hooks = {};

Hooks.DragDrop = {
  mounted() {
    let dropArea = document.getElementById(this.el.id);

    [("dragenter", "dragover", "dragleave", "drop")].forEach((eventName) => {
      dropArea.addEventListener(
        eventName,
        (e) => {
          e.preventDefault();
          console.log(e);
        },
        false,
      );
    });

    ["dragenter", "dragover"].forEach((eventName) => {
      dropArea.addEventListener(eventName, highlight, false);
    });

    ["dragleave", "drop"].forEach((eventName) => {
      dropArea.addEventListener(eventName, unhighlight, false);
    });

    function highlight(e) {
      dropArea.classList.add("bg-sky-600");
    }

    function unhighlight(e) {
      dropArea.classList.remove("bg-sky-600");
    }

    window.addEventListener("paste", (e) => {
      const files = e.clipboardData.files;
      const input = document.querySelector("input[type=file]");

      if (!files || files.length == 0 || !input) return;

      input.files = files;

      const event = document.createEvent("HTMLEvents");
      event.initEvent("input", true, true);
      input.dispatchEvent(event);
    });
  },
};

export default Hooks;
